
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
   c:	e8 e5 01 00 00       	call   1f6 <strlen>
  11:	89 44 24 08          	mov    %eax,0x8(%esp)
  15:	8b 45 0c             	mov    0xc(%ebp),%eax
  18:	89 44 24 04          	mov    %eax,0x4(%esp)
  1c:	8b 45 08             	mov    0x8(%ebp),%eax
  1f:	89 04 24             	mov    %eax,(%esp)
  22:	e8 b9 03 00 00       	call   3e0 <write>
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
  2f:	c7 44 24 04 68 04 00 	movl   $0x468,0x4(%esp)
  36:	00 
  37:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  3e:	e8 bd ff ff ff       	call   0 <printf>

  for(n=0; n<N; n++){
  43:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  4a:	eb 28                	jmp    74 <forktest+0x4b>
    pid = fork();
  4c:	e8 67 03 00 00       	call   3b8 <fork>
  51:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(pid < 0)
  54:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  58:	78 25                	js     7f <forktest+0x56>
      break;
    if(pid == 0)
  5a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  5e:	75 05                	jne    65 <forktest+0x3c>
      exit();
  60:	e8 5b 03 00 00       	call   3c0 <exit>
	else{
		if(n==5)
  65:	83 7d f4 05          	cmpl   $0x5,-0xc(%ebp)
  69:	75 05                	jne    70 <forktest+0x47>
			procstat();
  6b:	e8 f0 03 00 00       	call   460 <procstat>
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
			procstat();
	}
  }

//NUEVO FOR PARA QUE SALTE EL QUANTUM
  for(n=0; n<50000; n++){
  80:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  87:	eb 28                	jmp    b1 <forktest+0x88>
    pid = fork();
  89:	e8 2a 03 00 00       	call   3b8 <fork>
  8e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(pid < 0)
  91:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  95:	78 25                	js     bc <forktest+0x93>
      break;
    if(pid == 0)
  97:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  9b:	75 05                	jne    a2 <forktest+0x79>
      exit();
  9d:	e8 1e 03 00 00       	call   3c0 <exit>
	else{
		if(n==2)
  a2:	83 7d f4 02          	cmpl   $0x2,-0xc(%ebp)
  a6:	75 05                	jne    ad <forktest+0x84>
			procstat();
  a8:	e8 b3 03 00 00       	call   460 <procstat>
			procstat();
	}
  }

//NUEVO FOR PARA QUE SALTE EL QUANTUM
  for(n=0; n<50000; n++){
  ad:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  b1:	81 7d f4 4f c3 00 00 	cmpl   $0xc34f,-0xc(%ebp)
  b8:	7e cf                	jle    89 <forktest+0x60>
  ba:	eb 01                	jmp    bd <forktest+0x94>
    pid = fork();
    if(pid < 0)
      break;
  bc:	90                   	nop
		if(n==2)
			procstat();
	}
  }
 
  if(n == N){
  bd:	81 7d f4 e8 03 00 00 	cmpl   $0x3e8,-0xc(%ebp)
  c4:	75 47                	jne    10d <forktest+0xe4>
    printf(1, "fork claimed to work N times!\n", N);
  c6:	c7 44 24 08 e8 03 00 	movl   $0x3e8,0x8(%esp)
  cd:	00 
  ce:	c7 44 24 04 74 04 00 	movl   $0x474,0x4(%esp)
  d5:	00 
  d6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  dd:	e8 1e ff ff ff       	call   0 <printf>
    exit();
  e2:	e8 d9 02 00 00       	call   3c0 <exit>
  }
  
  for(; n > 0; n--){
    if(wait() < 0){
  e7:	e8 dc 02 00 00       	call   3c8 <wait>
  ec:	85 c0                	test   %eax,%eax
  ee:	79 19                	jns    109 <forktest+0xe0>
      printf(1, "wait stopped early\n");
  f0:	c7 44 24 04 93 04 00 	movl   $0x493,0x4(%esp)
  f7:	00 
  f8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  ff:	e8 fc fe ff ff       	call   0 <printf>
      exit();
 104:	e8 b7 02 00 00       	call   3c0 <exit>
  if(n == N){
    printf(1, "fork claimed to work N times!\n", N);
    exit();
  }
  
  for(; n > 0; n--){
 109:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 10d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 111:	7f d4                	jg     e7 <forktest+0xbe>
      printf(1, "wait stopped early\n");
      exit();
    }
  }
  
  if(wait() != -1){
 113:	e8 b0 02 00 00       	call   3c8 <wait>
 118:	83 f8 ff             	cmp    $0xffffffff,%eax
 11b:	74 19                	je     136 <forktest+0x10d>
    printf(1, "wait got too many\n");
 11d:	c7 44 24 04 a7 04 00 	movl   $0x4a7,0x4(%esp)
 124:	00 
 125:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 12c:	e8 cf fe ff ff       	call   0 <printf>
    exit();
 131:	e8 8a 02 00 00       	call   3c0 <exit>
  }
  
  printf(1, "fork test OK\n");
 136:	c7 44 24 04 ba 04 00 	movl   $0x4ba,0x4(%esp)
 13d:	00 
 13e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 145:	e8 b6 fe ff ff       	call   0 <printf>
}
 14a:	c9                   	leave  
 14b:	c3                   	ret    

