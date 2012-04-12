
_ps:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "types.h"
#include "stat.h"
#include "user.h"

int main(){
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
       procstat();
   6:	e8 09 03 00 00       	call   314 <procstat>
       exit();
   b:	e8 64 02 00 00       	call   274 <exit>

00000010 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  10:	55                   	push   %ebp
  11:	89 e5                	mov    %esp,%ebp
  13:	57                   	push   %edi
  14:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  15:	8b 4d 08             	mov    0x8(%ebp),%ecx
  18:	8b 55 10             	mov    0x10(%ebp),%edx
  1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  1e:	89 cb                	mov    %ecx,%ebx
  20:	89 df                	mov    %ebx,%edi
  22:	89 d1                	mov    %edx,%ecx
  24:	fc                   	cld    
  25:	f3 aa                	rep stos %al,%es:(%edi)
  27:	89 ca                	mov    %ecx,%edx
  29:	89 fb                	mov    %edi,%ebx
  2b:	89 5d 08             	mov    %ebx,0x8(%ebp)
  2e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  31:	5b                   	pop    %ebx
  32:	5f                   	pop    %edi
  33:	5d                   	pop    %ebp
  34:	c3                   	ret    

00000035 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  35:	55                   	push   %ebp
  36:	89 e5                	mov    %esp,%ebp
  38:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  3b:	8b 45 08             	mov    0x8(%ebp),%eax
  3e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  41:	90                   	nop
  42:	8b 45 0c             	mov    0xc(%ebp),%eax
  45:	0f b6 10             	movzbl (%eax),%edx
  48:	8b 45 08             	mov    0x8(%ebp),%eax
  4b:	88 10                	mov    %dl,(%eax)
  4d:	8b 45 08             	mov    0x8(%ebp),%eax
  50:	0f b6 00             	movzbl (%eax),%eax
  53:	84 c0                	test   %al,%al
  55:	0f 95 c0             	setne  %al
  58:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  5c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  60:	84 c0                	test   %al,%al
  62:	75 de                	jne    42 <strcpy+0xd>
    ;
  return os;
  64:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  67:	c9                   	leave  
  68:	c3                   	ret    

00000069 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  69:	55                   	push   %ebp
  6a:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  6c:	eb 08                	jmp    76 <strcmp+0xd>
    p++, q++;
  6e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  72:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  76:	8b 45 08             	mov    0x8(%ebp),%eax
  79:	0f b6 00             	movzbl (%eax),%eax
  7c:	84 c0                	test   %al,%al
  7e:	74 10                	je     90 <strcmp+0x27>
  80:	8b 45 08             	mov    0x8(%ebp),%eax
  83:	0f b6 10             	movzbl (%eax),%edx
  86:	8b 45 0c             	mov    0xc(%ebp),%eax
  89:	0f b6 00             	movzbl (%eax),%eax
  8c:	38 c2                	cmp    %al,%dl
  8e:	74 de                	je     6e <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  90:	8b 45 08             	mov    0x8(%ebp),%eax
  93:	0f b6 00             	movzbl (%eax),%eax
  96:	0f b6 d0             	movzbl %al,%edx
  99:	8b 45 0c             	mov    0xc(%ebp),%eax
  9c:	0f b6 00             	movzbl (%eax),%eax
  9f:	0f b6 c0             	movzbl %al,%eax
  a2:	89 d1                	mov    %edx,%ecx
  a4:	29 c1                	sub    %eax,%ecx
  a6:	89 c8                	mov    %ecx,%eax
}
  a8:	5d                   	pop    %ebp
  a9:	c3                   	ret    

000000aa <strlen>:

