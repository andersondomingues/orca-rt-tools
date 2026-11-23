"""Releases that do not come at a multiple of the release period from reset (first release at 3 ms with
T = 2 ms: APP-DES and APP-FIRBANK of STR2RTS): the packet windows of rttools.paper.rtlapp count from the
release of the model (release_offset), and the tick of each phase is the first tick after the release
(rttools.paper.ttcheck.release_tick, tests/test_tt_injection.py)."""
from rttools.paper import rtlapp


class Clk:
    """One raw unit of the log = one cycle."""
    def cycles(self, raw):
        return raw


def test_release_offset():
    # runs of this tree: first release at 3 ms, a multiple of T = 0.5 ms (and of 1 and 1.5 ms)
    assert rtlapp.release_offset({"warmup_cycles": "1347456"}, 224576) == 0
    assert rtlapp.release_offset({"warmup_cycles": "1578240"}, 131520) == 0
    # APP-DES at 725.768 MHz: 3 ms = 2,177,304 cycles, T = 1,451,536 cycles: half a period
    assert rtlapp.release_offset({"warmup_cycles": "2177304"}, 1451536) == 725768
    # no RUN_INFO clock lines (runs up to F): no offset
    assert rtlapp.release_offset({}, 250000) == 0 and rtlapp.release_offset(None, 250000) == 0


def test_packet_windows_count_from_the_release_of_the_model():
    """A packet sent 800,000 and received 900,000 cycles after a release in the middle of a tick, with a
    window that ends 250,000 cycles after the release of the model: late by 650,000 cycles from the release
    of the log, 75,768 cycles of slack from the release of the model, half a period later."""
    P = 1451536
    app = {"flows": {1: {"source": "A", "target": "B", "local": False, "src_label": "0-0", "dst_label": "1-0",
                          "bytes": 8}}}
    mdl = {"period_cycles": P, "flows": {1: {"release": 100000, "deadline": 250000}}, "tasks": {"A": {"phase": 0}}}
    ev = {1: {"send": {1: 2177443 + 800000}, "recv": {1: 2177443 + 900000}}}
    releases = [2177443]
    old = rtlapp.packets(app, mdl, Clk(), releases, ev)
    assert old["late"] == 1 and old["min_slack_remote_cycles"] == -650000 and "release_offset_cycles" not in old
    new = rtlapp.packets(app, mdl, Clk(), releases, ev, rtlapp.release_offset({"warmup_cycles": 2177304}, P))
    assert new["late"] == 0 and new["min_slack_remote_cycles"] == 75768 and new["release_offset_cycles"] == 725768
    assert new["flows"][0]["rows"][0]["send_cycles"] == 800000 - 725768
