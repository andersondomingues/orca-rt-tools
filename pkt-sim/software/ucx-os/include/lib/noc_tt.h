/* file:          noc_tt.h
 * description:   time-triggered injection of the packets between PEs
 *                (lib/noc_tt.c)
 *
 * Build with -DUCX_NOC_TT (kernel and application; Makefile, TR_DEFS and
 * TT_DEFS). Without UCX_NOC_TT the library defines nothing.
 */
#ifndef UCX_NOC_TT_H
#define UCX_NOC_TT_H

/* noc_packet_t of lib/noc.h, uint16_t and uint32_t of hal.h (include/ucx.h) */

/* Step of TIMER1 inside a tick. TIMER1 and its compare register hold 32
 * bits (hw/peripherals/peripherals_minimal.vhd), and hal.c accepts a tick of
 * up to 16 * 2^32 cycles. The tables app/<app>_tt.h and the queue of
 * lib/noc_tt.c keep the step in 16 bits when the tick of the build has at
 * most 65536 steps (16 * 65536 = 1,048,576 cycles: the code of every image
 * built before TIMER1 had 32 bits, byte for byte) and in 32 bits when it has
 * more (2 ms above 524.288 MHz: APP-DES and APP-FIRBANK of STR2RTS at the
 * clock of the flow of their image). The tick of the build is
 * UCX_TICK_CYCLES or F_CPU / F_TIMER, as in hal.c; the kernel and the
 * application take both from the same make variables. -DUCX_TT_STEP32
 * selects the 32 bits for any tick (tests/host/run.sh, test_noc_tt32). */
#ifndef UCX_TT_STEP32
#if defined(UCX_TICK_CYCLES)
#if (UCX_TICK_CYCLES / 16) > 65536
#define UCX_TT_STEP32
#endif
#elif defined(F_CPU) && defined(F_TIMER) && F_TIMER > 0
#if (F_CPU / F_TIMER / 16) > 65536
#define UCX_TT_STEP32
#endif
#endif
#endif
#ifdef UCX_TT_STEP32
typedef uint32_t ucx_tt_step_t;
#else
typedef uint16_t ucx_tt_step_t;
#endif

/* injection instant of a packet, from the tick that starts the phase of
 * the job that sends it: `ticks` ticks later, at step `count` of TIMER1
 * (16 cycles per step, hal.c), so `ticks` T + 16 `count` cycles after that
 * tick (T: tick period in cycles) */
struct ucx_tt_at {
	uint16_t ticks;
	ucx_tt_step_t count;
};

/* index of the current tick (number of ticks since the timer started) */
uint32_t ucx_noc_tt_ticks(void);

/* tick routine (kernel/sched.c, dispatch, before the tick hook of the
 * application): counts the tick and injects or arms the next packet */
void ucx_noc_tt_tick(void);

/* hands packet `pkt` to the kernel: a target on this PE receives it now
 * (ucx_noc_send); a target on another PE receives it at the instant `at`
 * counted from tick `tick` (the tick of the phase of the sending job). The
 * kernel writes the target and the tag into the packet at the injection,
 * so the job can reuse `pkt` for its next packet of the same flow. Returns
 * the value of ucx_noc_send for a target on this PE; for another PE, 0
 * (the kernel keeps the packet) or UCX_NOC_OUT_OF_MEMORY (queue full,
 * packet not sent) */
uint32_t ucx_noc_send_at(uint16_t target_cpu, uint16_t target_port, noc_packet_t *pkt, uint16_t tag,
	uint32_t tick, const struct ucx_tt_at *at);

/* packets that wait for their instant on this PE */
uint32_t ucx_noc_tt_pending(void);

#endif