uint
strlen(char *s)
{
  aa:	55                   	push   %ebp
  ab:	89 e5                	mov    %esp,%ebp
  ad:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
  b0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  b7:	eb 04                	jmp    bd <strlen+0x13>
  b9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  c0:	03 45 08             	add    0x8(%ebp),%eax
  c3:	0f b6 00             	movzbl (%eax),%eax
  c6:	84 c0                	test   %al,%al
  c8:	75 ef                	jne    b9 <strlen+0xf>
    ;
  return n;
  ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  cd:	c9                   	leave  
  ce:	c3                   	ret    

000000cf <memset>:

void*
memset(void *dst, int c, uint n)
{
  cf:	55                   	push   %ebp
  d0:	89 e5                	mov    %esp,%ebp
  d2:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
  d5:	8b 45 10             	mov    0x10(%ebp),%eax
  d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  df:	89 44 24 04          	mov    %eax,0x4(%esp)
  e3:	8b 45 08             	mov    0x8(%ebp),%eax
  e6:	89 04 24             	mov    %eax,(%esp)
  e9:	e8 22 ff ff ff       	call   10 <stosb>
  return dst;
  ee:	8b 45 08             	mov    0x8(%ebp),%eax
}
  f1:	c9                   	leave  
  f2:	c3                   	ret    

000000f3 <strchr>:

char*
strchr(const char *s, char c)
{
  f3:	55                   	push   %ebp
  f4:	89 e5                	mov    %esp,%ebp
  f6:	83 ec 04             	sub    $0x4,%esp
  f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  fc:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
  ff:	eb 14                	jmp    115 <strchr+0x22>
    if(*s == c)
 101:	8b 45 08             	mov    0x8(%ebp),%eax
 104:	0f b6 00             	movzbl (%eax),%eax
 107:	3a 45 fc             	cmp    -0x4(%ebp),%al
 10a:	75 05                	jne    111 <strchr+0x1e>
      return (char*)s;
 10c:	8b 45 08             	mov    0x8(%ebp),%eax
 10f:	eb 13                	jmp    124 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 111:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 115:	8b 45 08             	mov    0x8(%ebp),%eax
 118:	0f b6 00             	movzbl (%eax),%eax
 11b:	84 c0                	test   %al,%al
 11d:	75 e2                	jne    101 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 11f:	b8 00 00 00 00       	mov    $0x0,%eax
}
 124:	c9                   	leave  
 125:	c3                   	ret    

00000126 <gets>:

char*
gets(char *buf, int max)
{
 126:	55                   	push   %ebp
 127:	89 e5                	mov    %esp,%ebp
 129:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 12c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 133:	eb 44                	jmp    179 <gets+0x53>
    cc = read(0, &c, 1);
 135:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 13c:	00 
 13d:	8d 45 ef             	lea    -0x11(%ebp),%eax
 140:	89 44 24 04          	mov    %eax,0x4(%esp)
 144:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 14b:	e8 3c 01 00 00       	call   28c <read>
 150:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 153:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 157:	7e 2d                	jle    186 <gets+0x60>
      break;
    buf[i++] = c;
 159:	8b 45 f4             	mov    -0xc(%ebp),%eax
 15c:	03 45 08             	add    0x8(%ebp),%eax
 15f:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 163:	88 10                	mov    %dl,(%eax)
 165:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 169:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 16d:	3c 0a                	cmp    $0xa,%al
 16f:	74 16                	je     187 <gets+0x61>
 171:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 175:	3c 0d                	cmp    $0xd,%al
 177:	74 0e                	je     187 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 179:	8b 45 f4             	mov    -0xc(%ebp),%eax
 17c:	83 c0 01             	add    $0x1,%eax
 17f:	3b 45 0c             	cmp    0xc(%ebp),%eax
 182:	7c b1                	jl     135 <gets+0xf>
 184:	eb 01                	jmp    187 <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 186:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 187:	8b 45 f4             	mov    -0xc(%ebp),%eax
 18a:	03 45 08             	add    0x8(%ebp),%eax
 18d:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 190:	8b 45 08             	mov    0x8(%ebp),%eax
}
 193:	c9                   	leave  
 194:	c3                   	ret    

00000195 <stat>:

int
stat(char *n, struct stat *st)
{
 195:	55                   	push   %ebp
 196:	89 e5                	mov    %esp,%ebp
 198:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 19b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 1a2:	00 
 1a3:	8b 45 08             	mov    0x8(%ebp),%eax
 1a6:	89 04 24             	mov    %eax,(%esp)
 1a9:	e8 06 01 00 00       	call   2b4 <open>
 1ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 1b1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1b5:	79 07                	jns    1be <stat+0x29>
    return -1;
 1b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 1bc:	eb 23                	jmp    1e1 <stat+0x4c>
  r = fstat(fd, st);
 1be:	8b 45 0c             	mov    0xc(%ebp),%eax
 1c1:	89 44 24 04          	mov    %eax,0x4(%esp)
 1c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1c8:	89 04 24             	mov    %eax,(%esp)
 1cb:	e8 fc 00 00 00       	call   2cc <fstat>
 1d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 1d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1d6:	89 04 24             	mov    %eax,(%esp)
 1d9:	e8 be 00 00 00       	call   29c <close>
  return r;
 1de:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 1e1:	c9                   	leave  
 1e2:	c3                   	ret    

000001e3 <atoi>:

int
atoi(const char *s)
{
 1e3:	55                   	push   %ebp
 1e4:	89 e5                	mov    %esp,%ebp
 1e6:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 1e9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 1f0:	eb 24                	jmp    216 <atoi+0x33>
    n = n*10 + *s++ - '0';
 1f2:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1f5:	89 d0                	mov    %edx,%eax
 1f7:	c1 e0 02             	shl    $0x2,%eax
 1fa:	01 d0                	add    %edx,%eax
 1fc:	01 c0                	add    %eax,%eax
 1fe:	89 c2                	mov    %eax,%edx
 200:	8b 45 08             	mov    0x8(%ebp),%eax
 203:	0f b6 00             	movzbl (%eax),%eax
 206:	0f be c0             	movsbl %al,%eax
 209:	8d 04 02             	lea    (%edx,%eax,1),%eax
 20c:	83 e8 30             	sub    $0x30,%eax
 20f:	89 45 fc             	mov    %eax,-0x4(%ebp)
 212:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 216:	8b 45 08             	mov    0x8(%ebp),%eax
 219:	0f b6 00             	movzbl (%eax),%eax
 21c:	3c 2f                	cmp    $0x2f,%al
 21e:	7e 0a                	jle    22a <atoi+0x47>
 220:	8b 45 08             	mov    0x8(%ebp),%eax
 223:	0f b6 00             	movzbl (%eax),%eax
 226:	3c 39                	cmp    $0x39,%al
 228:	7e c8                	jle    1f2 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 22a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 22d:	c9                   	leave  
 22e:	c3                   	ret    

0000022f <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 22f:	55                   	push   %ebp
 230:	89 e5                	mov    %esp,%ebp
 232:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 235:	8b 45 08             	mov    0x8(%ebp),%eax
 238:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 23b:	8b 45 0c             	mov    0xc(%ebp),%eax
 23e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 241:	eb 13                	jmp    256 <memmove+0x27>
    *dst++ = *src++;
 243:	8b 45 f8             	mov    -0x8(%ebp),%eax
 246:	0f b6 10             	movzbl (%eax),%edx
 249:	8b 45 fc             	mov    -0x4(%ebp),%eax
 24c:	88 10                	mov    %dl,(%eax)
 24e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 252:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 256:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 25a:	0f 9f c0             	setg   %al
 25d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 261:	84 c0                	test   %al,%al
 263:	75 de                	jne    243 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 265:	8b 45 08             	mov    0x8(%ebp),%eax
}
 268:	c9                   	leave  
 269:	c3                   	ret    
 26a:	90                   	nop
 26b:	90                   	nop

0000026c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 26c:	b8 01 00 00 00       	mov    $0x1,%eax
 271:	cd 40                	int    $0x40
 273:	c3                   	ret    

00000274 <exit>:
SYSCALL(exit)
 274:	b8 02 00 00 00       	mov    $0x2,%eax
 279:	cd 40                	int    $0x40
 27b:	c3                   	ret    

0000027c <wait>:
SYSCALL(wait)
 27c:	b8 03 00 00 00       	mov    $0x3,%eax
 281:	cd 40                	int    $0x40
 283:	c3                   	ret    

00000284 <pipe>:
SYSCALL(pipe)
 284:	b8 04 00 00 00       	mov    $0x4,%eax
 289:	cd 40                	int    $0x40
 28b:	c3                   	ret    

0000028c <read>:
SYSCALL(read)
 28c:	b8 05 00 00 00       	mov    $0x5,%eax
 291:	cd 40                	int    $0x40
 293:	c3                   	ret    

00000294 <write>:
SYSCALL(write)
 294:	b8 10 00 00 00       	mov    $0x10,%eax
 299:	cd 40                	int    $0x40
 29b:	c3                   	ret    

0000029c <close>:
SYSCALL(close)
 29c:	b8 15 00 00 00       	mov    $0x15,%eax
 2a1:	cd 40                	int    $0x40
 2a3:	c3                   	ret    

000002a4 <kill>:
SYSCALL(kill)
 2a4:	b8 06 00 00 00       	mov    $0x6,%eax
 2a9:	cd 40                	int    $0x40
 2ab:	c3                   	ret    

000002ac <exec>:
SYSCALL(exec)
 2ac:	b8 07 00 00 00       	mov    $0x7,%eax
 2b1:	cd 40                	int    $0x40
 2b3:	c3                   	ret    

000002b4 <open>:
SYSCALL(open)
 2b4:	b8 0f 00 00 00       	mov    $0xf,%eax
 2b9:	cd 40                	int    $0x40
 2bb:	c3                   	ret    

000002bc <mknod>:
SYSCALL(mknod)
 2bc:	b8 11 00 00 00       	mov    $0x11,%eax
 2c1:	cd 40                	int    $0x40
 2c3:	c3                   	ret    

000002c4 <unlink>:
SYSCALL(unlink)
 2c4:	b8 12 00 00 00       	mov    $0x12,%eax
 2c9:	cd 40                	int    $0x40
 2cb:	c3                   	ret    

000002cc <fstat>:
SYSCALL(fstat)
 2cc:	b8 08 00 00 00       	mov    $0x8,%eax
 2d1:	cd 40                	int    $0x40
 2d3:	c3                   	ret    

000002d4 <link>:
SYSCALL(link)
 2d4:	b8 13 00 00 00       	mov    $0x13,%eax
 2d9:	cd 40                	int    $0x40
 2db:	c3                   	ret    

000002dc <mkdir>:
SYSCALL(mkdir)
 2dc:	b8 14 00 00 00       	mov    $0x14,%eax
 2e1:	cd 40                	int    $0x40
 2e3:	c3                   	ret    

000002e4 <chdir>:
SYSCALL(chdir)
 2e4:	b8 09 00 00 00       	mov    $0x9,%eax
 2e9:	cd 40                	int    $0x40
 2eb:	c3                   	ret    

000002ec <dup>:
SYSCALL(dup)
 2ec:	b8 0a 00 00 00       	mov    $0xa,%eax
 2f1:	cd 40                	int    $0x40
 2f3:	c3                   	ret    

000002f4 <getpid>:
SYSCALL(getpid)
 2f4:	b8 0b 00 00 00       	mov    $0xb,%eax
 2f9:	cd 40                	int    $0x40
 2fb:	c3                   	ret    

000002fc <sbrk>:
SYSCALL(sbrk)
 2fc:	b8 0c 00 00 00       	mov    $0xc,%eax
 301:	cd 40                	int    $0x40
 303:	c3                   	ret    

00000304 <sleep>:
SYSCALL(sleep)
 304:	b8 0d 00 00 00       	mov    $0xd,%eax
 309:	cd 40                	int    $0x40
 30b:	c3                   	ret    

0000030c <uptime>:
SYSCALL(uptime)
 30c:	b8 0e 00 00 00       	mov    $0xe,%eax
 311:	cd 40                	int    $0x40
 313:	c3                   	ret    

00000314 <procstat>:
SYSCALL(procstat)
 314:	b8 16 00 00 00       	mov    $0x16,%eax
 319:	cd 40                	int    $0x40
 31b:	c3                   	ret    

0000031c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 31c:	55                   	push   %ebp
 31d:	89 e5                	mov    %esp,%ebp
 31f:	83 ec 28             	sub    $0x28,%esp
 322:	8b 45 0c             	mov    0xc(%ebp),%eax
 325:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 328:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 32f:	00 
 330:	8d 45 f4             	lea    -0xc(%ebp),%eax
 333:	89 44 24 04          	mov    %eax,0x4(%esp)
 337:	8b 45 08             	mov    0x8(%ebp),%eax
 33a:	89 04 24             	mov    %eax,(%esp)
 33d:	e8 52 ff ff ff       	call   294 <write>
}
 342:	c9                   	leave  
 343:	c3                   	ret    

00000344 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 344:	55                   	push   %ebp
 345:	89 e5                	mov    %esp,%ebp
 347:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 34a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 351:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 355:	74 17                	je     36e <printint+0x2a>
 357:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 35b:	79 11                	jns    36e <printint+0x2a>
    neg = 1;
 35d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 364:	8b 45 0c             	mov    0xc(%ebp),%eax
 367:	f7 d8                	neg    %eax
 369:	89 45 ec             	mov    %eax,-0x14(%ebp)
 36c:	eb 06                	jmp    374 <printint+0x30>
  } else {
    x = xx;
 36e:	8b 45 0c             	mov    0xc(%ebp),%eax
 371:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 374:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 37b:	8b 4d 10             	mov    0x10(%ebp),%ecx
 37e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 381:	ba 00 00 00 00       	mov    $0x0,%edx
 386:	f7 f1                	div    %ecx
 388:	89 d0                	mov    %edx,%eax
 38a:	0f b6 90 c4 07 00 00 	movzbl 0x7c4(%eax),%edx
 391:	8d 45 dc             	lea    -0x24(%ebp),%eax
 394:	03 45 f4             	add    -0xc(%ebp),%eax
 397:	88 10                	mov    %dl,(%eax)
 399:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 39d:	8b 45 10             	mov    0x10(%ebp),%eax
 3a0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 3a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3a6:	ba 00 00 00 00       	mov    $0x0,%edx
 3ab:	f7 75 d4             	divl   -0x2c(%ebp)
 3ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3b1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 3b5:	75 c4                	jne    37b <printint+0x37>
  if(neg)
 3b7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3bb:	74 2a                	je     3e7 <printint+0xa3>
    buf[i++] = '-';
 3bd:	8d 45 dc             	lea    -0x24(%ebp),%eax
 3c0:	03 45 f4             	add    -0xc(%ebp),%eax
 3c3:	c6 00 2d             	movb   $0x2d,(%eax)
 3c6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 3ca:	eb 1b                	jmp    3e7 <printint+0xa3>
    putc(fd, buf[i]);
 3cc:	8d 45 dc             	lea    -0x24(%ebp),%eax
 3cf:	03 45 f4             	add    -0xc(%ebp),%eax
 3d2:	0f b6 00             	movzbl (%eax),%eax
 3d5:	0f be c0             	movsbl %al,%eax
 3d8:	89 44 24 04          	mov    %eax,0x4(%esp)
 3dc:	8b 45 08             	mov    0x8(%ebp),%eax
 3df:	89 04 24             	mov    %eax,(%esp)
 3e2:	e8 35 ff ff ff       	call   31c <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 3e7:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 3eb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 3ef:	79 db                	jns    3cc <printint+0x88>
    putc(fd, buf[i]);
}
 3f1:	c9                   	leave  
 3f2:	c3                   	ret    

