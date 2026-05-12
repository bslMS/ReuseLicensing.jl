# SPDX-FileCopyrightText: 2026 Guido Wolf Reichert <gwr@bsl-support.de>
# SPDX-License-Identifier: EUPL-1.2+

# License text files are stored under the base identifier, without trailing `+`.
base_license_identifier(id::String) = endswith(id, "+") ? String(chop(id)) : id

# Operator precedence used when re-rendering SPDX expressions.
precedence(::SPDXLicenseId) = 4
precedence(::SPDXLicenseRef) = 4
precedence(::SPDXWithExceptionExpression) = 3
precedence(::SPDXConjunctiveExpression) = 2
precedence(::SPDXDisjunctiveExpression) = 1

# Merge the identifier sets collected from two child expressions.
function merge_identifier_sets(
        left::Tuple{Set{String}, Set{String}, Set{String}},
        right::Tuple{Set{String}, Set{String}, Set{String}}
)
    licenses = union(left[1], right[1])
    exceptions = union(left[2], right[2])
    licenserefs = union(left[3], right[3])
    return licenses, exceptions, licenserefs
end

# Render a simple SPDX license identifier and collect its bundled-text lookup id.
function _render_and_collect_spdx(expr::SPDXLicenseId)
    licenses = Set{String}([base_license_identifier(expr.identifier)])
    return expr.identifier, licenses, Set{String}(), Set{String}()
end

# Render a `LicenseRef-...` expression and collect its lowercase payload for lookup.
function _render_and_collect_spdx(expr::SPDXLicenseRef)
    licenserefs = Set{String}([lowercase(expr.identifier)])
    return "LicenseRef-" * expr.identifier, Set{String}(), Set{String}(), licenserefs
end

# Render an SPDX `WITH` expression and collect both license and exception ids.
function _render_and_collect_spdx(expr::SPDXWithExceptionExpression)
    license_rendered, licenses, exceptions, licenserefs = render_and_collect_spdx(
        expr.license, precedence(expr))
    push!(exceptions, expr.exception.identifier)
    rendered = license_rendered * " WITH " * expr.exception.identifier
    return rendered, licenses, exceptions, licenserefs
end

# Render an SPDX `AND` expression and merge identifier sets from both operands.
function _render_and_collect_spdx(expr::SPDXConjunctiveExpression)
    left_rendered, left_licenses, left_exceptions, left_licenserefs = render_and_collect_spdx(
        expr.left, precedence(expr))
    right_rendered, right_licenses, right_exceptions, right_licenserefs = render_and_collect_spdx(
        expr.right, precedence(expr))
    licenses, exceptions, licenserefs = merge_identifier_sets(
        (left_licenses, left_exceptions, left_licenserefs),
        (right_licenses, right_exceptions, right_licenserefs)
    )
    rendered = left_rendered * " AND " * right_rendered
    return rendered, licenses, exceptions, licenserefs
end

# Render an SPDX `OR` expression and merge identifier sets from both operands.
function _render_and_collect_spdx(expr::SPDXDisjunctiveExpression)
    left_rendered, left_licenses, left_exceptions, left_licenserefs = render_and_collect_spdx(
        expr.left, precedence(expr))
    right_rendered, right_licenses, right_exceptions, right_licenserefs = render_and_collect_spdx(
        expr.right, precedence(expr))
    licenses, exceptions, licenserefs = merge_identifier_sets(
        (left_licenses, left_exceptions, left_licenserefs),
        (right_licenses, right_exceptions, right_licenserefs)
    )
    rendered = left_rendered * " OR " * right_rendered
    return rendered, licenses, exceptions, licenserefs
end

# Render an SPDX expression and collect the referenced identifiers.
function render_and_collect_spdx(
        expr::AbstractSPDXLicenseExpression,
        parent_precedence::Int = 0
)
    rendered, licenses, exceptions, licenserefs = _render_and_collect_spdx(expr)
    if precedence(expr) < parent_precedence
        rendered = "(" * rendered * ")"
    end
    return rendered, licenses, exceptions, licenserefs
end

# Render an SPDX AST back to its normalized string form.
function render_spdx_expression(expr::AbstractSPDXLicenseExpression)
    first(render_and_collect_spdx(expr))
end
