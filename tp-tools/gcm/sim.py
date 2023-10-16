from enum import Enum
from math import ceil

class KernelInfo():
    SCHEDULE_IRQ_WCET: int = None    # scheduler wcet (cycles)
    SCHEDULE_IRQ_FREQ: int = None    # number of sched. IRQs per second
    SCHEDULE_APP_TIME: float = None  # app time per sched. event

    NET_IRQ_WCET_RECV_1: int = None  # driver time, malloc
    NET_IRQ_WCET_RECV_2: int = None  # driver time, recv done
    NET_IRQ_WCET_SEND: int = None    # driver time, dma activation

    CPU_SPEED: int = None   # cpu speed, in Hertz (Hz)

    def __init__(self, sfreq, swcet, netd1, netd2, netd3, cpu_speed):
        self.SCHEDULE_IRQ_FREQ = sfreq
        self.SCHEDULE_IRQ_WCET = swcet
        self.NET_IRQ_WCET_RECV_1 = netd1
        self.NET_IRQ_WCET_RECV_2 = netd2
        self.NET_IRQ_WCET_SEND = netd3

        self.SCHEDULE_APP_TIME = (1.0 / self.SCHEDULE_IRQ_FREQ) \
            - self.SCHEDULE_IRQ_WCET

        self.CPU_SPEED = cpu_speed


UCX_OS = KernelInfo(
    sfreq=200,
    swcet=12345,
    netd1=0,
    netd2=20,
    netd3=0,
    cpu_speed=200000000  # 200MHz
)


class AppTask:
    _wcet: int = None  # wcet, in cycles
    _name: str = None

    def __init__(self, name: str, wcet: int):
        self._wcet = wcet
        self._name = name

    def __str__(self):
        return f"{self._name} ({self._wcet})"


class AppMessageType(Enum):
    INCOMING = 1
    OUTGOING = 2


class AppMessage():
    _type: AppMessageType = None    # message direction
    _payload: int   # payload data, in bytes
    _task: AppTask  # task to which receive or send

    def __init__(self, type, payload, task):
        self._type = type
        self._payload = payload
        self._task = task

    def __str__(self):
        if (self._type == AppMessageType.OUTGOING):
            return f"O <-- {self._task._name} ({self._payload})"
        else:
            return f"I --> {self._task._name} ({self._payload})"


class SystemEventType(Enum):
    APPLICATION_EVENT = 0
    KERNEL_TIME = 1
    SEND_ISR = 2
    RECV_ISR_1 = 3
    RECV_ISR_2 = 4


class SystemEvent():
    _type: SystemEventType = None
    _duration: int = None

    def __init__(self, itime, etype, duration, label):
        self._type = etype
        self._duration = duration
        self._initial_time = itime
        self._label = label

    def __str__(self):
        return f"[{self._initial_time}] {self._label}"


class KernelTracer():

    _event_queue: list[SystemEvent] = []
    _global_timer: int = None

    def trace(self):
        return "\n".join([str(x) for x in self._event_queue])

    def __init__(self, tasks: list[AppTask], imsg: list[AppMessage],
                 kinfo: KernelInfo):

        self._global_timer = 0

        # build the trace
        for m in imsg:
            if m._type == AppMessageType.INCOMING:

                # first message interruption
                e: SystemEvent = SystemEvent(self._global_timer,
                                             SystemEventType.RECV_ISR_1,
                                             m._payload,  # !TODO malloc time
                                             "RECV IRQ1")

                self._event_queue.append(e)
                self._global_timer += int(e._duration)

                # second message interruption
                e = SystemEvent(self._global_timer,
                                SystemEventType.RECV_ISR_2,
                                UCX_OS.NET_IRQ_WCET_RECV_2,
                                "RECV IRQ2")

                self._event_queue.append(e)
                self._global_timer += int(e._duration)

        for t in tasks:
            num_of_tasks = ceil(t._wcet / UCX_OS.SCHEDULE_APP_TIME)
            for i in range(0, num_of_tasks):
                e: SystemEvent = SystemEvent(self._global_timer,
                                             SystemEventType.KERNEL_TIME,
                                             UCX_OS.SCHEDULE_IRQ_WCET,
                                             "KERNEL")
                self._event_queue.append(e)
                self._global_timer += int(e._duration)

                e: SystemEvent = SystemEvent(self._global_timer,
                                             SystemEventType.APPLICATION_EVENT,
                                             UCX_OS.SCHEDULE_APP_TIME,
                                             f"TASK {t._name}")
                self._event_queue.append(e)
                self._global_timer += int(e._duration)

        for m in imsg:
            if m._type == AppMessageType.OUTGOING:
                # dma activation
                e: SystemEvent = SystemEvent(self._global_timer,
                                             SystemEventType.SEND_ISR,
                                             UCX_OS.NET_IRQ_WCET_SEND,
                                             "SEND IRQ")

                self._event_queue.append(e)
                self._global_timer += int(e._duration)
