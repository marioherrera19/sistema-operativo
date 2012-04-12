
_sh:     file format elf32-i386


Disassembly of section .text:

00000000 <runcmd>:
struct cmd *parsecmd(char*);

// Execute cmd.  Never returns.
void
runcmd(struct cmd *cmd)
{
       0:	55                   	push   %ebp
       1:	89 e5                	mov    %esp,%ebp
       3:	83 ec 38             	sub    $0x38,%esp
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
       6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
       a:	75 05                	jne    11 <runcmd+0x11>
    exit();
       c:	e8 57 0f 00 00       	call   f68 <exit>
  
  switch(cmd->type){
      11:	8b 45 08             	mov    0x8(%ebp),%eax
      14:	8b 00                	mov    (%eax),%eax
      16:	83 f8 05             	cmp    $0x5,%eax
      19:	77 09                	ja     24 <runcmd+0x24>
      1b:	8b 04 85 dc 14 00 00 	mov    0x14dc(,%eax,4),%eax
      22:	ff e0                	jmp    *%eax
  default:
    panic("runcmd");
      24:	c7 04 24 b0 14 00 00 	movl   $0x14b0,(%esp)
      2b:	e8 2c 03 00 00       	call   35c <panic>

  case EXEC:
    ecmd = (struct execcmd*)cmd;
      30:	8b 45 08             	mov    0x8(%ebp),%eax
      33:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ecmd->argv[0] == 0)
      36:	8b 45 f4             	mov    -0xc(%ebp),%eax
      39:	8b 40 04             	mov    0x4(%eax),%eax
      3c:	85 c0                	test   %eax,%eax
      3e:	75 05                	jne    45 <runcmd+0x45>
      exit();
      40:	e8 23 0f 00 00       	call   f68 <exit>
    exec(ecmd->argv[0], ecmd->argv);
      45:	8b 45 f4             	mov    -0xc(%ebp),%eax
      48:	8d 50 04             	lea    0x4(%eax),%edx
      4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
      4e:	8b 40 04             	mov    0x4(%eax),%eax
      51:	89 54 24 04          	mov    %edx,0x4(%esp)
      55:	89 04 24             	mov    %eax,(%esp)
      58:	e8 43 0f 00 00       	call   fa0 <exec>
    printf(2, "exec %s failed\n", ecmd->argv[0]);
      5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
      60:	8b 40 04             	mov    0x4(%eax),%eax
      63:	89 44 24 08          	mov    %eax,0x8(%esp)
      67:	c7 44 24 04 b7 14 00 	movl   $0x14b7,0x4(%esp)
      6e:	00 
      6f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      76:	e8 6c 10 00 00       	call   10e7 <printf>
    break;
      7b:	e9 86 01 00 00       	jmp    206 <runcmd+0x206>

  case REDIR:
    rcmd = (struct redircmd*)cmd;
      80:	8b 45 08             	mov    0x8(%ebp),%eax
      83:	89 45 f0             	mov    %eax,-0x10(%ebp)
    close(rcmd->fd);
      86:	8b 45 f0             	mov    -0x10(%ebp),%eax
      89:	8b 40 14             	mov    0x14(%eax),%eax
      8c:	89 04 24             	mov    %eax,(%esp)
      8f:	e8 fc 0e 00 00       	call   f90 <close>
    if(open(rcmd->file, rcmd->mode) < 0){
      94:	8b 45 f0             	mov    -0x10(%ebp),%eax
      97:	8b 50 10             	mov    0x10(%eax),%edx
      9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
      9d:	8b 40 08             	mov    0x8(%eax),%eax
      a0:	89 54 24 04          	mov    %edx,0x4(%esp)
      a4:	89 04 24             	mov    %eax,(%esp)
      a7:	e8 fc 0e 00 00       	call   fa8 <open>
      ac:	85 c0                	test   %eax,%eax
      ae:	79 23                	jns    d3 <runcmd+0xd3>
      printf(2, "open %s failed\n", rcmd->file);
      b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
      b3:	8b 40 08             	mov    0x8(%eax),%eax
      b6:	89 44 24 08          	mov    %eax,0x8(%esp)
      ba:	c7 44 24 04 c7 14 00 	movl   $0x14c7,0x4(%esp)
      c1:	00 
      c2:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      c9:	e8 19 10 00 00       	call   10e7 <printf>
      exit();
      ce:	e8 95 0e 00 00       	call   f68 <exit>
    }
    runcmd(rcmd->cmd);
      d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
      d6:	8b 40 04             	mov    0x4(%eax),%eax
      d9:	89 04 24             	mov    %eax,(%esp)
      dc:	e8 1f ff ff ff       	call   0 <runcmd>
    break;
      e1:	e9 20 01 00 00       	jmp    206 <runcmd+0x206>

  case LIST:
    lcmd = (struct listcmd*)cmd;
      e6:	8b 45 08             	mov    0x8(%ebp),%eax
      e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(fork1() == 0)
      ec:	e8 91 02 00 00       	call   382 <fork1>
      f1:	85 c0                	test   %eax,%eax
      f3:	75 0e                	jne    103 <runcmd+0x103>
      runcmd(lcmd->left);
      f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
      f8:	8b 40 04             	mov    0x4(%eax),%eax
      fb:	89 04 24             	mov    %eax,(%esp)
      fe:	e8 fd fe ff ff       	call   0 <runcmd>
    wait();
     103:	e8 68 0e 00 00       	call   f70 <wait>
    runcmd(lcmd->right);
     108:	8b 45 ec             	mov    -0x14(%ebp),%eax
     10b:	8b 40 08             	mov    0x8(%eax),%eax
     10e:	89 04 24             	mov    %eax,(%esp)
     111:	e8 ea fe ff ff       	call   0 <runcmd>
    break;
     116:	e9 eb 00 00 00       	jmp    206 <runcmd+0x206>

  case PIPE:
    pcmd = (struct pipecmd*)cmd;
     11b:	8b 45 08             	mov    0x8(%ebp),%eax
     11e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pipe(p) < 0)
     121:	8d 45 dc             	lea    -0x24(%ebp),%eax
     124:	89 04 24             	mov    %eax,(%esp)
     127:	e8 4c 0e 00 00       	call   f78 <pipe>
     12c:	85 c0                	test   %eax,%eax
     12e:	79 0c                	jns    13c <runcmd+0x13c>
      panic("pipe");
     130:	c7 04 24 d7 14 00 00 	movl   $0x14d7,(%esp)
     137:	e8 20 02 00 00       	call   35c <panic>
    if(fork1() == 0){
     13c:	e8 41 02 00 00       	call   382 <fork1>
     141:	85 c0                	test   %eax,%eax
     143:	75 3b                	jne    180 <runcmd+0x180>
      close(1);
     145:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     14c:	e8 3f 0e 00 00       	call   f90 <close>
      dup(p[1]);
     151:	8b 45 e0             	mov    -0x20(%ebp),%eax
     154:	89 04 24             	mov    %eax,(%esp)
     157:	e8 84 0e 00 00       	call   fe0 <dup>
      close(p[0]);
     15c:	8b 45 dc             	mov    -0x24(%ebp),%eax
     15f:	89 04 24             	mov    %eax,(%esp)
     162:	e8 29 0e 00 00       	call   f90 <close>
      close(p[1]);
     167:	8b 45 e0             	mov    -0x20(%ebp),%eax
     16a:	89 04 24             	mov    %eax,(%esp)
     16d:	e8 1e 0e 00 00       	call   f90 <close>
      runcmd(pcmd->left);
     172:	8b 45 e8             	mov    -0x18(%ebp),%eax
     175:	8b 40 04             	mov    0x4(%eax),%eax
     178:	89 04 24             	mov    %eax,(%esp)
     17b:	e8 80 fe ff ff       	call   0 <runcmd>
    }
    if(fork1() == 0){
     180:	e8 fd 01 00 00       	call   382 <fork1>
     185:	85 c0                	test   %eax,%eax
     187:	75 3b                	jne    1c4 <runcmd+0x1c4>
      close(0);
     189:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     190:	e8 fb 0d 00 00       	call   f90 <close>
      dup(p[0]);
     195:	8b 45 dc             	mov    -0x24(%ebp),%eax
     198:	89 04 24             	mov    %eax,(%esp)
     19b:	e8 40 0e 00 00       	call   fe0 <dup>
      close(p[0]);
     1a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
     1a3:	89 04 24             	mov    %eax,(%esp)
     1a6:	e8 e5 0d 00 00       	call   f90 <close>
      close(p[1]);
     1ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
     1ae:	89 04 24             	mov    %eax,(%esp)
     1b1:	e8 da 0d 00 00       	call   f90 <close>
      runcmd(pcmd->right);
     1b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
     1b9:	8b 40 08             	mov    0x8(%eax),%eax
     1bc:	89 04 24             	mov    %eax,(%esp)
     1bf:	e8 3c fe ff ff       	call   0 <runcmd>
    }
    close(p[0]);
     1c4:	8b 45 dc             	mov    -0x24(%ebp),%eax
     1c7:	89 04 24             	mov    %eax,(%esp)
     1ca:	e8 c1 0d 00 00       	call   f90 <close>
    close(p[1]);
     1cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
     1d2:	89 04 24             	mov    %eax,(%esp)
     1d5:	e8 b6 0d 00 00       	call   f90 <close>
    wait();
     1da:	e8 91 0d 00 00       	call   f70 <wait>
    wait();
     1df:	e8 8c 0d 00 00       	call   f70 <wait>
    break;
     1e4:	eb 20                	jmp    206 <runcmd+0x206>
    
  case BACK:
    bcmd = (struct backcmd*)cmd;
     1e6:	8b 45 08             	mov    0x8(%ebp),%eax
     1e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(fork1() == 0)
     1ec:	e8 91 01 00 00       	call   382 <fork1>
     1f1:	85 c0                	test   %eax,%eax
     1f3:	75 10                	jne    205 <runcmd+0x205>
      runcmd(bcmd->cmd);
     1f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     1f8:	8b 40 04             	mov    0x4(%eax),%eax
     1fb:	89 04 24             	mov    %eax,(%esp)
     1fe:	e8 fd fd ff ff       	call   0 <runcmd>
    break;
     203:	eb 01                	jmp    206 <runcmd+0x206>
     205:	90                   	nop
  }
  exit();
     206:	e8 5d 0d 00 00       	call   f68 <exit>

0000020b <getcmd>:
}

int
getcmd(char *buf, int nbuf)
{
     20b:	55                   	push   %ebp
     20c:	89 e5                	mov    %esp,%ebp
     20e:	83 ec 18             	sub    $0x18,%esp
  printf(2, "$ ");
     211:	c7 44 24 04 f4 14 00 	movl   $0x14f4,0x4(%esp)
     218:	00 
     219:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     220:	e8 c2 0e 00 00       	call   10e7 <printf>
  memset(buf, 0, nbuf);
     225:	8b 45 0c             	mov    0xc(%ebp),%eax
     228:	89 44 24 08          	mov    %eax,0x8(%esp)
     22c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     233:	00 
     234:	8b 45 08             	mov    0x8(%ebp),%eax
     237:	89 04 24             	mov    %eax,(%esp)
     23a:	e8 84 0b 00 00       	call   dc3 <memset>
  gets(buf, nbuf);
     23f:	8b 45 0c             	mov    0xc(%ebp),%eax
     242:	89 44 24 04          	mov    %eax,0x4(%esp)
     246:	8b 45 08             	mov    0x8(%ebp),%eax
     249:	89 04 24             	mov    %eax,(%esp)
     24c:	e8 c9 0b 00 00       	call   e1a <gets>
  if(buf[0] == 0) // EOF
     251:	8b 45 08             	mov    0x8(%ebp),%eax
     254:	0f b6 00             	movzbl (%eax),%eax
     257:	84 c0                	test   %al,%al
     259:	75 07                	jne    262 <getcmd+0x57>
    return -1;
     25b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     260:	eb 05                	jmp    267 <getcmd+0x5c>
  return 0;
     262:	b8 00 00 00 00       	mov    $0x0,%eax
}
     267:	c9                   	leave  
     268:	c3                   	ret    

00000269 <main>:

