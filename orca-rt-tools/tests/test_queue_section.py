"""Critical section around the queue of a task (pkt-sim/software/ucx-os/lib/noc.c: the dequeue of
ucx_noc_receive and the local enqueue of ucx_noc_send run with interrupts disabled in every image) in
the sections with interrupts disabled of the static analysis (rttools.wcet.ucx.sections)."""
import os
import shutil
import subprocess

import pytest

from tests.conftest import REPO_ROOT

EXP = os.path.join(REPO_ROOT, "experiments")
SPEC = os.path.join(EXP, "wcet", "specs", "weird_a_tt.json")
# image of run VH (tag r11-rc9): the code before the section entered every image
SPEC_VH = os.path.join(EXP, "wcet", "specs", "weird_a_VH.json")
NOC_C = os.path.join(REPO_ROOT, "pkt-sim", "software", "ucx-os", "lib", "noc.c")


def test_section_is_not_an_option():
    """noc.c has the section in every build: no UCX_NOC_QUEUE_DI in the conditions of the file, the
    Makefile or the build scripts."""
    for p in (NOC_C, os.path.join(REPO_ROOT, "pkt-sim", "software", "ucx-os", "Makefile"),
              os.path.join(EXP, "exp23", "build_sw.sh"), os.path.join(EXP, "exp23", "simulate.sh"),
              os.path.join(EXP, "str2rts", "rtl", "pilot.sh")):
        text = open(p).read()
        assert "ifdef UCX_NOC_QUEUE_DI" not in text and "defined(UCX_NOC_QUEUE_DI)" not in text, p
        assert "$(NOC_QUEUE_DI)" not in text and "NOC_QUEUE_DI=1\n" not in text and "${NOC_QUEUE_DI" not in text, p
    src = open(NOC_C).read()
    assert "noc_packet_t *pkt = ucx_queue_dequeue(pktdrv_tqueue[task_id]);\n  _interrupt_set(state);" in src
    assert "int32_t res = ucx_queue_enqueue(pktdrv_tqueue[target_task], pkt);\n    _interrupt_set(state);" in src


def test_stored_image_without_the_section():
    """An image up to tag r11-rc9 (run VH, experiments/exp23/logs/VH.image.elf) dequeues with interrupts
    enabled: the analysis reports no queue section for it. The images of this tree (images/tt) have both."""
    pytest.importorskip("elftools")
    pytest.importorskip("scipy")
    from rttools.wcet.__main__ import load_spec, run_spec
    res = run_spec(load_spec(SPEC_VH), None)
    assert "ucx_noc_receive" not in res["sections"]["sections"] and "ucx_noc_send" not in res["sections"]["sections"]
    new = run_spec(load_spec(SPEC), None)["sections"]
    assert new["sections"]["ucx_noc_receive"] == 96 and new["sections"]["ucx_noc_send"] == 107
    assert new["max"] == res["sections"]["max"] == 1151


@pytest.mark.skipif(shutil.which("riscv64-elf-gcc") is None, reason="riscv64-elf-gcc ausente")
def test_queue_sections_of_this_tree(tmp_path):
    """Image of application E of this tree: both queue sections are sections of the analysis, each
    far below the longest section (ucx_phase_wait), which stays the section of the blocking term B of
    the network interface (ni_terms) and of the release guard."""
    pytest.importorskip("elftools")
    pytest.importorskip("scipy")
    from rttools.wcet.__main__ import load_spec, run_spec
    r = subprocess.run(["bash", os.path.join(EXP, "exp23", "build_sw.sh"), str(tmp_path / "img")],
                       env={**os.environ, "APP": "weird_a", "F_CLK": "449152000"},
                       capture_output=True, text=True, timeout=1200)
    assert r.returncode == 0, (r.stdout + r.stderr)[-3000:]
    elf = str(tmp_path / "img" / "pkt-sim" / "software" / "ucx-os" / "build" / "target" / "image.elf")
    new = run_spec(load_spec(SPEC), elf)
    s = new["sections"]["sections"]
    assert 0 < s["ucx_noc_receive"] < 200 and 0 < s["ucx_noc_send"] < 200, s
    longest = max(v for k, v in s.items() if k not in ("ucx_noc_receive", "ucx_noc_send"))
    assert new["sections"]["max"] == longest and longest > 4 * max(s["ucx_noc_receive"], s["ucx_noc_send"])
