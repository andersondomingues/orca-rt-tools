from bench.kernel import TaskControlBlock

class SchedulingAlgorithm():

    @classmethod
    def RATE_MONOTONIC(self: "RateMonotonic", r: list[TaskControlBlock]):
        return sorted(r, key=lambda e: (1 / e._next_deadline), reverse=False)

    @classmethod
    def LEAST_SLACK_TIME(self: "LeastSlackTime", r: list[TaskControlBlock]):
        return sorted(r, key=lambda e: e._capacity - e._current_capacity, reverse=False)

    @classmethod
    def LEAST_LAXITY_FIRST(self: "LeastLaxityFirst", r: list[TaskControlBlock]):
        return sorted(r, key=lambda e: (e._deadline - e._period), reverse=False)

    @classmethod
    def EARLIEST_DEADLINE_FIRST(self: "EarliestDeadlineFirst", r: list[TaskControlBlock]):
        return sorted(r, key=lambda e: e._next_deadline, reverse=False)

    @classmethod
    def DEADLINE_MONOTONIC(self: "DeadlineMonotonic", r: list[TaskControlBlock]):
        return sorted(r, key=lambda e: e._deadline, reverse=False)
        

