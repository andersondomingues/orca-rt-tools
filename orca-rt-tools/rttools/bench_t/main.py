task_set_a = []
task_set_a.append({ "name": "A", "wcet": 285300})
task_set_a.append({ "name": "B", "wcet": 586000})
task_set_a.append({ "name": "D", "wcet": 140000})
task_set_a.append({ "name": "F", "wcet": 808000})

task_set_b = []
task_set_b.append({ "name": "C", "wcet": 963300})

task_set_c = []
task_set_c.append({ "name": "E", "wcet": 527000})
task_set_c.append({ "name": "I", "wcet": 753700})
task_set_c.append({ "name": "H", "wcet": 453000})

task_set_d = []
task_set_d.append({ "name": "G", "wcet": 1098800})
task_set_d.append({ "name": "J", "wcet": 1075700})

task_sets = [
   task_set_a, task_set_b, task_set_c, task_set_d
]





schedule_time = 110000
time_maximum = 2500000

for tasks in task_sets:
  time_current = 0

  for t in tasks:
      print(t)

  while (time_current < time_maximum):
    
    print(time_current, "scheduling event")
    time_current += schedule_time
    
    current_task = tasks[0]
    print(time_current, "tasks execution:", current_task["name"])
    time_current += current_task["wcet"] - schedule_time
    

    tasks.remove(current_task)
      
    if(len(tasks) == 0):
        print(time_current, "finished")
        break

  