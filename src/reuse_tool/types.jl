# SPDX-FileCopyrightText: 2026 Guido Wolf Reichert <gwr@bsl-support.de>
# SPDX-License-Identifier: EUPL-1.2+

struct ReuseLintLinesResult
    status::Int
    stdout::String
    stderr::String
end

struct ReuseLintJsonResult
    status::Int
    stdout::String
    stderr::String
end