int
main(void)
{
     269:	55                   	push   %ebp
     26a:	89 e5                	mov    %esp,%ebp
     26c:	83 e4 f0             	and    $0xfffffff0,%esp
     26f:	83 ec 20             	sub    $0x20,%esp
  static char buf[100];
  int fd;
  
  // Assumes three file descriptors open.
  while((fd = open("console", O_RDWR)) >= 0){
     272:	eb 19                	jmp    28d <main+0x24>
    if(fd >= 3){
     274:	83 7c 24 1c 02       	cmpl   $0x2,0x1c(%esp)
     279:	7e 12                	jle    28d <main+0x24>
      close(fd);
     27b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
     27f:	89 04 24             	mov    %eax,(%esp)
     282:	e8 09 0d 00 00       	call   f90 <close>
      break;
     287:	90                   	nop
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     288:	e9 ae 00 00 00       	jmp    33b <main+0xd2>
{
  static char buf[100];
  int fd;
  
  // Assumes three file descriptors open.
  while((fd = open("console", O_RDWR)) >= 0){
     28d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
     294:	00 
     295:	c7 04 24 f7 14 00 00 	movl   $0x14f7,(%esp)
     29c:	e8 07 0d 00 00       	call   fa8 <open>
     2a1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
     2a5:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
     2aa:	79 c8                	jns    274 <main+0xb>
      break;
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     2ac:	e9 8a 00 00 00       	jmp    33b <main+0xd2>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     2b1:	0f b6 05 e0 15 00 00 	movzbl 0x15e0,%eax
     2b8:	3c 63                	cmp    $0x63,%al
     2ba:	75 5a                	jne    316 <main+0xad>
     2bc:	0f b6 05 e1 15 00 00 	movzbl 0x15e1,%eax
     2c3:	3c 64                	cmp    $0x64,%al
     2c5:	75 4f                	jne    316 <main+0xad>
     2c7:	0f b6 05 e2 15 00 00 	movzbl 0x15e2,%eax
     2ce:	3c 20                	cmp    $0x20,%al
     2d0:	75 44                	jne    316 <main+0xad>
      // Clumsy but will have to do for now.
      // Chdir has no effect on the parent if run in the child.
      buf[strlen(buf)-1] = 0;  // chop \n
     2d2:	c7 04 24 e0 15 00 00 	movl   $0x15e0,(%esp)
     2d9:	e8 c0 0a 00 00       	call   d9e <strlen>
     2de:	83 e8 01             	sub    $0x1,%eax
     2e1:	c6 80 e0 15 00 00 00 	movb   $0x0,0x15e0(%eax)
      if(chdir(buf+3) < 0)
     2e8:	c7 04 24 e3 15 00 00 	movl   $0x15e3,(%esp)
     2ef:	e8 e4 0c 00 00       	call   fd8 <chdir>
     2f4:	85 c0                	test   %eax,%eax
     2f6:	79 42                	jns    33a <main+0xd1>
        printf(2, "cannot cd %s\n", buf+3);
     2f8:	c7 44 24 08 e3 15 00 	movl   $0x15e3,0x8(%esp)
     2ff:	00 
     300:	c7 44 24 04 ff 14 00 	movl   $0x14ff,0x4(%esp)
     307:	00 
     308:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     30f:	e8 d3 0d 00 00       	call   10e7 <printf>
      continue;
     314:	eb 25                	jmp    33b <main+0xd2>
    }
    if(fork1() == 0)
     316:	e8 67 00 00 00       	call   382 <fork1>
     31b:	85 c0                	test   %eax,%eax
     31d:	75 14                	jne    333 <main+0xca>
      runcmd(parsecmd(buf));
     31f:	c7 04 24 e0 15 00 00 	movl   $0x15e0,(%esp)
     326:	e8 cc 03 00 00       	call   6f7 <parsecmd>
     32b:	89 04 24             	mov    %eax,(%esp)
     32e:	e8 cd fc ff ff       	call   0 <runcmd>
    wait();
     333:	e8 38 0c 00 00       	call   f70 <wait>
     338:	eb 01                	jmp    33b <main+0xd2>
      // Clumsy but will have to do for now.
      // Chdir has no effect on the parent if run in the child.
      buf[strlen(buf)-1] = 0;  // chop \n
      if(chdir(buf+3) < 0)
        printf(2, "cannot cd %s\n", buf+3);
      continue;
     33a:	90                   	nop
      break;
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     33b:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
     342:	00 
     343:	c7 04 24 e0 15 00 00 	movl   $0x15e0,(%esp)
     34a:	e8 bc fe ff ff       	call   20b <getcmd>
     34f:	85 c0                	test   %eax,%eax
     351:	0f 89 5a ff ff ff    	jns    2b1 <main+0x48>
    }
    if(fork1() == 0)
      runcmd(parsecmd(buf));
    wait();
  }
  exit();
     357:	e8 0c 0c 00 00       	call   f68 <exit>

0000035c <panic>:
}

void
panic(char *s)
{
     35c:	55                   	push   %ebp
     35d:	89 e5                	mov    %esp,%ebp
     35f:	83 ec 18             	sub    $0x18,%esp
  printf(2, "%s\n", s);
     362:	8b 45 08             	mov    0x8(%ebp),%eax
     365:	89 44 24 08          	mov    %eax,0x8(%esp)
     369:	c7 44 24 04 0d 15 00 	movl   $0x150d,0x4(%esp)
     370:	00 
     371:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     378:	e8 6a 0d 00 00       	call   10e7 <printf>
  exit();
     37d:	e8 e6 0b 00 00       	call   f68 <exit>

00000382 <fork1>:
}

int
fork1(void)
{
     382:	55                   	push   %ebp
     383:	89 e5                	mov    %esp,%ebp
     385:	83 ec 28             	sub    $0x28,%esp
  int pid;
  
  pid = fork();
     388:	e8 d3 0b 00 00       	call   f60 <fork>
     38d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pid == -1)
     390:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
     394:	75 0c                	jne    3a2 <fork1+0x20>
    panic("fork");
     396:	c7 04 24 11 15 00 00 	movl   $0x1511,(%esp)
     39d:	e8 ba ff ff ff       	call   35c <panic>
  return pid;
     3a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     3a5:	c9                   	leave  
     3a6:	c3                   	ret    

000003a7 <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
     3a7:	55                   	push   %ebp
     3a8:	89 e5                	mov    %esp,%ebp
     3aa:	83 ec 28             	sub    $0x28,%esp
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     3ad:	c7 04 24 54 00 00 00 	movl   $0x54,(%esp)
     3b4:	e8 16 10 00 00       	call   13cf <malloc>
     3b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     3bc:	c7 44 24 08 54 00 00 	movl   $0x54,0x8(%esp)
     3c3:	00 
     3c4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     3cb:	00 
     3cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
     3cf:	89 04 24             	mov    %eax,(%esp)
     3d2:	e8 ec 09 00 00       	call   dc3 <memset>
  cmd->type = EXEC;
     3d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
     3da:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  return (struct cmd*)cmd;
     3e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     3e3:	c9                   	leave  
     3e4:	c3                   	ret    

000003e5 <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     3e5:	55                   	push   %ebp
     3e6:	89 e5                	mov    %esp,%ebp
     3e8:	83 ec 28             	sub    $0x28,%esp
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
     3eb:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
     3f2:	e8 d8 0f 00 00       	call   13cf <malloc>
     3f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     3fa:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
     401:	00 
     402:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     409:	00 
     40a:	8b 45 f4             	mov    -0xc(%ebp),%eax
     40d:	89 04 24             	mov    %eax,(%esp)
     410:	e8 ae 09 00 00       	call   dc3 <memset>
  cmd->type = REDIR;
     415:	8b 45 f4             	mov    -0xc(%ebp),%eax
     418:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  cmd->cmd = subcmd;
     41e:	8b 45 f4             	mov    -0xc(%ebp),%eax
     421:	8b 55 08             	mov    0x8(%ebp),%edx
     424:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->file = file;
     427:	8b 45 f4             	mov    -0xc(%ebp),%eax
     42a:	8b 55 0c             	mov    0xc(%ebp),%edx
     42d:	89 50 08             	mov    %edx,0x8(%eax)
  cmd->efile = efile;
     430:	8b 45 f4             	mov    -0xc(%ebp),%eax
     433:	8b 55 10             	mov    0x10(%ebp),%edx
     436:	89 50 0c             	mov    %edx,0xc(%eax)
  cmd->mode = mode;
     439:	8b 45 f4             	mov    -0xc(%ebp),%eax
     43c:	8b 55 14             	mov    0x14(%ebp),%edx
     43f:	89 50 10             	mov    %edx,0x10(%eax)
  cmd->fd = fd;
     442:	8b 45 f4             	mov    -0xc(%ebp),%eax
     445:	8b 55 18             	mov    0x18(%ebp),%edx
     448:	89 50 14             	mov    %edx,0x14(%eax)
  return (struct cmd*)cmd;
     44b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     44e:	c9                   	leave  
     44f:	c3                   	ret    

00000450 <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
     450:	55                   	push   %ebp
     451:	89 e5                	mov    %esp,%ebp
     453:	83 ec 28             	sub    $0x28,%esp
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
     456:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
     45d:	e8 6d 0f 00 00       	call   13cf <malloc>
     462:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     465:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
     46c:	00 
     46d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     474:	00 
     475:	8b 45 f4             	mov    -0xc(%ebp),%eax
     478:	89 04 24             	mov    %eax,(%esp)
     47b:	e8 43 09 00 00       	call   dc3 <memset>
  cmd->type = PIPE;
     480:	8b 45 f4             	mov    -0xc(%ebp),%eax
     483:	c7 00 03 00 00 00    	movl   $0x3,(%eax)
  cmd->left = left;
     489:	8b 45 f4             	mov    -0xc(%ebp),%eax
     48c:	8b 55 08             	mov    0x8(%ebp),%edx
     48f:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->right = right;
     492:	8b 45 f4             	mov    -0xc(%ebp),%eax
     495:	8b 55 0c             	mov    0xc(%ebp),%edx
     498:	89 50 08             	mov    %edx,0x8(%eax)
  return (struct cmd*)cmd;
     49b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     49e:	c9                   	leave  
     49f:	c3                   	ret    

000004a0 <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
     4a0:	55                   	push   %ebp
     4a1:	89 e5                	mov    %esp,%ebp
     4a3:	83 ec 28             	sub    $0x28,%esp
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     4a6:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
     4ad:	e8 1d 0f 00 00       	call   13cf <malloc>
     4b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     4b5:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
     4bc:	00 
     4bd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     4c4:	00 
     4c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4c8:	89 04 24             	mov    %eax,(%esp)
     4cb:	e8 f3 08 00 00       	call   dc3 <memset>
  cmd->type = LIST;
     4d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4d3:	c7 00 04 00 00 00    	movl   $0x4,(%eax)
  cmd->left = left;
     4d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4dc:	8b 55 08             	mov    0x8(%ebp),%edx
     4df:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->right = right;
     4e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4e5:	8b 55 0c             	mov    0xc(%ebp),%edx
     4e8:	89 50 08             	mov    %edx,0x8(%eax)
  return (struct cmd*)cmd;
     4eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     4ee:	c9                   	leave  
     4ef:	c3                   	ret    

000004f0 <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
     4f0:	55                   	push   %ebp
     4f1:	89 e5                	mov    %esp,%ebp
     4f3:	83 ec 28             	sub    $0x28,%esp
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     4f6:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
     4fd:	e8 cd 0e 00 00       	call   13cf <malloc>
     502:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     505:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
     50c:	00 
     50d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     514:	00 
     515:	8b 45 f4             	mov    -0xc(%ebp),%eax
     518:	89 04 24             	mov    %eax,(%esp)
     51b:	e8 a3 08 00 00       	call   dc3 <memset>
  cmd->type = BACK;
     520:	8b 45 f4             	mov    -0xc(%ebp),%eax
     523:	c7 00 05 00 00 00    	movl   $0x5,(%eax)
  cmd->cmd = subcmd;
     529:	8b 45 f4             	mov    -0xc(%ebp),%eax
     52c:	8b 55 08             	mov    0x8(%ebp),%edx
     52f:	89 50 04             	mov    %edx,0x4(%eax)
  return (struct cmd*)cmd;
     532:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     535:	c9                   	leave  
     536:	c3                   	ret    

00000537 <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
     537:	55                   	push   %ebp
     538:	89 e5                	mov    %esp,%ebp
     53a:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int ret;
  
  s = *ps;
     53d:	8b 45 08             	mov    0x8(%ebp),%eax
     540:	8b 00                	mov    (%eax),%eax
     542:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(s < es && strchr(whitespace, *s))
     545:	eb 04                	jmp    54b <gettoken+0x14>
    s++;
     547:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
{
  char *s;
  int ret;
  
  s = *ps;
  while(s < es && strchr(whitespace, *s))
     54b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     54e:	3b 45 0c             	cmp    0xc(%ebp),%eax
     551:	73 1d                	jae    570 <gettoken+0x39>
     553:	8b 45 f4             	mov    -0xc(%ebp),%eax
     556:	0f b6 00             	movzbl (%eax),%eax
     559:	0f be c0             	movsbl %al,%eax
     55c:	89 44 24 04          	mov    %eax,0x4(%esp)
     560:	c7 04 24 a8 15 00 00 	movl   $0x15a8,(%esp)
     567:	e8 7b 08 00 00       	call   de7 <strchr>
     56c:	85 c0                	test   %eax,%eax
     56e:	75 d7                	jne    547 <gettoken+0x10>
    s++;
  if(q)
     570:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
     574:	74 08                	je     57e <gettoken+0x47>
    *q = s;
     576:	8b 45 10             	mov    0x10(%ebp),%eax
     579:	8b 55 f4             	mov    -0xc(%ebp),%edx
     57c:	89 10                	mov    %edx,(%eax)
  ret = *s;
     57e:	8b 45 f4             	mov    -0xc(%ebp),%eax
     581:	0f b6 00             	movzbl (%eax),%eax
     584:	0f be c0             	movsbl %al,%eax
     587:	89 45 f0             	mov    %eax,-0x10(%ebp)
  switch(*s){
     58a:	8b 45 f4             	mov    -0xc(%ebp),%eax
     58d:	0f b6 00             	movzbl (%eax),%eax
     590:	0f be c0             	movsbl %al,%eax
     593:	83 f8 3c             	cmp    $0x3c,%eax
     596:	7f 1e                	jg     5b6 <gettoken+0x7f>
     598:	83 f8 3b             	cmp    $0x3b,%eax
     59b:	7d 23                	jge    5c0 <gettoken+0x89>
     59d:	83 f8 29             	cmp    $0x29,%eax
     5a0:	7f 3f                	jg     5e1 <gettoken+0xaa>
     5a2:	83 f8 28             	cmp    $0x28,%eax
     5a5:	7d 19                	jge    5c0 <gettoken+0x89>
     5a7:	85 c0                	test   %eax,%eax
     5a9:	0f 84 83 00 00 00    	je     632 <gettoken+0xfb>
     5af:	83 f8 26             	cmp    $0x26,%eax
     5b2:	74 0c                	je     5c0 <gettoken+0x89>
     5b4:	eb 2b                	jmp    5e1 <gettoken+0xaa>
     5b6:	83 f8 3e             	cmp    $0x3e,%eax
     5b9:	74 0b                	je     5c6 <gettoken+0x8f>
     5bb:	83 f8 7c             	cmp    $0x7c,%eax
     5be:	75 21                	jne    5e1 <gettoken+0xaa>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
     5c0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    break;
     5c4:	eb 76                	jmp    63c <gettoken+0x105>
  case '>':
    s++;
     5c6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(*s == '>'){
     5ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
     5cd:	0f b6 00             	movzbl (%eax),%eax
     5d0:	3c 3e                	cmp    $0x3e,%al
     5d2:	75 61                	jne    635 <gettoken+0xfe>
      ret = '+';
     5d4:	c7 45 f0 2b 00 00 00 	movl   $0x2b,-0x10(%ebp)
      s++;
     5db:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    }
    break;
     5df:	eb 5b                	jmp    63c <gettoken+0x105>
  default:
    ret = 'a';
     5e1:	c7 45 f0 61 00 00 00 	movl   $0x61,-0x10(%ebp)
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     5e8:	eb 04                	jmp    5ee <gettoken+0xb7>
      s++;
     5ea:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      s++;
    }
    break;
  default:
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     5ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
     5f1:	3b 45 0c             	cmp    0xc(%ebp),%eax
     5f4:	73 42                	jae    638 <gettoken+0x101>
     5f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
     5f9:	0f b6 00             	movzbl (%eax),%eax
     5fc:	0f be c0             	movsbl %al,%eax
     5ff:	89 44 24 04          	mov    %eax,0x4(%esp)
     603:	c7 04 24 a8 15 00 00 	movl   $0x15a8,(%esp)
     60a:	e8 d8 07 00 00       	call   de7 <strchr>
     60f:	85 c0                	test   %eax,%eax
     611:	75 28                	jne    63b <gettoken+0x104>
     613:	8b 45 f4             	mov    -0xc(%ebp),%eax
     616:	0f b6 00             	movzbl (%eax),%eax
     619:	0f be c0             	movsbl %al,%eax
     61c:	89 44 24 04          	mov    %eax,0x4(%esp)
     620:	c7 04 24 ae 15 00 00 	movl   $0x15ae,(%esp)
     627:	e8 bb 07 00 00       	call   de7 <strchr>
     62c:	85 c0                	test   %eax,%eax
     62e:	74 ba                	je     5ea <gettoken+0xb3>
      s++;
    break;
     630:	eb 0a                	jmp    63c <gettoken+0x105>
  if(q)
    *q = s;
  ret = *s;
  switch(*s){
  case 0:
    break;
     632:	90                   	nop
     633:	eb 07                	jmp    63c <gettoken+0x105>
    s++;
    if(*s == '>'){
      ret = '+';
      s++;
    }
    break;
     635:	90                   	nop
     636:	eb 04                	jmp    63c <gettoken+0x105>
  default:
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
     638:	90                   	nop
     639:	eb 01                	jmp    63c <gettoken+0x105>
     63b:	90                   	nop
  }
  if(eq)
     63c:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
     640:	74 0e                	je     650 <gettoken+0x119>
    *eq = s;
     642:	8b 45 14             	mov    0x14(%ebp),%eax
     645:	8b 55 f4             	mov    -0xc(%ebp),%edx
     648:	89 10                	mov    %edx,(%eax)
  
  while(s < es && strchr(whitespace, *s))
     64a:	eb 04                	jmp    650 <gettoken+0x119>
    s++;
     64c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    break;
  }
  if(eq)
    *eq = s;
  
  while(s < es && strchr(whitespace, *s))
     650:	8b 45 f4             	mov    -0xc(%ebp),%eax
     653:	3b 45 0c             	cmp    0xc(%ebp),%eax
     656:	73 1d                	jae    675 <gettoken+0x13e>
     658:	8b 45 f4             	mov    -0xc(%ebp),%eax
     65b:	0f b6 00             	movzbl (%eax),%eax
     65e:	0f be c0             	movsbl %al,%eax
     661:	89 44 24 04          	mov    %eax,0x4(%esp)
     665:	c7 04 24 a8 15 00 00 	movl   $0x15a8,(%esp)
     66c:	e8 76 07 00 00       	call   de7 <strchr>
     671:	85 c0                	test   %eax,%eax
     673:	75 d7                	jne    64c <gettoken+0x115>
    s++;
  *ps = s;
     675:	8b 45 08             	mov    0x8(%ebp),%eax
     678:	8b 55 f4             	mov    -0xc(%ebp),%edx
     67b:	89 10                	mov    %edx,(%eax)
  return ret;
     67d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     680:	c9                   	leave  
     681:	c3                   	ret    

00000682 <peek>:

int
peek(char **ps, char *es, char *toks)
{
     682:	55                   	push   %ebp
     683:	89 e5                	mov    %esp,%ebp
     685:	83 ec 28             	sub    $0x28,%esp
  char *s;
  
  s = *ps;
     688:	8b 45 08             	mov    0x8(%ebp),%eax
     68b:	8b 00                	mov    (%eax),%eax
     68d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(s < es && strchr(whitespace, *s))
     690:	eb 04                	jmp    696 <peek+0x14>
    s++;
     692:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
peek(char **ps, char *es, char *toks)
{
  char *s;
  
  s = *ps;
  while(s < es && strchr(whitespace, *s))
     696:	8b 45 f4             	mov    -0xc(%ebp),%eax
     699:	3b 45 0c             	cmp    0xc(%ebp),%eax
     69c:	73 1d                	jae    6bb <peek+0x39>
     69e:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6a1:	0f b6 00             	movzbl (%eax),%eax
     6a4:	0f be c0             	movsbl %al,%eax
     6a7:	89 44 24 04          	mov    %eax,0x4(%esp)
     6ab:	c7 04 24 a8 15 00 00 	movl   $0x15a8,(%esp)
     6b2:	e8 30 07 00 00       	call   de7 <strchr>
     6b7:	85 c0                	test   %eax,%eax
     6b9:	75 d7                	jne    692 <peek+0x10>
    s++;
  *ps = s;
     6bb:	8b 45 08             	mov    0x8(%ebp),%eax
     6be:	8b 55 f4             	mov    -0xc(%ebp),%edx
     6c1:	89 10                	mov    %edx,(%eax)
  return *s && strchr(toks, *s);
     6c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6c6:	0f b6 00             	movzbl (%eax),%eax
     6c9:	84 c0                	test   %al,%al
     6cb:	74 23                	je     6f0 <peek+0x6e>
     6cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6d0:	0f b6 00             	movzbl (%eax),%eax
     6d3:	0f be c0             	movsbl %al,%eax
     6d6:	89 44 24 04          	mov    %eax,0x4(%esp)
     6da:	8b 45 10             	mov    0x10(%ebp),%eax
     6dd:	89 04 24             	mov    %eax,(%esp)
     6e0:	e8 02 07 00 00       	call   de7 <strchr>
     6e5:	85 c0                	test   %eax,%eax
     6e7:	74 07                	je     6f0 <peek+0x6e>
     6e9:	b8 01 00 00 00       	mov    $0x1,%eax
     6ee:	eb 05                	jmp    6f5 <peek+0x73>
     6f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
     6f5:	c9                   	leave  
     6f6:	c3                   	ret    

000006f7 <parsecmd>:
struct cmd *parseexec(char**, char*);
struct cmd *nulterminate(struct cmd*);

struct cmd*
parsecmd(char *s)
{
     6f7:	55                   	push   %ebp
     6f8:	89 e5                	mov    %esp,%ebp
     6fa:	53                   	push   %ebx
     6fb:	83 ec 24             	sub    $0x24,%esp
  char *es;
  struct cmd *cmd;

  es = s + strlen(s);
     6fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
     701:	8b 45 08             	mov    0x8(%ebp),%eax
     704:	89 04 24             	mov    %eax,(%esp)
     707:	e8 92 06 00 00       	call   d9e <strlen>
     70c:	8d 04 03             	lea    (%ebx,%eax,1),%eax
     70f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cmd = parseline(&s, es);
     712:	8b 45 f4             	mov    -0xc(%ebp),%eax
     715:	89 44 24 04          	mov    %eax,0x4(%esp)
     719:	8d 45 08             	lea    0x8(%ebp),%eax
     71c:	89 04 24             	mov    %eax,(%esp)
     71f:	e8 60 00 00 00       	call   784 <parseline>
     724:	89 45 f0             	mov    %eax,-0x10(%ebp)
  peek(&s, es, "");
     727:	c7 44 24 08 16 15 00 	movl   $0x1516,0x8(%esp)
     72e:	00 
     72f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     732:	89 44 24 04          	mov    %eax,0x4(%esp)
     736:	8d 45 08             	lea    0x8(%ebp),%eax
     739:	89 04 24             	mov    %eax,(%esp)
     73c:	e8 41 ff ff ff       	call   682 <peek>
  if(s != es){
     741:	8b 45 08             	mov    0x8(%ebp),%eax
     744:	3b 45 f4             	cmp    -0xc(%ebp),%eax
     747:	74 27                	je     770 <parsecmd+0x79>
    printf(2, "leftovers: %s\n", s);
     749:	8b 45 08             	mov    0x8(%ebp),%eax
     74c:	89 44 24 08          	mov    %eax,0x8(%esp)
     750:	c7 44 24 04 17 15 00 	movl   $0x1517,0x4(%esp)
     757:	00 
     758:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     75f:	e8 83 09 00 00       	call   10e7 <printf>
    panic("syntax");
     764:	c7 04 24 26 15 00 00 	movl   $0x1526,(%esp)
     76b:	e8 ec fb ff ff       	call   35c <panic>
  }
  nulterminate(cmd);
     770:	8b 45 f0             	mov    -0x10(%ebp),%eax
     773:	89 04 24             	mov    %eax,(%esp)
     776:	e8 a5 04 00 00       	call   c20 <nulterminate>
  return cmd;
     77b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     77e:	83 c4 24             	add    $0x24,%esp
     781:	5b                   	pop    %ebx
     782:	5d                   	pop    %ebp
     783:	c3                   	ret    

00000784 <parseline>:

struct cmd*
parseline(char **ps, char *es)
{
     784:	55                   	push   %ebp
     785:	89 e5                	mov    %esp,%ebp
     787:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;

  cmd = parsepipe(ps, es);
     78a:	8b 45 0c             	mov    0xc(%ebp),%eax
     78d:	89 44 24 04          	mov    %eax,0x4(%esp)
     791:	8b 45 08             	mov    0x8(%ebp),%eax
     794:	89 04 24             	mov    %eax,(%esp)
     797:	e8 bc 00 00 00       	call   858 <parsepipe>
     79c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(peek(ps, es, "&")){
     79f:	eb 30                	jmp    7d1 <parseline+0x4d>
    gettoken(ps, es, 0, 0);
     7a1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     7a8:	00 
     7a9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     7b0:	00 
     7b1:	8b 45 0c             	mov    0xc(%ebp),%eax
     7b4:	89 44 24 04          	mov    %eax,0x4(%esp)
     7b8:	8b 45 08             	mov    0x8(%ebp),%eax
     7bb:	89 04 24             	mov    %eax,(%esp)
     7be:	e8 74 fd ff ff       	call   537 <gettoken>
    cmd = backcmd(cmd);
     7c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
     7c6:	89 04 24             	mov    %eax,(%esp)
     7c9:	e8 22 fd ff ff       	call   4f0 <backcmd>
     7ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
parseline(char **ps, char *es)
{
  struct cmd *cmd;

  cmd = parsepipe(ps, es);
  while(peek(ps, es, "&")){
     7d1:	c7 44 24 08 2d 15 00 	movl   $0x152d,0x8(%esp)
     7d8:	00 
     7d9:	8b 45 0c             	mov    0xc(%ebp),%eax
     7dc:	89 44 24 04          	mov    %eax,0x4(%esp)
     7e0:	8b 45 08             	mov    0x8(%ebp),%eax
     7e3:	89 04 24             	mov    %eax,(%esp)
     7e6:	e8 97 fe ff ff       	call   682 <peek>
     7eb:	85 c0                	test   %eax,%eax
     7ed:	75 b2                	jne    7a1 <parseline+0x1d>
    gettoken(ps, es, 0, 0);
    cmd = backcmd(cmd);
  }
  if(peek(ps, es, ";")){
     7ef:	c7 44 24 08 2f 15 00 	movl   $0x152f,0x8(%esp)
     7f6:	00 
     7f7:	8b 45 0c             	mov    0xc(%ebp),%eax
     7fa:	89 44 24 04          	mov    %eax,0x4(%esp)
     7fe:	8b 45 08             	mov    0x8(%ebp),%eax
     801:	89 04 24             	mov    %eax,(%esp)
     804:	e8 79 fe ff ff       	call   682 <peek>
     809:	85 c0                	test   %eax,%eax
     80b:	74 46                	je     853 <parseline+0xcf>
    gettoken(ps, es, 0, 0);
     80d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     814:	00 
     815:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     81c:	00 
     81d:	8b 45 0c             	mov    0xc(%ebp),%eax
     820:	89 44 24 04          	mov    %eax,0x4(%esp)
     824:	8b 45 08             	mov    0x8(%ebp),%eax
     827:	89 04 24             	mov    %eax,(%esp)
     82a:	e8 08 fd ff ff       	call   537 <gettoken>
    cmd = listcmd(cmd, parseline(ps, es));
     82f:	8b 45 0c             	mov    0xc(%ebp),%eax
     832:	89 44 24 04          	mov    %eax,0x4(%esp)
     836:	8b 45 08             	mov    0x8(%ebp),%eax
     839:	89 04 24             	mov    %eax,(%esp)
     83c:	e8 43 ff ff ff       	call   784 <parseline>
     841:	89 44 24 04          	mov    %eax,0x4(%esp)
     845:	8b 45 f4             	mov    -0xc(%ebp),%eax
     848:	89 04 24             	mov    %eax,(%esp)
     84b:	e8 50 fc ff ff       	call   4a0 <listcmd>
     850:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  return cmd;
     853:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     856:	c9                   	leave  
     857:	c3                   	ret    

00000858 <parsepipe>:

struct cmd*
parsepipe(char **ps, char *es)
{
     858:	55                   	push   %ebp
     859:	89 e5                	mov    %esp,%ebp
     85b:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;

  cmd = parseexec(ps, es);
     85e:	8b 45 0c             	mov    0xc(%ebp),%eax
     861:	89 44 24 04          	mov    %eax,0x4(%esp)
     865:	8b 45 08             	mov    0x8(%ebp),%eax
     868:	89 04 24             	mov    %eax,(%esp)
     86b:	e8 68 02 00 00       	call   ad8 <parseexec>
     870:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(peek(ps, es, "|")){
     873:	c7 44 24 08 31 15 00 	movl   $0x1531,0x8(%esp)
     87a:	00 
     87b:	8b 45 0c             	mov    0xc(%ebp),%eax
     87e:	89 44 24 04          	mov    %eax,0x4(%esp)
     882:	8b 45 08             	mov    0x8(%ebp),%eax
     885:	89 04 24             	mov    %eax,(%esp)
     888:	e8 f5 fd ff ff       	call   682 <peek>
     88d:	85 c0                	test   %eax,%eax
     88f:	74 46                	je     8d7 <parsepipe+0x7f>
    gettoken(ps, es, 0, 0);
     891:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     898:	00 
     899:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     8a0:	00 
     8a1:	8b 45 0c             	mov    0xc(%ebp),%eax
     8a4:	89 44 24 04          	mov    %eax,0x4(%esp)
     8a8:	8b 45 08             	mov    0x8(%ebp),%eax
     8ab:	89 04 24             	mov    %eax,(%esp)
     8ae:	e8 84 fc ff ff       	call   537 <gettoken>
    cmd = pipecmd(cmd, parsepipe(ps, es));
     8b3:	8b 45 0c             	mov    0xc(%ebp),%eax
     8b6:	89 44 24 04          	mov    %eax,0x4(%esp)
     8ba:	8b 45 08             	mov    0x8(%ebp),%eax
     8bd:	89 04 24             	mov    %eax,(%esp)
     8c0:	e8 93 ff ff ff       	call   858 <parsepipe>
     8c5:	89 44 24 04          	mov    %eax,0x4(%esp)
     8c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
     8cc:	89 04 24             	mov    %eax,(%esp)
     8cf:	e8 7c fb ff ff       	call   450 <pipecmd>
     8d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  return cmd;
     8d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     8da:	c9                   	leave  
     8db:	c3                   	ret    

000008dc <parseredirs>:

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     8dc:	55                   	push   %ebp
     8dd:	89 e5                	mov    %esp,%ebp
     8df:	83 ec 38             	sub    $0x38,%esp
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     8e2:	e9 f6 00 00 00       	jmp    9dd <parseredirs+0x101>
    tok = gettoken(ps, es, 0, 0);
     8e7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     8ee:	00 
     8ef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     8f6:	00 
     8f7:	8b 45 10             	mov    0x10(%ebp),%eax
     8fa:	89 44 24 04          	mov    %eax,0x4(%esp)
     8fe:	8b 45 0c             	mov    0xc(%ebp),%eax
     901:	89 04 24             	mov    %eax,(%esp)
     904:	e8 2e fc ff ff       	call   537 <gettoken>
     909:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(gettoken(ps, es, &q, &eq) != 'a')
     90c:	8d 45 ec             	lea    -0x14(%ebp),%eax
     90f:	89 44 24 0c          	mov    %eax,0xc(%esp)
     913:	8d 45 f0             	lea    -0x10(%ebp),%eax
     916:	89 44 24 08          	mov    %eax,0x8(%esp)
     91a:	8b 45 10             	mov    0x10(%ebp),%eax
     91d:	89 44 24 04          	mov    %eax,0x4(%esp)
     921:	8b 45 0c             	mov    0xc(%ebp),%eax
     924:	89 04 24             	mov    %eax,(%esp)
     927:	e8 0b fc ff ff       	call   537 <gettoken>
     92c:	83 f8 61             	cmp    $0x61,%eax
     92f:	74 0c                	je     93d <parseredirs+0x61>
      panic("missing file for redirection");
     931:	c7 04 24 33 15 00 00 	movl   $0x1533,(%esp)
     938:	e8 1f fa ff ff       	call   35c <panic>
    switch(tok){
     93d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     940:	83 f8 3c             	cmp    $0x3c,%eax
     943:	74 0f                	je     954 <parseredirs+0x78>
     945:	83 f8 3e             	cmp    $0x3e,%eax
     948:	74 38                	je     982 <parseredirs+0xa6>
     94a:	83 f8 2b             	cmp    $0x2b,%eax
     94d:	74 61                	je     9b0 <parseredirs+0xd4>
     94f:	e9 89 00 00 00       	jmp    9dd <parseredirs+0x101>
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     954:	8b 55 ec             	mov    -0x14(%ebp),%edx
     957:	8b 45 f0             	mov    -0x10(%ebp),%eax
     95a:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
     961:	00 
     962:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     969:	00 
     96a:	89 54 24 08          	mov    %edx,0x8(%esp)
     96e:	89 44 24 04          	mov    %eax,0x4(%esp)
     972:	8b 45 08             	mov    0x8(%ebp),%eax
     975:	89 04 24             	mov    %eax,(%esp)
     978:	e8 68 fa ff ff       	call   3e5 <redircmd>
     97d:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     980:	eb 5b                	jmp    9dd <parseredirs+0x101>
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     982:	8b 55 ec             	mov    -0x14(%ebp),%edx
     985:	8b 45 f0             	mov    -0x10(%ebp),%eax
     988:	c7 44 24 10 01 00 00 	movl   $0x1,0x10(%esp)
     98f:	00 
     990:	c7 44 24 0c 01 02 00 	movl   $0x201,0xc(%esp)
     997:	00 
     998:	89 54 24 08          	mov    %edx,0x8(%esp)
     99c:	89 44 24 04          	mov    %eax,0x4(%esp)
     9a0:	8b 45 08             	mov    0x8(%ebp),%eax
     9a3:	89 04 24             	mov    %eax,(%esp)
     9a6:	e8 3a fa ff ff       	call   3e5 <redircmd>
     9ab:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     9ae:	eb 2d                	jmp    9dd <parseredirs+0x101>
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     9b0:	8b 55 ec             	mov    -0x14(%ebp),%edx
     9b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
     9b6:	c7 44 24 10 01 00 00 	movl   $0x1,0x10(%esp)
     9bd:	00 
     9be:	c7 44 24 0c 01 02 00 	movl   $0x201,0xc(%esp)
     9c5:	00 
     9c6:	89 54 24 08          	mov    %edx,0x8(%esp)
     9ca:	89 44 24 04          	mov    %eax,0x4(%esp)
     9ce:	8b 45 08             	mov    0x8(%ebp),%eax
     9d1:	89 04 24             	mov    %eax,(%esp)
     9d4:	e8 0c fa ff ff       	call   3e5 <redircmd>
     9d9:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     9dc:	90                   	nop
parseredirs(struct cmd *cmd, char **ps, char *es)
{
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     9dd:	c7 44 24 08 50 15 00 	movl   $0x1550,0x8(%esp)
     9e4:	00 
     9e5:	8b 45 10             	mov    0x10(%ebp),%eax
     9e8:	89 44 24 04          	mov    %eax,0x4(%esp)
     9ec:	8b 45 0c             	mov    0xc(%ebp),%eax
     9ef:	89 04 24             	mov    %eax,(%esp)
     9f2:	e8 8b fc ff ff       	call   682 <peek>
     9f7:	85 c0                	test   %eax,%eax
     9f9:	0f 85 e8 fe ff ff    	jne    8e7 <parseredirs+0xb>
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
      break;
    }
  }
  return cmd;
     9ff:	8b 45 08             	mov    0x8(%ebp),%eax
}
     a02:	c9                   	leave  
     a03:	c3                   	ret    

00000a04 <parseblock>:

struct cmd*
parseblock(char **ps, char *es)
{
     a04:	55                   	push   %ebp
     a05:	89 e5                	mov    %esp,%ebp
     a07:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;

  if(!peek(ps, es, "("))
     a0a:	c7 44 24 08 53 15 00 	movl   $0x1553,0x8(%esp)
     a11:	00 
     a12:	8b 45 0c             	mov    0xc(%ebp),%eax
     a15:	89 44 24 04          	mov    %eax,0x4(%esp)
     a19:	8b 45 08             	mov    0x8(%ebp),%eax
     a1c:	89 04 24             	mov    %eax,(%esp)
     a1f:	e8 5e fc ff ff       	call   682 <peek>
     a24:	85 c0                	test   %eax,%eax
     a26:	75 0c                	jne    a34 <parseblock+0x30>
    panic("parseblock");
     a28:	c7 04 24 55 15 00 00 	movl   $0x1555,(%esp)
     a2f:	e8 28 f9 ff ff       	call   35c <panic>
  gettoken(ps, es, 0, 0);
     a34:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     a3b:	00 
     a3c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     a43:	00 
     a44:	8b 45 0c             	mov    0xc(%ebp),%eax
     a47:	89 44 24 04          	mov    %eax,0x4(%esp)
     a4b:	8b 45 08             	mov    0x8(%ebp),%eax
     a4e:	89 04 24             	mov    %eax,(%esp)
     a51:	e8 e1 fa ff ff       	call   537 <gettoken>
  cmd = parseline(ps, es);
     a56:	8b 45 0c             	mov    0xc(%ebp),%eax
     a59:	89 44 24 04          	mov    %eax,0x4(%esp)
     a5d:	8b 45 08             	mov    0x8(%ebp),%eax
     a60:	89 04 24             	mov    %eax,(%esp)
     a63:	e8 1c fd ff ff       	call   784 <parseline>
     a68:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!peek(ps, es, ")"))
     a6b:	c7 44 24 08 60 15 00 	movl   $0x1560,0x8(%esp)
     a72:	00 
     a73:	8b 45 0c             	mov    0xc(%ebp),%eax
     a76:	89 44 24 04          	mov    %eax,0x4(%esp)
     a7a:	8b 45 08             	mov    0x8(%ebp),%eax
     a7d:	89 04 24             	mov    %eax,(%esp)
     a80:	e8 fd fb ff ff       	call   682 <peek>
     a85:	85 c0                	test   %eax,%eax
     a87:	75 0c                	jne    a95 <parseblock+0x91>
    panic("syntax - missing )");
     a89:	c7 04 24 62 15 00 00 	movl   $0x1562,(%esp)
     a90:	e8 c7 f8 ff ff       	call   35c <panic>
  gettoken(ps, es, 0, 0);
     a95:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     a9c:	00 
     a9d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     aa4:	00 
     aa5:	8b 45 0c             	mov    0xc(%ebp),%eax
     aa8:	89 44 24 04          	mov    %eax,0x4(%esp)
     aac:	8b 45 08             	mov    0x8(%ebp),%eax
     aaf:	89 04 24             	mov    %eax,(%esp)
     ab2:	e8 80 fa ff ff       	call   537 <gettoken>
  cmd = parseredirs(cmd, ps, es);
     ab7:	8b 45 0c             	mov    0xc(%ebp),%eax
     aba:	89 44 24 08          	mov    %eax,0x8(%esp)
     abe:	8b 45 08             	mov    0x8(%ebp),%eax
     ac1:	89 44 24 04          	mov    %eax,0x4(%esp)
     ac5:	8b 45 f4             	mov    -0xc(%ebp),%eax
     ac8:	89 04 24             	mov    %eax,(%esp)
     acb:	e8 0c fe ff ff       	call   8dc <parseredirs>
     ad0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  return cmd;
     ad3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     ad6:	c9                   	leave  
     ad7:	c3                   	ret    

00000ad8 <parseexec>:

struct cmd*
parseexec(char **ps, char *es)
{
     ad8:	55                   	push   %ebp
     ad9:	89 e5                	mov    %esp,%ebp
     adb:	83 ec 38             	sub    $0x38,%esp
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;
  
  if(peek(ps, es, "("))
     ade:	c7 44 24 08 53 15 00 	movl   $0x1553,0x8(%esp)
     ae5:	00 
     ae6:	8b 45 0c             	mov    0xc(%ebp),%eax
     ae9:	89 44 24 04          	mov    %eax,0x4(%esp)
     aed:	8b 45 08             	mov    0x8(%ebp),%eax
     af0:	89 04 24             	mov    %eax,(%esp)
     af3:	e8 8a fb ff ff       	call   682 <peek>
     af8:	85 c0                	test   %eax,%eax
     afa:	74 17                	je     b13 <parseexec+0x3b>
    return parseblock(ps, es);
     afc:	8b 45 0c             	mov    0xc(%ebp),%eax
     aff:	89 44 24 04          	mov    %eax,0x4(%esp)
     b03:	8b 45 08             	mov    0x8(%ebp),%eax
     b06:	89 04 24             	mov    %eax,(%esp)
     b09:	e8 f6 fe ff ff       	call   a04 <parseblock>
     b0e:	e9 0b 01 00 00       	jmp    c1e <parseexec+0x146>

  ret = execcmd();
     b13:	e8 8f f8 ff ff       	call   3a7 <execcmd>
     b18:	89 45 f0             	mov    %eax,-0x10(%ebp)
  cmd = (struct execcmd*)ret;
     b1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
     b1e:	89 45 ec             	mov    %eax,-0x14(%ebp)

  argc = 0;
     b21:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  ret = parseredirs(ret, ps, es);
     b28:	8b 45 0c             	mov    0xc(%ebp),%eax
     b2b:	89 44 24 08          	mov    %eax,0x8(%esp)
     b2f:	8b 45 08             	mov    0x8(%ebp),%eax
     b32:	89 44 24 04          	mov    %eax,0x4(%esp)
     b36:	8b 45 f0             	mov    -0x10(%ebp),%eax
     b39:	89 04 24             	mov    %eax,(%esp)
     b3c:	e8 9b fd ff ff       	call   8dc <parseredirs>
     b41:	89 45 f0             	mov    %eax,-0x10(%ebp)
  while(!peek(ps, es, "|)&;")){
     b44:	e9 8e 00 00 00       	jmp    bd7 <parseexec+0xff>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     b49:	8d 45 e0             	lea    -0x20(%ebp),%eax
     b4c:	89 44 24 0c          	mov    %eax,0xc(%esp)
     b50:	8d 45 e4             	lea    -0x1c(%ebp),%eax
     b53:	89 44 24 08          	mov    %eax,0x8(%esp)
     b57:	8b 45 0c             	mov    0xc(%ebp),%eax
     b5a:	89 44 24 04          	mov    %eax,0x4(%esp)
     b5e:	8b 45 08             	mov    0x8(%ebp),%eax
     b61:	89 04 24             	mov    %eax,(%esp)
     b64:	e8 ce f9 ff ff       	call   537 <gettoken>
     b69:	89 45 e8             	mov    %eax,-0x18(%ebp)
     b6c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
     b70:	0f 84 85 00 00 00    	je     bfb <parseexec+0x123>
      break;
    if(tok != 'a')
     b76:	83 7d e8 61          	cmpl   $0x61,-0x18(%ebp)
     b7a:	74 0c                	je     b88 <parseexec+0xb0>
      panic("syntax");
     b7c:	c7 04 24 26 15 00 00 	movl   $0x1526,(%esp)
     b83:	e8 d4 f7 ff ff       	call   35c <panic>
    cmd->argv[argc] = q;
     b88:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
     b8b:	8b 45 ec             	mov    -0x14(%ebp),%eax
     b8e:	8b 55 f4             	mov    -0xc(%ebp),%edx
     b91:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
    cmd->eargv[argc] = eq;
     b95:	8b 55 e0             	mov    -0x20(%ebp),%edx
     b98:	8b 45 ec             	mov    -0x14(%ebp),%eax
     b9b:	8b 4d f4             	mov    -0xc(%ebp),%ecx
     b9e:	83 c1 08             	add    $0x8,%ecx
     ba1:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    argc++;
     ba5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(argc >= MAXARGS)
     ba9:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
     bad:	7e 0c                	jle    bbb <parseexec+0xe3>
      panic("too many args");
     baf:	c7 04 24 75 15 00 00 	movl   $0x1575,(%esp)
     bb6:	e8 a1 f7 ff ff       	call   35c <panic>
    ret = parseredirs(ret, ps, es);
     bbb:	8b 45 0c             	mov    0xc(%ebp),%eax
     bbe:	89 44 24 08          	mov    %eax,0x8(%esp)
     bc2:	8b 45 08             	mov    0x8(%ebp),%eax
     bc5:	89 44 24 04          	mov    %eax,0x4(%esp)
     bc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
     bcc:	89 04 24             	mov    %eax,(%esp)
     bcf:	e8 08 fd ff ff       	call   8dc <parseredirs>
     bd4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  ret = execcmd();
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
  while(!peek(ps, es, "|)&;")){
     bd7:	c7 44 24 08 83 15 00 	movl   $0x1583,0x8(%esp)
     bde:	00 
     bdf:	8b 45 0c             	mov    0xc(%ebp),%eax
     be2:	89 44 24 04          	mov    %eax,0x4(%esp)
     be6:	8b 45 08             	mov    0x8(%ebp),%eax
     be9:	89 04 24             	mov    %eax,(%esp)
     bec:	e8 91 fa ff ff       	call   682 <peek>
     bf1:	85 c0                	test   %eax,%eax
     bf3:	0f 84 50 ff ff ff    	je     b49 <parseexec+0x71>
     bf9:	eb 01                	jmp    bfc <parseexec+0x124>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
      break;
     bfb:	90                   	nop
    argc++;
    if(argc >= MAXARGS)
      panic("too many args");
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
     bfc:	8b 45 ec             	mov    -0x14(%ebp),%eax
     bff:	8b 55 f4             	mov    -0xc(%ebp),%edx
     c02:	c7 44 90 04 00 00 00 	movl   $0x0,0x4(%eax,%edx,4)
     c09:	00 
  cmd->eargv[argc] = 0;
     c0a:	8b 45 ec             	mov    -0x14(%ebp),%eax
     c0d:	8b 55 f4             	mov    -0xc(%ebp),%edx
     c10:	83 c2 08             	add    $0x8,%edx
     c13:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
     c1a:	00 
  return ret;
     c1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     c1e:	c9                   	leave  
     c1f:	c3                   	ret    

00000c20 <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
     c20:	55                   	push   %ebp
     c21:	89 e5                	mov    %esp,%ebp
     c23:	83 ec 38             	sub    $0x38,%esp
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
     c26:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
     c2a:	75 0a                	jne    c36 <nulterminate+0x16>
    return 0;
     c2c:	b8 00 00 00 00       	mov    $0x0,%eax
     c31:	e9 c9 00 00 00       	jmp    cff <nulterminate+0xdf>
  
  switch(cmd->type){
     c36:	8b 45 08             	mov    0x8(%ebp),%eax
     c39:	8b 00                	mov    (%eax),%eax
     c3b:	83 f8 05             	cmp    $0x5,%eax
     c3e:	0f 87 b8 00 00 00    	ja     cfc <nulterminate+0xdc>
     c44:	8b 04 85 88 15 00 00 	mov    0x1588(,%eax,4),%eax
     c4b:	ff e0                	jmp    *%eax
  case EXEC:
    ecmd = (struct execcmd*)cmd;
     c4d:	8b 45 08             	mov    0x8(%ebp),%eax
     c50:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for(i=0; ecmd->argv[i]; i++)
     c53:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     c5a:	eb 14                	jmp    c70 <nulterminate+0x50>
      *ecmd->eargv[i] = 0;
     c5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
     c5f:	8b 55 f4             	mov    -0xc(%ebp),%edx
     c62:	83 c2 08             	add    $0x8,%edx
     c65:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
     c69:	c6 00 00             	movb   $0x0,(%eax)
    return 0;
  
  switch(cmd->type){
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
     c6c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     c70:	8b 45 f0             	mov    -0x10(%ebp),%eax
     c73:	8b 55 f4             	mov    -0xc(%ebp),%edx
     c76:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
     c7a:	85 c0                	test   %eax,%eax
     c7c:	75 de                	jne    c5c <nulterminate+0x3c>
      *ecmd->eargv[i] = 0;
    break;
     c7e:	eb 7c                	jmp    cfc <nulterminate+0xdc>

  case REDIR:
    rcmd = (struct redircmd*)cmd;
     c80:	8b 45 08             	mov    0x8(%ebp),%eax
     c83:	89 45 ec             	mov    %eax,-0x14(%ebp)
    nulterminate(rcmd->cmd);
     c86:	8b 45 ec             	mov    -0x14(%ebp),%eax
     c89:	8b 40 04             	mov    0x4(%eax),%eax
     c8c:	89 04 24             	mov    %eax,(%esp)
     c8f:	e8 8c ff ff ff       	call   c20 <nulterminate>
    *rcmd->efile = 0;
     c94:	8b 45 ec             	mov    -0x14(%ebp),%eax
     c97:	8b 40 0c             	mov    0xc(%eax),%eax
     c9a:	c6 00 00             	movb   $0x0,(%eax)
    break;
     c9d:	eb 5d                	jmp    cfc <nulterminate+0xdc>

  case PIPE:
    pcmd = (struct pipecmd*)cmd;
     c9f:	8b 45 08             	mov    0x8(%ebp),%eax
     ca2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nulterminate(pcmd->left);
     ca5:	8b 45 e8             	mov    -0x18(%ebp),%eax
     ca8:	8b 40 04             	mov    0x4(%eax),%eax
     cab:	89 04 24             	mov    %eax,(%esp)
     cae:	e8 6d ff ff ff       	call   c20 <nulterminate>
    nulterminate(pcmd->right);
     cb3:	8b 45 e8             	mov    -0x18(%ebp),%eax
     cb6:	8b 40 08             	mov    0x8(%eax),%eax
     cb9:	89 04 24             	mov    %eax,(%esp)
     cbc:	e8 5f ff ff ff       	call   c20 <nulterminate>
    break;
     cc1:	eb 39                	jmp    cfc <nulterminate+0xdc>
    
  case LIST:
    lcmd = (struct listcmd*)cmd;
     cc3:	8b 45 08             	mov    0x8(%ebp),%eax
     cc6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nulterminate(lcmd->left);
     cc9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     ccc:	8b 40 04             	mov    0x4(%eax),%eax
     ccf:	89 04 24             	mov    %eax,(%esp)
     cd2:	e8 49 ff ff ff       	call   c20 <nulterminate>
    nulterminate(lcmd->right);
     cd7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     cda:	8b 40 08             	mov    0x8(%eax),%eax
     cdd:	89 04 24             	mov    %eax,(%esp)
     ce0:	e8 3b ff ff ff       	call   c20 <nulterminate>
    break;
     ce5:	eb 15                	jmp    cfc <nulterminate+0xdc>

  case BACK:
    bcmd = (struct backcmd*)cmd;
     ce7:	8b 45 08             	mov    0x8(%ebp),%eax
     cea:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nulterminate(bcmd->cmd);
     ced:	8b 45 e0             	mov    -0x20(%ebp),%eax
     cf0:	8b 40 04             	mov    0x4(%eax),%eax
     cf3:	89 04 24             	mov    %eax,(%esp)
     cf6:	e8 25 ff ff ff       	call   c20 <nulterminate>
    break;
     cfb:	90                   	nop
  }
  return cmd;
     cfc:	8b 45 08             	mov    0x8(%ebp),%eax
}
     cff:	c9                   	leave  
     d00:	c3                   	ret    
     d01:	90                   	nop
     d02:	90                   	nop
     d03:	90                   	nop

00000d04 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
     d04:	55                   	push   %ebp
     d05:	89 e5                	mov    %esp,%ebp
     d07:	57                   	push   %edi
     d08:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
     d09:	8b 4d 08             	mov    0x8(%ebp),%ecx
     d0c:	8b 55 10             	mov    0x10(%ebp),%edx
     d0f:	8b 45 0c             	mov    0xc(%ebp),%eax
     d12:	89 cb                	mov    %ecx,%ebx
     d14:	89 df                	mov    %ebx,%edi
     d16:	89 d1                	mov    %edx,%ecx
     d18:	fc                   	cld    
     d19:	f3 aa                	rep stos %al,%es:(%edi)
     d1b:	89 ca                	mov    %ecx,%edx
     d1d:	89 fb                	mov    %edi,%ebx
     d1f:	89 5d 08             	mov    %ebx,0x8(%ebp)
     d22:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
     d25:	5b                   	pop    %ebx
     d26:	5f                   	pop    %edi
     d27:	5d                   	pop    %ebp
     d28:	c3                   	ret    

00000d29 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
     d29:	55                   	push   %ebp
     d2a:	89 e5                	mov    %esp,%ebp
     d2c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
     d2f:	8b 45 08             	mov    0x8(%ebp),%eax
     d32:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
     d35:	90                   	nop
     d36:	8b 45 0c             	mov    0xc(%ebp),%eax
     d39:	0f b6 10             	movzbl (%eax),%edx
     d3c:	8b 45 08             	mov    0x8(%ebp),%eax
     d3f:	88 10                	mov    %dl,(%eax)
     d41:	8b 45 08             	mov    0x8(%ebp),%eax
     d44:	0f b6 00             	movzbl (%eax),%eax
     d47:	84 c0                	test   %al,%al
     d49:	0f 95 c0             	setne  %al
     d4c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     d50:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
     d54:	84 c0                	test   %al,%al
     d56:	75 de                	jne    d36 <strcpy+0xd>
    ;
  return os;
     d58:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     d5b:	c9                   	leave  
     d5c:	c3                   	ret    

00000d5d <strcmp>:

int
strcmp(const char *p, const char *q)
{
     d5d:	55                   	push   %ebp
     d5e:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
     d60:	eb 08                	jmp    d6a <strcmp+0xd>
    p++, q++;
     d62:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     d66:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
     d6a:	8b 45 08             	mov    0x8(%ebp),%eax
     d6d:	0f b6 00             	movzbl (%eax),%eax
     d70:	84 c0                	test   %al,%al
     d72:	74 10                	je     d84 <strcmp+0x27>
     d74:	8b 45 08             	mov    0x8(%ebp),%eax
     d77:	0f b6 10             	movzbl (%eax),%edx
     d7a:	8b 45 0c             	mov    0xc(%ebp),%eax
     d7d:	0f b6 00             	movzbl (%eax),%eax
     d80:	38 c2                	cmp    %al,%dl
     d82:	74 de                	je     d62 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
     d84:	8b 45 08             	mov    0x8(%ebp),%eax
     d87:	0f b6 00             	movzbl (%eax),%eax
     d8a:	0f b6 d0             	movzbl %al,%edx
     d8d:	8b 45 0c             	mov    0xc(%ebp),%eax
     d90:	0f b6 00             	movzbl (%eax),%eax
     d93:	0f b6 c0             	movzbl %al,%eax
     d96:	89 d1                	mov    %edx,%ecx
     d98:	29 c1                	sub    %eax,%ecx
     d9a:	89 c8                	mov    %ecx,%eax
}
     d9c:	5d                   	pop    %ebp
     d9d:	c3                   	ret    

00000d9e <strlen>:

uint
strlen(char *s)
{
     d9e:	55                   	push   %ebp
     d9f:	89 e5                	mov    %esp,%ebp
     da1:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
     da4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
     dab:	eb 04                	jmp    db1 <strlen+0x13>
     dad:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
     db1:	8b 45 fc             	mov    -0x4(%ebp),%eax
     db4:	03 45 08             	add    0x8(%ebp),%eax
     db7:	0f b6 00             	movzbl (%eax),%eax
     dba:	84 c0                	test   %al,%al
     dbc:	75 ef                	jne    dad <strlen+0xf>
    ;
  return n;
     dbe:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     dc1:	c9                   	leave  
     dc2:	c3                   	ret    

00000dc3 <memset>:

void*
memset(void *dst, int c, uint n)
{
     dc3:	55                   	push   %ebp
     dc4:	89 e5                	mov    %esp,%ebp
     dc6:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
     dc9:	8b 45 10             	mov    0x10(%ebp),%eax
     dcc:	89 44 24 08          	mov    %eax,0x8(%esp)
     dd0:	8b 45 0c             	mov    0xc(%ebp),%eax
     dd3:	89 44 24 04          	mov    %eax,0x4(%esp)
     dd7:	8b 45 08             	mov    0x8(%ebp),%eax
     dda:	89 04 24             	mov    %eax,(%esp)
     ddd:	e8 22 ff ff ff       	call   d04 <stosb>
  return dst;
     de2:	8b 45 08             	mov    0x8(%ebp),%eax
}
     de5:	c9                   	leave  
     de6:	c3                   	ret    

00000de7 <strchr>:

char*
strchr(const char *s, char c)
{
     de7:	55                   	push   %ebp
     de8:	89 e5                	mov    %esp,%ebp
     dea:	83 ec 04             	sub    $0x4,%esp
     ded:	8b 45 0c             	mov    0xc(%ebp),%eax
     df0:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
     df3:	eb 14                	jmp    e09 <strchr+0x22>
    if(*s == c)
     df5:	8b 45 08             	mov    0x8(%ebp),%eax
     df8:	0f b6 00             	movzbl (%eax),%eax
     dfb:	3a 45 fc             	cmp    -0x4(%ebp),%al
     dfe:	75 05                	jne    e05 <strchr+0x1e>
      return (char*)s;
     e00:	8b 45 08             	mov    0x8(%ebp),%eax
     e03:	eb 13                	jmp    e18 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
     e05:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     e09:	8b 45 08             	mov    0x8(%ebp),%eax
     e0c:	0f b6 00             	movzbl (%eax),%eax
     e0f:	84 c0                	test   %al,%al
     e11:	75 e2                	jne    df5 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
     e13:	b8 00 00 00 00       	mov    $0x0,%eax
}
     e18:	c9                   	leave  
     e19:	c3                   	ret    

00000e1a <gets>:

char*
gets(char *buf, int max)
{
     e1a:	55                   	push   %ebp
     e1b:	89 e5                	mov    %esp,%ebp
     e1d:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     e20:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     e27:	eb 44                	jmp    e6d <gets+0x53>
    cc = read(0, &c, 1);
     e29:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     e30:	00 
     e31:	8d 45 ef             	lea    -0x11(%ebp),%eax
     e34:	89 44 24 04          	mov    %eax,0x4(%esp)
     e38:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     e3f:	e8 3c 01 00 00       	call   f80 <read>
     e44:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
     e47:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     e4b:	7e 2d                	jle    e7a <gets+0x60>
      break;
    buf[i++] = c;
     e4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     e50:	03 45 08             	add    0x8(%ebp),%eax
     e53:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
     e57:	88 10                	mov    %dl,(%eax)
     e59:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
     e5d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     e61:	3c 0a                	cmp    $0xa,%al
     e63:	74 16                	je     e7b <gets+0x61>
     e65:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     e69:	3c 0d                	cmp    $0xd,%al
     e6b:	74 0e                	je     e7b <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     e6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     e70:	83 c0 01             	add    $0x1,%eax
     e73:	3b 45 0c             	cmp    0xc(%ebp),%eax
     e76:	7c b1                	jl     e29 <gets+0xf>
     e78:	eb 01                	jmp    e7b <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
     e7a:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
     e7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     e7e:	03 45 08             	add    0x8(%ebp),%eax
     e81:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
     e84:	8b 45 08             	mov    0x8(%ebp),%eax
}
     e87:	c9                   	leave  
     e88:	c3                   	ret    

00000e89 <stat>:

int
stat(char *n, struct stat *st)
{
     e89:	55                   	push   %ebp
     e8a:	89 e5                	mov    %esp,%ebp
     e8c:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     e8f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     e96:	00 
     e97:	8b 45 08             	mov    0x8(%ebp),%eax
     e9a:	89 04 24             	mov    %eax,(%esp)
     e9d:	e8 06 01 00 00       	call   fa8 <open>
     ea2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
     ea5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     ea9:	79 07                	jns    eb2 <stat+0x29>
    return -1;
     eab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     eb0:	eb 23                	jmp    ed5 <stat+0x4c>
  r = fstat(fd, st);
     eb2:	8b 45 0c             	mov    0xc(%ebp),%eax
     eb5:	89 44 24 04          	mov    %eax,0x4(%esp)
     eb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
     ebc:	89 04 24             	mov    %eax,(%esp)
     ebf:	e8 fc 00 00 00       	call   fc0 <fstat>
     ec4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
     ec7:	8b 45 f4             	mov    -0xc(%ebp),%eax
     eca:	89 04 24             	mov    %eax,(%esp)
     ecd:	e8 be 00 00 00       	call   f90 <close>
  return r;
     ed2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     ed5:	c9                   	leave  
     ed6:	c3                   	ret    

00000ed7 <atoi>:

int
atoi(const char *s)
{
     ed7:	55                   	push   %ebp
     ed8:	89 e5                	mov    %esp,%ebp
     eda:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
     edd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
     ee4:	eb 24                	jmp    f0a <atoi+0x33>
    n = n*10 + *s++ - '0';
     ee6:	8b 55 fc             	mov    -0x4(%ebp),%edx
     ee9:	89 d0                	mov    %edx,%eax
     eeb:	c1 e0 02             	shl    $0x2,%eax
     eee:	01 d0                	add    %edx,%eax
     ef0:	01 c0                	add    %eax,%eax
     ef2:	89 c2                	mov    %eax,%edx
     ef4:	8b 45 08             	mov    0x8(%ebp),%eax
     ef7:	0f b6 00             	movzbl (%eax),%eax
     efa:	0f be c0             	movsbl %al,%eax
     efd:	8d 04 02             	lea    (%edx,%eax,1),%eax
     f00:	83 e8 30             	sub    $0x30,%eax
     f03:	89 45 fc             	mov    %eax,-0x4(%ebp)
     f06:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     f0a:	8b 45 08             	mov    0x8(%ebp),%eax
     f0d:	0f b6 00             	movzbl (%eax),%eax
     f10:	3c 2f                	cmp    $0x2f,%al
     f12:	7e 0a                	jle    f1e <atoi+0x47>
     f14:	8b 45 08             	mov    0x8(%ebp),%eax
     f17:	0f b6 00             	movzbl (%eax),%eax
     f1a:	3c 39                	cmp    $0x39,%al
     f1c:	7e c8                	jle    ee6 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
     f1e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     f21:	c9                   	leave  
     f22:	c3                   	ret    

00000f23 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
     f23:	55                   	push   %ebp
     f24:	89 e5                	mov    %esp,%ebp
     f26:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
     f29:	8b 45 08             	mov    0x8(%ebp),%eax
     f2c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
     f2f:	8b 45 0c             	mov    0xc(%ebp),%eax
     f32:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
     f35:	eb 13                	jmp    f4a <memmove+0x27>
    *dst++ = *src++;
     f37:	8b 45 f8             	mov    -0x8(%ebp),%eax
     f3a:	0f b6 10             	movzbl (%eax),%edx
     f3d:	8b 45 fc             	mov    -0x4(%ebp),%eax
     f40:	88 10                	mov    %dl,(%eax)
     f42:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
     f46:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
     f4a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
     f4e:	0f 9f c0             	setg   %al
     f51:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
     f55:	84 c0                	test   %al,%al
     f57:	75 de                	jne    f37 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
     f59:	8b 45 08             	mov    0x8(%ebp),%eax
}
     f5c:	c9                   	leave  
     f5d:	c3                   	ret    
     f5e:	90                   	nop
     f5f:	90                   	nop

00000f60 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
     f60:	b8 01 00 00 00       	mov    $0x1,%eax
     f65:	cd 40                	int    $0x40
     f67:	c3                   	ret    

00000f68 <exit>:
SYSCALL(exit)
     f68:	b8 02 00 00 00       	mov    $0x2,%eax
     f6d:	cd 40                	int    $0x40
     f6f:	c3                   	ret    

00000f70 <wait>:
SYSCALL(wait)
     f70:	b8 03 00 00 00       	mov    $0x3,%eax
     f75:	cd 40                	int    $0x40
     f77:	c3                   	ret    

00000f78 <pipe>:
SYSCALL(pipe)
     f78:	b8 04 00 00 00       	mov    $0x4,%eax
     f7d:	cd 40                	int    $0x40
     f7f:	c3                   	ret    

00000f80 <read>:
SYSCALL(read)
     f80:	b8 05 00 00 00       	mov    $0x5,%eax
     f85:	cd 40                	int    $0x40
     f87:	c3                   	ret    

00000f88 <write>:
SYSCALL(write)
     f88:	b8 10 00 00 00       	mov    $0x10,%eax
     f8d:	cd 40                	int    $0x40
     f8f:	c3                   	ret    

00000f90 <close>:
SYSCALL(close)
     f90:	b8 15 00 00 00       	mov    $0x15,%eax
     f95:	cd 40                	int    $0x40
     f97:	c3                   	ret    

00000f98 <kill>:
SYSCALL(kill)
     f98:	b8 06 00 00 00       	mov    $0x6,%eax
     f9d:	cd 40                	int    $0x40
     f9f:	c3                   	ret    

00000fa0 <exec>:
SYSCALL(exec)
     fa0:	b8 07 00 00 00       	mov    $0x7,%eax
     fa5:	cd 40                	int    $0x40
     fa7:	c3                   	ret    

00000fa8 <open>:
SYSCALL(open)
     fa8:	b8 0f 00 00 00       	mov    $0xf,%eax
     fad:	cd 40                	int    $0x40
     faf:	c3                   	ret    

00000fb0 <mknod>:
SYSCALL(mknod)
     fb0:	b8 11 00 00 00       	mov    $0x11,%eax
     fb5:	cd 40                	int    $0x40
     fb7:	c3                   	ret    

00000fb8 <unlink>:
SYSCALL(unlink)
     fb8:	b8 12 00 00 00       	mov    $0x12,%eax
     fbd:	cd 40                	int    $0x40
     fbf:	c3                   	ret    

00000fc0 <fstat>:
SYSCALL(fstat)
     fc0:	b8 08 00 00 00       	mov    $0x8,%eax
     fc5:	cd 40                	int    $0x40
     fc7:	c3                   	ret    

00000fc8 <link>:
SYSCALL(link)
     fc8:	b8 13 00 00 00       	mov    $0x13,%eax
     fcd:	cd 40                	int    $0x40
     fcf:	c3                   	ret    

00000fd0 <mkdir>:
SYSCALL(mkdir)
     fd0:	b8 14 00 00 00       	mov    $0x14,%eax
     fd5:	cd 40                	int    $0x40
     fd7:	c3                   	ret    

00000fd8 <chdir>:
SYSCALL(chdir)
     fd8:	b8 09 00 00 00       	mov    $0x9,%eax
     fdd:	cd 40                	int    $0x40
     fdf:	c3                   	ret    

00000fe0 <dup>:
SYSCALL(dup)
     fe0:	b8 0a 00 00 00       	mov    $0xa,%eax
     fe5:	cd 40                	int    $0x40
     fe7:	c3                   	ret    

00000fe8 <getpid>:
SYSCALL(getpid)
     fe8:	b8 0b 00 00 00       	mov    $0xb,%eax
     fed:	cd 40                	int    $0x40
     fef:	c3                   	ret    

00000ff0 <sbrk>:
SYSCALL(sbrk)
     ff0:	b8 0c 00 00 00       	mov    $0xc,%eax
     ff5:	cd 40                	int    $0x40
     ff7:	c3                   	ret    

00000ff8 <sleep>:
SYSCALL(sleep)
     ff8:	b8 0d 00 00 00       	mov    $0xd,%eax
     ffd:	cd 40                	int    $0x40
     fff:	c3                   	ret    

00001000 <uptime>:
SYSCALL(uptime)
    1000:	b8 0e 00 00 00       	mov    $0xe,%eax
    1005:	cd 40                	int    $0x40
    1007:	c3                   	ret    

00001008 <procstat>:
SYSCALL(procstat)
    1008:	b8 16 00 00 00       	mov    $0x16,%eax
    100d:	cd 40                	int    $0x40
    100f:	c3                   	ret    

00001010 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    1010:	55                   	push   %ebp
    1011:	89 e5                	mov    %esp,%ebp
    1013:	83 ec 28             	sub    $0x28,%esp
    1016:	8b 45 0c             	mov    0xc(%ebp),%eax
    1019:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    101c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    1023:	00 
    1024:	8d 45 f4             	lea    -0xc(%ebp),%eax
    1027:	89 44 24 04          	mov    %eax,0x4(%esp)
    102b:	8b 45 08             	mov    0x8(%ebp),%eax
    102e:	89 04 24             	mov    %eax,(%esp)
    1031:	e8 52 ff ff ff       	call   f88 <write>
}
    1036:	c9                   	leave  
    1037:	c3                   	ret    

00001038 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    1038:	55                   	push   %ebp
    1039:	89 e5                	mov    %esp,%ebp
    103b:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    103e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    1045:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    1049:	74 17                	je     1062 <printint+0x2a>
    104b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    104f:	79 11                	jns    1062 <printint+0x2a>
    neg = 1;
    1051:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    1058:	8b 45 0c             	mov    0xc(%ebp),%eax
    105b:	f7 d8                	neg    %eax
    105d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    1060:	eb 06                	jmp    1068 <printint+0x30>
  } else {
    x = xx;
    1062:	8b 45 0c             	mov    0xc(%ebp),%eax
    1065:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    1068:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    106f:	8b 4d 10             	mov    0x10(%ebp),%ecx
    1072:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1075:	ba 00 00 00 00       	mov    $0x0,%edx
    107a:	f7 f1                	div    %ecx
    107c:	89 d0                	mov    %edx,%eax
    107e:	0f b6 90 b8 15 00 00 	movzbl 0x15b8(%eax),%edx
    1085:	8d 45 dc             	lea    -0x24(%ebp),%eax
    1088:	03 45 f4             	add    -0xc(%ebp),%eax
    108b:	88 10                	mov    %dl,(%eax)
    108d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
    1091:	8b 45 10             	mov    0x10(%ebp),%eax
    1094:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    1097:	8b 45 ec             	mov    -0x14(%ebp),%eax
    109a:	ba 00 00 00 00       	mov    $0x0,%edx
    109f:	f7 75 d4             	divl   -0x2c(%ebp)
    10a2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    10a5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    10a9:	75 c4                	jne    106f <printint+0x37>
  if(neg)
    10ab:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    10af:	74 2a                	je     10db <printint+0xa3>
    buf[i++] = '-';
    10b1:	8d 45 dc             	lea    -0x24(%ebp),%eax
    10b4:	03 45 f4             	add    -0xc(%ebp),%eax
    10b7:	c6 00 2d             	movb   $0x2d,(%eax)
    10ba:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
    10be:	eb 1b                	jmp    10db <printint+0xa3>
    putc(fd, buf[i]);
    10c0:	8d 45 dc             	lea    -0x24(%ebp),%eax
    10c3:	03 45 f4             	add    -0xc(%ebp),%eax
    10c6:	0f b6 00             	movzbl (%eax),%eax
    10c9:	0f be c0             	movsbl %al,%eax
    10cc:	89 44 24 04          	mov    %eax,0x4(%esp)
    10d0:	8b 45 08             	mov    0x8(%ebp),%eax
    10d3:	89 04 24             	mov    %eax,(%esp)
    10d6:	e8 35 ff ff ff       	call   1010 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    10db:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    10df:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    10e3:	79 db                	jns    10c0 <printint+0x88>
    putc(fd, buf[i]);
}
    10e5:	c9                   	leave  
    10e6:	c3                   	ret    

000010e7 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    10e7:	55                   	push   %ebp
    10e8:	89 e5                	mov    %esp,%ebp
    10ea:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    10ed:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    10f4:	8d 45 0c             	lea    0xc(%ebp),%eax
    10f7:	83 c0 04             	add    $0x4,%eax
    10fa:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    10fd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    1104:	e9 7e 01 00 00       	jmp    1287 <printf+0x1a0>
    c = fmt[i] & 0xff;
    1109:	8b 55 0c             	mov    0xc(%ebp),%edx
    110c:	8b 45 f0             	mov    -0x10(%ebp),%eax
    110f:	8d 04 02             	lea    (%edx,%eax,1),%eax
    1112:	0f b6 00             	movzbl (%eax),%eax
    1115:	0f be c0             	movsbl %al,%eax
    1118:	25 ff 00 00 00       	and    $0xff,%eax
    111d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    1120:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1124:	75 2c                	jne    1152 <printf+0x6b>
      if(c == '%'){
    1126:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    112a:	75 0c                	jne    1138 <printf+0x51>
        state = '%';
    112c:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    1133:	e9 4b 01 00 00       	jmp    1283 <printf+0x19c>
      } else {
        putc(fd, c);
    1138:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    113b:	0f be c0             	movsbl %al,%eax
    113e:	89 44 24 04          	mov    %eax,0x4(%esp)
    1142:	8b 45 08             	mov    0x8(%ebp),%eax
    1145:	89 04 24             	mov    %eax,(%esp)
    1148:	e8 c3 fe ff ff       	call   1010 <putc>
    114d:	e9 31 01 00 00       	jmp    1283 <printf+0x19c>
      }
    } else if(state == '%'){
    1152:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    1156:	0f 85 27 01 00 00    	jne    1283 <printf+0x19c>
      if(c == 'd'){
    115c:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    1160:	75 2d                	jne    118f <printf+0xa8>
        printint(fd, *ap, 10, 1);
    1162:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1165:	8b 00                	mov    (%eax),%eax
    1167:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
    116e:	00 
    116f:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    1176:	00 
    1177:	89 44 24 04          	mov    %eax,0x4(%esp)
    117b:	8b 45 08             	mov    0x8(%ebp),%eax
    117e:	89 04 24             	mov    %eax,(%esp)
    1181:	e8 b2 fe ff ff       	call   1038 <printint>
        ap++;
    1186:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    118a:	e9 ed 00 00 00       	jmp    127c <printf+0x195>
      } else if(c == 'x' || c == 'p'){
    118f:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    1193:	74 06                	je     119b <printf+0xb4>
    1195:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    1199:	75 2d                	jne    11c8 <printf+0xe1>
        printint(fd, *ap, 16, 0);
    119b:	8b 45 e8             	mov    -0x18(%ebp),%eax
    119e:	8b 00                	mov    (%eax),%eax
    11a0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
    11a7:	00 
    11a8:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
    11af:	00 
    11b0:	89 44 24 04          	mov    %eax,0x4(%esp)
    11b4:	8b 45 08             	mov    0x8(%ebp),%eax
    11b7:	89 04 24             	mov    %eax,(%esp)
    11ba:	e8 79 fe ff ff       	call   1038 <printint>
        ap++;
    11bf:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    11c3:	e9 b4 00 00 00       	jmp    127c <printf+0x195>
      } else if(c == 's'){
    11c8:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    11cc:	75 46                	jne    1214 <printf+0x12d>
        s = (char*)*ap;
    11ce:	8b 45 e8             	mov    -0x18(%ebp),%eax
    11d1:	8b 00                	mov    (%eax),%eax
    11d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    11d6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    11da:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    11de:	75 27                	jne    1207 <printf+0x120>
          s = "(null)";
    11e0:	c7 45 f4 a0 15 00 00 	movl   $0x15a0,-0xc(%ebp)
        while(*s != 0){
    11e7:	eb 1f                	jmp    1208 <printf+0x121>
          putc(fd, *s);
    11e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    11ec:	0f b6 00             	movzbl (%eax),%eax
    11ef:	0f be c0             	movsbl %al,%eax
    11f2:	89 44 24 04          	mov    %eax,0x4(%esp)
    11f6:	8b 45 08             	mov    0x8(%ebp),%eax
    11f9:	89 04 24             	mov    %eax,(%esp)
    11fc:	e8 0f fe ff ff       	call   1010 <putc>
          s++;
    1201:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1205:	eb 01                	jmp    1208 <printf+0x121>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    1207:	90                   	nop
    1208:	8b 45 f4             	mov    -0xc(%ebp),%eax
    120b:	0f b6 00             	movzbl (%eax),%eax
    120e:	84 c0                	test   %al,%al
    1210:	75 d7                	jne    11e9 <printf+0x102>
    1212:	eb 68                	jmp    127c <printf+0x195>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    1214:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    1218:	75 1d                	jne    1237 <printf+0x150>
        putc(fd, *ap);
    121a:	8b 45 e8             	mov    -0x18(%ebp),%eax
    121d:	8b 00                	mov    (%eax),%eax
    121f:	0f be c0             	movsbl %al,%eax
    1222:	89 44 24 04          	mov    %eax,0x4(%esp)
    1226:	8b 45 08             	mov    0x8(%ebp),%eax
    1229:	89 04 24             	mov    %eax,(%esp)
    122c:	e8 df fd ff ff       	call   1010 <putc>
        ap++;
    1231:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1235:	eb 45                	jmp    127c <printf+0x195>
      } else if(c == '%'){
    1237:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    123b:	75 17                	jne    1254 <printf+0x16d>
        putc(fd, c);
    123d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1240:	0f be c0             	movsbl %al,%eax
    1243:	89 44 24 04          	mov    %eax,0x4(%esp)
    1247:	8b 45 08             	mov    0x8(%ebp),%eax
    124a:	89 04 24             	mov    %eax,(%esp)
    124d:	e8 be fd ff ff       	call   1010 <putc>
    1252:	eb 28                	jmp    127c <printf+0x195>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    1254:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
    125b:	00 
    125c:	8b 45 08             	mov    0x8(%ebp),%eax
    125f:	89 04 24             	mov    %eax,(%esp)
    1262:	e8 a9 fd ff ff       	call   1010 <putc>
        putc(fd, c);
    1267:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    126a:	0f be c0             	movsbl %al,%eax
    126d:	89 44 24 04          	mov    %eax,0x4(%esp)
    1271:	8b 45 08             	mov    0x8(%ebp),%eax
    1274:	89 04 24             	mov    %eax,(%esp)
    1277:	e8 94 fd ff ff       	call   1010 <putc>
      }
      state = 0;
    127c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    1283:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    1287:	8b 55 0c             	mov    0xc(%ebp),%edx
    128a:	8b 45 f0             	mov    -0x10(%ebp),%eax
    128d:	8d 04 02             	lea    (%edx,%eax,1),%eax
    1290:	0f b6 00             	movzbl (%eax),%eax
    1293:	84 c0                	test   %al,%al
    1295:	0f 85 6e fe ff ff    	jne    1109 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    129b:	c9                   	leave  
    129c:	c3                   	ret    
    129d:	90                   	nop
    129e:	90                   	nop
    129f:	90                   	nop

000012a0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    12a0:	55                   	push   %ebp
    12a1:	89 e5                	mov    %esp,%ebp
    12a3:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    12a6:	8b 45 08             	mov    0x8(%ebp),%eax
    12a9:	83 e8 08             	sub    $0x8,%eax
    12ac:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    12af:	a1 4c 16 00 00       	mov    0x164c,%eax
    12b4:	89 45 fc             	mov    %eax,-0x4(%ebp)
    12b7:	eb 24                	jmp    12dd <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    12b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12bc:	8b 00                	mov    (%eax),%eax
    12be:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    12c1:	77 12                	ja     12d5 <free+0x35>
    12c3:	8b 45 f8             	mov    -0x8(%ebp),%eax
    12c6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    12c9:	77 24                	ja     12ef <free+0x4f>
    12cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12ce:	8b 00                	mov    (%eax),%eax
    12d0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    12d3:	77 1a                	ja     12ef <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    12d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12d8:	8b 00                	mov    (%eax),%eax
    12da:	89 45 fc             	mov    %eax,-0x4(%ebp)
    12dd:	8b 45 f8             	mov    -0x8(%ebp),%eax
    12e0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    12e3:	76 d4                	jbe    12b9 <free+0x19>
    12e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12e8:	8b 00                	mov    (%eax),%eax
    12ea:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    12ed:	76 ca                	jbe    12b9 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    12ef:	8b 45 f8             	mov    -0x8(%ebp),%eax
    12f2:	8b 40 04             	mov    0x4(%eax),%eax
    12f5:	c1 e0 03             	shl    $0x3,%eax
    12f8:	89 c2                	mov    %eax,%edx
    12fa:	03 55 f8             	add    -0x8(%ebp),%edx
    12fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1300:	8b 00                	mov    (%eax),%eax
    1302:	39 c2                	cmp    %eax,%edx
    1304:	75 24                	jne    132a <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
    1306:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1309:	8b 50 04             	mov    0x4(%eax),%edx
    130c:	8b 45 fc             	mov    -0x4(%ebp),%eax
    130f:	8b 00                	mov    (%eax),%eax
    1311:	8b 40 04             	mov    0x4(%eax),%eax
    1314:	01 c2                	add    %eax,%edx
    1316:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1319:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    131c:	8b 45 fc             	mov    -0x4(%ebp),%eax
    131f:	8b 00                	mov    (%eax),%eax
    1321:	8b 10                	mov    (%eax),%edx
    1323:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1326:	89 10                	mov    %edx,(%eax)
    1328:	eb 0a                	jmp    1334 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
    132a:	8b 45 fc             	mov    -0x4(%ebp),%eax
    132d:	8b 10                	mov    (%eax),%edx
    132f:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1332:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    1334:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1337:	8b 40 04             	mov    0x4(%eax),%eax
    133a:	c1 e0 03             	shl    $0x3,%eax
    133d:	03 45 fc             	add    -0x4(%ebp),%eax
    1340:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1343:	75 20                	jne    1365 <free+0xc5>
    p->s.size += bp->s.size;
    1345:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1348:	8b 50 04             	mov    0x4(%eax),%edx
    134b:	8b 45 f8             	mov    -0x8(%ebp),%eax
    134e:	8b 40 04             	mov    0x4(%eax),%eax
    1351:	01 c2                	add    %eax,%edx
    1353:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1356:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    1359:	8b 45 f8             	mov    -0x8(%ebp),%eax
    135c:	8b 10                	mov    (%eax),%edx
    135e:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1361:	89 10                	mov    %edx,(%eax)
    1363:	eb 08                	jmp    136d <free+0xcd>
  } else
    p->s.ptr = bp;
    1365:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1368:	8b 55 f8             	mov    -0x8(%ebp),%edx
    136b:	89 10                	mov    %edx,(%eax)
  freep = p;
    136d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1370:	a3 4c 16 00 00       	mov    %eax,0x164c
}
    1375:	c9                   	leave  
    1376:	c3                   	ret    

00001377 <morecore>:

static Header*
morecore(uint nu)
{
    1377:	55                   	push   %ebp
    1378:	89 e5                	mov    %esp,%ebp
    137a:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    137d:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    1384:	77 07                	ja     138d <morecore+0x16>
    nu = 4096;
    1386:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    138d:	8b 45 08             	mov    0x8(%ebp),%eax
    1390:	c1 e0 03             	shl    $0x3,%eax
    1393:	89 04 24             	mov    %eax,(%esp)
    1396:	e8 55 fc ff ff       	call   ff0 <sbrk>
    139b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    139e:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    13a2:	75 07                	jne    13ab <morecore+0x34>
    return 0;
    13a4:	b8 00 00 00 00       	mov    $0x0,%eax
    13a9:	eb 22                	jmp    13cd <morecore+0x56>
  hp = (Header*)p;
    13ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    13b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
    13b4:	8b 55 08             	mov    0x8(%ebp),%edx
    13b7:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    13ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
    13bd:	83 c0 08             	add    $0x8,%eax
    13c0:	89 04 24             	mov    %eax,(%esp)
    13c3:	e8 d8 fe ff ff       	call   12a0 <free>
  return freep;
    13c8:	a1 4c 16 00 00       	mov    0x164c,%eax
}
    13cd:	c9                   	leave  
    13ce:	c3                   	ret    

000013cf <malloc>:

void*
malloc(uint nbytes)
{
    13cf:	55                   	push   %ebp
    13d0:	89 e5                	mov    %esp,%ebp
    13d2:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    13d5:	8b 45 08             	mov    0x8(%ebp),%eax
    13d8:	83 c0 07             	add    $0x7,%eax
    13db:	c1 e8 03             	shr    $0x3,%eax
    13de:	83 c0 01             	add    $0x1,%eax
    13e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    13e4:	a1 4c 16 00 00       	mov    0x164c,%eax
    13e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    13ec:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    13f0:	75 23                	jne    1415 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    13f2:	c7 45 f0 44 16 00 00 	movl   $0x1644,-0x10(%ebp)
    13f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
    13fc:	a3 4c 16 00 00       	mov    %eax,0x164c
    1401:	a1 4c 16 00 00       	mov    0x164c,%eax
    1406:	a3 44 16 00 00       	mov    %eax,0x1644
    base.s.size = 0;
    140b:	c7 05 48 16 00 00 00 	movl   $0x0,0x1648
    1412:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1415:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1418:	8b 00                	mov    (%eax),%eax
    141a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    141d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1420:	8b 40 04             	mov    0x4(%eax),%eax
    1423:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1426:	72 4d                	jb     1475 <malloc+0xa6>
      if(p->s.size == nunits)
    1428:	8b 45 f4             	mov    -0xc(%ebp),%eax
    142b:	8b 40 04             	mov    0x4(%eax),%eax
    142e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1431:	75 0c                	jne    143f <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    1433:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1436:	8b 10                	mov    (%eax),%edx
    1438:	8b 45 f0             	mov    -0x10(%ebp),%eax
    143b:	89 10                	mov    %edx,(%eax)
    143d:	eb 26                	jmp    1465 <malloc+0x96>
      else {
        p->s.size -= nunits;
    143f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1442:	8b 40 04             	mov    0x4(%eax),%eax
    1445:	89 c2                	mov    %eax,%edx
    1447:	2b 55 ec             	sub    -0x14(%ebp),%edx
    144a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    144d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    1450:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1453:	8b 40 04             	mov    0x4(%eax),%eax
    1456:	c1 e0 03             	shl    $0x3,%eax
    1459:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    145c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    145f:	8b 55 ec             	mov    -0x14(%ebp),%edx
    1462:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    1465:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1468:	a3 4c 16 00 00       	mov    %eax,0x164c
      return (void*)(p + 1);
    146d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1470:	83 c0 08             	add    $0x8,%eax
    1473:	eb 38                	jmp    14ad <malloc+0xde>
    }
    if(p == freep)
    1475:	a1 4c 16 00 00       	mov    0x164c,%eax
    147a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    147d:	75 1b                	jne    149a <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
    147f:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1482:	89 04 24             	mov    %eax,(%esp)
    1485:	e8 ed fe ff ff       	call   1377 <morecore>
    148a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    148d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1491:	75 07                	jne    149a <malloc+0xcb>
        return 0;
    1493:	b8 00 00 00 00       	mov    $0x0,%eax
    1498:	eb 13                	jmp    14ad <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    149a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    149d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    14a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14a3:	8b 00                	mov    (%eax),%eax
    14a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    14a8:	e9 70 ff ff ff       	jmp    141d <malloc+0x4e>
}
    14ad:	c9                   	leave  
    14ae:	c3                   	ret    