000003f3 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 3f3:	55                   	push   %ebp
 3f4:	89 e5                	mov    %esp,%ebp
 3f6:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 3f9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 400:	8d 45 0c             	lea    0xc(%ebp),%eax
 403:	83 c0 04             	add    $0x4,%eax
 406:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 409:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 410:	e9 7e 01 00 00       	jmp    593 <printf+0x1a0>
    c = fmt[i] & 0xff;
 415:	8b 55 0c             	mov    0xc(%ebp),%edx
 418:	8b 45 f0             	mov    -0x10(%ebp),%eax
 41b:	8d 04 02             	lea    (%edx,%eax,1),%eax
 41e:	0f b6 00             	movzbl (%eax),%eax
 421:	0f be c0             	movsbl %al,%eax
 424:	25 ff 00 00 00       	and    $0xff,%eax
 429:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 42c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 430:	75 2c                	jne    45e <printf+0x6b>
      if(c == '%'){
 432:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 436:	75 0c                	jne    444 <printf+0x51>
        state = '%';
 438:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 43f:	e9 4b 01 00 00       	jmp    58f <printf+0x19c>
      } else {
        putc(fd, c);
 444:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 447:	0f be c0             	movsbl %al,%eax
 44a:	89 44 24 04          	mov    %eax,0x4(%esp)
 44e:	8b 45 08             	mov    0x8(%ebp),%eax
 451:	89 04 24             	mov    %eax,(%esp)
 454:	e8 c3 fe ff ff       	call   31c <putc>
 459:	e9 31 01 00 00       	jmp    58f <printf+0x19c>
      }
    } else if(state == '%'){
 45e:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 462:	0f 85 27 01 00 00    	jne    58f <printf+0x19c>
      if(c == 'd'){
 468:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 46c:	75 2d                	jne    49b <printf+0xa8>
        printint(fd, *ap, 10, 1);
 46e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 471:	8b 00                	mov    (%eax),%eax
 473:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 47a:	00 
 47b:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 482:	00 
 483:	89 44 24 04          	mov    %eax,0x4(%esp)
 487:	8b 45 08             	mov    0x8(%ebp),%eax
 48a:	89 04 24             	mov    %eax,(%esp)
 48d:	e8 b2 fe ff ff       	call   344 <printint>
        ap++;
 492:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 496:	e9 ed 00 00 00       	jmp    588 <printf+0x195>
      } else if(c == 'x' || c == 'p'){
 49b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 49f:	74 06                	je     4a7 <printf+0xb4>
 4a1:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 4a5:	75 2d                	jne    4d4 <printf+0xe1>
        printint(fd, *ap, 16, 0);
 4a7:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4aa:	8b 00                	mov    (%eax),%eax
 4ac:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 4b3:	00 
 4b4:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 4bb:	00 
 4bc:	89 44 24 04          	mov    %eax,0x4(%esp)
 4c0:	8b 45 08             	mov    0x8(%ebp),%eax
 4c3:	89 04 24             	mov    %eax,(%esp)
 4c6:	e8 79 fe ff ff       	call   344 <printint>
        ap++;
 4cb:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4cf:	e9 b4 00 00 00       	jmp    588 <printf+0x195>
      } else if(c == 's'){
 4d4:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 4d8:	75 46                	jne    520 <printf+0x12d>
        s = (char*)*ap;
 4da:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4dd:	8b 00                	mov    (%eax),%eax
 4df:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 4e2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 4e6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4ea:	75 27                	jne    513 <printf+0x120>
          s = "(null)";
 4ec:	c7 45 f4 bb 07 00 00 	movl   $0x7bb,-0xc(%ebp)
        while(*s != 0){
 4f3:	eb 1f                	jmp    514 <printf+0x121>
          putc(fd, *s);
 4f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4f8:	0f b6 00             	movzbl (%eax),%eax
 4fb:	0f be c0             	movsbl %al,%eax
 4fe:	89 44 24 04          	mov    %eax,0x4(%esp)
 502:	8b 45 08             	mov    0x8(%ebp),%eax
 505:	89 04 24             	mov    %eax,(%esp)
 508:	e8 0f fe ff ff       	call   31c <putc>
          s++;
 50d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 511:	eb 01                	jmp    514 <printf+0x121>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 513:	90                   	nop
 514:	8b 45 f4             	mov    -0xc(%ebp),%eax
 517:	0f b6 00             	movzbl (%eax),%eax
 51a:	84 c0                	test   %al,%al
 51c:	75 d7                	jne    4f5 <printf+0x102>
 51e:	eb 68                	jmp    588 <printf+0x195>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 520:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 524:	75 1d                	jne    543 <printf+0x150>
        putc(fd, *ap);
 526:	8b 45 e8             	mov    -0x18(%ebp),%eax
 529:	8b 00                	mov    (%eax),%eax
 52b:	0f be c0             	movsbl %al,%eax
 52e:	89 44 24 04          	mov    %eax,0x4(%esp)
 532:	8b 45 08             	mov    0x8(%ebp),%eax
 535:	89 04 24             	mov    %eax,(%esp)
 538:	e8 df fd ff ff       	call   31c <putc>
        ap++;
 53d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 541:	eb 45                	jmp    588 <printf+0x195>
      } else if(c == '%'){
 543:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 547:	75 17                	jne    560 <printf+0x16d>
        putc(fd, c);
 549:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 54c:	0f be c0             	movsbl %al,%eax
 54f:	89 44 24 04          	mov    %eax,0x4(%esp)
 553:	8b 45 08             	mov    0x8(%ebp),%eax
 556:	89 04 24             	mov    %eax,(%esp)
 559:	e8 be fd ff ff       	call   31c <putc>
 55e:	eb 28                	jmp    588 <printf+0x195>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 560:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 567:	00 
 568:	8b 45 08             	mov    0x8(%ebp),%eax
 56b:	89 04 24             	mov    %eax,(%esp)
 56e:	e8 a9 fd ff ff       	call   31c <putc>
        putc(fd, c);
 573:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 576:	0f be c0             	movsbl %al,%eax
 579:	89 44 24 04          	mov    %eax,0x4(%esp)
 57d:	8b 45 08             	mov    0x8(%ebp),%eax
 580:	89 04 24             	mov    %eax,(%esp)
 583:	e8 94 fd ff ff       	call   31c <putc>
      }
      state = 0;
 588:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 58f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 593:	8b 55 0c             	mov    0xc(%ebp),%edx
 596:	8b 45 f0             	mov    -0x10(%ebp),%eax
 599:	8d 04 02             	lea    (%edx,%eax,1),%eax
 59c:	0f b6 00             	movzbl (%eax),%eax
 59f:	84 c0                	test   %al,%al
 5a1:	0f 85 6e fe ff ff    	jne    415 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 5a7:	c9                   	leave  
 5a8:	c3                   	ret    
 5a9:	90                   	nop
 5aa:	90                   	nop
 5ab:	90                   	nop

000005ac <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5ac:	55                   	push   %ebp
 5ad:	89 e5                	mov    %esp,%ebp
 5af:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5b2:	8b 45 08             	mov    0x8(%ebp),%eax
 5b5:	83 e8 08             	sub    $0x8,%eax
 5b8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5bb:	a1 e0 07 00 00       	mov    0x7e0,%eax
 5c0:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5c3:	eb 24                	jmp    5e9 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5c8:	8b 00                	mov    (%eax),%eax
 5ca:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5cd:	77 12                	ja     5e1 <free+0x35>
 5cf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5d2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5d5:	77 24                	ja     5fb <free+0x4f>
 5d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5da:	8b 00                	mov    (%eax),%eax
 5dc:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 5df:	77 1a                	ja     5fb <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5e4:	8b 00                	mov    (%eax),%eax
 5e6:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5e9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5ec:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5ef:	76 d4                	jbe    5c5 <free+0x19>
 5f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5f4:	8b 00                	mov    (%eax),%eax
 5f6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 5f9:	76 ca                	jbe    5c5 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 5fb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5fe:	8b 40 04             	mov    0x4(%eax),%eax
 601:	c1 e0 03             	shl    $0x3,%eax
 604:	89 c2                	mov    %eax,%edx
 606:	03 55 f8             	add    -0x8(%ebp),%edx
 609:	8b 45 fc             	mov    -0x4(%ebp),%eax
 60c:	8b 00                	mov    (%eax),%eax
 60e:	39 c2                	cmp    %eax,%edx
 610:	75 24                	jne    636 <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 612:	8b 45 f8             	mov    -0x8(%ebp),%eax
 615:	8b 50 04             	mov    0x4(%eax),%edx
 618:	8b 45 fc             	mov    -0x4(%ebp),%eax
 61b:	8b 00                	mov    (%eax),%eax
 61d:	8b 40 04             	mov    0x4(%eax),%eax
 620:	01 c2                	add    %eax,%edx
 622:	8b 45 f8             	mov    -0x8(%ebp),%eax
 625:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 628:	8b 45 fc             	mov    -0x4(%ebp),%eax
 62b:	8b 00                	mov    (%eax),%eax
 62d:	8b 10                	mov    (%eax),%edx
 62f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 632:	89 10                	mov    %edx,(%eax)
 634:	eb 0a                	jmp    640 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 636:	8b 45 fc             	mov    -0x4(%ebp),%eax
 639:	8b 10                	mov    (%eax),%edx
 63b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 63e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 640:	8b 45 fc             	mov    -0x4(%ebp),%eax
 643:	8b 40 04             	mov    0x4(%eax),%eax
 646:	c1 e0 03             	shl    $0x3,%eax
 649:	03 45 fc             	add    -0x4(%ebp),%eax
 64c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 64f:	75 20                	jne    671 <free+0xc5>
    p->s.size += bp->s.size;
 651:	8b 45 fc             	mov    -0x4(%ebp),%eax
 654:	8b 50 04             	mov    0x4(%eax),%edx
 657:	8b 45 f8             	mov    -0x8(%ebp),%eax
 65a:	8b 40 04             	mov    0x4(%eax),%eax
 65d:	01 c2                	add    %eax,%edx
 65f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 662:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 665:	8b 45 f8             	mov    -0x8(%ebp),%eax
 668:	8b 10                	mov    (%eax),%edx
 66a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 66d:	89 10                	mov    %edx,(%eax)
 66f:	eb 08                	jmp    679 <free+0xcd>
  } else
    p->s.ptr = bp;
 671:	8b 45 fc             	mov    -0x4(%ebp),%eax
 674:	8b 55 f8             	mov    -0x8(%ebp),%edx
 677:	89 10                	mov    %edx,(%eax)
  freep = p;
 679:	8b 45 fc             	mov    -0x4(%ebp),%eax
 67c:	a3 e0 07 00 00       	mov    %eax,0x7e0
}
 681:	c9                   	leave  
 682:	c3                   	ret    

