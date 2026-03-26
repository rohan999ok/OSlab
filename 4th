#include <stdio.h>
#include <string.h>

#define MAX 100

typedef struct {
    int pid;
    int arrival;
    int burst;
    int remaining;
    int type;
    int completion;
    int tat;
    int waiting;
} Process;

int main() {
    Process sq[MAX], uq[MAX];
    Process all[MAX];
    int n;
    int sq_size = 0, uq_size = 0;

    printf("Enter number of processes: ");
    scanf("%d", &n);

    for (int i = 0; i < n; i++) {
        int pid, at, bt;
        char typeStr[10];

        printf("Enter PID, ArrivalTime, BurstTime, Type(System/User): ");
        scanf("%d %d %d %s", &pid, &at, &bt, typeStr);

        all[i].pid = pid;
        all[i].arrival = at;
        all[i].burst = bt;
        all[i].remaining = bt;
        all[i].completion = 0;
        all[i].tat = 0;
        all[i].waiting = 0;
        all[i].type = (strcmp(typeStr, "System") == 0 ||
                       strcmp(typeStr, "system") == 0) ? 0 : 1;

        if (all[i].type == 0) {
            sq[sq_size] = all[i];
            sq_size++;
        } else {
            uq[uq_size] = all[i];
            uq_size++;
        }
    }

    for (int i = 0; i < sq_size - 1; i++) {
        for (int j = 0; j < sq_size - i - 1; j++) {
            if (sq[j].arrival > sq[j + 1].arrival) {
                Process tmp = sq[j];
                sq[j] = sq[j + 1];
                sq[j + 1] = tmp;
            }
        }
    }

    for (int i = 0; i < uq_size - 1; i++) {
        for (int j = 0; j < uq_size - i - 1; j++) {
            if (uq[j].arrival > uq[j + 1].arrival) {
                Process tmp = uq[j];
                uq[j] = uq[j + 1];
                uq[j + 1] = tmp;
            }
        }
    }

    int current_time = 0;
    int sq_front = 0, uq_front = 0;

    while (sq_front < sq_size || uq_front < uq_size) {

        while (sq_front < sq_size) {
            Process *p = &sq[sq_front];

            if (current_time < p->arrival)
                current_time = p->arrival;

            current_time += p->burst;
            p->completion = current_time;

            for (int k = 0; k < n; k++) {
                if (all[k].pid == p->pid) {
                    all[k].completion = p->completion;
                    break;
                }
            }

            sq_front++;
        }

        while (sq_front >= sq_size && uq_front < uq_size) {
            Process *p = &uq[uq_front];

            if (current_time < p->arrival)
                current_time = p->arrival;

            current_time += p->burst;
            p->completion = current_time;

            for (int k = 0; k < n; k++) {
                if (all[k].pid == p->pid) {
                    all[k].completion = p->completion;
                    break;
                }
            }

            uq_front++;
        }
    }

    double sum_tat = 0, sum_wait = 0;

    for (int i = 0; i < n; i++) {
        all[i].tat = all[i].completion - all[i].arrival;
        all[i].waiting = all[i].tat - all[i].burst;
        sum_tat += all[i].tat;
        sum_wait += all[i].waiting;
    }

    printf("\nPID\tType\tAT\tBT\tCT\tTAT\tWT\n");
    for (int i = 0; i < n; i++) {
        printf("%d\t%s\t%d\t%d\t%d\t%d\t%d\n",
               all[i].pid,
               all[i].type == 0 ? "System" : "User",
               all[i].arrival,
               all[i].burst,
               all[i].completion,
               all[i].tat,
               all[i].waiting);
    }

    printf("\nAverage Turnaround Time = %.2f\n", sum_tat / n);
    printf("Average Waiting Time    = %.2f\n", sum_wait / n);

    return 0;


Enter number of processes: 3      
Enter PID, ArrivalTime, BurstTime, Type(S/U): 0 9 8 U
Enter PID, ArrivalTime, BurstTime, Type(S/U): 0 2 3 U
Enter PID, ArrivalTime, BurstTime, Type(S/U): 2 3 4 S   

PID     Type    AT      BT      CT      TAT     WT
0       User    9       8       17      8       0
0       User    2       3       0       -2      -5
2       User    3       4       9       6       2

Average Turnaround Time = 4.00
Average Waiting Time    = 11.00
}
