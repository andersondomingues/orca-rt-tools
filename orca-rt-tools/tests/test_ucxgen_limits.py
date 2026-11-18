"""rttools.ucxgen above the defaults of the kernel (applications of one
release period): marker letters per PE with more than 52 tasks, tag modulus
of the flows, MAX_TASKS and MAX_PKT_QUEUE_SLOTS of the build in the manifest
and in <name>.sim; applications under the defaults keep their output."""
import collections
import os

import pytest

from tests.conftest import REPO_ROOT
from rttools.ucxgen import emit, memory, model

APPS = os.path.join(REPO_ROOT, "apps")


def str2rts(name, mesh="4x4"):
    d = os.path.join(APPS, "str2rts", name)
    return model.build(os.path.join(d, name + ".csv"), os.path.join(d, f"{name}-ONTO-hermes{mesh}.map"),
                       "x_" + name.split("-")[1], mesh=mesh)


def test_application_under_the_defaults_has_no_new_key():
    m = model.build(os.path.join(APPS, "car-v", "car-v.csv"), os.path.join(APPS, "car-v", "car-v-ONTO-hermes4x4.map"),
                    "car_v", mesh="4x4")
    assert "kernel_limits" not in m and "iter_letters" not in m
    assert m["tag_mod"] == model.TAG_MOD
    assert [t["iter_letter"] for t in m["tasks"]] == list(model.ITER_LETTERS[:len(m["tasks"])])
    assert emit.kernel_limits_setup(m) == ""
    assert "MAX_TASKS" not in emit.sim_setup(m)


def test_small_str2rts_application_keeps_the_defaults():
    m = str2rts("app-matmult")
    assert "kernel_limits" not in m and "iter_letters" not in m and m["tag_mod"] == 1024


def test_more_than_52_tasks_take_letters_per_pe():
    m = str2rts("app-filterbank")
    assert len(m["tasks"]) == 53 and m["iter_letters"] == "pe"
    pairs = collections.Counter((t["pe_label"], t["iter_letter"]) for t in m["tasks"])
    assert max(pairs.values()) == 1                     # rtlapp.iterations reads (PE, letter)
    assert all(t["iter_letter"] in model.ITER_LETTERS for t in m["tasks"])
    # the letters of a PE follow the order of the CSV
    for pe in {t["pe"] for t in m["tasks"]}:
        ts = [t for t in m["tasks"] if t["pe"] == pe]
        assert [t["iter_letter"] for t in ts] == list(model.ITER_LETTERS[:len(ts)])
    # a join of 8 edges: 16 slots; 59 flows keep the modulus 1024
    assert m["kernel_limits"] == {"MAX_PKT_QUEUE_SLOTS": 16} and m["tag_mod"] == 1024


def test_wide_join_asks_for_queue_slots():
    m = str2rts("app-audiobeam")
    assert max(len(t["inputs"]) for t in m["tasks"]) == 15
    assert m["kernel_limits"] == {"MAX_PKT_QUEUE_SLOTS": 32} and "iter_letters" not in m
    text = emit.sim_setup(m)
    assert text.endswith("MAX_PKT_QUEUE_SLOTS=32\n") and "TICK_RELEASE=1\n" in text
    # the heap model takes the slots of the build
    base = memory.pe_demand(dict(m, kernel_limits={}))
    wide = memory.pe_demand(m)
    for pe, n in collections.Counter(t["pe"] for t in m["tasks"]).items():
        assert wide[pe]["bytes"] - base[pe]["bytes"] == n * (32 - 8) * 4


def test_many_tasks_per_pe_and_many_flows():
    m = str2rts("app-des")
    most = max(collections.Counter(t["pe"] for t in m["tasks"]).values())
    assert most == 30 and m["kernel_limits"]["MAX_TASKS"] == 31
    assert m["tag_mod"] == 64 and len(m["flows"]) * 64 + 63 <= model.MAX_TAG
    assert len({f["tag_base"] for f in m["flows"]}) == len(m["flows"])
    assert "MAX_TASKS=31\n" in emit.sim_setup(m)
    assert "#define TAG_MOD     64" in emit.c_source(m)


def test_auto_tag_mod():
    assert model.auto_tag_mod(23) == 1024 and model.auto_tag_mod(63) == 1024
    assert model.auto_tag_mod(64) == 512 and model.auto_tag_mod(598) == 64
    with pytest.raises(model.GenError):
        model.auto_tag_mod(40000)


def test_explicit_tag_mod_that_does_not_fit_is_an_error():
    d = os.path.join(APPS, "str2rts", "app-des")
    with pytest.raises(model.GenError, match="16-bit tag"):
        model.build(os.path.join(d, "app-des.csv"), os.path.join(d, "app-des-ONTO-hermes4x4.map"), "x", mesh="4x4",
                    tag_mod=1024)
