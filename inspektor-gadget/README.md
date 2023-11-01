Sample

### inspektor-gadget

```
❯ kubectl gadget -n kube-system trace bind
K8S.NODE               K8S.NAMESPACE          K8S.POD                K8S.CONTAINER         PID        COMM        PROTO ADDR            PORT  OPTS  IF
kind-v1.28.0-worker2   kube-system            node-dns-bcj4p         unbound               159310     unbound     UDP   ::              53    rR...
kind-v1.28.0-worker2   kube-system            node-dns-bcj4p         unbound               159310     unbound     TCP   ::              53    rR...
kind-v1.28.0-worker2   kube-system            node-dns-bcj4p         unbound               159310     unbound     UDP   0.0.0.0         53    rR...
kind-v1.28.0-worker2   kube-system            node-dns-bcj4p         unbound               159310     unbound     TCP   0.0.0.0         53    rR...
kind-v1.28.0-worker2   kube-system            node-dns-bcj4p         unbound               159310     unbound     UDP   ::              53    rR...
kind-v1.28.0-worker2   kube-system            node-dns-bcj4p         unbound               159310     unbound     TCP   ::              53    rR...
kind-v1.28.0-worker2   kube-system            node-dns-bcj4p         unbound               159310     unbound     UDP   0.0.0.0         53    rR...
kind-v1.28.0-worker2   kube-system            node-dns-bcj4p         unbound               159310     unbound     TCP   0.0.0.0         53    rR...
kind-v1.28.0-worker2   kube-system            node-dns-bcj4p         unbound               159310     unbound     UDP   ::              53    rR...
```

### debug command

```
❯ kubectl debug -n kube-system "node-dns-bcj4p" -it --image=debian:latest --target=unbound -- sh
Targeting container "unbound". If you don't see processes from this container it may be because the container runtime doesn't support this feature.
Defaulting debug container name to debugger-xrvqm.
If you don't see a command prompt, try pressing enter.

# apt update
Get:1 http://deb.debian.org/debian bookworm InRelease [151 kB]
~snip~~
# apt install procps
Reading package lists... Done
# ps auxf
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root          29  0.0  0.0   2576  1536 pts/0    Ss   12:16   0:00 sh
root         224  0.0  0.0   8088  4224 pts/0    R+   12:17   0:00  \_ ps auxf
root           1  0.1  0.3 1031420 99184 ?       Ssl  12:15   0:00 unbound -d -p -c /etc/unbound/unbound.conf
# bash
root@kind-v1:/# ls -l /etc/unbound/unbound.conf
ls: cannot access '/etc/unbound/unbound.conf': No such file or directory
root@kind-v1:/# head /proc/1/root/etc/unbound/unbound.conf
server:
  do-daemonize: no
  #interface: 0.0.0.0
  interface: 127.0.0.1
```
