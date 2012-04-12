
_forktest:     file format elf32-i386


Disassembly of section .text:

00000000 <printf>:

#define N  1000

void
printf(int fd, char *s, ...)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 18             	sub    $0x18,%esp
  write(fd, s, strlen(s));
   6:	8b 45 0c             	mov    0xc(%ebp),%eax
   9:	89 04 24             	mov    %eax,(%esp)
   c:	e8 a9 01 00 00       	call   1ba <strlen>
  11:	89 44 24 08          	mov    %eax,0x8(%esp)
  15:	8b 45 0c             	mov    0xc(%ebp),%eax
  18:	89 44 24 04          	mov    %eax,0x4(%esp)
  1c:	8b 45 08             	mov    0x8(%ebp),%eax
  1f:	89 04 24             	mov    %eax,(%esp)
  22:	e8 7d 03 00 00       	call   3a4 <write>
}
  27:	c9                   	leave  
  28:	c3                   	ret    

00000029 <forktest>:

void
forktest(void)
{
  29:	55                   	push   %ebp
  2a:	89 e5                	mov    %esp,%ebp
  2c:	83 ec 28             	sub    $0x28,%esp
  int n, pid;

  printf(1, "fork test\n");
  2f:	c7 44 24 04 2c 04 00 	movl   $0x42c,0x4(%esp)
  36:	00 
  37:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  3e:	e8 bd ff ff ff       	call   0 <printf>

  for(n=0; n<N; n++){
  43:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  4a:	eb 28                	jmp    74 <forktest+0x4b>
    pid = fork();
  4c:	e8 2b 03 00 00       	call   37c <fork>
  51:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(pid < 0)
  54:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  58:	78 25                	js     7f <forktest+0x56>
      break;
    if(pid == 0)
  5a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  5e:	75 05                	jne    65 <forktest+0x3c>
      exit();
  60:	e8 1f 03 00 00       	call   384 <exit>
	else{
		if(n==5)
  65:	83 7d f4 05          	cmpl   $0x5,-0xc(%ebp)
  69:	75 05                	jne    70 <forktest+0x47>
			procstat();
  6b:	e8 b4 03 00 00       	call   424 <procstat>
{
  int n, pid;

  printf(1, "fork test\n");

  for(n=0; n<N; n++){
  70:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  74:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
  7b:	7e cf                	jle    4c <forktest+0x23>
  7d:	eb 01                	jmp    80 <forktest+0x57>
    pid = fork();
    if(pid < 0)
      break;
  7f:	90                   	nop
		if(n==5)
			procstat();
	}
  }
  
  if(n == N){
  80:	81 7d f4 e8 03 00 00 	cmpl   $0x3e8,-0xc(%ebp)
  87:	75 47                	jne    d0 <forktest+0xa7>
    printf(1, "fork claimed to work N times!\n", N);
  89:	c7 44 24 08 e8 03 00 	movl   $0x3e8,0x8(%esp)
  90:	00 
  91:	c7 44 24 04 38 04 00 	movl   $0x438,0x4(%esp)
  98:	00 
  99:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  a0:	e8 5b ff ff ff       	call   0 <printf>
    exit();
  a5:	e8 da 02 00 00       	call   384 <exit>
  }
  
  for(; n > 0; n--){
    if(wait() < 0){
  aa:	e8 dd 02 00 00       	call   38c <wait>
  af:	85 c0                	test   %eax,%eax
  b1:	79 19                	jns    cc <forktest+0xa3>
      printf(1, "wait stopped early\n");
  b3:	c7 44 24 04 57 04 00 	movl   $0x457,0x4(%esp)
  ba:	00 
  bb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  c2:	e8 39 ff ff ff       	call   0 <printf>
      exit();
  c7:	e8 b8 02 00 00       	call   384 <exit>
  if(n == N){
    printf(1, "fork claimed to work N times!\n", N);
    exit();
  }
  
  for(; n > 0; n--){
  cc:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  d0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  d4:	7f d4                	jg     aa <forktest+0x81>
      printf(1, "wait stopped early\n");
      exit();
    }
  }
  
  if(wait() != -1){
  d6:	e8 b1 02 00 00       	call   38c <wait>
  db:	83 f8 ff             	cmp    $0xffffffff,%eax
  de:	74 19                	je     f9 <forktest+0xd0>
    printf(1, "wait got too many\n");
  e0:	c7 44 24 04 6b 04 00 	movl   $0x46b,0x4(%esp)
  e7:	00 
  e8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  ef:	e8 0c ff ff ff       	call   0 <printf>
    exit();
  f4:	e8 8b 02 00 00       	call   384 <exit>
  }
  
  printf(1, "fork test OK\n");
  f9:	c7 44 24 04 7e 04 00 	movl   $0x47e,0x4(%esp)
 100:	00 
 101:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 108:	e8 f3 fe ff ff       	call   0 <printf>
}
 10d:	c9                   	leave  
 10e:	c3                   	ret    

0000010f <main>:

int
main(void)
{
 10f:	55                   	push   %ebp
 110:	89 e5                	mov    %esp,%ebp
 112:	83 e4 f0             	and    $0xfffffff0,%esp
  forktest();
 115:	e8 0f ff ff ff       	call   29 <forktest>
  exit();
 11a:	e8 65 02 00 00       	call   384 <exit>
 11f:	90                   	nop

00000120 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 120:	55                   	push   %ebp
 121:	89 e5                	mov    %esp,%ebp
 123:	57                   	push   %edi
 124:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 125:	8b 4d 08             	mov    0x8(%ebp),%ecx
 128:	8b 55 10             	mov    0x10(%ebp),%edx
 12b:	8b 45 0c             	mov    0xc(%ebp),%eax
 12e:	89 cb                	mov    %ecx,%ebx
 130:	89 df                	mov    %ebx,%edi
 132:	89 d1                	mov    %edx,%ecx
 134:	fc                   	cld    
 135:	f3 aa                	rep stos %al,%es:(%edi)
 137:	89 ca                	mov    %ecx,%edx
 139:	89 fb                	mov    %edi,%ebx
 13b:	89 5d 08             	mov    %ebx,0x8(%ebp)
 13e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 141:	5b                   	pop    %ebx
 142:	5f                   	pop    %edi
 143:	5d                   	pop    %ebp
 144:	c3                   	ret    

00000145 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 145:	55                   	push   %ebp
 146:	89 e5                	mov    %esp,%ebp
 148:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 14b:	8b 45 08             	mov    0x8(%ebp),%eax
 14e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 151:	90                   	nop
 152:	8b 45 0c             	mov    0xc(%ebp),%eax
 155:	0f b6 10             	movzbl (%eax),%edx
 158:	8b 45 08             	mov    0x8(%ebp),%eax
 15b:	88 10                	mov    %dl,(%eax)
 15d:	8b 45 08             	mov    0x8(%ebp),%eax
 160:	0f b6 00             	movzbl (%eax),%eax
 163:	84 c0                	test   %al,%al
 165:	0f 95 c0             	setne  %al
 168:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 16c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 170:	84 c0                	test   %al,%al
 172:	75 de                	jne    152 <strcpy+0xd>
    ;
  return os;
 174:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 177:	c9                   	leave  
 178:	c3                   	ret    

00000179 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 179:	55                   	push   %ebp
 17a:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 17c:	eb 08                	jmp    186 <strcmp+0xd>
    p++, q++;
 17e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 182:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 186:	8b 45 08             	mov    0x8(%ebp),%eax
 189:	0f b6 00             	movzbl (%eax),%eax
 18c:	84 c0                	test   %al,%al
 18e:	74 10                	je     1a0 <strcmp+0x27>
 190:	8b 45 08             	mov    0x8(%ebp),%eax
 193:	0f b6 10             	movzbl (%eax),%edx
 196:	8b 45 0c             	mov    0xc(%ebp),%eax
 199:	0f b6 00             	movzbl (%eax),%eax
 19c:	38 c2                	cmp    %al,%dl
 19e:	74 de                	je     17e <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 1a0:	8b 45 08             	mov    0x8(%ebp),%eax
 1a3:	0f b6 00             	movzbl (%eax),%eax
 1a6:	0f b6 d0             	movzbl %al,%edx
 1a9:	8b 45 0c             	mov    0xc(%ebp),%eax
 1ac:	0f b6 00             	movzbl (%eax),%eax
 1af:	0f b6 c0             	movzbl %al,%eax
 1b2:	89 d1                	mov    %edx,%ecx
 1b4:	29 c1                	sub    %eax,%ecx
 1b6:	89 c8                	mov    %ecx,%eax
}
 1b8:	5d                   	pop    %ebp
 1b9:	c3                   	ret    

000001ba <strlen>:

uint
strlen(char *s)
{
 1ba:	55                   	push   %ebp
 1bb:	89 e5                	mov    %esp,%ebp
 1bd:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1c0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1c7:	eb 04                	jmp    1cd <strlen+0x13>
 1c9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 1d0:	03 45 08             	add    0x8(%ebp),%eax
 1d3:	0f b6 00             	movzbl (%eax),%eax
 1d6:	84 c0                	test   %al,%al
 1d8:	75 ef                	jne    1c9 <strlen+0xf>
    ;
  return n;
 1da:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1dd:	c9                   	leave  
 1de:	c3                   	ret    

000001df <memset>:

void*
memset(void *dst, int c, uint n)
{
 1df:	55                   	push   %ebp
 1e0:	89 e5                	mov    %esp,%ebp
 1e2:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 1e5:	8b 45 10             	mov    0x10(%ebp),%eax
 1e8:	89 44 24 08          	mov    %eax,0x8(%esp)
 1ec:	8b 45 0c             	mov    0xc(%ebp),%eax
 1ef:	89 44 24 04          	mov    %eax,0x4(%esp)
 1f3:	8b 45 08             	mov    0x8(%ebp),%eax
 1f6:	89 04 24             	mov    %eax,(%esp)
 1f9:	e8 22 ff ff ff       	call   120 <stosb>
  return dst;
 1fe:	8b 45 08             	mov    0x8(%ebp),%eax
}
 201:	c9                   	leave  
 202:	c3                   	ret    

00000203 <strchr>:

char*
strchr(const char *s, char c)
{
 203:	55                   	push   %ebp
 204:	89 e5                	mov    %esp,%ebp
 206:	83 ec 04             	sub    $0x4,%esp
 209:	8b 45 0c             	mov    0xc(%ebp),%eax
 20c:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 20f:	eb 14                	jmp    225 <strchr+0x22>
    if(*s == c)
 211:	8b 45 08             	mov    0x8(%ebp),%eax
 214:	0f b6 00             	movzbl (%eax),%eax
 217:	3a 45 fc             	cmp    -0x4(%ebp),%al
 21a:	75 05                	jne    221 <strchr+0x1e>
      return (char*)s;
 21c:	8b 45 08             	mov    0x8(%ebp),%eax
 21f:	eb 13                	jmp    234 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 221:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 225:	8b 45 08             	mov    0x8(%ebp),%eax
 228:	0f b6 00             	movzbl (%eax),%eax
 22b:	84 c0                	test   %al,%al
 22d:	75 e2                	jne    211 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 22f:	b8 00 00 00 00       	mov    $0x0,%eax
}
 234:	c9                   	leave  
 235:	c3                   	ret    

00000236 <gets>:

char*
gets(char *buf, int max)
{
 236:	55                   	push   %ebp
 237:	89 e5                	mov    %esp,%ebp
 239:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 23c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 243:	eb 44                	jmp    289 <gets+0x53>
    cc = read(0, &c, 1);
 245:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 24c:	00 
 24d:	8d 45 ef             	lea    -0x11(%ebp),%eax
 250:	89 44 24 04          	mov    %eax,0x4(%esp)
 254:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 25b:	e8 3c 01 00 00       	call   39c <read>
 260:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 263:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 267:	7e 2d                	jle    296 <gets+0x60>
      break;
    buf[i++] = c;
 269:	8b 45 f4             	mov    -0xc(%ebp),%eax
 26c:	03 45 08             	add    0x8(%ebp),%eax
 26f:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 273:	88 10                	mov    %dl,(%eax)
 275:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 279:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 27d:	3c 0a                	cmp    $0xa,%al
 27f:	74 16                	je     297 <gets+0x61>
 281:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 285:	3c 0d                	cmp    $0xd,%al
 287:	74 0e                	je     297 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 289:	8b 45 f4             	mov    -0xc(%ebp),%eax
 28c:	83 c0 01             	add    $0x1,%eax
 28f:	3b 45 0c             	cmp    0xc(%ebp),%eax
 292:	7c b1                	jl     245 <gets+0xf>
 294:	eb 01                	jmp    297 <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 296:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 297:	8b 45 f4             	mov    -0xc(%ebp),%eax
 29a:	03 45 08             	add    0x8(%ebp),%eax
 29d:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 2a0:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2a3:	c9                   	leave  
 2a4:	c3                   	ret    

000002a5 <stat>:

int
stat(char *n, struct stat *st)
{
 2a5:	55                   	push   %ebp
 2a6:	89 e5                	mov    %esp,%ebp
 2a8:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2ab:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 2b2:	00 
 2b3:	8b 45 08             	mov    0x8(%ebp),%eax
 2b6:	89 04 24             	mov    %eax,(%esp)
 2b9:	e8 06 01 00 00       	call   3c4 <open>
 2be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2c1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2c5:	79 07                	jns    2ce <stat+0x29>
    return -1;
 2c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2cc:	eb 23                	jmp    2f1 <stat+0x4c>
  r = fstat(fd, st);
 2ce:	8b 45 0c             	mov    0xc(%ebp),%eax
 2d1:	89 44 24 04          	mov    %eax,0x4(%esp)
 2d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2d8:	89 04 24             	mov    %eax,(%esp)
 2db:	e8 fc 00 00 00       	call   3dc <fstat>
 2e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2e6:	89 04 24             	mov    %eax,(%esp)
 2e9:	e8 be 00 00 00       	call   3ac <close>
  return r;
 2ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2f1:	c9                   	leave  
 2f2:	c3                   	ret    

000002f3 <atoi>:

int
atoi(const char *s)
{
 2f3:	55                   	push   %ebp
 2f4:	89 e5                	mov    %esp,%ebp
 2f6:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2f9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 300:	eb 24                	jmp    326 <atoi+0x33>
    n = n*10 + *s++ - '0';
 302:	8b 55 fc             	mov    -0x4(%ebp),%edx
 305:	89 d0                	mov    %edx,%eax
 307:	c1 e0 02             	shl    $0x2,%eax
 30a:	01 d0                	add    %edx,%eax
 30c:	01 c0                	add    %eax,%eax
 30e:	89 c2                	mov    %eax,%edx
 310:	8b 45 08             	mov    0x8(%ebp),%eax
 313:	0f b6 00             	movzbl (%eax),%eax
 316:	0f be c0             	movsbl %al,%eax
 319:	8d 04 02             	lea    (%edx,%eax,1),%eax
 31c:	83 e8 30             	sub    $0x30,%eax
 31f:	89 45 fc             	mov    %eax,-0x4(%ebp)
 322:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 326:	8b 45 08             	mov    0x8(%ebp),%eax
 329:	0f b6 00             	movzbl (%eax),%eax
 32c:	3c 2f                	cmp    $0x2f,%al
 32e:	7e 0a                	jle    33a <atoi+0x47>
 330:	8b 45 08             	mov    0x8(%ebp),%eax
 333:	0f b6 00             	movzbl (%eax),%eax
 336:	3c 39                	cmp    $0x39,%al
 338:	7e c8                	jle    302 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 33a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 33d:	c9                   	leave  
 33e:	c3                   	ret    

0000033f <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 33f:	55                   	push   %ebp
 340:	89 e5                	mov    %esp,%ebp
 342:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 345:	8b 45 08             	mov    0x8(%ebp),%eax
 348:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 34b:	8b 45 0c             	mov    0xc(%ebp),%eax
 34e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 351:	eb 13                	jmp    366 <memmove+0x27>
    *dst++ = *src++;
 353:	8b 45 f8             	mov    -0x8(%ebp),%eax
 356:	0f b6 10             	movzbl (%eax),%edx
 359:	8b 45 fc             	mov    -0x4(%ebp),%eax
 35c:	88 10                	mov    %dl,(%eax)
 35e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 362:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 366:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 36a:	0f 9f c0             	setg   %al
 36d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 371:	84 c0                	test   %al,%al
 373:	75 de                	jne    353 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 375:	8b 45 08             	mov    0x8(%ebp),%eax
}
 378:	c9                   	leave  
 379:	c3                   	ret    
 37a:	90                   	nop
 37b:	90                   	nop

0000037c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 37c:	b8 01 00 00 00       	mov    $0x1,%eax
 381:	cd 40                	int    $0x40
 383:	c3                   	ret    

00000384 <exit>:
SYSCALL(exit)
 384:	b8 02 00 00 00       	mov    $0x2,%eax
 389:	cd 40                	int    $0x40
 38b:	c3                   	ret    

0000038c <wait>:
SYSCALL(wait)
 38c:	b8 03 00 00 00       	mov    $0x3,%eax
 391:	cd 40                	int    $0x40
 393:	c3                   	ret    

00000394 <pipe>:
SYSCALL(pipe)
 394:	b8 04 00 00 00       	mov    $0x4,%eax
 399:	cd 40                	int    $0x40
 39b:	c3                   	ret    

0000039c <read>:
SYSCALL(read)
 39c:	b8 05 00 00 00       	mov    $0x5,%eax
 3a1:	cd 40                	int    $0x40
 3a3:	c3                   	ret    

000003a4 <write>:
SYSCALL(write)
 3a4:	b8 10 00 00 00       	mov    $0x10,%eax
 3a9:	cd 40                	int    $0x40
 3ab:	c3                   	ret    

000003ac <close>:
SYSCALL(close)
 3ac:	b8 15 00 00 00       	mov    $0x15,%eax
 3b1:	cd 40                	int    $0x40
 3b3:	c3                   	ret    

000003b4 <kill>:
SYSCALL(kill)
 3b4:	b8 06 00 00 00       	mov    $0x6,%eax
 3b9:	cd 40                	int    $0x40
 3bb:	c3                   	ret    

000003bc <exec>:
SYSCALL(exec)
 3bc:	b8 07 00 00 00       	mov    $0x7,%eax
 3c1:	cd 40                	int    $0x40
 3c3:	c3                   	ret    

000003c4 <open>:
SYSCALL(open)
 3c4:	b8 0f 00 00 00       	mov    $0xf,%eax
 3c9:	cd 40                	int    $0x40
 3cb:	c3                   	ret    

000003cc <mknod>:
SYSCALL(mknod)
 3cc:	b8 11 00 00 00       	mov    $0x11,%eax
 3d1:	cd 40                	int    $0x40
 3d3:	c3                   	ret    

000003d4 <unlink>:
SYSCALL(unlink)
 3d4:	b8 12 00 00 00       	mov    $0x12,%eax
 3d9:	cd 40                	int    $0x40
 3db:	c3                   	ret    

000003dc <fstat>:
SYSCALL(fstat)
 3dc:	b8 08 00 00 00       	mov    $0x8,%eax
 3e1:	cd 40                	int    $0x40
 3e3:	c3                   	ret    

000003e4 <link>:
SYSCALL(link)
 3e4:	b8 13 00 00 00       	mov    $0x13,%eax
 3e9:	cd 40                	int    $0x40
 3eb:	c3                   	ret    

000003ec <mkdir>:
SYSCALL(mkdir)
 3ec:	b8 14 00 00 00       	mov    $0x14,%eax
 3f1:	cd 40                	int    $0x40
 3f3:	c3                   	ret    

000003f4 <chdir>:
SYSCALL(chdir)
 3f4:	b8 09 00 00 00       	mov    $0x9,%eax
 3f9:	cd 40                	int    $0x40
 3fb:	c3                   	ret    

000003fc <dup>:
SYSCALL(dup)
 3fc:	b8 0a 00 00 00       	mov    $0xa,%eax
 401:	cd 40                	int    $0x40
 403:	c3                   	ret    

00000404 <getpid>:
SYSCALL(getpid)
 404:	b8 0b 00 00 00       	mov    $0xb,%eax
 409:	cd 40                	int    $0x40
 40b:	c3                   	ret    

0000040c <sbrk>:
SYSCALL(sbrk)
 40c:	b8 0c 00 00 00       	mov    $0xc,%eax
 411:	cd 40                	int    $0x40
 413:	c3                   	ret    

00000414 <sleep>:
SYSCALL(sleep)
 414:	b8 0d 00 00 00       	mov    $0xd,%eax
 419:	cd 40                	int    $0x40
 41b:	c3                   	ret    

0000041c <uptime>:
SYSCALL(uptime)
 41c:	b8 0e 00 00 00       	mov    $0xe,%eax
 421:	cd 40                	int    $0x40
 423:	c3                   	ret    

00000424 <procstat>:
SYSCALL(procstat)
 424:	b8 16 00 00 00       	mov    $0x16,%eax
 429:	cd 40                	int    $0x40
 42b:	c3                   	ret    
