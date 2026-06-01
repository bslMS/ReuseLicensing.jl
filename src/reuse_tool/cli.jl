# SPDX-FileCopyrightText: 2026 Guido Wolf Reichert <gwr@bsl-support.de>
# SPDX-License-Identifier: EUPL-1.2+

has_reuse() = Sys.which("reuse") !== nothing

# Return path to executable or throw an ArgumentError.
function reuse_executable()
    exe = Sys.which("reuse")
    exe === nothing && throw(ArgumentError(
        "Could not find `reuse` on PATH. Install the REUSE tool or make it " *
        "available on the PATH."
    ))
    return exe
end

function run_command(cmd::Cmd)
    stdout = Pipe()
    stderr = Pipe()
    proc = run(pipeline(ignorestatus(cmd); stdout, stderr), wait = false)

    close(stdout.in)
    close(stderr.in)

    out = read(stdout, String)
    err = read(stderr, String)

    wait(proc)

    return proc.exitcode, out, err
end

# Run `reuse lint --lines` and return the result.
function reuse_lint_lines(; root = pwd(), multiprocessing = true)
    cmd = if multiprocessing
        `$(reuse_executable()) --root $(root) lint -l`
    else
        `$(reuse_executable()) --no-multiprocessing --root $(root) lint -l`
    end
    return ReuseLintLinesResult(run_command(cmd)...)
end

# Check REUSE compliance using `reuse lint -l`.
function is_reuse_compliant(; root = pwd(), multiprocessing = true)
    result = reuse_lint_lines(; root, multiprocessing)
    return result.status == 0 &&
           isempty(strip(result.stdout))
end

# Run `reuse lint --json` and return the result.
function reuse_lint_json(; root = pwd(), multiprocessing = true)
    cmd = if multiprocessing
        `$(reuse_executable()) --root $(root) lint --json`
    else
        `$(reuse_executable()) --no-multiprocessing --root $(root) lint --json`
    end
    return ReuseLintJsonResult(run_command(cmd)...)
end