00000683 <morecore>:

static Header*
morecore(uint nu)
{
 683:	55                   	push   %ebp
 684:	89 e5                	mov    %esp,%ebp
 686:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 689:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 690:	77 07                	ja     699 <morecore+0x16>
    nu = 4096;
 692:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 699:	8b 45 08             	mov    0x8(%ebp),%eax
 69c:	c1 e0 03             	shl    $0x3,%eax
 69f:	89 04 24             	mov    %eax,(%esp)
 6a2:	e8 55 fc ff ff       	call   2fc <sbrk>
 6a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 6aa:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 6ae:	75 07                	jne    6b7 <morecore+0x34>
    return 0;
 6b0:	b8 00 00 00 00       	mov    $0x0,%eax
 6b5:	eb 22                	jmp    6d9 <morecore+0x56>
  hp = (Header*)p;
 6b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 6bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6c0:	8b 55 08             	mov    0x8(%ebp),%edx
 6c3:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 6c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6c9:	83 c0 08             	add    $0x8,%eax
 6cc:	89 04 24             	mov    %eax,(%esp)
 6cf:	e8 d8 fe ff ff       	call   5ac <free>
  return freep;
 6d4:	a1 e0 07 00 00       	mov    0x7e0,%eax
}
 6d9:	c9                   	leave  
 6da:	c3                   	ret    

