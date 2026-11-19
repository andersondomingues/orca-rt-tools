"""Runs the UCX-OS host C tests (pkt-sim/software/ucx-os/tests/host)
with gcc, AddressSanitizer and UBSan: address conversions of device/ddma.c
(test_ddma.c) and reception and port handling of lib/noc.c (test_noc.c)."""
import os
import shutil
import subprocess

import pytest

from tests.conftest import REPO_ROOT

HOST = os.path.join(REPO_ROOT, "pkt-sim", "software", "ucx-os", "tests", "host")

pytestmark = pytest.mark.skipif(shutil.which("gcc") is None, reason="gcc ausente")


@pytest.mark.parametrize("name", sorted(
    f[:-2] for f in os.listdir(HOST) if f.startswith("test_") and f.endswith(".c")))
def test_host(name, tmp_path):
    r = subprocess.run(["sh", os.path.join(HOST, "run.sh"), name],
                       env={**os.environ, "OUT": str(tmp_path)},
                       capture_output=True, text=True, timeout=300)
    assert r.returncode == 0, r.stdout + r.stderr[-4000:]
    assert "FAIL" not in r.stdout


def test_host_noc_tt_step32(tmp_path):
    """test_noc_tt.c with the 32-bit step of TIMER1 (-DUCX_TT_STEP32, test_noc_tt32 of run.sh): the
    kernel of a tick of more than 16 * 65536 cycles; a step above 65535 leaves at its step."""
    r = subprocess.run(["sh", os.path.join(HOST, "run.sh"), "test_noc_tt32"],
                       env={**os.environ, "OUT": str(tmp_path)},
                       capture_output=True, text=True, timeout=300)
    assert r.returncode == 0, r.stdout + r.stderr[-4000:]
    assert "FAIL" not in r.stdout
    assert "PASS test_step_above_16_bits" in r.stdout