0000014c <main>:

int
main(void)
{
 14c:	55                   	push   %ebp
 14d:	89 e5                	mov    %esp,%ebp
 14f:	83 e4 f0             	and    $0xfffffff0,%esp
  forktest();
 152:	e8 d2 fe ff ff       	call   29 <forktest>
  exit();
 157:	e8 64 02 00 00       	call   3c0 <exit>

0000015c <stosb>:
 15c:	55                   	push   %ebp
 15d:	89 e5                	mov    %esp,%ebp
 15f:	57                   	push   %edi
 160:	53                   	push   %ebx
 161:	8b 4d 08             	mov    0x8(%ebp),%ecx
 164:	8b 55 10             	mov    0x10(%ebp),%edx
 167:	8b 45 0c             	mov    0xc(%ebp),%eax
 16a:	89 cb                	mov    %ecx,%ebx
 16c:	89 df                	mov    %ebx,%edi
 16e:	89 d1                	mov    %edx,%ecx
 170:	fc                   	cld    
 171:	f3 aa                	rep stos %al,%es:(%edi)
 173:	89 ca                	mov    %ecx,%edx
 175:	89 fb                	mov    %edi,%ebx
 177:	89 5d 08             	mov    %ebx,0x8(%ebp)
 17a:	89 55 10             	mov    %edx,0x10(%ebp)
 17d:	5b                   	pop    %ebx
 17e:	5f                   	pop    %edi
 17f:	5d                   	pop    %ebp
 180:	c3                   	ret    

00000181 <strcpy>:
 181:	55                   	push   %ebp
 182:	89 e5                	mov    %esp,%ebp
 184:	83 ec 10             	sub    $0x10,%esp
 187:	8b 45 08             	mov    0x8(%ebp),%eax
 18a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 18d:	90                   	nop
 18e:	8b 45 0c             	mov    0xc(%ebp),%eax
 191:	0f b6 10             	movzbl (%eax),%edx
 194:	8b 45 08             	mov    0x8(%ebp),%eax
 197:	88 10                	mov    %dl,(%eax)
 199:	8b 45 08             	mov    0x8(%ebp),%eax
 19c:	0f b6 00             	movzbl (%eax),%eax
 19f:	84 c0                	test   %al,%al
 1a1:	0f 95 c0             	setne  %al
 1a4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1a8:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 1ac:	84 c0                	test   %al,%al
 1ae:	75 de                	jne    18e <strcpy+0xd>
 1b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 1b3:	c9                   	leave  
 1b4:	c3                   	ret    

000001b5 <strcmp>:
 1b5:	55                   	push   %ebp
 1b6:	89 e5                	mov    %esp,%ebp
 1b8:	eb 08                	jmp    1c2 <strcmp+0xd>
 1ba:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1be:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 1c2:	8b 45 08             	mov    0x8(%ebp),%eax
 1c5:	0f b6 00             	movzbl (%eax),%eax
 1c8:	84 c0                	test   %al,%al
 1ca:	74 10                	je     1dc <strcmp+0x27>
 1cc:	8b 45 08             	mov    0x8(%ebp),%eax
 1cf:	0f b6 10             	movzbl (%eax),%edx
 1d2:	8b 45 0c             	mov    0xc(%ebp),%eax
 1d5:	0f b6 00             	movzbl (%eax),%eax
 1d8:	38 c2                	cmp    %al,%dl
 1da:	74 de                	je     1ba <strcmp+0x5>
 1dc:	8b 45 08             	mov    0x8(%ebp),%eax
 1df:	0f b6 00             	movzbl (%eax),%eax
 1e2:	0f b6 d0             	movzbl %al,%edx
 1e5:	8b 45 0c             	mov    0xc(%ebp),%eax
 1e8:	0f b6 00             	movzbl (%eax),%eax
 1eb:	0f b6 c0             	movzbl %al,%eax
 1ee:	89 d1                	mov    %edx,%ecx
 1f0:	29 c1                	sub    %eax,%ecx
 1f2:	89 c8                	mov    %ecx,%eax
 1f4:	5d                   	pop    %ebp
 1f5:	c3                   	ret    

000001f6 <strlen>:
 1f6:	55                   	push   %ebp
 1f7:	89 e5                	mov    %esp,%ebp
 1f9:	83 ec 10             	sub    $0x10,%esp
 1fc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 203:	eb 04                	jmp    209 <strlen+0x13>
 205:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 209:	8b 45 fc             	mov    -0x4(%ebp),%eax
 20c:	03 45 08             	add    0x8(%ebp),%eax
 20f:	0f b6 00             	movzbl (%eax),%eax
 212:	84 c0                	test   %al,%al
 214:	75 ef                	jne    205 <strlen+0xf>
 216:	8b 45 fc             	mov    -0x4(%ebp),%eax
 219:	c9                   	leave  
 21a:	c3                   	ret    

0000021b <memset>:
 21b:	55                   	push   %ebp
 21c:	89 e5                	mov    %esp,%ebp
 21e:	83 ec 0c             	sub    $0xc,%esp
 221:	8b 45 10             	mov    0x10(%ebp),%eax
 224:	89 44 24 08          	mov    %eax,0x8(%esp)
 228:	8b 45 0c             	mov    0xc(%ebp),%eax
 22b:	89 44 24 04          	mov    %eax,0x4(%esp)
 22f:	8b 45 08             	mov    0x8(%ebp),%eax
 232:	89 04 24             	mov    %eax,(%esp)
 235:	e8 22 ff ff ff       	call   15c <stosb>
 23a:	8b 45 08             	mov    0x8(%ebp),%eax
 23d:	c9                   	leave  
 23e:	c3                   	ret    

0000023f <strchr>:
 23f:	55                   	push   %ebp
 240:	89 e5                	mov    %esp,%ebp
 242:	83 ec 04             	sub    $0x4,%esp
 245:	8b 45 0c             	mov    0xc(%ebp),%eax
 248:	88 45 fc             	mov    %al,-0x4(%ebp)
 24b:	eb 14                	jmp    261 <strchr+0x22>
 24d:	8b 45 08             	mov    0x8(%ebp),%eax
 250:	0f b6 00             	movzbl (%eax),%eax
 253:	3a 45 fc             	cmp    -0x4(%ebp),%al
 256:	75 05                	jne    25d <strchr+0x1e>
 258:	8b 45 08             	mov    0x8(%ebp),%eax
 25b:	eb 13                	jmp    270 <strchr+0x31>
 25d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 261:	8b 45 08             	mov    0x8(%ebp),%eax
 264:	0f b6 00             	movzbl (%eax),%eax
 267:	84 c0                	test   %al,%al
 269:	75 e2                	jne    24d <strchr+0xe>
 26b:	b8 00 00 00 00       	mov    $0x0,%eax
 270:	c9                   	leave  
 271:	c3                   	ret    

00000272 <gets>:
 272:	55                   	push   %ebp
 273:	89 e5                	mov    %esp,%ebp
 275:	83 ec 28             	sub    $0x28,%esp
 278:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 27f:	eb 44                	jmp    2c5 <gets+0x53>
 281:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 288:	00 
 289:	8d 45 ef             	lea    -0x11(%ebp),%eax
 28c:	89 44 24 04          	mov    %eax,0x4(%esp)
 290:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 297:	e8 3c 01 00 00       	call   3d8 <read>
 29c:	89 45 f0             	mov    %eax,-0x10(%ebp)
 29f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 2a3:	7e 2d                	jle    2d2 <gets+0x60>
 2a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2a8:	03 45 08             	add    0x8(%ebp),%eax
 2ab:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 2af:	88 10                	mov    %dl,(%eax)
 2b1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 2b5:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2b9:	3c 0a                	cmp    $0xa,%al
 2bb:	74 16                	je     2d3 <gets+0x61>
 2bd:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2c1:	3c 0d                	cmp    $0xd,%al
 2c3:	74 0e                	je     2d3 <gets+0x61>
 2c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2c8:	83 c0 01             	add    $0x1,%eax
 2cb:	3b 45 0c             	cmp    0xc(%ebp),%eax
 2ce:	7c b1                	jl     281 <gets+0xf>
 2d0:	eb 01                	jmp    2d3 <gets+0x61>
 2d2:	90                   	nop
 2d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2d6:	03 45 08             	add    0x8(%ebp),%eax
 2d9:	c6 00 00             	movb   $0x0,(%eax)
 2dc:	8b 45 08             	mov    0x8(%ebp),%eax
 2df:	c9                   	leave  
 2e0:	c3                   	ret    

000002e1 <stat>:
 2e1:	55                   	push   %ebp
 2e2:	89 e5                	mov    %esp,%ebp
 2e4:	83 ec 28             	sub    $0x28,%esp
 2e7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 2ee:	00 
 2ef:	8b 45 08             	mov    0x8(%ebp),%eax
 2f2:	89 04 24             	mov    %eax,(%esp)
 2f5:	e8 06 01 00 00       	call   400 <open>
 2fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
 2fd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 301:	79 07                	jns    30a <stat+0x29>
 303:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 308:	eb 23                	jmp    32d <stat+0x4c>
 30a:	8b 45 0c             	mov    0xc(%ebp),%eax
 30d:	89 44 24 04          	mov    %eax,0x4(%esp)
 311:	8b 45 f4             	mov    -0xc(%ebp),%eax
 314:	89 04 24             	mov    %eax,(%esp)
 317:	e8 fc 00 00 00       	call   418 <fstat>
 31c:	89 45 f0             	mov    %eax,-0x10(%ebp)
 31f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 322:	89 04 24             	mov    %eax,(%esp)
 325:	e8 be 00 00 00       	call   3e8 <close>
 32a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 32d:	c9                   	leave  
 32e:	c3                   	ret    

0000032f <atoi>:
 32f:	55                   	push   %ebp
 330:	89 e5                	mov    %esp,%ebp
 332:	83 ec 10             	sub    $0x10,%esp
 335:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 33c:	eb 24                	jmp    362 <atoi+0x33>
 33e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 341:	89 d0                	mov    %edx,%eax
 343:	c1 e0 02             	shl    $0x2,%eax
 346:	01 d0                	add    %edx,%eax
 348:	01 c0                	add    %eax,%eax
 34a:	89 c2                	mov    %eax,%edx
 34c:	8b 45 08             	mov    0x8(%ebp),%eax
 34f:	0f b6 00             	movzbl (%eax),%eax
 352:	0f be c0             	movsbl %al,%eax
 355:	8d 04 02             	lea    (%edx,%eax,1),%eax
 358:	83 e8 30             	sub    $0x30,%eax
 35b:	89 45 fc             	mov    %eax,-0x4(%ebp)
 35e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 362:	8b 45 08             	mov    0x8(%ebp),%eax
 365:	0f b6 00             	movzbl (%eax),%eax
 368:	3c 2f                	cmp    $0x2f,%al
 36a:	7e 0a                	jle    376 <atoi+0x47>
 36c:	8b 45 08             	mov    0x8(%ebp),%eax
 36f:	0f b6 00             	movzbl (%eax),%eax
 372:	3c 39                	cmp    $0x39,%al
 374:	7e c8                	jle    33e <atoi+0xf>
 376:	8b 45 fc             	mov    -0x4(%ebp),%eax
 379:	c9                   	leave  
 37a:	c3                   	ret    

0000037b <memmove>:
 37b:	55                   	push   %ebp
 37c:	89 e5                	mov    %esp,%ebp
 37e:	83 ec 10             	sub    $0x10,%esp
 381:	8b 45 08             	mov    0x8(%ebp),%eax
 384:	89 45 fc             	mov    %eax,-0x4(%ebp)
 387:	8b 45 0c             	mov    0xc(%ebp),%eax
 38a:	89 45 f8             	mov    %eax,-0x8(%ebp)
 38d:	eb 13                	jmp    3a2 <memmove+0x27>
 38f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 392:	0f b6 10             	movzbl (%eax),%edx
 395:	8b 45 fc             	mov    -0x4(%ebp),%eax
 398:	88 10                	mov    %dl,(%eax)
 39a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 39e:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 3a2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 3a6:	0f 9f c0             	setg   %al
 3a9:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 3ad:	84 c0                	test   %al,%al
 3af:	75 de                	jne    38f <memmove+0x14>
 3b1:	8b 45 08             	mov    0x8(%ebp),%eax
 3b4:	c9                   	leave  
 3b5:	c3                   	ret    
 3b6:	90                   	nop
 3b7:	90                   	nop

000003b8 <fork>:
 3b8:	b8 01 00 00 00       	mov    $0x1,%eax
 3bd:	cd 40                	int    $0x40
 3bf:	c3                   	ret    

000003c0 <exit>:
 3c0:	b8 02 00 00 00       	mov    $0x2,%eax
 3c5:	cd 40                	int    $0x40
 3c7:	c3                   	ret    

000003c8 <wait>:
 3c8:	b8 03 00 00 00       	mov    $0x3,%eax
 3cd:	cd 40                	int    $0x40
 3cf:	c3                   	ret    

000003d0 <pipe>:
 3d0:	b8 04 00 00 00       	mov    $0x4,%eax
 3d5:	cd 40                	int    $0x40
 3d7:	c3                   	ret    

000003d8 <read>:
 3d8:	b8 05 00 00 00       	mov    $0x5,%eax
 3dd:	cd 40                	int    $0x40
 3df:	c3                   	ret    

000003e0 <write>:
 3e0:	b8 10 00 00 00       	mov    $0x10,%eax
 3e5:	cd 40                	int    $0x40
 3e7:	c3                   	ret    

000003e8 <close>:
 3e8:	b8 15 00 00 00       	mov    $0x15,%eax
 3ed:	cd 40                	int    $0x40
 3ef:	c3                   	ret    

000003f0 <kill>:
 3f0:	b8 06 00 00 00       	mov    $0x6,%eax
 3f5:	cd 40                	int    $0x40
 3f7:	c3                   	ret    

000003f8 <exec>:
 3f8:	b8 07 00 00 00       	mov    $0x7,%eax
 3fd:	cd 40                	int    $0x40
 3ff:	c3                   	ret    

00000400 <open>:
 400:	b8 0f 00 00 00       	mov    $0xf,%eax
 405:	cd 40                	int    $0x40
 407:	c3                   	ret    

00000408 <mknod>:
 408:	b8 11 00 00 00       	mov    $0x11,%eax
 40d:	cd 40                	int    $0x40
 40f:	c3                   	ret    

00000410 <unlink>:
 410:	b8 12 00 00 00       	mov    $0x12,%eax
 415:	cd 40                	int    $0x40
 417:	c3                   	ret    

00000418 <fstat>:
 418:	b8 08 00 00 00       	mov    $0x8,%eax
 41d:	cd 40                	int    $0x40
 41f:	c3                   	ret    

00000420 <link>:
 420:	b8 13 00 00 00       	mov    $0x13,%eax
 425:	cd 40                	int    $0x40
 427:	c3                   	ret    

00000428 <mkdir>:
 428:	b8 14 00 00 00       	mov    $0x14,%eax
 42d:	cd 40                	int    $0x40
 42f:	c3                   	ret    

00000430 <chdir>:
 430:	b8 09 00 00 00       	mov    $0x9,%eax
 435:	cd 40                	int    $0x40
 437:	c3                   	ret    

00000438 <dup>:
 438:	b8 0a 00 00 00       	mov    $0xa,%eax
 43d:	cd 40                	int    $0x40
 43f:	c3                   	ret    

00000440 <getpid>:
 440:	b8 0b 00 00 00       	mov    $0xb,%eax
 445:	cd 40                	int    $0x40
 447:	c3                   	ret    

00000448 <sbrk>:
 448:	b8 0c 00 00 00       	mov    $0xc,%eax
 44d:	cd 40                	int    $0x40
 44f:	c3                   	ret    

00000450 <sleep>:
 450:	b8 0d 00 00 00       	mov    $0xd,%eax
 455:	cd 40                	int    $0x40
 457:	c3                   	ret    

00000458 <uptime>:
 458:	b8 0e 00 00 00       	mov    $0xe,%eax
 45d:	cd 40                	int    $0x40
 45f:	c3                   	ret    

00000460 <procstat>:
 460:	b8 16 00 00 00       	mov    $0x16,%eax
 465:	cd 40                	int    $0x40
 467:	c3                   	ret    
