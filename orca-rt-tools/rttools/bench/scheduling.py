from rttools.bench.kernel import TaskControlBlock

class RateMonotonicScheduling():
    @classmethod
    def schedule(self: "RateMonotonicScheduling", r: "list[TaskControlBlock]"):
        return sorted(r, key=lambda e: (1 / e._next_deadline), reverse=False)

class LeastSlackTimeScheduling():
    @classmethod
    def schedule(self: "LeastSlackTimeScheduling", r: "list[TaskControlBlock]"):
        return sorted(r, key=lambda e: e._capacity - e._current_capacity, reverse=False)

class LeastLaxityFirstScheduling():
    @classmethod
    def schedule(self: "LeastLaxityFirstScheduling", r: "list[TaskControlBlock]"):
        return sorted(r, key=lambda e: (e._deadline - e._period), reverse=False)

class EarliestDeadlineFirst():
    @classmethod
    def schedule(self: "EarliestDeadlineFirst", r: "list[TaskControlBlock]"):
        return sorted(r, key=lambda e: e._next_deadline, reverse=False)

class DeadlineMonotonicSchedule():
    @classmethod
    def schedule(self: "DeadlineMonotonicSchedule", r: "list[TaskControlBlock]"):
        return sorted(r, key=lambda e: e._deadline, reverse=False)

class RoundRobinSchedule():
    @classmethod
    def schedule(self: "RoundRobinSchedule", r: "list[TaskControlBlock]"):
        top_element = r[0]
        r = r[1::]
        r.append(top_element)
        return r
        