000006db <malloc>:

void*
malloc(uint nbytes)
{
 6db:	55                   	push   %ebp
 6dc:	89 e5                	mov    %esp,%ebp
 6de:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 6e1:	8b 45 08             	mov    0x8(%ebp),%eax
 6e4:	83 c0 07             	add    $0x7,%eax
 6e7:	c1 e8 03             	shr    $0x3,%eax
 6ea:	83 c0 01             	add    $0x1,%eax
 6ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 6f0:	a1 e0 07 00 00       	mov    0x7e0,%eax
 6f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
 6f8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6fc:	75 23                	jne    721 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 6fe:	c7 45 f0 d8 07 00 00 	movl   $0x7d8,-0x10(%ebp)
 705:	8b 45 f0             	mov    -0x10(%ebp),%eax
 708:	a3 e0 07 00 00       	mov    %eax,0x7e0
 70d:	a1 e0 07 00 00       	mov    0x7e0,%eax
 712:	a3 d8 07 00 00       	mov    %eax,0x7d8
    base.s.size = 0;
 717:	c7 05 dc 07 00 00 00 	movl   $0x0,0x7dc
 71e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 721:	8b 45 f0             	mov    -0x10(%ebp),%eax
 724:	8b 00                	mov    (%eax),%eax
 726:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 729:	8b 45 f4             	mov    -0xc(%ebp),%eax
 72c:	8b 40 04             	mov    0x4(%eax),%eax
 72f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 732:	72 4d                	jb     781 <malloc+0xa6>
      if(p->s.size == nunits)
 734:	8b 45 f4             	mov    -0xc(%ebp),%eax
 737:	8b 40 04             	mov    0x4(%eax),%eax
 73a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 73d:	75 0c                	jne    74b <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 73f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 742:	8b 10                	mov    (%eax),%edx
 744:	8b 45 f0             	mov    -0x10(%ebp),%eax
 747:	89 10                	mov    %edx,(%eax)
 749:	eb 26                	jmp    771 <malloc+0x96>
      else {
        p->s.size -= nunits;
 74b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 74e:	8b 40 04             	mov    0x4(%eax),%eax
 751:	89 c2                	mov    %eax,%edx
 753:	2b 55 ec             	sub    -0x14(%ebp),%edx
 756:	8b 45 f4             	mov    -0xc(%ebp),%eax
 759:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 75c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 75f:	8b 40 04             	mov    0x4(%eax),%eax
 762:	c1 e0 03             	shl    $0x3,%eax
 765:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 768:	8b 45 f4             	mov    -0xc(%ebp),%eax
 76b:	8b 55 ec             	mov    -0x14(%ebp),%edx
 76e:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 771:	8b 45 f0             	mov    -0x10(%ebp),%eax
 774:	a3 e0 07 00 00       	mov    %eax,0x7e0
      return (void*)(p + 1);
 779:	8b 45 f4             	mov    -0xc(%ebp),%eax
 77c:	83 c0 08             	add    $0x8,%eax
 77f:	eb 38                	jmp    7b9 <malloc+0xde>
    }
    if(p == freep)
 781:	a1 e0 07 00 00       	mov    0x7e0,%eax
 786:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 789:	75 1b                	jne    7a6 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 78b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 78e:	89 04 24             	mov    %eax,(%esp)
 791:	e8 ed fe ff ff       	call   683 <morecore>
 796:	89 45 f4             	mov    %eax,-0xc(%ebp)
 799:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 79d:	75 07                	jne    7a6 <malloc+0xcb>
        return 0;
 79f:	b8 00 00 00 00       	mov    $0x0,%eax
 7a4:	eb 13                	jmp    7b9 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7af:	8b 00                	mov    (%eax),%eax
 7b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 7b4:	e9 70 ff ff ff       	jmp    729 <malloc+0x4e>
}
 7b9:	c9                   	leave  
 7ba:	c3                   	ret    
