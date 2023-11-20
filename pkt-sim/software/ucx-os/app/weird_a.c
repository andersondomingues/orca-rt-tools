#include <ucx.h>

#define CPU_A 0
#define CPU_B 0
#define CPU_D 0
#define CPU_F 0

#define CPU_C 1

#define CPU_E 2
#define CPU_H 2
#define CPU_I 2

#define CPU_G 3
#define CPU_J 3

// cannot use port 0 (noc driver bug)
#define PORT_A 10
#define PORT_B 1
#define PORT_C 2
#define PORT_D 3
#define PORT_E 4
#define PORT_F 5
#define PORT_G 6
#define PORT_H 7
#define PORT_I 8
#define PORT_J 9

#define TASK_A_WORKLOAD 1230
#define TASK_B_WORKLOAD 4560
#define TASK_C_WORKLOAD 7890
#define TASK_D_WORKLOAD 1200
#define TASK_E_WORKLOAD 3450
#define TASK_F_WORKLOAD 6780
#define TASK_G_WORKLOAD 9010
#define TASK_H_WORKLOAD 2340
#define TASK_I_WORKLOAD 5670
#define TASK_J_WORKLOAD 8900

#define COMM_AC_WORKLOAD 1230
#define COMM_AB_WORKLOAD 4560
#define COMM_BD_WORKLOAD 7890
#define COMM_CE_WORKLOAD 1200
#define COMM_DF_WORKLOAD 3450
#define COMM_FG_WORKLOAD 6780
#define COMM_EI_WORKLOAD 9010
#define COMM_EH_WORKLOAD 2340
#define COMM_IJ_WORKLOAD 5670
#define COMM_HJ_WORKLOAD 8900
#define COMM_GJ_WORKLOAD 1230

// ------------------------------ TASKS
void recv_and_print()
{
  while (ucx_noc_probe() <= 0);

  noc_packet_t *pkt = ucx_noc_receive();

  tprintf("<- %d:%d (from %d:%d)\n",
          pkt->source_node, pkt->source_port,
          pkt->target_node, pkt->target_port);

  ucx_free(pkt);
}

noc_packet_t *create_pkt(uint32_t comm_workload)
{
  noc_packet_t *pkt_rec = ucx_noc_create_packet(comm_workload);

  for (int i = 0; i < comm_workload; i++)
    pkt_rec->data[i] = i;

  return pkt_rec;
}

// ------------------------------ TASK A
void task_a()
{
  ucx_noc_comm_create(PORT_A);

  ucx_sleep(TASK_A_WORKLOAD);

  tprintf("A->B\n");
  noc_packet_t *pkt = create_pkt(COMM_AB_WORKLOAD);
  ucx_noc_send(CPU_B, PORT_B, pkt, COMM_AB_WORKLOAD);
  ucx_free(pkt);

  tprintf("A->C\n");
  pkt = create_pkt(COMM_AC_WORKLOAD);
  ucx_noc_send(CPU_C, PORT_C, pkt, COMM_AC_WORKLOAD);
  ucx_free(pkt);

  ucx_sleep(-1);
}

// ------------------------------ TASK B
void task_b()
{
  ucx_noc_comm_create(PORT_B);
  recv_and_print();

  ucx_sleep(TASK_B_WORKLOAD);

  tprintf("B->D\n");
  noc_packet_t *pkt = create_pkt(COMM_BD_WORKLOAD);
  ucx_noc_send(CPU_D, PORT_D, pkt, COMM_BD_WORKLOAD);

  ucx_sleep(-1);
}

// ------------------------------ TASK C
void task_c()
{
  ucx_noc_comm_create(PORT_C);
  recv_and_print();

  ucx_sleep(TASK_C_WORKLOAD);

  tprintf("C->E\n");
  noc_packet_t *pkt = create_pkt(COMM_CE_WORKLOAD);
  ucx_noc_send(CPU_E, PORT_E, pkt, COMM_CE_WORKLOAD);

  ucx_sleep(-1);
}

// ------------------------------ TASK D
void task_d()
{
  ucx_noc_comm_create(PORT_D);
  recv_and_print();

  ucx_sleep(TASK_D_WORKLOAD);

  tprintf("D->F\n");
  noc_packet_t *pkt = create_pkt(COMM_DF_WORKLOAD);
  ucx_noc_send(CPU_F, PORT_F, pkt, COMM_DF_WORKLOAD);

  ucx_sleep(-1);
}

