#define _GNU_SOURCE
#include <arpa/inet.h>
#include <dlfcn.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

/* Per-process opt-in; no system library or executable is replaced. */
static int enabled;
static uint32_t wire_xid;
__attribute__((constructor)) static void init_xid(void)
{
    const char *s = getenv("IPTV_FIXED_XID");
    if (s) {
        char *end;
        unsigned long v = strtoul(s, &end, 16);
        if (strlen(s) != 8 || *end || !v || v > UINT32_MAX) {
            fputs("udhcpc-xid: invalid 8-digit XID\n", stderr);
            _exit(125);
        }
        wire_xid = htonl((uint32_t)v);
        enabled = 1;
        /* DHCP event scripts and their children must not inherit the hook. */
        unsetenv("LD_PRELOAD");
        unsetenv("IPTV_FIXED_XID");
    }
}

int rand(void)
{
    if (enabled) return (int)wire_xid;
    int (*real_rand)(void) = dlsym(RTLD_NEXT, "rand");
    if (!real_rand) _exit(126);
    return real_rand();
}