// ------------------------------ TASK E
void task_e()
{
  ucx_noc_comm_create(PORT_E);
  recv_and_print();

  ucx_sleep(TASK_E_WORKLOAD);

  tprintf("E->I\n");
  noc_packet_t *pkt = create_pkt(COMM_EI_WORKLOAD);
  ucx_noc_send(CPU_I, PORT_I, pkt, COMM_DF_WORKLOAD);
  ucx_free(pkt);  // << avoid malloc error

  tprintf("E->H\n");
  pkt = create_pkt(COMM_EH_WORKLOAD);
  ucx_noc_send(CPU_H, PORT_H, pkt, COMM_EH_WORKLOAD);

  ucx_sleep(-1);
}

// ------------------------------ TASK F
void task_f()
{
  ucx_noc_comm_create(PORT_F);
  recv_and_print();

  ucx_sleep(TASK_F_WORKLOAD);

  tprintf("F->G\n");
  noc_packet_t *pkt = create_pkt(COMM_FG_WORKLOAD);
  ucx_noc_send(CPU_G, PORT_G, pkt, COMM_FG_WORKLOAD);

  ucx_sleep(-1);
}

// ------------------------------ TASK G
void task_g()
{
  ucx_noc_comm_create(PORT_G);
  recv_and_print();

  ucx_sleep(TASK_G_WORKLOAD);

  tprintf("G->J\n");
  noc_packet_t *pkt = create_pkt(COMM_GJ_WORKLOAD);
  ucx_noc_send(CPU_J, PORT_J, pkt, COMM_GJ_WORKLOAD);

  ucx_sleep(-1);
}

// ------------------------------ TASK H
void task_h()
{
  ucx_noc_comm_create(PORT_H);
  recv_and_print();

  ucx_sleep(TASK_H_WORKLOAD);

  tprintf("H->J\n");
  noc_packet_t *pkt = create_pkt(COMM_HJ_WORKLOAD);
  ucx_noc_send(CPU_J, PORT_J, pkt, COMM_HJ_WORKLOAD);

  ucx_sleep(-1);
}

// ------------------------------ TASK I
void task_i()
{
  ucx_noc_comm_create(PORT_I);
  recv_and_print();

  ucx_sleep(TASK_I_WORKLOAD);

  tprintf("I->J\n");
  noc_packet_t *pkt = create_pkt(COMM_IJ_WORKLOAD);
  ucx_noc_send(CPU_J, PORT_J, pkt, COMM_IJ_WORKLOAD);

  ucx_sleep(-1);
}

// ------------------------------ TASK J
void task_j()
{
  ucx_noc_comm_create(PORT_J);

  recv_and_print();
  recv_and_print();
  recv_and_print();

  ucx_sleep(TASK_J_WORKLOAD);

  ucx_sleep(-1);
}

void idle_task_p(void)
{
  // ucx_sleep(-1);
  for (;;);
}

int32_t app_main(void)
{

  uint32_t cpu_id = ucx_noc_cpu_id();

  switch (cpu_id)
  {
  case 0: // ABDF
    ucx_task_add(task_f, "F", DEFAULT_STACK_SIZE, 0, 0, 0);
    ucx_task_add(task_d, "D", DEFAULT_STACK_SIZE, 0, 0, 0);
    ucx_task_add(task_b, "B", DEFAULT_STACK_SIZE, 0, 0, 0);
    ucx_task_add(task_a, "A", DEFAULT_STACK_SIZE, 0, 0, 0);
    break;
  case 1: // C
    ucx_task_add(task_c, "C", DEFAULT_STACK_SIZE, 0, 0, 0);
    break;
  case 2: // EHI
    ucx_task_add(task_h, "H", DEFAULT_STACK_SIZE, 0, 0, 0);
    ucx_task_add(task_i, "I", DEFAULT_STACK_SIZE, 0, 0, 0);
    ucx_task_add(task_e, "E", DEFAULT_STACK_SIZE, 0, 0, 0);
    break;
  case 3: // GJ
    ucx_task_add(task_j, "J", DEFAULT_STACK_SIZE, 0, 0, 0);
    ucx_task_add(task_g, "G", DEFAULT_STACK_SIZE, 0, 0, 0);
    break;
  default:
    ucx_task_add(idle_task_p, "IDLE", DEFAULT_STACK_SIZE, 0, 0, 0);
    break;
  }

  return 1;
}
