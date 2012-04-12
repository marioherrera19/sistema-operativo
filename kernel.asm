
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4 0f                	in     $0xf,%al

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 50 c6 10 80       	mov    $0x8010c650,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 2b 34 10 80       	mov    $0x8010342b,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	c7 44 24 04 ec 81 10 	movl   $0x801081ec,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
80100049:	e8 3c 4b 00 00       	call   80104b8a <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 90 db 10 80 84 	movl   $0x8010db84,0x8010db90
80100055:	db 10 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 94 db 10 80 84 	movl   $0x8010db84,0x8010db94
8010005f:	db 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 94 c6 10 80 	movl   $0x8010c694,-0xc(%ebp)
80100069:	eb 3a                	jmp    801000a5 <binit+0x71>
    b->next = bcache.head.next;
8010006b:	8b 15 94 db 10 80    	mov    0x8010db94,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 0c 84 db 10 80 	movl   $0x8010db84,0xc(%eax)
    b->dev = -1;
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008b:	a1 94 db 10 80       	mov    0x8010db94,%eax
80100090:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100093:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100099:	a3 94 db 10 80       	mov    %eax,0x8010db94

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009e:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a5:	b8 84 db 10 80       	mov    $0x8010db84,%eax
801000aa:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ad:	72 bc                	jb     8010006b <binit+0x37>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000af:	c9                   	leave  
801000b0:	c3                   	ret    

801000b1 <bget>:
// Look through buffer cache for sector on device dev.
// If not found, allocate fresh block.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint sector)
{
801000b1:	55                   	push   %ebp
801000b2:	89 e5                	mov    %esp,%ebp
801000b4:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b7:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
801000be:	e8 e8 4a 00 00       	call   80104bab <acquire>

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c3:	a1 94 db 10 80       	mov    0x8010db94,%eax
801000c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000cb:	eb 63                	jmp    80100130 <bget+0x7f>
    if(b->dev == dev && b->sector == sector){
801000cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d0:	8b 40 04             	mov    0x4(%eax),%eax
801000d3:	3b 45 08             	cmp    0x8(%ebp),%eax
801000d6:	75 4f                	jne    80100127 <bget+0x76>
801000d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000db:	8b 40 08             	mov    0x8(%eax),%eax
801000de:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e1:	75 44                	jne    80100127 <bget+0x76>
      if(!(b->flags & B_BUSY)){
801000e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e6:	8b 00                	mov    (%eax),%eax
801000e8:	83 e0 01             	and    $0x1,%eax
801000eb:	85 c0                	test   %eax,%eax
801000ed:	75 23                	jne    80100112 <bget+0x61>
        b->flags |= B_BUSY;
801000ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f2:	8b 00                	mov    (%eax),%eax
801000f4:	89 c2                	mov    %eax,%edx
801000f6:	83 ca 01             	or     $0x1,%edx
801000f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000fc:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
801000fe:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
80100105:	e8 03 4b 00 00       	call   80104c0d <release>
        return b;
8010010a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010d:	e9 93 00 00 00       	jmp    801001a5 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100112:	c7 44 24 04 60 c6 10 	movl   $0x8010c660,0x4(%esp)
80100119:	80 
8010011a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011d:	89 04 24             	mov    %eax,(%esp)
80100120:	e8 8a 47 00 00       	call   801048af <sleep>
      goto loop;
80100125:	eb 9c                	jmp    801000c3 <bget+0x12>

  acquire(&bcache.lock);

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100127:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010012a:	8b 40 10             	mov    0x10(%eax),%eax
8010012d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100130:	81 7d f4 84 db 10 80 	cmpl   $0x8010db84,-0xc(%ebp)
80100137:	75 94                	jne    801000cd <bget+0x1c>
      goto loop;
    }
  }

  // Not cached; recycle some non-busy and clean buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100139:	a1 90 db 10 80       	mov    0x8010db90,%eax
8010013e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100141:	eb 4d                	jmp    80100190 <bget+0xdf>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
80100143:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100146:	8b 00                	mov    (%eax),%eax
80100148:	83 e0 01             	and    $0x1,%eax
8010014b:	85 c0                	test   %eax,%eax
8010014d:	75 38                	jne    80100187 <bget+0xd6>
8010014f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100152:	8b 00                	mov    (%eax),%eax
80100154:	83 e0 04             	and    $0x4,%eax
80100157:	85 c0                	test   %eax,%eax
80100159:	75 2c                	jne    80100187 <bget+0xd6>
      b->dev = dev;
8010015b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015e:	8b 55 08             	mov    0x8(%ebp),%edx
80100161:	89 50 04             	mov    %edx,0x4(%eax)
      b->sector = sector;
80100164:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100167:	8b 55 0c             	mov    0xc(%ebp),%edx
8010016a:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
8010016d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100170:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100176:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
8010017d:	e8 8b 4a 00 00       	call   80104c0d <release>
      return b;
80100182:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100185:	eb 1e                	jmp    801001a5 <bget+0xf4>
      goto loop;
    }
  }

  // Not cached; recycle some non-busy and clean buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100187:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010018a:	8b 40 0c             	mov    0xc(%eax),%eax
8010018d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100190:	81 7d f4 84 db 10 80 	cmpl   $0x8010db84,-0xc(%ebp)
80100197:	75 aa                	jne    80100143 <bget+0x92>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
80100199:	c7 04 24 f3 81 10 80 	movl   $0x801081f3,(%esp)
801001a0:	e8 a1 03 00 00       	call   80100546 <panic>
}
801001a5:	c9                   	leave  
801001a6:	c3                   	ret    

801001a7 <bread>:

// Return a B_BUSY buf with the contents of the indicated disk sector.
struct buf*
bread(uint dev, uint sector)
{
801001a7:	55                   	push   %ebp
801001a8:	89 e5                	mov    %esp,%ebp
801001aa:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  b = bget(dev, sector);
801001ad:	8b 45 0c             	mov    0xc(%ebp),%eax
801001b0:	89 44 24 04          	mov    %eax,0x4(%esp)
801001b4:	8b 45 08             	mov    0x8(%ebp),%eax
801001b7:	89 04 24             	mov    %eax,(%esp)
801001ba:	e8 f2 fe ff ff       	call   801000b1 <bget>
801001bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID))
801001c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001c5:	8b 00                	mov    (%eax),%eax
801001c7:	83 e0 02             	and    $0x2,%eax
801001ca:	85 c0                	test   %eax,%eax
801001cc:	75 0b                	jne    801001d9 <bread+0x32>
    iderw(b);
801001ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d1:	89 04 24             	mov    %eax,(%esp)
801001d4:	e8 fb 25 00 00       	call   801027d4 <iderw>
  return b;
801001d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001dc:	c9                   	leave  
801001dd:	c3                   	ret    

801001de <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001de:	55                   	push   %ebp
801001df:	89 e5                	mov    %esp,%ebp
801001e1:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
801001e4:	8b 45 08             	mov    0x8(%ebp),%eax
801001e7:	8b 00                	mov    (%eax),%eax
801001e9:	83 e0 01             	and    $0x1,%eax
801001ec:	85 c0                	test   %eax,%eax
801001ee:	75 0c                	jne    801001fc <bwrite+0x1e>
    panic("bwrite");
801001f0:	c7 04 24 04 82 10 80 	movl   $0x80108204,(%esp)
801001f7:	e8 4a 03 00 00       	call   80100546 <panic>
  b->flags |= B_DIRTY;
801001fc:	8b 45 08             	mov    0x8(%ebp),%eax
801001ff:	8b 00                	mov    (%eax),%eax
80100201:	89 c2                	mov    %eax,%edx
80100203:	83 ca 04             	or     $0x4,%edx
80100206:	8b 45 08             	mov    0x8(%ebp),%eax
80100209:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010020b:	8b 45 08             	mov    0x8(%ebp),%eax
8010020e:	89 04 24             	mov    %eax,(%esp)
80100211:	e8 be 25 00 00       	call   801027d4 <iderw>
}
80100216:	c9                   	leave  
80100217:	c3                   	ret    

80100218 <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100218:	55                   	push   %ebp
80100219:	89 e5                	mov    %esp,%ebp
8010021b:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
8010021e:	8b 45 08             	mov    0x8(%ebp),%eax
80100221:	8b 00                	mov    (%eax),%eax
80100223:	83 e0 01             	and    $0x1,%eax
80100226:	85 c0                	test   %eax,%eax
80100228:	75 0c                	jne    80100236 <brelse+0x1e>
    panic("brelse");
8010022a:	c7 04 24 0b 82 10 80 	movl   $0x8010820b,(%esp)
80100231:	e8 10 03 00 00       	call   80100546 <panic>

  acquire(&bcache.lock);
80100236:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
8010023d:	e8 69 49 00 00       	call   80104bab <acquire>

  b->next->prev = b->prev;
80100242:	8b 45 08             	mov    0x8(%ebp),%eax
80100245:	8b 40 10             	mov    0x10(%eax),%eax
80100248:	8b 55 08             	mov    0x8(%ebp),%edx
8010024b:	8b 52 0c             	mov    0xc(%edx),%edx
8010024e:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
80100251:	8b 45 08             	mov    0x8(%ebp),%eax
80100254:	8b 40 0c             	mov    0xc(%eax),%eax
80100257:	8b 55 08             	mov    0x8(%ebp),%edx
8010025a:	8b 52 10             	mov    0x10(%edx),%edx
8010025d:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
80100260:	8b 15 94 db 10 80    	mov    0x8010db94,%edx
80100266:	8b 45 08             	mov    0x8(%ebp),%eax
80100269:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
8010026c:	8b 45 08             	mov    0x8(%ebp),%eax
8010026f:	c7 40 0c 84 db 10 80 	movl   $0x8010db84,0xc(%eax)
  bcache.head.next->prev = b;
80100276:	a1 94 db 10 80       	mov    0x8010db94,%eax
8010027b:	8b 55 08             	mov    0x8(%ebp),%edx
8010027e:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
80100281:	8b 45 08             	mov    0x8(%ebp),%eax
80100284:	a3 94 db 10 80       	mov    %eax,0x8010db94

  b->flags &= ~B_BUSY;
80100289:	8b 45 08             	mov    0x8(%ebp),%eax
8010028c:	8b 00                	mov    (%eax),%eax
8010028e:	89 c2                	mov    %eax,%edx
80100290:	83 e2 fe             	and    $0xfffffffe,%edx
80100293:	8b 45 08             	mov    0x8(%ebp),%eax
80100296:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80100298:	8b 45 08             	mov    0x8(%ebp),%eax
8010029b:	89 04 24             	mov    %eax,(%esp)
8010029e:	e8 f2 46 00 00       	call   80104995 <wakeup>

  release(&bcache.lock);
801002a3:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
801002aa:	e8 5e 49 00 00       	call   80104c0d <release>
}
801002af:	c9                   	leave  
801002b0:	c3                   	ret    
801002b1:	00 00                	add    %al,(%eax)
	...

801002b4 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002b4:	55                   	push   %ebp
801002b5:	89 e5                	mov    %esp,%ebp
801002b7:	53                   	push   %ebx
801002b8:	83 ec 18             	sub    $0x18,%esp
801002bb:	8b 45 08             	mov    0x8(%ebp),%eax
801002be:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002c2:	0f b7 45 e8          	movzwl -0x18(%ebp),%eax
801002c6:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
801002ca:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
801002ce:	ec                   	in     (%dx),%al
801002cf:	89 c3                	mov    %eax,%ebx
801002d1:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
801002d4:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
801002d8:	83 c4 18             	add    $0x18,%esp
801002db:	5b                   	pop    %ebx
801002dc:	5d                   	pop    %ebp
801002dd:	c3                   	ret    

801002de <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002de:	55                   	push   %ebp
801002df:	89 e5                	mov    %esp,%ebp
801002e1:	83 ec 08             	sub    $0x8,%esp
801002e4:	8b 55 08             	mov    0x8(%ebp),%edx
801002e7:	8b 45 0c             	mov    0xc(%ebp),%eax
801002ea:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801002ee:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801002f1:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801002f5:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801002f9:	ee                   	out    %al,(%dx)
}
801002fa:	c9                   	leave  
801002fb:	c3                   	ret    

801002fc <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801002fc:	55                   	push   %ebp
801002fd:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801002ff:	fa                   	cli    
}
80100300:	5d                   	pop    %ebp
80100301:	c3                   	ret    

80100302 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100302:	55                   	push   %ebp
80100303:	89 e5                	mov    %esp,%ebp
80100305:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
80100308:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010030c:	74 19                	je     80100327 <printint+0x25>
8010030e:	8b 45 08             	mov    0x8(%ebp),%eax
80100311:	c1 e8 1f             	shr    $0x1f,%eax
80100314:	89 45 10             	mov    %eax,0x10(%ebp)
80100317:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010031b:	74 0a                	je     80100327 <printint+0x25>
    x = -xx;
8010031d:	8b 45 08             	mov    0x8(%ebp),%eax
80100320:	f7 d8                	neg    %eax
80100322:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100325:	eb 06                	jmp    8010032d <printint+0x2b>
  else
    x = xx;
80100327:	8b 45 08             	mov    0x8(%ebp),%eax
8010032a:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
8010032d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100334:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100337:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010033a:	ba 00 00 00 00       	mov    $0x0,%edx
8010033f:	f7 f1                	div    %ecx
80100341:	89 d0                	mov    %edx,%eax
80100343:	0f b6 90 04 90 10 80 	movzbl -0x7fef6ffc(%eax),%edx
8010034a:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010034d:	03 45 f4             	add    -0xc(%ebp),%eax
80100350:	88 10                	mov    %dl,(%eax)
80100352:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
80100356:	8b 45 0c             	mov    0xc(%ebp),%eax
80100359:	89 45 d4             	mov    %eax,-0x2c(%ebp)
8010035c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010035f:	ba 00 00 00 00       	mov    $0x0,%edx
80100364:	f7 75 d4             	divl   -0x2c(%ebp)
80100367:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010036a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010036e:	75 c4                	jne    80100334 <printint+0x32>

  if(sign)
80100370:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100374:	74 23                	je     80100399 <printint+0x97>
    buf[i++] = '-';
80100376:	8d 45 e0             	lea    -0x20(%ebp),%eax
80100379:	03 45 f4             	add    -0xc(%ebp),%eax
8010037c:	c6 00 2d             	movb   $0x2d,(%eax)
8010037f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
80100383:	eb 14                	jmp    80100399 <printint+0x97>
    consputc(buf[i]);
80100385:	8d 45 e0             	lea    -0x20(%ebp),%eax
80100388:	03 45 f4             	add    -0xc(%ebp),%eax
8010038b:	0f b6 00             	movzbl (%eax),%eax
8010038e:	0f be c0             	movsbl %al,%eax
80100391:	89 04 24             	mov    %eax,(%esp)
80100394:	e8 c1 03 00 00       	call   8010075a <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
80100399:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
8010039d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003a1:	79 e2                	jns    80100385 <printint+0x83>
    consputc(buf[i]);
}
801003a3:	c9                   	leave  
801003a4:	c3                   	ret    

801003a5 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003a5:	55                   	push   %ebp
801003a6:	89 e5                	mov    %esp,%ebp
801003a8:	83 ec 38             	sub    $0x38,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003ab:	a1 f4 b5 10 80       	mov    0x8010b5f4,%eax
801003b0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003b3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003b7:	74 0c                	je     801003c5 <cprintf+0x20>
    acquire(&cons.lock);
801003b9:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
801003c0:	e8 e6 47 00 00       	call   80104bab <acquire>

  if (fmt == 0)
801003c5:	8b 45 08             	mov    0x8(%ebp),%eax
801003c8:	85 c0                	test   %eax,%eax
801003ca:	75 0c                	jne    801003d8 <cprintf+0x33>
    panic("null fmt");
801003cc:	c7 04 24 12 82 10 80 	movl   $0x80108212,(%esp)
801003d3:	e8 6e 01 00 00       	call   80100546 <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003d8:	8d 45 08             	lea    0x8(%ebp),%eax
801003db:	83 c0 04             	add    $0x4,%eax
801003de:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801003e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801003e8:	e9 21 01 00 00       	jmp    8010050e <cprintf+0x169>
    if(c != '%'){
801003ed:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801003f1:	74 10                	je     80100403 <cprintf+0x5e>
      consputc(c);
801003f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801003f6:	89 04 24             	mov    %eax,(%esp)
801003f9:	e8 5c 03 00 00       	call   8010075a <consputc>
      continue;
801003fe:	e9 07 01 00 00       	jmp    8010050a <cprintf+0x165>
    }
    c = fmt[++i] & 0xff;
80100403:	8b 55 08             	mov    0x8(%ebp),%edx
80100406:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010040a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010040d:	8d 04 02             	lea    (%edx,%eax,1),%eax
80100410:	0f b6 00             	movzbl (%eax),%eax
80100413:	0f be c0             	movsbl %al,%eax
80100416:	25 ff 00 00 00       	and    $0xff,%eax
8010041b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
8010041e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100422:	0f 84 09 01 00 00    	je     80100531 <cprintf+0x18c>
      break;
    switch(c){
80100428:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010042b:	83 f8 70             	cmp    $0x70,%eax
8010042e:	74 4d                	je     8010047d <cprintf+0xd8>
80100430:	83 f8 70             	cmp    $0x70,%eax
80100433:	7f 13                	jg     80100448 <cprintf+0xa3>
80100435:	83 f8 25             	cmp    $0x25,%eax
80100438:	0f 84 a6 00 00 00    	je     801004e4 <cprintf+0x13f>
8010043e:	83 f8 64             	cmp    $0x64,%eax
80100441:	74 14                	je     80100457 <cprintf+0xb2>
80100443:	e9 aa 00 00 00       	jmp    801004f2 <cprintf+0x14d>
80100448:	83 f8 73             	cmp    $0x73,%eax
8010044b:	74 53                	je     801004a0 <cprintf+0xfb>
8010044d:	83 f8 78             	cmp    $0x78,%eax
80100450:	74 2b                	je     8010047d <cprintf+0xd8>
80100452:	e9 9b 00 00 00       	jmp    801004f2 <cprintf+0x14d>
    case 'd':
      printint(*argp++, 10, 1);
80100457:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010045a:	8b 00                	mov    (%eax),%eax
8010045c:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
80100460:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80100467:	00 
80100468:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
8010046f:	00 
80100470:	89 04 24             	mov    %eax,(%esp)
80100473:	e8 8a fe ff ff       	call   80100302 <printint>
      break;
80100478:	e9 8d 00 00 00       	jmp    8010050a <cprintf+0x165>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
8010047d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100480:	8b 00                	mov    (%eax),%eax
80100482:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
80100486:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010048d:	00 
8010048e:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80100495:	00 
80100496:	89 04 24             	mov    %eax,(%esp)
80100499:	e8 64 fe ff ff       	call   80100302 <printint>
      break;
8010049e:	eb 6a                	jmp    8010050a <cprintf+0x165>
    case 's':
      if((s = (char*)*argp++) == 0)
801004a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004a3:	8b 00                	mov    (%eax),%eax
801004a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004a8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004ac:	0f 94 c0             	sete   %al
801004af:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
801004b3:	84 c0                	test   %al,%al
801004b5:	74 20                	je     801004d7 <cprintf+0x132>
        s = "(null)";
801004b7:	c7 45 ec 1b 82 10 80 	movl   $0x8010821b,-0x14(%ebp)
      for(; *s; s++)
801004be:	eb 18                	jmp    801004d8 <cprintf+0x133>
        consputc(*s);
801004c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004c3:	0f b6 00             	movzbl (%eax),%eax
801004c6:	0f be c0             	movsbl %al,%eax
801004c9:	89 04 24             	mov    %eax,(%esp)
801004cc:	e8 89 02 00 00       	call   8010075a <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004d1:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004d5:	eb 01                	jmp    801004d8 <cprintf+0x133>
801004d7:	90                   	nop
801004d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004db:	0f b6 00             	movzbl (%eax),%eax
801004de:	84 c0                	test   %al,%al
801004e0:	75 de                	jne    801004c0 <cprintf+0x11b>
        consputc(*s);
      break;
801004e2:	eb 26                	jmp    8010050a <cprintf+0x165>
    case '%':
      consputc('%');
801004e4:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004eb:	e8 6a 02 00 00       	call   8010075a <consputc>
      break;
801004f0:	eb 18                	jmp    8010050a <cprintf+0x165>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
801004f2:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004f9:	e8 5c 02 00 00       	call   8010075a <consputc>
      consputc(c);
801004fe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100501:	89 04 24             	mov    %eax,(%esp)
80100504:	e8 51 02 00 00       	call   8010075a <consputc>
      break;
80100509:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010050a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010050e:	8b 55 08             	mov    0x8(%ebp),%edx
80100511:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100514:	8d 04 02             	lea    (%edx,%eax,1),%eax
80100517:	0f b6 00             	movzbl (%eax),%eax
8010051a:	0f be c0             	movsbl %al,%eax
8010051d:	25 ff 00 00 00       	and    $0xff,%eax
80100522:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100525:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100529:	0f 85 be fe ff ff    	jne    801003ed <cprintf+0x48>
8010052f:	eb 01                	jmp    80100532 <cprintf+0x18d>
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
80100531:	90                   	nop
      consputc(c);
      break;
    }
  }

  if(locking)
80100532:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100536:	74 0c                	je     80100544 <cprintf+0x19f>
    release(&cons.lock);
80100538:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
8010053f:	e8 c9 46 00 00       	call   80104c0d <release>
}
80100544:	c9                   	leave  
80100545:	c3                   	ret    

80100546 <panic>:

void
panic(char *s)
{
80100546:	55                   	push   %ebp
80100547:	89 e5                	mov    %esp,%ebp
80100549:	83 ec 48             	sub    $0x48,%esp
  int i;
  uint pcs[10];
  
  cli();
8010054c:	e8 ab fd ff ff       	call   801002fc <cli>
  cons.locking = 0;
80100551:	c7 05 f4 b5 10 80 00 	movl   $0x0,0x8010b5f4
80100558:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010055b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100561:	0f b6 00             	movzbl (%eax),%eax
80100564:	0f b6 c0             	movzbl %al,%eax
80100567:	89 44 24 04          	mov    %eax,0x4(%esp)
8010056b:	c7 04 24 22 82 10 80 	movl   $0x80108222,(%esp)
80100572:	e8 2e fe ff ff       	call   801003a5 <cprintf>
  cprintf(s);
80100577:	8b 45 08             	mov    0x8(%ebp),%eax
8010057a:	89 04 24             	mov    %eax,(%esp)
8010057d:	e8 23 fe ff ff       	call   801003a5 <cprintf>
  cprintf("\n");
80100582:	c7 04 24 31 82 10 80 	movl   $0x80108231,(%esp)
80100589:	e8 17 fe ff ff       	call   801003a5 <cprintf>
  getcallerpcs(&s, pcs);
8010058e:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100591:	89 44 24 04          	mov    %eax,0x4(%esp)
80100595:	8d 45 08             	lea    0x8(%ebp),%eax
80100598:	89 04 24             	mov    %eax,(%esp)
8010059b:	e8 bc 46 00 00       	call   80104c5c <getcallerpcs>
  for(i=0; i<10; i++)
801005a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005a7:	eb 1b                	jmp    801005c4 <panic+0x7e>
    cprintf(" %p", pcs[i]);
801005a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005ac:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005b0:	89 44 24 04          	mov    %eax,0x4(%esp)
801005b4:	c7 04 24 33 82 10 80 	movl   $0x80108233,(%esp)
801005bb:	e8 e5 fd ff ff       	call   801003a5 <cprintf>
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005c0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005c4:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005c8:	7e df                	jle    801005a9 <panic+0x63>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005ca:	c7 05 a0 b5 10 80 01 	movl   $0x1,0x8010b5a0
801005d1:	00 00 00 
  for(;;)
    ;
801005d4:	eb fe                	jmp    801005d4 <panic+0x8e>

801005d6 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801005d6:	55                   	push   %ebp
801005d7:	89 e5                	mov    %esp,%ebp
801005d9:	83 ec 28             	sub    $0x28,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801005dc:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801005e3:	00 
801005e4:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801005eb:	e8 ee fc ff ff       	call   801002de <outb>
  pos = inb(CRTPORT+1) << 8;
801005f0:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801005f7:	e8 b8 fc ff ff       	call   801002b4 <inb>
801005fc:	0f b6 c0             	movzbl %al,%eax
801005ff:	c1 e0 08             	shl    $0x8,%eax
80100602:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
80100605:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
8010060c:	00 
8010060d:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100614:	e8 c5 fc ff ff       	call   801002de <outb>
  pos |= inb(CRTPORT+1);
80100619:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100620:	e8 8f fc ff ff       	call   801002b4 <inb>
80100625:	0f b6 c0             	movzbl %al,%eax
80100628:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
8010062b:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
8010062f:	75 30                	jne    80100661 <cgaputc+0x8b>
    pos += 80 - pos%80;
80100631:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100634:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100639:	89 c8                	mov    %ecx,%eax
8010063b:	f7 ea                	imul   %edx
8010063d:	c1 fa 05             	sar    $0x5,%edx
80100640:	89 c8                	mov    %ecx,%eax
80100642:	c1 f8 1f             	sar    $0x1f,%eax
80100645:	29 c2                	sub    %eax,%edx
80100647:	89 d0                	mov    %edx,%eax
80100649:	c1 e0 02             	shl    $0x2,%eax
8010064c:	01 d0                	add    %edx,%eax
8010064e:	c1 e0 04             	shl    $0x4,%eax
80100651:	89 ca                	mov    %ecx,%edx
80100653:	29 c2                	sub    %eax,%edx
80100655:	b8 50 00 00 00       	mov    $0x50,%eax
8010065a:	29 d0                	sub    %edx,%eax
8010065c:	01 45 f4             	add    %eax,-0xc(%ebp)
8010065f:	eb 33                	jmp    80100694 <cgaputc+0xbe>
  else if(c == BACKSPACE){
80100661:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100668:	75 0c                	jne    80100676 <cgaputc+0xa0>
    if(pos > 0) --pos;
8010066a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010066e:	7e 24                	jle    80100694 <cgaputc+0xbe>
80100670:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100674:	eb 1e                	jmp    80100694 <cgaputc+0xbe>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100676:	a1 00 90 10 80       	mov    0x80109000,%eax
8010067b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010067e:	01 d2                	add    %edx,%edx
80100680:	8d 14 10             	lea    (%eax,%edx,1),%edx
80100683:	8b 45 08             	mov    0x8(%ebp),%eax
80100686:	66 25 ff 00          	and    $0xff,%ax
8010068a:	80 cc 07             	or     $0x7,%ah
8010068d:	66 89 02             	mov    %ax,(%edx)
80100690:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  
  if((pos/80) >= 24){  // Scroll up.
80100694:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
8010069b:	7e 53                	jle    801006f0 <cgaputc+0x11a>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
8010069d:	a1 00 90 10 80       	mov    0x80109000,%eax
801006a2:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006a8:	a1 00 90 10 80       	mov    0x80109000,%eax
801006ad:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
801006b4:	00 
801006b5:	89 54 24 04          	mov    %edx,0x4(%esp)
801006b9:	89 04 24             	mov    %eax,(%esp)
801006bc:	e8 0c 48 00 00       	call   80104ecd <memmove>
    pos -= 80;
801006c1:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006c5:	b8 80 07 00 00       	mov    $0x780,%eax
801006ca:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006cd:	01 c0                	add    %eax,%eax
801006cf:	8b 15 00 90 10 80    	mov    0x80109000,%edx
801006d5:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006d8:	01 c9                	add    %ecx,%ecx
801006da:	01 ca                	add    %ecx,%edx
801006dc:	89 44 24 08          	mov    %eax,0x8(%esp)
801006e0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801006e7:	00 
801006e8:	89 14 24             	mov    %edx,(%esp)
801006eb:	e8 0a 47 00 00       	call   80104dfa <memset>
  }
  
  outb(CRTPORT, 14);
801006f0:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801006f7:	00 
801006f8:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801006ff:	e8 da fb ff ff       	call   801002de <outb>
  outb(CRTPORT+1, pos>>8);
80100704:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100707:	c1 f8 08             	sar    $0x8,%eax
8010070a:	0f b6 c0             	movzbl %al,%eax
8010070d:	89 44 24 04          	mov    %eax,0x4(%esp)
80100711:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100718:	e8 c1 fb ff ff       	call   801002de <outb>
  outb(CRTPORT, 15);
8010071d:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100724:	00 
80100725:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010072c:	e8 ad fb ff ff       	call   801002de <outb>
  outb(CRTPORT+1, pos);
80100731:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100734:	0f b6 c0             	movzbl %al,%eax
80100737:	89 44 24 04          	mov    %eax,0x4(%esp)
8010073b:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100742:	e8 97 fb ff ff       	call   801002de <outb>
  crt[pos] = ' ' | 0x0700;
80100747:	a1 00 90 10 80       	mov    0x80109000,%eax
8010074c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010074f:	01 d2                	add    %edx,%edx
80100751:	01 d0                	add    %edx,%eax
80100753:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
80100758:	c9                   	leave  
80100759:	c3                   	ret    

8010075a <consputc>:

void
consputc(int c)
{
8010075a:	55                   	push   %ebp
8010075b:	89 e5                	mov    %esp,%ebp
8010075d:	83 ec 18             	sub    $0x18,%esp
  if(panicked){
80100760:	a1 a0 b5 10 80       	mov    0x8010b5a0,%eax
80100765:	85 c0                	test   %eax,%eax
80100767:	74 07                	je     80100770 <consputc+0x16>
    cli();
80100769:	e8 8e fb ff ff       	call   801002fc <cli>
    for(;;)
      ;
8010076e:	eb fe                	jmp    8010076e <consputc+0x14>
  }

  if(c == BACKSPACE){
80100770:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100777:	75 26                	jne    8010079f <consputc+0x45>
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100779:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100780:	e8 c8 60 00 00       	call   8010684d <uartputc>
80100785:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010078c:	e8 bc 60 00 00       	call   8010684d <uartputc>
80100791:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100798:	e8 b0 60 00 00       	call   8010684d <uartputc>
8010079d:	eb 0b                	jmp    801007aa <consputc+0x50>
  } else
    uartputc(c);
8010079f:	8b 45 08             	mov    0x8(%ebp),%eax
801007a2:	89 04 24             	mov    %eax,(%esp)
801007a5:	e8 a3 60 00 00       	call   8010684d <uartputc>
  cgaputc(c);
801007aa:	8b 45 08             	mov    0x8(%ebp),%eax
801007ad:	89 04 24             	mov    %eax,(%esp)
801007b0:	e8 21 fe ff ff       	call   801005d6 <cgaputc>
}
801007b5:	c9                   	leave  
801007b6:	c3                   	ret    

801007b7 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007b7:	55                   	push   %ebp
801007b8:	89 e5                	mov    %esp,%ebp
801007ba:	83 ec 28             	sub    $0x28,%esp
  int c;

  acquire(&input.lock);
801007bd:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
801007c4:	e8 e2 43 00 00       	call   80104bab <acquire>
  while((c = getc()) >= 0){
801007c9:	e9 47 01 00 00       	jmp    80100915 <consoleintr+0x15e>
    switch(c){
801007ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007d1:	83 f8 10             	cmp    $0x10,%eax
801007d4:	74 1e                	je     801007f4 <consoleintr+0x3d>
801007d6:	83 f8 10             	cmp    $0x10,%eax
801007d9:	7f 0a                	jg     801007e5 <consoleintr+0x2e>
801007db:	83 f8 08             	cmp    $0x8,%eax
801007de:	74 68                	je     80100848 <consoleintr+0x91>
801007e0:	e9 94 00 00 00       	jmp    80100879 <consoleintr+0xc2>
801007e5:	83 f8 15             	cmp    $0x15,%eax
801007e8:	74 2f                	je     80100819 <consoleintr+0x62>
801007ea:	83 f8 7f             	cmp    $0x7f,%eax
801007ed:	74 59                	je     80100848 <consoleintr+0x91>
801007ef:	e9 85 00 00 00       	jmp    80100879 <consoleintr+0xc2>
    case C('P'):  // Process listing.
      procdump();
801007f4:	e8 4c 42 00 00       	call   80104a45 <procdump>
      break;
801007f9:	e9 17 01 00 00       	jmp    80100915 <consoleintr+0x15e>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
801007fe:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100803:	83 e8 01             	sub    $0x1,%eax
80100806:	a3 5c de 10 80       	mov    %eax,0x8010de5c
        consputc(BACKSPACE);
8010080b:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100812:	e8 43 ff ff ff       	call   8010075a <consputc>
80100817:	eb 01                	jmp    8010081a <consoleintr+0x63>
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100819:	90                   	nop
8010081a:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100820:	a1 58 de 10 80       	mov    0x8010de58,%eax
80100825:	39 c2                	cmp    %eax,%edx
80100827:	0f 84 db 00 00 00    	je     80100908 <consoleintr+0x151>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
8010082d:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100832:	83 e8 01             	sub    $0x1,%eax
80100835:	83 e0 7f             	and    $0x7f,%eax
80100838:	0f b6 80 d4 dd 10 80 	movzbl -0x7fef222c(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010083f:	3c 0a                	cmp    $0xa,%al
80100841:	75 bb                	jne    801007fe <consoleintr+0x47>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100843:	e9 cd 00 00 00       	jmp    80100915 <consoleintr+0x15e>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100848:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
8010084e:	a1 58 de 10 80       	mov    0x8010de58,%eax
80100853:	39 c2                	cmp    %eax,%edx
80100855:	0f 84 b0 00 00 00    	je     8010090b <consoleintr+0x154>
        input.e--;
8010085b:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100860:	83 e8 01             	sub    $0x1,%eax
80100863:	a3 5c de 10 80       	mov    %eax,0x8010de5c
        consputc(BACKSPACE);
80100868:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
8010086f:	e8 e6 fe ff ff       	call   8010075a <consputc>
      }
      break;
80100874:	e9 9c 00 00 00       	jmp    80100915 <consoleintr+0x15e>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100879:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010087d:	0f 84 8b 00 00 00    	je     8010090e <consoleintr+0x157>
80100883:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100889:	a1 54 de 10 80       	mov    0x8010de54,%eax
8010088e:	89 d1                	mov    %edx,%ecx
80100890:	29 c1                	sub    %eax,%ecx
80100892:	89 c8                	mov    %ecx,%eax
80100894:	83 f8 7f             	cmp    $0x7f,%eax
80100897:	77 78                	ja     80100911 <consoleintr+0x15a>
        c = (c == '\r') ? '\n' : c;
80100899:	83 7d f4 0d          	cmpl   $0xd,-0xc(%ebp)
8010089d:	74 05                	je     801008a4 <consoleintr+0xed>
8010089f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008a2:	eb 05                	jmp    801008a9 <consoleintr+0xf2>
801008a4:	b8 0a 00 00 00       	mov    $0xa,%eax
801008a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008ac:	a1 5c de 10 80       	mov    0x8010de5c,%eax
801008b1:	89 c1                	mov    %eax,%ecx
801008b3:	83 e1 7f             	and    $0x7f,%ecx
801008b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801008b9:	88 91 d4 dd 10 80    	mov    %dl,-0x7fef222c(%ecx)
801008bf:	83 c0 01             	add    $0x1,%eax
801008c2:	a3 5c de 10 80       	mov    %eax,0x8010de5c
        consputc(c);
801008c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008ca:	89 04 24             	mov    %eax,(%esp)
801008cd:	e8 88 fe ff ff       	call   8010075a <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801008d2:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
801008d6:	74 18                	je     801008f0 <consoleintr+0x139>
801008d8:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
801008dc:	74 12                	je     801008f0 <consoleintr+0x139>
801008de:	a1 5c de 10 80       	mov    0x8010de5c,%eax
801008e3:	8b 15 54 de 10 80    	mov    0x8010de54,%edx
801008e9:	83 ea 80             	sub    $0xffffff80,%edx
801008ec:	39 d0                	cmp    %edx,%eax
801008ee:	75 24                	jne    80100914 <consoleintr+0x15d>
          input.w = input.e;
801008f0:	a1 5c de 10 80       	mov    0x8010de5c,%eax
801008f5:	a3 58 de 10 80       	mov    %eax,0x8010de58
          wakeup(&input.r);
801008fa:	c7 04 24 54 de 10 80 	movl   $0x8010de54,(%esp)
80100901:	e8 8f 40 00 00       	call   80104995 <wakeup>
        }
      }
      break;
80100906:	eb 0d                	jmp    80100915 <consoleintr+0x15e>
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100908:	90                   	nop
80100909:	eb 0a                	jmp    80100915 <consoleintr+0x15e>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
8010090b:	90                   	nop
8010090c:	eb 07                	jmp    80100915 <consoleintr+0x15e>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
          input.w = input.e;
          wakeup(&input.r);
        }
      }
      break;
8010090e:	90                   	nop
8010090f:	eb 04                	jmp    80100915 <consoleintr+0x15e>
80100911:	90                   	nop
80100912:	eb 01                	jmp    80100915 <consoleintr+0x15e>
80100914:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c;

  acquire(&input.lock);
  while((c = getc()) >= 0){
80100915:	8b 45 08             	mov    0x8(%ebp),%eax
80100918:	ff d0                	call   *%eax
8010091a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010091d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100921:	0f 89 a7 fe ff ff    	jns    801007ce <consoleintr+0x17>
        }
      }
      break;
    }
  }
  release(&input.lock);
80100927:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
8010092e:	e8 da 42 00 00       	call   80104c0d <release>
}
80100933:	c9                   	leave  
80100934:	c3                   	ret    

80100935 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100935:	55                   	push   %ebp
80100936:	89 e5                	mov    %esp,%ebp
80100938:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
8010093b:	8b 45 08             	mov    0x8(%ebp),%eax
8010093e:	89 04 24             	mov    %eax,(%esp)
80100941:	e8 8e 10 00 00       	call   801019d4 <iunlock>
  target = n;
80100946:	8b 45 10             	mov    0x10(%ebp),%eax
80100949:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
8010094c:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100953:	e8 53 42 00 00       	call   80104bab <acquire>
  while(n > 0){
80100958:	e9 a8 00 00 00       	jmp    80100a05 <consoleread+0xd0>
    while(input.r == input.w){
      if(proc->killed){
8010095d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100963:	8b 40 24             	mov    0x24(%eax),%eax
80100966:	85 c0                	test   %eax,%eax
80100968:	74 21                	je     8010098b <consoleread+0x56>
        release(&input.lock);
8010096a:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100971:	e8 97 42 00 00       	call   80104c0d <release>
        ilock(ip);
80100976:	8b 45 08             	mov    0x8(%ebp),%eax
80100979:	89 04 24             	mov    %eax,(%esp)
8010097c:	e8 02 0f 00 00       	call   80101883 <ilock>
        return -1;
80100981:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100986:	e9 a9 00 00 00       	jmp    80100a34 <consoleread+0xff>
      }
      sleep(&input.r, &input.lock);
8010098b:	c7 44 24 04 a0 dd 10 	movl   $0x8010dda0,0x4(%esp)
80100992:	80 
80100993:	c7 04 24 54 de 10 80 	movl   $0x8010de54,(%esp)
8010099a:	e8 10 3f 00 00       	call   801048af <sleep>
8010099f:	eb 01                	jmp    801009a2 <consoleread+0x6d>

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
801009a1:	90                   	nop
801009a2:	8b 15 54 de 10 80    	mov    0x8010de54,%edx
801009a8:	a1 58 de 10 80       	mov    0x8010de58,%eax
801009ad:	39 c2                	cmp    %eax,%edx
801009af:	74 ac                	je     8010095d <consoleread+0x28>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009b1:	a1 54 de 10 80       	mov    0x8010de54,%eax
801009b6:	89 c2                	mov    %eax,%edx
801009b8:	83 e2 7f             	and    $0x7f,%edx
801009bb:	0f b6 92 d4 dd 10 80 	movzbl -0x7fef222c(%edx),%edx
801009c2:	0f be d2             	movsbl %dl,%edx
801009c5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801009c8:	83 c0 01             	add    $0x1,%eax
801009cb:	a3 54 de 10 80       	mov    %eax,0x8010de54
    if(c == C('D')){  // EOF
801009d0:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801009d4:	75 17                	jne    801009ed <consoleread+0xb8>
      if(n < target){
801009d6:	8b 45 10             	mov    0x10(%ebp),%eax
801009d9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801009dc:	73 2f                	jae    80100a0d <consoleread+0xd8>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
801009de:	a1 54 de 10 80       	mov    0x8010de54,%eax
801009e3:	83 e8 01             	sub    $0x1,%eax
801009e6:	a3 54 de 10 80       	mov    %eax,0x8010de54
      }
      break;
801009eb:	eb 24                	jmp    80100a11 <consoleread+0xdc>
    }
    *dst++ = c;
801009ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801009f0:	89 c2                	mov    %eax,%edx
801009f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801009f5:	88 10                	mov    %dl,(%eax)
801009f7:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    --n;
801009fb:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
801009ff:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a03:	74 0b                	je     80100a10 <consoleread+0xdb>
  int c;

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
80100a05:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a09:	7f 96                	jg     801009a1 <consoleread+0x6c>
80100a0b:	eb 04                	jmp    80100a11 <consoleread+0xdc>
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
80100a0d:	90                   	nop
80100a0e:	eb 01                	jmp    80100a11 <consoleread+0xdc>
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
80100a10:	90                   	nop
  }
  release(&input.lock);
80100a11:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100a18:	e8 f0 41 00 00       	call   80104c0d <release>
  ilock(ip);
80100a1d:	8b 45 08             	mov    0x8(%ebp),%eax
80100a20:	89 04 24             	mov    %eax,(%esp)
80100a23:	e8 5b 0e 00 00       	call   80101883 <ilock>

  return target - n;
80100a28:	8b 45 10             	mov    0x10(%ebp),%eax
80100a2b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a2e:	89 d1                	mov    %edx,%ecx
80100a30:	29 c1                	sub    %eax,%ecx
80100a32:	89 c8                	mov    %ecx,%eax
}
80100a34:	c9                   	leave  
80100a35:	c3                   	ret    

80100a36 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a36:	55                   	push   %ebp
80100a37:	89 e5                	mov    %esp,%ebp
80100a39:	83 ec 28             	sub    $0x28,%esp
  int i;

  iunlock(ip);
80100a3c:	8b 45 08             	mov    0x8(%ebp),%eax
80100a3f:	89 04 24             	mov    %eax,(%esp)
80100a42:	e8 8d 0f 00 00       	call   801019d4 <iunlock>
  acquire(&cons.lock);
80100a47:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100a4e:	e8 58 41 00 00       	call   80104bab <acquire>
  for(i = 0; i < n; i++)
80100a53:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100a5a:	eb 1d                	jmp    80100a79 <consolewrite+0x43>
    consputc(buf[i] & 0xff);
80100a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a5f:	03 45 0c             	add    0xc(%ebp),%eax
80100a62:	0f b6 00             	movzbl (%eax),%eax
80100a65:	0f be c0             	movsbl %al,%eax
80100a68:	25 ff 00 00 00       	and    $0xff,%eax
80100a6d:	89 04 24             	mov    %eax,(%esp)
80100a70:	e8 e5 fc ff ff       	call   8010075a <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100a75:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100a79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a7c:	3b 45 10             	cmp    0x10(%ebp),%eax
80100a7f:	7c db                	jl     80100a5c <consolewrite+0x26>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100a81:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100a88:	e8 80 41 00 00       	call   80104c0d <release>
  ilock(ip);
80100a8d:	8b 45 08             	mov    0x8(%ebp),%eax
80100a90:	89 04 24             	mov    %eax,(%esp)
80100a93:	e8 eb 0d 00 00       	call   80101883 <ilock>

  return n;
80100a98:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100a9b:	c9                   	leave  
80100a9c:	c3                   	ret    

80100a9d <consoleinit>:

void
consoleinit(void)
{
80100a9d:	55                   	push   %ebp
80100a9e:	89 e5                	mov    %esp,%ebp
80100aa0:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100aa3:	c7 44 24 04 37 82 10 	movl   $0x80108237,0x4(%esp)
80100aaa:	80 
80100aab:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100ab2:	e8 d3 40 00 00       	call   80104b8a <initlock>
  initlock(&input.lock, "input");
80100ab7:	c7 44 24 04 3f 82 10 	movl   $0x8010823f,0x4(%esp)
80100abe:	80 
80100abf:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100ac6:	e8 bf 40 00 00       	call   80104b8a <initlock>

  devsw[CONSOLE].write = consolewrite;
80100acb:	c7 05 0c e8 10 80 36 	movl   $0x80100a36,0x8010e80c
80100ad2:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100ad5:	c7 05 08 e8 10 80 35 	movl   $0x80100935,0x8010e808
80100adc:	09 10 80 
  cons.locking = 1;
80100adf:	c7 05 f4 b5 10 80 01 	movl   $0x1,0x8010b5f4
80100ae6:	00 00 00 

  picenable(IRQ_KBD);
80100ae9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100af0:	e8 f4 2f 00 00       	call   80103ae9 <picenable>
  ioapicenable(IRQ_KBD, 0);
80100af5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100afc:	00 
80100afd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100b04:	e8 8d 1e 00 00       	call   80102996 <ioapicenable>
}
80100b09:	c9                   	leave  
80100b0a:	c3                   	ret    
	...

80100b0c <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b0c:	55                   	push   %ebp
80100b0d:	89 e5                	mov    %esp,%ebp
80100b0f:	81 ec 38 01 00 00    	sub    $0x138,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  if((ip = namei(path)) == 0)
80100b15:	8b 45 08             	mov    0x8(%ebp),%eax
80100b18:	89 04 24             	mov    %eax,(%esp)
80100b1b:	e8 0b 19 00 00       	call   8010242b <namei>
80100b20:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b23:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b27:	75 0a                	jne    80100b33 <exec+0x27>
    return -1;
80100b29:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b2e:	e9 df 03 00 00       	jmp    80100f12 <exec+0x406>
  ilock(ip);
80100b33:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b36:	89 04 24             	mov    %eax,(%esp)
80100b39:	e8 45 0d 00 00       	call   80101883 <ilock>
  pgdir = 0;
80100b3e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100b45:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100b4b:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100b52:	00 
80100b53:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100b5a:	00 
80100b5b:	89 44 24 04          	mov    %eax,0x4(%esp)
80100b5f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b62:	89 04 24             	mov    %eax,(%esp)
80100b65:	e8 12 12 00 00       	call   80101d7c <readi>
80100b6a:	83 f8 33             	cmp    $0x33,%eax
80100b6d:	0f 86 59 03 00 00    	jbe    80100ecc <exec+0x3c0>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100b73:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100b79:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100b7e:	0f 85 4b 03 00 00    	jne    80100ecf <exec+0x3c3>
    goto bad;

  if((pgdir = setupkvm(kalloc)) == 0)
80100b84:	c7 04 24 22 2b 10 80 	movl   $0x80102b22,(%esp)
80100b8b:	e8 02 6e 00 00       	call   80107992 <setupkvm>
80100b90:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100b93:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100b97:	0f 84 35 03 00 00    	je     80100ed2 <exec+0x3c6>
    goto bad;

  // Load program into memory.
  sz = 0;
80100b9d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100ba4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100bab:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100bb1:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100bb4:	e9 ca 00 00 00       	jmp    80100c83 <exec+0x177>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100bb9:	8b 55 e8             	mov    -0x18(%ebp),%edx
80100bbc:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100bc2:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100bc9:	00 
80100bca:	89 54 24 08          	mov    %edx,0x8(%esp)
80100bce:	89 44 24 04          	mov    %eax,0x4(%esp)
80100bd2:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100bd5:	89 04 24             	mov    %eax,(%esp)
80100bd8:	e8 9f 11 00 00       	call   80101d7c <readi>
80100bdd:	83 f8 20             	cmp    $0x20,%eax
80100be0:	0f 85 ef 02 00 00    	jne    80100ed5 <exec+0x3c9>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100be6:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100bec:	83 f8 01             	cmp    $0x1,%eax
80100bef:	0f 85 80 00 00 00    	jne    80100c75 <exec+0x169>
      continue;
    if(ph.memsz < ph.filesz)
80100bf5:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100bfb:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c01:	39 c2                	cmp    %eax,%edx
80100c03:	0f 82 cf 02 00 00    	jb     80100ed8 <exec+0x3cc>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c09:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100c0f:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c15:	8d 04 02             	lea    (%edx,%eax,1),%eax
80100c18:	89 44 24 08          	mov    %eax,0x8(%esp)
80100c1c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c1f:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c23:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c26:	89 04 24             	mov    %eax,(%esp)
80100c29:	e8 38 71 00 00       	call   80107d66 <allocuvm>
80100c2e:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c31:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c35:	0f 84 a0 02 00 00    	je     80100edb <exec+0x3cf>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c3b:	8b 8d fc fe ff ff    	mov    -0x104(%ebp),%ecx
80100c41:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c47:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100c4d:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100c51:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100c55:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100c58:	89 54 24 08          	mov    %edx,0x8(%esp)
80100c5c:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c60:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c63:	89 04 24             	mov    %eax,(%esp)
80100c66:	e8 0b 70 00 00       	call   80107c76 <loaduvm>
80100c6b:	85 c0                	test   %eax,%eax
80100c6d:	0f 88 6b 02 00 00    	js     80100ede <exec+0x3d2>
80100c73:	eb 01                	jmp    80100c76 <exec+0x16a>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100c75:	90                   	nop
  if((pgdir = setupkvm(kalloc)) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c76:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100c7a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c7d:	83 c0 20             	add    $0x20,%eax
80100c80:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c83:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100c8a:	0f b7 c0             	movzwl %ax,%eax
80100c8d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100c90:	0f 8f 23 ff ff ff    	jg     80100bb9 <exec+0xad>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100c96:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100c99:	89 04 24             	mov    %eax,(%esp)
80100c9c:	e8 69 0e 00 00       	call   80101b0a <iunlockput>
  ip = 0;
80100ca1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100ca8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cab:	05 ff 0f 00 00       	add    $0xfff,%eax
80100cb0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100cb5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100cb8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cbb:	05 00 20 00 00       	add    $0x2000,%eax
80100cc0:	89 44 24 08          	mov    %eax,0x8(%esp)
80100cc4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cc7:	89 44 24 04          	mov    %eax,0x4(%esp)
80100ccb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100cce:	89 04 24             	mov    %eax,(%esp)
80100cd1:	e8 90 70 00 00       	call   80107d66 <allocuvm>
80100cd6:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cd9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cdd:	0f 84 fe 01 00 00    	je     80100ee1 <exec+0x3d5>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100ce3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100ce6:	2d 00 20 00 00       	sub    $0x2000,%eax
80100ceb:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cef:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100cf2:	89 04 24             	mov    %eax,(%esp)
80100cf5:	e8 90 72 00 00       	call   80107f8a <clearpteu>
  sp = sz;
80100cfa:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cfd:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d00:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d07:	e9 81 00 00 00       	jmp    80100d8d <exec+0x281>
    if(argc >= MAXARG)
80100d0c:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d10:	0f 87 ce 01 00 00    	ja     80100ee4 <exec+0x3d8>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d16:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d19:	c1 e0 02             	shl    $0x2,%eax
80100d1c:	03 45 0c             	add    0xc(%ebp),%eax
80100d1f:	8b 00                	mov    (%eax),%eax
80100d21:	89 04 24             	mov    %eax,(%esp)
80100d24:	e8 53 43 00 00       	call   8010507c <strlen>
80100d29:	f7 d0                	not    %eax
80100d2b:	03 45 dc             	add    -0x24(%ebp),%eax
80100d2e:	83 e0 fc             	and    $0xfffffffc,%eax
80100d31:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d34:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d37:	c1 e0 02             	shl    $0x2,%eax
80100d3a:	03 45 0c             	add    0xc(%ebp),%eax
80100d3d:	8b 00                	mov    (%eax),%eax
80100d3f:	89 04 24             	mov    %eax,(%esp)
80100d42:	e8 35 43 00 00       	call   8010507c <strlen>
80100d47:	83 c0 01             	add    $0x1,%eax
80100d4a:	89 c2                	mov    %eax,%edx
80100d4c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d4f:	c1 e0 02             	shl    $0x2,%eax
80100d52:	03 45 0c             	add    0xc(%ebp),%eax
80100d55:	8b 00                	mov    (%eax),%eax
80100d57:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100d5b:	89 44 24 08          	mov    %eax,0x8(%esp)
80100d5f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d62:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d66:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100d69:	89 04 24             	mov    %eax,(%esp)
80100d6c:	e8 cd 73 00 00       	call   8010813e <copyout>
80100d71:	85 c0                	test   %eax,%eax
80100d73:	0f 88 6e 01 00 00    	js     80100ee7 <exec+0x3db>
      goto bad;
    ustack[3+argc] = sp;
80100d79:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d7c:	8d 50 03             	lea    0x3(%eax),%edx
80100d7f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d82:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d89:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100d8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d90:	c1 e0 02             	shl    $0x2,%eax
80100d93:	03 45 0c             	add    0xc(%ebp),%eax
80100d96:	8b 00                	mov    (%eax),%eax
80100d98:	85 c0                	test   %eax,%eax
80100d9a:	0f 85 6c ff ff ff    	jne    80100d0c <exec+0x200>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100da0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100da3:	83 c0 03             	add    $0x3,%eax
80100da6:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100dad:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100db1:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100db8:	ff ff ff 
  ustack[1] = argc;
80100dbb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dbe:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100dc4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dc7:	83 c0 01             	add    $0x1,%eax
80100dca:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dd1:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dd4:	29 d0                	sub    %edx,%eax
80100dd6:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100ddc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ddf:	83 c0 04             	add    $0x4,%eax
80100de2:	c1 e0 02             	shl    $0x2,%eax
80100de5:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100de8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100deb:	83 c0 04             	add    $0x4,%eax
80100dee:	c1 e0 02             	shl    $0x2,%eax
80100df1:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100df5:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100dfb:	89 44 24 08          	mov    %eax,0x8(%esp)
80100dff:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e02:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e06:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100e09:	89 04 24             	mov    %eax,(%esp)
80100e0c:	e8 2d 73 00 00       	call   8010813e <copyout>
80100e11:	85 c0                	test   %eax,%eax
80100e13:	0f 88 d1 00 00 00    	js     80100eea <exec+0x3de>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e19:	8b 45 08             	mov    0x8(%ebp),%eax
80100e1c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100e1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e22:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100e25:	eb 17                	jmp    80100e3e <exec+0x332>
    if(*s == '/')
80100e27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e2a:	0f b6 00             	movzbl (%eax),%eax
80100e2d:	3c 2f                	cmp    $0x2f,%al
80100e2f:	75 09                	jne    80100e3a <exec+0x32e>
      last = s+1;
80100e31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e34:	83 c0 01             	add    $0x1,%eax
80100e37:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e3a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100e3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e41:	0f b6 00             	movzbl (%eax),%eax
80100e44:	84 c0                	test   %al,%al
80100e46:	75 df                	jne    80100e27 <exec+0x31b>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100e48:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e4e:	8d 50 6c             	lea    0x6c(%eax),%edx
80100e51:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80100e58:	00 
80100e59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100e5c:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e60:	89 14 24             	mov    %edx,(%esp)
80100e63:	e8 c6 41 00 00       	call   8010502e <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100e68:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e6e:	8b 40 04             	mov    0x4(%eax),%eax
80100e71:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100e74:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e7a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100e7d:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100e80:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e86:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100e89:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100e8b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e91:	8b 40 18             	mov    0x18(%eax),%eax
80100e94:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100e9a:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100e9d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ea3:	8b 40 18             	mov    0x18(%eax),%eax
80100ea6:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100ea9:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100eac:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eb2:	89 04 24             	mov    %eax,(%esp)
80100eb5:	e8 ca 6b 00 00       	call   80107a84 <switchuvm>
  freevm(oldpgdir);
80100eba:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100ebd:	89 04 24             	mov    %eax,(%esp)
80100ec0:	e8 37 70 00 00       	call   80107efc <freevm>
  return 0;
80100ec5:	b8 00 00 00 00       	mov    $0x0,%eax
80100eca:	eb 46                	jmp    80100f12 <exec+0x406>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
80100ecc:	90                   	nop
80100ecd:	eb 1c                	jmp    80100eeb <exec+0x3df>
  if(elf.magic != ELF_MAGIC)
    goto bad;
80100ecf:	90                   	nop
80100ed0:	eb 19                	jmp    80100eeb <exec+0x3df>

  if((pgdir = setupkvm(kalloc)) == 0)
    goto bad;
80100ed2:	90                   	nop
80100ed3:	eb 16                	jmp    80100eeb <exec+0x3df>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80100ed5:	90                   	nop
80100ed6:	eb 13                	jmp    80100eeb <exec+0x3df>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80100ed8:	90                   	nop
80100ed9:	eb 10                	jmp    80100eeb <exec+0x3df>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
80100edb:	90                   	nop
80100edc:	eb 0d                	jmp    80100eeb <exec+0x3df>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80100ede:	90                   	nop
80100edf:	eb 0a                	jmp    80100eeb <exec+0x3df>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
80100ee1:	90                   	nop
80100ee2:	eb 07                	jmp    80100eeb <exec+0x3df>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80100ee4:	90                   	nop
80100ee5:	eb 04                	jmp    80100eeb <exec+0x3df>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80100ee7:	90                   	nop
80100ee8:	eb 01                	jmp    80100eeb <exec+0x3df>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
80100eea:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
80100eeb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100eef:	74 0b                	je     80100efc <exec+0x3f0>
    freevm(pgdir);
80100ef1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100ef4:	89 04 24             	mov    %eax,(%esp)
80100ef7:	e8 00 70 00 00       	call   80107efc <freevm>
  if(ip)
80100efc:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f00:	74 0b                	je     80100f0d <exec+0x401>
    iunlockput(ip);
80100f02:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100f05:	89 04 24             	mov    %eax,(%esp)
80100f08:	e8 fd 0b 00 00       	call   80101b0a <iunlockput>
  return -1;
80100f0d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100f12:	c9                   	leave  
80100f13:	c3                   	ret    

80100f14 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f14:	55                   	push   %ebp
80100f15:	89 e5                	mov    %esp,%ebp
80100f17:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
80100f1a:	c7 44 24 04 45 82 10 	movl   $0x80108245,0x4(%esp)
80100f21:	80 
80100f22:	c7 04 24 60 de 10 80 	movl   $0x8010de60,(%esp)
80100f29:	e8 5c 3c 00 00       	call   80104b8a <initlock>
}
80100f2e:	c9                   	leave  
80100f2f:	c3                   	ret    

80100f30 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f30:	55                   	push   %ebp
80100f31:	89 e5                	mov    %esp,%ebp
80100f33:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
80100f36:	c7 04 24 60 de 10 80 	movl   $0x8010de60,(%esp)
80100f3d:	e8 69 3c 00 00       	call   80104bab <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f42:	c7 45 f4 94 de 10 80 	movl   $0x8010de94,-0xc(%ebp)
80100f49:	eb 29                	jmp    80100f74 <filealloc+0x44>
    if(f->ref == 0){
80100f4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f4e:	8b 40 04             	mov    0x4(%eax),%eax
80100f51:	85 c0                	test   %eax,%eax
80100f53:	75 1b                	jne    80100f70 <filealloc+0x40>
      f->ref = 1;
80100f55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f58:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100f5f:	c7 04 24 60 de 10 80 	movl   $0x8010de60,(%esp)
80100f66:	e8 a2 3c 00 00       	call   80104c0d <release>
      return f;
80100f6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f6e:	eb 1f                	jmp    80100f8f <filealloc+0x5f>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f70:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100f74:	b8 f4 e7 10 80       	mov    $0x8010e7f4,%eax
80100f79:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100f7c:	72 cd                	jb     80100f4b <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100f7e:	c7 04 24 60 de 10 80 	movl   $0x8010de60,(%esp)
80100f85:	e8 83 3c 00 00       	call   80104c0d <release>
  return 0;
80100f8a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100f8f:	c9                   	leave  
80100f90:	c3                   	ret    

80100f91 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100f91:	55                   	push   %ebp
80100f92:	89 e5                	mov    %esp,%ebp
80100f94:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
80100f97:	c7 04 24 60 de 10 80 	movl   $0x8010de60,(%esp)
80100f9e:	e8 08 3c 00 00       	call   80104bab <acquire>
  if(f->ref < 1)
80100fa3:	8b 45 08             	mov    0x8(%ebp),%eax
80100fa6:	8b 40 04             	mov    0x4(%eax),%eax
80100fa9:	85 c0                	test   %eax,%eax
80100fab:	7f 0c                	jg     80100fb9 <filedup+0x28>
    panic("filedup");
80100fad:	c7 04 24 4c 82 10 80 	movl   $0x8010824c,(%esp)
80100fb4:	e8 8d f5 ff ff       	call   80100546 <panic>
  f->ref++;
80100fb9:	8b 45 08             	mov    0x8(%ebp),%eax
80100fbc:	8b 40 04             	mov    0x4(%eax),%eax
80100fbf:	8d 50 01             	lea    0x1(%eax),%edx
80100fc2:	8b 45 08             	mov    0x8(%ebp),%eax
80100fc5:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80100fc8:	c7 04 24 60 de 10 80 	movl   $0x8010de60,(%esp)
80100fcf:	e8 39 3c 00 00       	call   80104c0d <release>
  return f;
80100fd4:	8b 45 08             	mov    0x8(%ebp),%eax
}
80100fd7:	c9                   	leave  
80100fd8:	c3                   	ret    

80100fd9 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100fd9:	55                   	push   %ebp
80100fda:	89 e5                	mov    %esp,%ebp
80100fdc:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
80100fdf:	c7 04 24 60 de 10 80 	movl   $0x8010de60,(%esp)
80100fe6:	e8 c0 3b 00 00       	call   80104bab <acquire>
  if(f->ref < 1)
80100feb:	8b 45 08             	mov    0x8(%ebp),%eax
80100fee:	8b 40 04             	mov    0x4(%eax),%eax
80100ff1:	85 c0                	test   %eax,%eax
80100ff3:	7f 0c                	jg     80101001 <fileclose+0x28>
    panic("fileclose");
80100ff5:	c7 04 24 54 82 10 80 	movl   $0x80108254,(%esp)
80100ffc:	e8 45 f5 ff ff       	call   80100546 <panic>
  if(--f->ref > 0){
80101001:	8b 45 08             	mov    0x8(%ebp),%eax
80101004:	8b 40 04             	mov    0x4(%eax),%eax
80101007:	8d 50 ff             	lea    -0x1(%eax),%edx
8010100a:	8b 45 08             	mov    0x8(%ebp),%eax
8010100d:	89 50 04             	mov    %edx,0x4(%eax)
80101010:	8b 45 08             	mov    0x8(%ebp),%eax
80101013:	8b 40 04             	mov    0x4(%eax),%eax
80101016:	85 c0                	test   %eax,%eax
80101018:	7e 11                	jle    8010102b <fileclose+0x52>
    release(&ftable.lock);
8010101a:	c7 04 24 60 de 10 80 	movl   $0x8010de60,(%esp)
80101021:	e8 e7 3b 00 00       	call   80104c0d <release>
    return;
80101026:	e9 82 00 00 00       	jmp    801010ad <fileclose+0xd4>
  }
  ff = *f;
8010102b:	8b 45 08             	mov    0x8(%ebp),%eax
8010102e:	8b 10                	mov    (%eax),%edx
80101030:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101033:	8b 50 04             	mov    0x4(%eax),%edx
80101036:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101039:	8b 50 08             	mov    0x8(%eax),%edx
8010103c:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010103f:	8b 50 0c             	mov    0xc(%eax),%edx
80101042:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101045:	8b 50 10             	mov    0x10(%eax),%edx
80101048:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010104b:	8b 40 14             	mov    0x14(%eax),%eax
8010104e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101051:	8b 45 08             	mov    0x8(%ebp),%eax
80101054:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
8010105b:	8b 45 08             	mov    0x8(%ebp),%eax
8010105e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101064:	c7 04 24 60 de 10 80 	movl   $0x8010de60,(%esp)
8010106b:	e8 9d 3b 00 00       	call   80104c0d <release>
  
  if(ff.type == FD_PIPE)
80101070:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101073:	83 f8 01             	cmp    $0x1,%eax
80101076:	75 18                	jne    80101090 <fileclose+0xb7>
    pipeclose(ff.pipe, ff.writable);
80101078:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010107c:	0f be d0             	movsbl %al,%edx
8010107f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101082:	89 54 24 04          	mov    %edx,0x4(%esp)
80101086:	89 04 24             	mov    %eax,(%esp)
80101089:	e8 15 2d 00 00       	call   80103da3 <pipeclose>
8010108e:	eb 1d                	jmp    801010ad <fileclose+0xd4>
  else if(ff.type == FD_INODE){
80101090:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101093:	83 f8 02             	cmp    $0x2,%eax
80101096:	75 15                	jne    801010ad <fileclose+0xd4>
    begin_trans();
80101098:	e8 a4 21 00 00       	call   80103241 <begin_trans>
    iput(ff.ip);
8010109d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801010a0:	89 04 24             	mov    %eax,(%esp)
801010a3:	e8 91 09 00 00       	call   80101a39 <iput>
    commit_trans();
801010a8:	e8 dd 21 00 00       	call   8010328a <commit_trans>
  }
}
801010ad:	c9                   	leave  
801010ae:	c3                   	ret    

801010af <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801010af:	55                   	push   %ebp
801010b0:	89 e5                	mov    %esp,%ebp
801010b2:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
801010b5:	8b 45 08             	mov    0x8(%ebp),%eax
801010b8:	8b 00                	mov    (%eax),%eax
801010ba:	83 f8 02             	cmp    $0x2,%eax
801010bd:	75 38                	jne    801010f7 <filestat+0x48>
    ilock(f->ip);
801010bf:	8b 45 08             	mov    0x8(%ebp),%eax
801010c2:	8b 40 10             	mov    0x10(%eax),%eax
801010c5:	89 04 24             	mov    %eax,(%esp)
801010c8:	e8 b6 07 00 00       	call   80101883 <ilock>
    stati(f->ip, st);
801010cd:	8b 45 08             	mov    0x8(%ebp),%eax
801010d0:	8b 40 10             	mov    0x10(%eax),%eax
801010d3:	8b 55 0c             	mov    0xc(%ebp),%edx
801010d6:	89 54 24 04          	mov    %edx,0x4(%esp)
801010da:	89 04 24             	mov    %eax,(%esp)
801010dd:	e8 55 0c 00 00       	call   80101d37 <stati>
    iunlock(f->ip);
801010e2:	8b 45 08             	mov    0x8(%ebp),%eax
801010e5:	8b 40 10             	mov    0x10(%eax),%eax
801010e8:	89 04 24             	mov    %eax,(%esp)
801010eb:	e8 e4 08 00 00       	call   801019d4 <iunlock>
    return 0;
801010f0:	b8 00 00 00 00       	mov    $0x0,%eax
801010f5:	eb 05                	jmp    801010fc <filestat+0x4d>
  }
  return -1;
801010f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801010fc:	c9                   	leave  
801010fd:	c3                   	ret    

801010fe <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801010fe:	55                   	push   %ebp
801010ff:	89 e5                	mov    %esp,%ebp
80101101:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
80101104:	8b 45 08             	mov    0x8(%ebp),%eax
80101107:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010110b:	84 c0                	test   %al,%al
8010110d:	75 0a                	jne    80101119 <fileread+0x1b>
    return -1;
8010110f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101114:	e9 9f 00 00 00       	jmp    801011b8 <fileread+0xba>
  if(f->type == FD_PIPE)
80101119:	8b 45 08             	mov    0x8(%ebp),%eax
8010111c:	8b 00                	mov    (%eax),%eax
8010111e:	83 f8 01             	cmp    $0x1,%eax
80101121:	75 1e                	jne    80101141 <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101123:	8b 45 08             	mov    0x8(%ebp),%eax
80101126:	8b 40 0c             	mov    0xc(%eax),%eax
80101129:	8b 55 10             	mov    0x10(%ebp),%edx
8010112c:	89 54 24 08          	mov    %edx,0x8(%esp)
80101130:	8b 55 0c             	mov    0xc(%ebp),%edx
80101133:	89 54 24 04          	mov    %edx,0x4(%esp)
80101137:	89 04 24             	mov    %eax,(%esp)
8010113a:	e8 e6 2d 00 00       	call   80103f25 <piperead>
8010113f:	eb 77                	jmp    801011b8 <fileread+0xba>
  if(f->type == FD_INODE){
80101141:	8b 45 08             	mov    0x8(%ebp),%eax
80101144:	8b 00                	mov    (%eax),%eax
80101146:	83 f8 02             	cmp    $0x2,%eax
80101149:	75 61                	jne    801011ac <fileread+0xae>
    ilock(f->ip);
8010114b:	8b 45 08             	mov    0x8(%ebp),%eax
8010114e:	8b 40 10             	mov    0x10(%eax),%eax
80101151:	89 04 24             	mov    %eax,(%esp)
80101154:	e8 2a 07 00 00       	call   80101883 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101159:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010115c:	8b 45 08             	mov    0x8(%ebp),%eax
8010115f:	8b 50 14             	mov    0x14(%eax),%edx
80101162:	8b 45 08             	mov    0x8(%ebp),%eax
80101165:	8b 40 10             	mov    0x10(%eax),%eax
80101168:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010116c:	89 54 24 08          	mov    %edx,0x8(%esp)
80101170:	8b 55 0c             	mov    0xc(%ebp),%edx
80101173:	89 54 24 04          	mov    %edx,0x4(%esp)
80101177:	89 04 24             	mov    %eax,(%esp)
8010117a:	e8 fd 0b 00 00       	call   80101d7c <readi>
8010117f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101182:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101186:	7e 11                	jle    80101199 <fileread+0x9b>
      f->off += r;
80101188:	8b 45 08             	mov    0x8(%ebp),%eax
8010118b:	8b 50 14             	mov    0x14(%eax),%edx
8010118e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101191:	01 c2                	add    %eax,%edx
80101193:	8b 45 08             	mov    0x8(%ebp),%eax
80101196:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101199:	8b 45 08             	mov    0x8(%ebp),%eax
8010119c:	8b 40 10             	mov    0x10(%eax),%eax
8010119f:	89 04 24             	mov    %eax,(%esp)
801011a2:	e8 2d 08 00 00       	call   801019d4 <iunlock>
    return r;
801011a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011aa:	eb 0c                	jmp    801011b8 <fileread+0xba>
  }
  panic("fileread");
801011ac:	c7 04 24 5e 82 10 80 	movl   $0x8010825e,(%esp)
801011b3:	e8 8e f3 ff ff       	call   80100546 <panic>
}
801011b8:	c9                   	leave  
801011b9:	c3                   	ret    

801011ba <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801011ba:	55                   	push   %ebp
801011bb:	89 e5                	mov    %esp,%ebp
801011bd:	53                   	push   %ebx
801011be:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
801011c1:	8b 45 08             	mov    0x8(%ebp),%eax
801011c4:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801011c8:	84 c0                	test   %al,%al
801011ca:	75 0a                	jne    801011d6 <filewrite+0x1c>
    return -1;
801011cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011d1:	e9 23 01 00 00       	jmp    801012f9 <filewrite+0x13f>
  if(f->type == FD_PIPE)
801011d6:	8b 45 08             	mov    0x8(%ebp),%eax
801011d9:	8b 00                	mov    (%eax),%eax
801011db:	83 f8 01             	cmp    $0x1,%eax
801011de:	75 21                	jne    80101201 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
801011e0:	8b 45 08             	mov    0x8(%ebp),%eax
801011e3:	8b 40 0c             	mov    0xc(%eax),%eax
801011e6:	8b 55 10             	mov    0x10(%ebp),%edx
801011e9:	89 54 24 08          	mov    %edx,0x8(%esp)
801011ed:	8b 55 0c             	mov    0xc(%ebp),%edx
801011f0:	89 54 24 04          	mov    %edx,0x4(%esp)
801011f4:	89 04 24             	mov    %eax,(%esp)
801011f7:	e8 39 2c 00 00       	call   80103e35 <pipewrite>
801011fc:	e9 f8 00 00 00       	jmp    801012f9 <filewrite+0x13f>
  if(f->type == FD_INODE){
80101201:	8b 45 08             	mov    0x8(%ebp),%eax
80101204:	8b 00                	mov    (%eax),%eax
80101206:	83 f8 02             	cmp    $0x2,%eax
80101209:	0f 85 de 00 00 00    	jne    801012ed <filewrite+0x133>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
8010120f:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
80101216:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
8010121d:	e9 a8 00 00 00       	jmp    801012ca <filewrite+0x110>
      int n1 = n - i;
80101222:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101225:	8b 55 10             	mov    0x10(%ebp),%edx
80101228:	89 d1                	mov    %edx,%ecx
8010122a:	29 c1                	sub    %eax,%ecx
8010122c:	89 c8                	mov    %ecx,%eax
8010122e:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101231:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101234:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101237:	7e 06                	jle    8010123f <filewrite+0x85>
        n1 = max;
80101239:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010123c:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_trans();
8010123f:	e8 fd 1f 00 00       	call   80103241 <begin_trans>
      ilock(f->ip);
80101244:	8b 45 08             	mov    0x8(%ebp),%eax
80101247:	8b 40 10             	mov    0x10(%eax),%eax
8010124a:	89 04 24             	mov    %eax,(%esp)
8010124d:	e8 31 06 00 00       	call   80101883 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101252:	8b 5d f0             	mov    -0x10(%ebp),%ebx
80101255:	8b 45 08             	mov    0x8(%ebp),%eax
80101258:	8b 48 14             	mov    0x14(%eax),%ecx
8010125b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010125e:	89 c2                	mov    %eax,%edx
80101260:	03 55 0c             	add    0xc(%ebp),%edx
80101263:	8b 45 08             	mov    0x8(%ebp),%eax
80101266:	8b 40 10             	mov    0x10(%eax),%eax
80101269:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
8010126d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80101271:	89 54 24 04          	mov    %edx,0x4(%esp)
80101275:	89 04 24             	mov    %eax,(%esp)
80101278:	e8 6b 0c 00 00       	call   80101ee8 <writei>
8010127d:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101280:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101284:	7e 11                	jle    80101297 <filewrite+0xdd>
        f->off += r;
80101286:	8b 45 08             	mov    0x8(%ebp),%eax
80101289:	8b 50 14             	mov    0x14(%eax),%edx
8010128c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010128f:	01 c2                	add    %eax,%edx
80101291:	8b 45 08             	mov    0x8(%ebp),%eax
80101294:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101297:	8b 45 08             	mov    0x8(%ebp),%eax
8010129a:	8b 40 10             	mov    0x10(%eax),%eax
8010129d:	89 04 24             	mov    %eax,(%esp)
801012a0:	e8 2f 07 00 00       	call   801019d4 <iunlock>
      commit_trans();
801012a5:	e8 e0 1f 00 00       	call   8010328a <commit_trans>

      if(r < 0)
801012aa:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801012ae:	78 28                	js     801012d8 <filewrite+0x11e>
        break;
      if(r != n1)
801012b0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012b3:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801012b6:	74 0c                	je     801012c4 <filewrite+0x10a>
        panic("short filewrite");
801012b8:	c7 04 24 67 82 10 80 	movl   $0x80108267,(%esp)
801012bf:	e8 82 f2 ff ff       	call   80100546 <panic>
      i += r;
801012c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012c7:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801012ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012cd:	3b 45 10             	cmp    0x10(%ebp),%eax
801012d0:	0f 8c 4c ff ff ff    	jl     80101222 <filewrite+0x68>
801012d6:	eb 01                	jmp    801012d9 <filewrite+0x11f>
        f->off += r;
      iunlock(f->ip);
      commit_trans();

      if(r < 0)
        break;
801012d8:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
801012d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012dc:	3b 45 10             	cmp    0x10(%ebp),%eax
801012df:	75 05                	jne    801012e6 <filewrite+0x12c>
801012e1:	8b 45 10             	mov    0x10(%ebp),%eax
801012e4:	eb 05                	jmp    801012eb <filewrite+0x131>
801012e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012eb:	eb 0c                	jmp    801012f9 <filewrite+0x13f>
  }
  panic("filewrite");
801012ed:	c7 04 24 77 82 10 80 	movl   $0x80108277,(%esp)
801012f4:	e8 4d f2 ff ff       	call   80100546 <panic>
}
801012f9:	83 c4 24             	add    $0x24,%esp
801012fc:	5b                   	pop    %ebx
801012fd:	5d                   	pop    %ebp
801012fe:	c3                   	ret    
	...

80101300 <readsb>:
static void itrunc(struct inode*);

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101300:	55                   	push   %ebp
80101301:	89 e5                	mov    %esp,%ebp
80101303:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
80101306:	8b 45 08             	mov    0x8(%ebp),%eax
80101309:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80101310:	00 
80101311:	89 04 24             	mov    %eax,(%esp)
80101314:	e8 8e ee ff ff       	call   801001a7 <bread>
80101319:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
8010131c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010131f:	83 c0 18             	add    $0x18,%eax
80101322:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80101329:	00 
8010132a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010132e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101331:	89 04 24             	mov    %eax,(%esp)
80101334:	e8 94 3b 00 00       	call   80104ecd <memmove>
  brelse(bp);
80101339:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010133c:	89 04 24             	mov    %eax,(%esp)
8010133f:	e8 d4 ee ff ff       	call   80100218 <brelse>
}
80101344:	c9                   	leave  
80101345:	c3                   	ret    

80101346 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101346:	55                   	push   %ebp
80101347:	89 e5                	mov    %esp,%ebp
80101349:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
8010134c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010134f:	8b 45 08             	mov    0x8(%ebp),%eax
80101352:	89 54 24 04          	mov    %edx,0x4(%esp)
80101356:	89 04 24             	mov    %eax,(%esp)
80101359:	e8 49 ee ff ff       	call   801001a7 <bread>
8010135e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101361:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101364:	83 c0 18             	add    $0x18,%eax
80101367:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010136e:	00 
8010136f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101376:	00 
80101377:	89 04 24             	mov    %eax,(%esp)
8010137a:	e8 7b 3a 00 00       	call   80104dfa <memset>
  log_write(bp);
8010137f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101382:	89 04 24             	mov    %eax,(%esp)
80101385:	e8 58 1f 00 00       	call   801032e2 <log_write>
  brelse(bp);
8010138a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010138d:	89 04 24             	mov    %eax,(%esp)
80101390:	e8 83 ee ff ff       	call   80100218 <brelse>
}
80101395:	c9                   	leave  
80101396:	c3                   	ret    

80101397 <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101397:	55                   	push   %ebp
80101398:	89 e5                	mov    %esp,%ebp
8010139a:	53                   	push   %ebx
8010139b:	83 ec 34             	sub    $0x34,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
8010139e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  readsb(dev, &sb);
801013a5:	8b 45 08             	mov    0x8(%ebp),%eax
801013a8:	8d 55 d8             	lea    -0x28(%ebp),%edx
801013ab:	89 54 24 04          	mov    %edx,0x4(%esp)
801013af:	89 04 24             	mov    %eax,(%esp)
801013b2:	e8 49 ff ff ff       	call   80101300 <readsb>
  for(b = 0; b < sb.size; b += BPB){
801013b7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801013be:	e9 13 01 00 00       	jmp    801014d6 <balloc+0x13f>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
801013c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013c6:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801013cc:	85 c0                	test   %eax,%eax
801013ce:	0f 48 c2             	cmovs  %edx,%eax
801013d1:	c1 f8 0c             	sar    $0xc,%eax
801013d4:	8b 55 e0             	mov    -0x20(%ebp),%edx
801013d7:	c1 ea 03             	shr    $0x3,%edx
801013da:	01 d0                	add    %edx,%eax
801013dc:	83 c0 03             	add    $0x3,%eax
801013df:	89 44 24 04          	mov    %eax,0x4(%esp)
801013e3:	8b 45 08             	mov    0x8(%ebp),%eax
801013e6:	89 04 24             	mov    %eax,(%esp)
801013e9:	e8 b9 ed ff ff       	call   801001a7 <bread>
801013ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801013f1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801013f8:	e9 a8 00 00 00       	jmp    801014a5 <balloc+0x10e>
      m = 1 << (bi % 8);
801013fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101400:	89 c2                	mov    %eax,%edx
80101402:	c1 fa 1f             	sar    $0x1f,%edx
80101405:	c1 ea 1d             	shr    $0x1d,%edx
80101408:	01 d0                	add    %edx,%eax
8010140a:	83 e0 07             	and    $0x7,%eax
8010140d:	29 d0                	sub    %edx,%eax
8010140f:	ba 01 00 00 00       	mov    $0x1,%edx
80101414:	89 d3                	mov    %edx,%ebx
80101416:	89 c1                	mov    %eax,%ecx
80101418:	d3 e3                	shl    %cl,%ebx
8010141a:	89 d8                	mov    %ebx,%eax
8010141c:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010141f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101422:	8d 50 07             	lea    0x7(%eax),%edx
80101425:	85 c0                	test   %eax,%eax
80101427:	0f 48 c2             	cmovs  %edx,%eax
8010142a:	c1 f8 03             	sar    $0x3,%eax
8010142d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101430:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101435:	0f b6 c0             	movzbl %al,%eax
80101438:	23 45 e8             	and    -0x18(%ebp),%eax
8010143b:	85 c0                	test   %eax,%eax
8010143d:	75 62                	jne    801014a1 <balloc+0x10a>
        bp->data[bi/8] |= m;  // Mark block in use.
8010143f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101442:	8d 50 07             	lea    0x7(%eax),%edx
80101445:	85 c0                	test   %eax,%eax
80101447:	0f 48 c2             	cmovs  %edx,%eax
8010144a:	c1 f8 03             	sar    $0x3,%eax
8010144d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101450:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101455:	89 d1                	mov    %edx,%ecx
80101457:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010145a:	09 ca                	or     %ecx,%edx
8010145c:	89 d1                	mov    %edx,%ecx
8010145e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101461:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
80101465:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101468:	89 04 24             	mov    %eax,(%esp)
8010146b:	e8 72 1e 00 00       	call   801032e2 <log_write>
        brelse(bp);
80101470:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101473:	89 04 24             	mov    %eax,(%esp)
80101476:	e8 9d ed ff ff       	call   80100218 <brelse>
        bzero(dev, b + bi);
8010147b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010147e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101481:	01 c2                	add    %eax,%edx
80101483:	8b 45 08             	mov    0x8(%ebp),%eax
80101486:	89 54 24 04          	mov    %edx,0x4(%esp)
8010148a:	89 04 24             	mov    %eax,(%esp)
8010148d:	e8 b4 fe ff ff       	call   80101346 <bzero>
        return b + bi;
80101492:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101495:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101498:	8d 04 02             	lea    (%edx,%eax,1),%eax
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
}
8010149b:	83 c4 34             	add    $0x34,%esp
8010149e:	5b                   	pop    %ebx
8010149f:	5d                   	pop    %ebp
801014a0:	c3                   	ret    

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014a1:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801014a5:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801014ac:	7f 16                	jg     801014c4 <balloc+0x12d>
801014ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014b4:	8d 04 02             	lea    (%edx,%eax,1),%eax
801014b7:	89 c2                	mov    %eax,%edx
801014b9:	8b 45 d8             	mov    -0x28(%ebp),%eax
801014bc:	39 c2                	cmp    %eax,%edx
801014be:	0f 82 39 ff ff ff    	jb     801013fd <balloc+0x66>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
801014c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014c7:	89 04 24             	mov    %eax,(%esp)
801014ca:	e8 49 ed ff ff       	call   80100218 <brelse>
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
801014cf:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801014d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014d9:	8b 45 d8             	mov    -0x28(%ebp),%eax
801014dc:	39 c2                	cmp    %eax,%edx
801014de:	0f 82 df fe ff ff    	jb     801013c3 <balloc+0x2c>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
801014e4:	c7 04 24 81 82 10 80 	movl   $0x80108281,(%esp)
801014eb:	e8 56 f0 ff ff       	call   80100546 <panic>

801014f0 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
801014f0:	55                   	push   %ebp
801014f1:	89 e5                	mov    %esp,%ebp
801014f3:	53                   	push   %ebx
801014f4:	83 ec 34             	sub    $0x34,%esp
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
801014f7:	8d 45 dc             	lea    -0x24(%ebp),%eax
801014fa:	89 44 24 04          	mov    %eax,0x4(%esp)
801014fe:	8b 45 08             	mov    0x8(%ebp),%eax
80101501:	89 04 24             	mov    %eax,(%esp)
80101504:	e8 f7 fd ff ff       	call   80101300 <readsb>
  bp = bread(dev, BBLOCK(b, sb.ninodes));
80101509:	8b 45 0c             	mov    0xc(%ebp),%eax
8010150c:	89 c2                	mov    %eax,%edx
8010150e:	c1 ea 0c             	shr    $0xc,%edx
80101511:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101514:	c1 e8 03             	shr    $0x3,%eax
80101517:	8d 04 02             	lea    (%edx,%eax,1),%eax
8010151a:	8d 50 03             	lea    0x3(%eax),%edx
8010151d:	8b 45 08             	mov    0x8(%ebp),%eax
80101520:	89 54 24 04          	mov    %edx,0x4(%esp)
80101524:	89 04 24             	mov    %eax,(%esp)
80101527:	e8 7b ec ff ff       	call   801001a7 <bread>
8010152c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
8010152f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101532:	25 ff 0f 00 00       	and    $0xfff,%eax
80101537:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
8010153a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010153d:	89 c2                	mov    %eax,%edx
8010153f:	c1 fa 1f             	sar    $0x1f,%edx
80101542:	c1 ea 1d             	shr    $0x1d,%edx
80101545:	01 d0                	add    %edx,%eax
80101547:	83 e0 07             	and    $0x7,%eax
8010154a:	29 d0                	sub    %edx,%eax
8010154c:	ba 01 00 00 00       	mov    $0x1,%edx
80101551:	89 d3                	mov    %edx,%ebx
80101553:	89 c1                	mov    %eax,%ecx
80101555:	d3 e3                	shl    %cl,%ebx
80101557:	89 d8                	mov    %ebx,%eax
80101559:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
8010155c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010155f:	8d 50 07             	lea    0x7(%eax),%edx
80101562:	85 c0                	test   %eax,%eax
80101564:	0f 48 c2             	cmovs  %edx,%eax
80101567:	c1 f8 03             	sar    $0x3,%eax
8010156a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010156d:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101572:	0f b6 c0             	movzbl %al,%eax
80101575:	23 45 ec             	and    -0x14(%ebp),%eax
80101578:	85 c0                	test   %eax,%eax
8010157a:	75 0c                	jne    80101588 <bfree+0x98>
    panic("freeing free block");
8010157c:	c7 04 24 97 82 10 80 	movl   $0x80108297,(%esp)
80101583:	e8 be ef ff ff       	call   80100546 <panic>
  bp->data[bi/8] &= ~m;
80101588:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010158b:	8d 50 07             	lea    0x7(%eax),%edx
8010158e:	85 c0                	test   %eax,%eax
80101590:	0f 48 c2             	cmovs  %edx,%eax
80101593:	c1 f8 03             	sar    $0x3,%eax
80101596:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101599:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
8010159e:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801015a1:	f7 d1                	not    %ecx
801015a3:	21 ca                	and    %ecx,%edx
801015a5:	89 d1                	mov    %edx,%ecx
801015a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015aa:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
801015ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015b1:	89 04 24             	mov    %eax,(%esp)
801015b4:	e8 29 1d 00 00       	call   801032e2 <log_write>
  brelse(bp);
801015b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015bc:	89 04 24             	mov    %eax,(%esp)
801015bf:	e8 54 ec ff ff       	call   80100218 <brelse>
}
801015c4:	83 c4 34             	add    $0x34,%esp
801015c7:	5b                   	pop    %ebx
801015c8:	5d                   	pop    %ebp
801015c9:	c3                   	ret    

801015ca <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
801015ca:	55                   	push   %ebp
801015cb:	89 e5                	mov    %esp,%ebp
801015cd:	83 ec 18             	sub    $0x18,%esp
  initlock(&icache.lock, "icache");
801015d0:	c7 44 24 04 aa 82 10 	movl   $0x801082aa,0x4(%esp)
801015d7:	80 
801015d8:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
801015df:	e8 a6 35 00 00       	call   80104b8a <initlock>
}
801015e4:	c9                   	leave  
801015e5:	c3                   	ret    

801015e6 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
801015e6:	55                   	push   %ebp
801015e7:	89 e5                	mov    %esp,%ebp
801015e9:	83 ec 48             	sub    $0x48,%esp
801015ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801015ef:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
801015f3:	8b 45 08             	mov    0x8(%ebp),%eax
801015f6:	8d 55 dc             	lea    -0x24(%ebp),%edx
801015f9:	89 54 24 04          	mov    %edx,0x4(%esp)
801015fd:	89 04 24             	mov    %eax,(%esp)
80101600:	e8 fb fc ff ff       	call   80101300 <readsb>

  for(inum = 1; inum < sb.ninodes; inum++){
80101605:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
8010160c:	e9 98 00 00 00       	jmp    801016a9 <ialloc+0xc3>
    bp = bread(dev, IBLOCK(inum));
80101611:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101614:	c1 e8 03             	shr    $0x3,%eax
80101617:	83 c0 02             	add    $0x2,%eax
8010161a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010161e:	8b 45 08             	mov    0x8(%ebp),%eax
80101621:	89 04 24             	mov    %eax,(%esp)
80101624:	e8 7e eb ff ff       	call   801001a7 <bread>
80101629:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
8010162c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010162f:	83 c0 18             	add    $0x18,%eax
80101632:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101635:	83 e2 07             	and    $0x7,%edx
80101638:	c1 e2 06             	shl    $0x6,%edx
8010163b:	01 d0                	add    %edx,%eax
8010163d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101640:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101643:	0f b7 00             	movzwl (%eax),%eax
80101646:	66 85 c0             	test   %ax,%ax
80101649:	75 4f                	jne    8010169a <ialloc+0xb4>
      memset(dip, 0, sizeof(*dip));
8010164b:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
80101652:	00 
80101653:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010165a:	00 
8010165b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010165e:	89 04 24             	mov    %eax,(%esp)
80101661:	e8 94 37 00 00       	call   80104dfa <memset>
      dip->type = type;
80101666:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101669:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
8010166d:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101670:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101673:	89 04 24             	mov    %eax,(%esp)
80101676:	e8 67 1c 00 00       	call   801032e2 <log_write>
      brelse(bp);
8010167b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010167e:	89 04 24             	mov    %eax,(%esp)
80101681:	e8 92 eb ff ff       	call   80100218 <brelse>
      return iget(dev, inum);
80101686:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101689:	89 44 24 04          	mov    %eax,0x4(%esp)
8010168d:	8b 45 08             	mov    0x8(%ebp),%eax
80101690:	89 04 24             	mov    %eax,(%esp)
80101693:	e8 e6 00 00 00       	call   8010177e <iget>
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
}
80101698:	c9                   	leave  
80101699:	c3                   	ret    
      dip->type = type;
      log_write(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
8010169a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010169d:	89 04 24             	mov    %eax,(%esp)
801016a0:	e8 73 eb ff ff       	call   80100218 <brelse>
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);

  for(inum = 1; inum < sb.ninodes; inum++){
801016a5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801016a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801016af:	39 c2                	cmp    %eax,%edx
801016b1:	0f 82 5a ff ff ff    	jb     80101611 <ialloc+0x2b>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
801016b7:	c7 04 24 b1 82 10 80 	movl   $0x801082b1,(%esp)
801016be:	e8 83 ee ff ff       	call   80100546 <panic>

801016c3 <iupdate>:
}

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
801016c3:	55                   	push   %ebp
801016c4:	89 e5                	mov    %esp,%ebp
801016c6:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
801016c9:	8b 45 08             	mov    0x8(%ebp),%eax
801016cc:	8b 40 04             	mov    0x4(%eax),%eax
801016cf:	c1 e8 03             	shr    $0x3,%eax
801016d2:	8d 50 02             	lea    0x2(%eax),%edx
801016d5:	8b 45 08             	mov    0x8(%ebp),%eax
801016d8:	8b 00                	mov    (%eax),%eax
801016da:	89 54 24 04          	mov    %edx,0x4(%esp)
801016de:	89 04 24             	mov    %eax,(%esp)
801016e1:	e8 c1 ea ff ff       	call   801001a7 <bread>
801016e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801016e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016ec:	83 c0 18             	add    $0x18,%eax
801016ef:	89 c2                	mov    %eax,%edx
801016f1:	8b 45 08             	mov    0x8(%ebp),%eax
801016f4:	8b 40 04             	mov    0x4(%eax),%eax
801016f7:	83 e0 07             	and    $0x7,%eax
801016fa:	c1 e0 06             	shl    $0x6,%eax
801016fd:	8d 04 02             	lea    (%edx,%eax,1),%eax
80101700:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101703:	8b 45 08             	mov    0x8(%ebp),%eax
80101706:	0f b7 50 10          	movzwl 0x10(%eax),%edx
8010170a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010170d:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101710:	8b 45 08             	mov    0x8(%ebp),%eax
80101713:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101717:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010171a:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010171e:	8b 45 08             	mov    0x8(%ebp),%eax
80101721:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101725:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101728:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
8010172c:	8b 45 08             	mov    0x8(%ebp),%eax
8010172f:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101733:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101736:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
8010173a:	8b 45 08             	mov    0x8(%ebp),%eax
8010173d:	8b 50 18             	mov    0x18(%eax),%edx
80101740:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101743:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101746:	8b 45 08             	mov    0x8(%ebp),%eax
80101749:	8d 50 1c             	lea    0x1c(%eax),%edx
8010174c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010174f:	83 c0 0c             	add    $0xc,%eax
80101752:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101759:	00 
8010175a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010175e:	89 04 24             	mov    %eax,(%esp)
80101761:	e8 67 37 00 00       	call   80104ecd <memmove>
  log_write(bp);
80101766:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101769:	89 04 24             	mov    %eax,(%esp)
8010176c:	e8 71 1b 00 00       	call   801032e2 <log_write>
  brelse(bp);
80101771:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101774:	89 04 24             	mov    %eax,(%esp)
80101777:	e8 9c ea ff ff       	call   80100218 <brelse>
}
8010177c:	c9                   	leave  
8010177d:	c3                   	ret    

8010177e <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
8010177e:	55                   	push   %ebp
8010177f:	89 e5                	mov    %esp,%ebp
80101781:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101784:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
8010178b:	e8 1b 34 00 00       	call   80104bab <acquire>

  // Is the inode already cached?
  empty = 0;
80101790:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101797:	c7 45 f4 94 e8 10 80 	movl   $0x8010e894,-0xc(%ebp)
8010179e:	eb 59                	jmp    801017f9 <iget+0x7b>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801017a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017a3:	8b 40 08             	mov    0x8(%eax),%eax
801017a6:	85 c0                	test   %eax,%eax
801017a8:	7e 35                	jle    801017df <iget+0x61>
801017aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017ad:	8b 00                	mov    (%eax),%eax
801017af:	3b 45 08             	cmp    0x8(%ebp),%eax
801017b2:	75 2b                	jne    801017df <iget+0x61>
801017b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017b7:	8b 40 04             	mov    0x4(%eax),%eax
801017ba:	3b 45 0c             	cmp    0xc(%ebp),%eax
801017bd:	75 20                	jne    801017df <iget+0x61>
      ip->ref++;
801017bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017c2:	8b 40 08             	mov    0x8(%eax),%eax
801017c5:	8d 50 01             	lea    0x1(%eax),%edx
801017c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017cb:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
801017ce:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
801017d5:	e8 33 34 00 00       	call   80104c0d <release>
      return ip;
801017da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017dd:	eb 70                	jmp    8010184f <iget+0xd1>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801017df:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801017e3:	75 10                	jne    801017f5 <iget+0x77>
801017e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017e8:	8b 40 08             	mov    0x8(%eax),%eax
801017eb:	85 c0                	test   %eax,%eax
801017ed:	75 06                	jne    801017f5 <iget+0x77>
      empty = ip;
801017ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017f2:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801017f5:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
801017f9:	b8 34 f8 10 80       	mov    $0x8010f834,%eax
801017fe:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101801:	72 9d                	jb     801017a0 <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101803:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101807:	75 0c                	jne    80101815 <iget+0x97>
    panic("iget: no inodes");
80101809:	c7 04 24 c3 82 10 80 	movl   $0x801082c3,(%esp)
80101810:	e8 31 ed ff ff       	call   80100546 <panic>

  ip = empty;
80101815:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101818:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
8010181b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010181e:	8b 55 08             	mov    0x8(%ebp),%edx
80101821:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101823:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101826:	8b 55 0c             	mov    0xc(%ebp),%edx
80101829:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
8010182c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010182f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
80101836:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101839:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101840:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
80101847:	e8 c1 33 00 00       	call   80104c0d <release>

  return ip;
8010184c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010184f:	c9                   	leave  
80101850:	c3                   	ret    

80101851 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101851:	55                   	push   %ebp
80101852:	89 e5                	mov    %esp,%ebp
80101854:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101857:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
8010185e:	e8 48 33 00 00       	call   80104bab <acquire>
  ip->ref++;
80101863:	8b 45 08             	mov    0x8(%ebp),%eax
80101866:	8b 40 08             	mov    0x8(%eax),%eax
80101869:	8d 50 01             	lea    0x1(%eax),%edx
8010186c:	8b 45 08             	mov    0x8(%ebp),%eax
8010186f:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101872:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
80101879:	e8 8f 33 00 00       	call   80104c0d <release>
  return ip;
8010187e:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101881:	c9                   	leave  
80101882:	c3                   	ret    

80101883 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101883:	55                   	push   %ebp
80101884:	89 e5                	mov    %esp,%ebp
80101886:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101889:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010188d:	74 0a                	je     80101899 <ilock+0x16>
8010188f:	8b 45 08             	mov    0x8(%ebp),%eax
80101892:	8b 40 08             	mov    0x8(%eax),%eax
80101895:	85 c0                	test   %eax,%eax
80101897:	7f 0c                	jg     801018a5 <ilock+0x22>
    panic("ilock");
80101899:	c7 04 24 d3 82 10 80 	movl   $0x801082d3,(%esp)
801018a0:	e8 a1 ec ff ff       	call   80100546 <panic>

  acquire(&icache.lock);
801018a5:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
801018ac:	e8 fa 32 00 00       	call   80104bab <acquire>
  while(ip->flags & I_BUSY)
801018b1:	eb 13                	jmp    801018c6 <ilock+0x43>
    sleep(ip, &icache.lock);
801018b3:	c7 44 24 04 60 e8 10 	movl   $0x8010e860,0x4(%esp)
801018ba:	80 
801018bb:	8b 45 08             	mov    0x8(%ebp),%eax
801018be:	89 04 24             	mov    %eax,(%esp)
801018c1:	e8 e9 2f 00 00       	call   801048af <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
801018c6:	8b 45 08             	mov    0x8(%ebp),%eax
801018c9:	8b 40 0c             	mov    0xc(%eax),%eax
801018cc:	83 e0 01             	and    $0x1,%eax
801018cf:	84 c0                	test   %al,%al
801018d1:	75 e0                	jne    801018b3 <ilock+0x30>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
801018d3:	8b 45 08             	mov    0x8(%ebp),%eax
801018d6:	8b 40 0c             	mov    0xc(%eax),%eax
801018d9:	89 c2                	mov    %eax,%edx
801018db:	83 ca 01             	or     $0x1,%edx
801018de:	8b 45 08             	mov    0x8(%ebp),%eax
801018e1:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
801018e4:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
801018eb:	e8 1d 33 00 00       	call   80104c0d <release>

  if(!(ip->flags & I_VALID)){
801018f0:	8b 45 08             	mov    0x8(%ebp),%eax
801018f3:	8b 40 0c             	mov    0xc(%eax),%eax
801018f6:	83 e0 02             	and    $0x2,%eax
801018f9:	85 c0                	test   %eax,%eax
801018fb:	0f 85 d1 00 00 00    	jne    801019d2 <ilock+0x14f>
    bp = bread(ip->dev, IBLOCK(ip->inum));
80101901:	8b 45 08             	mov    0x8(%ebp),%eax
80101904:	8b 40 04             	mov    0x4(%eax),%eax
80101907:	c1 e8 03             	shr    $0x3,%eax
8010190a:	8d 50 02             	lea    0x2(%eax),%edx
8010190d:	8b 45 08             	mov    0x8(%ebp),%eax
80101910:	8b 00                	mov    (%eax),%eax
80101912:	89 54 24 04          	mov    %edx,0x4(%esp)
80101916:	89 04 24             	mov    %eax,(%esp)
80101919:	e8 89 e8 ff ff       	call   801001a7 <bread>
8010191e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101921:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101924:	83 c0 18             	add    $0x18,%eax
80101927:	89 c2                	mov    %eax,%edx
80101929:	8b 45 08             	mov    0x8(%ebp),%eax
8010192c:	8b 40 04             	mov    0x4(%eax),%eax
8010192f:	83 e0 07             	and    $0x7,%eax
80101932:	c1 e0 06             	shl    $0x6,%eax
80101935:	8d 04 02             	lea    (%edx,%eax,1),%eax
80101938:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
8010193b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010193e:	0f b7 10             	movzwl (%eax),%edx
80101941:	8b 45 08             	mov    0x8(%ebp),%eax
80101944:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101948:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010194b:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010194f:	8b 45 08             	mov    0x8(%ebp),%eax
80101952:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101956:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101959:	0f b7 50 04          	movzwl 0x4(%eax),%edx
8010195d:	8b 45 08             	mov    0x8(%ebp),%eax
80101960:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101964:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101967:	0f b7 50 06          	movzwl 0x6(%eax),%edx
8010196b:	8b 45 08             	mov    0x8(%ebp),%eax
8010196e:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101972:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101975:	8b 50 08             	mov    0x8(%eax),%edx
80101978:	8b 45 08             	mov    0x8(%ebp),%eax
8010197b:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
8010197e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101981:	8d 50 0c             	lea    0xc(%eax),%edx
80101984:	8b 45 08             	mov    0x8(%ebp),%eax
80101987:	83 c0 1c             	add    $0x1c,%eax
8010198a:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101991:	00 
80101992:	89 54 24 04          	mov    %edx,0x4(%esp)
80101996:	89 04 24             	mov    %eax,(%esp)
80101999:	e8 2f 35 00 00       	call   80104ecd <memmove>
    brelse(bp);
8010199e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019a1:	89 04 24             	mov    %eax,(%esp)
801019a4:	e8 6f e8 ff ff       	call   80100218 <brelse>
    ip->flags |= I_VALID;
801019a9:	8b 45 08             	mov    0x8(%ebp),%eax
801019ac:	8b 40 0c             	mov    0xc(%eax),%eax
801019af:	89 c2                	mov    %eax,%edx
801019b1:	83 ca 02             	or     $0x2,%edx
801019b4:	8b 45 08             	mov    0x8(%ebp),%eax
801019b7:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
801019ba:	8b 45 08             	mov    0x8(%ebp),%eax
801019bd:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801019c1:	66 85 c0             	test   %ax,%ax
801019c4:	75 0c                	jne    801019d2 <ilock+0x14f>
      panic("ilock: no type");
801019c6:	c7 04 24 d9 82 10 80 	movl   $0x801082d9,(%esp)
801019cd:	e8 74 eb ff ff       	call   80100546 <panic>
  }
}
801019d2:	c9                   	leave  
801019d3:	c3                   	ret    

801019d4 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
801019d4:	55                   	push   %ebp
801019d5:	89 e5                	mov    %esp,%ebp
801019d7:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
801019da:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801019de:	74 17                	je     801019f7 <iunlock+0x23>
801019e0:	8b 45 08             	mov    0x8(%ebp),%eax
801019e3:	8b 40 0c             	mov    0xc(%eax),%eax
801019e6:	83 e0 01             	and    $0x1,%eax
801019e9:	85 c0                	test   %eax,%eax
801019eb:	74 0a                	je     801019f7 <iunlock+0x23>
801019ed:	8b 45 08             	mov    0x8(%ebp),%eax
801019f0:	8b 40 08             	mov    0x8(%eax),%eax
801019f3:	85 c0                	test   %eax,%eax
801019f5:	7f 0c                	jg     80101a03 <iunlock+0x2f>
    panic("iunlock");
801019f7:	c7 04 24 e8 82 10 80 	movl   $0x801082e8,(%esp)
801019fe:	e8 43 eb ff ff       	call   80100546 <panic>

  acquire(&icache.lock);
80101a03:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
80101a0a:	e8 9c 31 00 00       	call   80104bab <acquire>
  ip->flags &= ~I_BUSY;
80101a0f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a12:	8b 40 0c             	mov    0xc(%eax),%eax
80101a15:	89 c2                	mov    %eax,%edx
80101a17:	83 e2 fe             	and    $0xfffffffe,%edx
80101a1a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a1d:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101a20:	8b 45 08             	mov    0x8(%ebp),%eax
80101a23:	89 04 24             	mov    %eax,(%esp)
80101a26:	e8 6a 2f 00 00       	call   80104995 <wakeup>
  release(&icache.lock);
80101a2b:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
80101a32:	e8 d6 31 00 00       	call   80104c0d <release>
}
80101a37:	c9                   	leave  
80101a38:	c3                   	ret    

80101a39 <iput>:
// be recycled.
// If that was the last reference and the inode has no links
// to it, free the inode (and its content) on disk.
void
iput(struct inode *ip)
{
80101a39:	55                   	push   %ebp
80101a3a:	89 e5                	mov    %esp,%ebp
80101a3c:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101a3f:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
80101a46:	e8 60 31 00 00       	call   80104bab <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101a4b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a4e:	8b 40 08             	mov    0x8(%eax),%eax
80101a51:	83 f8 01             	cmp    $0x1,%eax
80101a54:	0f 85 93 00 00 00    	jne    80101aed <iput+0xb4>
80101a5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5d:	8b 40 0c             	mov    0xc(%eax),%eax
80101a60:	83 e0 02             	and    $0x2,%eax
80101a63:	85 c0                	test   %eax,%eax
80101a65:	0f 84 82 00 00 00    	je     80101aed <iput+0xb4>
80101a6b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a6e:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101a72:	66 85 c0             	test   %ax,%ax
80101a75:	75 76                	jne    80101aed <iput+0xb4>
    // inode has no links: truncate and free inode.
    if(ip->flags & I_BUSY)
80101a77:	8b 45 08             	mov    0x8(%ebp),%eax
80101a7a:	8b 40 0c             	mov    0xc(%eax),%eax
80101a7d:	83 e0 01             	and    $0x1,%eax
80101a80:	84 c0                	test   %al,%al
80101a82:	74 0c                	je     80101a90 <iput+0x57>
      panic("iput busy");
80101a84:	c7 04 24 f0 82 10 80 	movl   $0x801082f0,(%esp)
80101a8b:	e8 b6 ea ff ff       	call   80100546 <panic>
    ip->flags |= I_BUSY;
80101a90:	8b 45 08             	mov    0x8(%ebp),%eax
80101a93:	8b 40 0c             	mov    0xc(%eax),%eax
80101a96:	89 c2                	mov    %eax,%edx
80101a98:	83 ca 01             	or     $0x1,%edx
80101a9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9e:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101aa1:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
80101aa8:	e8 60 31 00 00       	call   80104c0d <release>
    itrunc(ip);
80101aad:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab0:	89 04 24             	mov    %eax,(%esp)
80101ab3:	e8 72 01 00 00       	call   80101c2a <itrunc>
    ip->type = 0;
80101ab8:	8b 45 08             	mov    0x8(%ebp),%eax
80101abb:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101ac1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac4:	89 04 24             	mov    %eax,(%esp)
80101ac7:	e8 f7 fb ff ff       	call   801016c3 <iupdate>
    acquire(&icache.lock);
80101acc:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
80101ad3:	e8 d3 30 00 00       	call   80104bab <acquire>
    ip->flags = 0;
80101ad8:	8b 45 08             	mov    0x8(%ebp),%eax
80101adb:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101ae2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae5:	89 04 24             	mov    %eax,(%esp)
80101ae8:	e8 a8 2e 00 00       	call   80104995 <wakeup>
  }
  ip->ref--;
80101aed:	8b 45 08             	mov    0x8(%ebp),%eax
80101af0:	8b 40 08             	mov    0x8(%eax),%eax
80101af3:	8d 50 ff             	lea    -0x1(%eax),%edx
80101af6:	8b 45 08             	mov    0x8(%ebp),%eax
80101af9:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101afc:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
80101b03:	e8 05 31 00 00       	call   80104c0d <release>
}
80101b08:	c9                   	leave  
80101b09:	c3                   	ret    

80101b0a <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101b0a:	55                   	push   %ebp
80101b0b:	89 e5                	mov    %esp,%ebp
80101b0d:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101b10:	8b 45 08             	mov    0x8(%ebp),%eax
80101b13:	89 04 24             	mov    %eax,(%esp)
80101b16:	e8 b9 fe ff ff       	call   801019d4 <iunlock>
  iput(ip);
80101b1b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b1e:	89 04 24             	mov    %eax,(%esp)
80101b21:	e8 13 ff ff ff       	call   80101a39 <iput>
}
80101b26:	c9                   	leave  
80101b27:	c3                   	ret    

80101b28 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101b28:	55                   	push   %ebp
80101b29:	89 e5                	mov    %esp,%ebp
80101b2b:	53                   	push   %ebx
80101b2c:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101b2f:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101b33:	77 3e                	ja     80101b73 <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101b35:	8b 45 08             	mov    0x8(%ebp),%eax
80101b38:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b3b:	83 c2 04             	add    $0x4,%edx
80101b3e:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101b42:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b45:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b49:	75 20                	jne    80101b6b <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101b4b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b4e:	8b 00                	mov    (%eax),%eax
80101b50:	89 04 24             	mov    %eax,(%esp)
80101b53:	e8 3f f8 ff ff       	call   80101397 <balloc>
80101b58:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b5b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b5e:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b61:	8d 4a 04             	lea    0x4(%edx),%ecx
80101b64:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b67:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101b6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b6e:	e9 b1 00 00 00       	jmp    80101c24 <bmap+0xfc>
  }
  bn -= NDIRECT;
80101b73:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101b77:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101b7b:	0f 87 97 00 00 00    	ja     80101c18 <bmap+0xf0>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101b81:	8b 45 08             	mov    0x8(%ebp),%eax
80101b84:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b87:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b8a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b8e:	75 19                	jne    80101ba9 <bmap+0x81>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101b90:	8b 45 08             	mov    0x8(%ebp),%eax
80101b93:	8b 00                	mov    (%eax),%eax
80101b95:	89 04 24             	mov    %eax,(%esp)
80101b98:	e8 fa f7 ff ff       	call   80101397 <balloc>
80101b9d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ba0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ba6:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101ba9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bac:	8b 00                	mov    (%eax),%eax
80101bae:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101bb1:	89 54 24 04          	mov    %edx,0x4(%esp)
80101bb5:	89 04 24             	mov    %eax,(%esp)
80101bb8:	e8 ea e5 ff ff       	call   801001a7 <bread>
80101bbd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101bc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bc3:	83 c0 18             	add    $0x18,%eax
80101bc6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101bc9:	8b 45 0c             	mov    0xc(%ebp),%eax
80101bcc:	c1 e0 02             	shl    $0x2,%eax
80101bcf:	03 45 ec             	add    -0x14(%ebp),%eax
80101bd2:	8b 00                	mov    (%eax),%eax
80101bd4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bd7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101bdb:	75 2b                	jne    80101c08 <bmap+0xe0>
      a[bn] = addr = balloc(ip->dev);
80101bdd:	8b 45 0c             	mov    0xc(%ebp),%eax
80101be0:	c1 e0 02             	shl    $0x2,%eax
80101be3:	89 c3                	mov    %eax,%ebx
80101be5:	03 5d ec             	add    -0x14(%ebp),%ebx
80101be8:	8b 45 08             	mov    0x8(%ebp),%eax
80101beb:	8b 00                	mov    (%eax),%eax
80101bed:	89 04 24             	mov    %eax,(%esp)
80101bf0:	e8 a2 f7 ff ff       	call   80101397 <balloc>
80101bf5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bfb:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101bfd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c00:	89 04 24             	mov    %eax,(%esp)
80101c03:	e8 da 16 00 00       	call   801032e2 <log_write>
    }
    brelse(bp);
80101c08:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c0b:	89 04 24             	mov    %eax,(%esp)
80101c0e:	e8 05 e6 ff ff       	call   80100218 <brelse>
    return addr;
80101c13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c16:	eb 0c                	jmp    80101c24 <bmap+0xfc>
  }

  panic("bmap: out of range");
80101c18:	c7 04 24 fa 82 10 80 	movl   $0x801082fa,(%esp)
80101c1f:	e8 22 e9 ff ff       	call   80100546 <panic>
}
80101c24:	83 c4 24             	add    $0x24,%esp
80101c27:	5b                   	pop    %ebx
80101c28:	5d                   	pop    %ebp
80101c29:	c3                   	ret    

80101c2a <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101c2a:	55                   	push   %ebp
80101c2b:	89 e5                	mov    %esp,%ebp
80101c2d:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101c30:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101c37:	eb 44                	jmp    80101c7d <itrunc+0x53>
    if(ip->addrs[i]){
80101c39:	8b 45 08             	mov    0x8(%ebp),%eax
80101c3c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c3f:	83 c2 04             	add    $0x4,%edx
80101c42:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c46:	85 c0                	test   %eax,%eax
80101c48:	74 2f                	je     80101c79 <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101c4a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c50:	83 c2 04             	add    $0x4,%edx
80101c53:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101c57:	8b 45 08             	mov    0x8(%ebp),%eax
80101c5a:	8b 00                	mov    (%eax),%eax
80101c5c:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c60:	89 04 24             	mov    %eax,(%esp)
80101c63:	e8 88 f8 ff ff       	call   801014f0 <bfree>
      ip->addrs[i] = 0;
80101c68:	8b 45 08             	mov    0x8(%ebp),%eax
80101c6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c6e:	83 c2 04             	add    $0x4,%edx
80101c71:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101c78:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101c79:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101c7d:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101c81:	7e b6                	jle    80101c39 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101c83:	8b 45 08             	mov    0x8(%ebp),%eax
80101c86:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c89:	85 c0                	test   %eax,%eax
80101c8b:	0f 84 8f 00 00 00    	je     80101d20 <itrunc+0xf6>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101c91:	8b 45 08             	mov    0x8(%ebp),%eax
80101c94:	8b 50 4c             	mov    0x4c(%eax),%edx
80101c97:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9a:	8b 00                	mov    (%eax),%eax
80101c9c:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ca0:	89 04 24             	mov    %eax,(%esp)
80101ca3:	e8 ff e4 ff ff       	call   801001a7 <bread>
80101ca8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101cab:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cae:	83 c0 18             	add    $0x18,%eax
80101cb1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101cb4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101cbb:	eb 2f                	jmp    80101cec <itrunc+0xc2>
      if(a[j])
80101cbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cc0:	c1 e0 02             	shl    $0x2,%eax
80101cc3:	03 45 e8             	add    -0x18(%ebp),%eax
80101cc6:	8b 00                	mov    (%eax),%eax
80101cc8:	85 c0                	test   %eax,%eax
80101cca:	74 1c                	je     80101ce8 <itrunc+0xbe>
        bfree(ip->dev, a[j]);
80101ccc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ccf:	c1 e0 02             	shl    $0x2,%eax
80101cd2:	03 45 e8             	add    -0x18(%ebp),%eax
80101cd5:	8b 10                	mov    (%eax),%edx
80101cd7:	8b 45 08             	mov    0x8(%ebp),%eax
80101cda:	8b 00                	mov    (%eax),%eax
80101cdc:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ce0:	89 04 24             	mov    %eax,(%esp)
80101ce3:	e8 08 f8 ff ff       	call   801014f0 <bfree>
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101ce8:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101cec:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cef:	83 f8 7f             	cmp    $0x7f,%eax
80101cf2:	76 c9                	jbe    80101cbd <itrunc+0x93>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101cf4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cf7:	89 04 24             	mov    %eax,(%esp)
80101cfa:	e8 19 e5 ff ff       	call   80100218 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101cff:	8b 45 08             	mov    0x8(%ebp),%eax
80101d02:	8b 50 4c             	mov    0x4c(%eax),%edx
80101d05:	8b 45 08             	mov    0x8(%ebp),%eax
80101d08:	8b 00                	mov    (%eax),%eax
80101d0a:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d0e:	89 04 24             	mov    %eax,(%esp)
80101d11:	e8 da f7 ff ff       	call   801014f0 <bfree>
    ip->addrs[NDIRECT] = 0;
80101d16:	8b 45 08             	mov    0x8(%ebp),%eax
80101d19:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101d20:	8b 45 08             	mov    0x8(%ebp),%eax
80101d23:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101d2a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d2d:	89 04 24             	mov    %eax,(%esp)
80101d30:	e8 8e f9 ff ff       	call   801016c3 <iupdate>
}
80101d35:	c9                   	leave  
80101d36:	c3                   	ret    

80101d37 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101d37:	55                   	push   %ebp
80101d38:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101d3a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d3d:	8b 00                	mov    (%eax),%eax
80101d3f:	89 c2                	mov    %eax,%edx
80101d41:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d44:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101d47:	8b 45 08             	mov    0x8(%ebp),%eax
80101d4a:	8b 50 04             	mov    0x4(%eax),%edx
80101d4d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d50:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101d53:	8b 45 08             	mov    0x8(%ebp),%eax
80101d56:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101d5a:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d5d:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101d60:	8b 45 08             	mov    0x8(%ebp),%eax
80101d63:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101d67:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d6a:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101d6e:	8b 45 08             	mov    0x8(%ebp),%eax
80101d71:	8b 50 18             	mov    0x18(%eax),%edx
80101d74:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d77:	89 50 10             	mov    %edx,0x10(%eax)
}
80101d7a:	5d                   	pop    %ebp
80101d7b:	c3                   	ret    

80101d7c <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101d7c:	55                   	push   %ebp
80101d7d:	89 e5                	mov    %esp,%ebp
80101d7f:	53                   	push   %ebx
80101d80:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101d83:	8b 45 08             	mov    0x8(%ebp),%eax
80101d86:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101d8a:	66 83 f8 03          	cmp    $0x3,%ax
80101d8e:	75 60                	jne    80101df0 <readi+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101d90:	8b 45 08             	mov    0x8(%ebp),%eax
80101d93:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101d97:	66 85 c0             	test   %ax,%ax
80101d9a:	78 20                	js     80101dbc <readi+0x40>
80101d9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d9f:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101da3:	66 83 f8 09          	cmp    $0x9,%ax
80101da7:	7f 13                	jg     80101dbc <readi+0x40>
80101da9:	8b 45 08             	mov    0x8(%ebp),%eax
80101dac:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101db0:	98                   	cwtl   
80101db1:	8b 04 c5 00 e8 10 80 	mov    -0x7fef1800(,%eax,8),%eax
80101db8:	85 c0                	test   %eax,%eax
80101dba:	75 0a                	jne    80101dc6 <readi+0x4a>
      return -1;
80101dbc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101dc1:	e9 1c 01 00 00       	jmp    80101ee2 <readi+0x166>
    return devsw[ip->major].read(ip, dst, n);
80101dc6:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc9:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101dcd:	98                   	cwtl   
80101dce:	8b 14 c5 00 e8 10 80 	mov    -0x7fef1800(,%eax,8),%edx
80101dd5:	8b 45 14             	mov    0x14(%ebp),%eax
80101dd8:	89 44 24 08          	mov    %eax,0x8(%esp)
80101ddc:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ddf:	89 44 24 04          	mov    %eax,0x4(%esp)
80101de3:	8b 45 08             	mov    0x8(%ebp),%eax
80101de6:	89 04 24             	mov    %eax,(%esp)
80101de9:	ff d2                	call   *%edx
80101deb:	e9 f2 00 00 00       	jmp    80101ee2 <readi+0x166>
  }

  if(off > ip->size || off + n < off)
80101df0:	8b 45 08             	mov    0x8(%ebp),%eax
80101df3:	8b 40 18             	mov    0x18(%eax),%eax
80101df6:	3b 45 10             	cmp    0x10(%ebp),%eax
80101df9:	72 0e                	jb     80101e09 <readi+0x8d>
80101dfb:	8b 45 14             	mov    0x14(%ebp),%eax
80101dfe:	8b 55 10             	mov    0x10(%ebp),%edx
80101e01:	8d 04 02             	lea    (%edx,%eax,1),%eax
80101e04:	3b 45 10             	cmp    0x10(%ebp),%eax
80101e07:	73 0a                	jae    80101e13 <readi+0x97>
    return -1;
80101e09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101e0e:	e9 cf 00 00 00       	jmp    80101ee2 <readi+0x166>
  if(off + n > ip->size)
80101e13:	8b 45 14             	mov    0x14(%ebp),%eax
80101e16:	8b 55 10             	mov    0x10(%ebp),%edx
80101e19:	01 c2                	add    %eax,%edx
80101e1b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e1e:	8b 40 18             	mov    0x18(%eax),%eax
80101e21:	39 c2                	cmp    %eax,%edx
80101e23:	76 0c                	jbe    80101e31 <readi+0xb5>
    n = ip->size - off;
80101e25:	8b 45 08             	mov    0x8(%ebp),%eax
80101e28:	8b 40 18             	mov    0x18(%eax),%eax
80101e2b:	2b 45 10             	sub    0x10(%ebp),%eax
80101e2e:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101e31:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e38:	e9 96 00 00 00       	jmp    80101ed3 <readi+0x157>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101e3d:	8b 45 10             	mov    0x10(%ebp),%eax
80101e40:	c1 e8 09             	shr    $0x9,%eax
80101e43:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e47:	8b 45 08             	mov    0x8(%ebp),%eax
80101e4a:	89 04 24             	mov    %eax,(%esp)
80101e4d:	e8 d6 fc ff ff       	call   80101b28 <bmap>
80101e52:	8b 55 08             	mov    0x8(%ebp),%edx
80101e55:	8b 12                	mov    (%edx),%edx
80101e57:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e5b:	89 14 24             	mov    %edx,(%esp)
80101e5e:	e8 44 e3 ff ff       	call   801001a7 <bread>
80101e63:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101e66:	8b 45 10             	mov    0x10(%ebp),%eax
80101e69:	89 c2                	mov    %eax,%edx
80101e6b:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80101e71:	b8 00 02 00 00       	mov    $0x200,%eax
80101e76:	89 c1                	mov    %eax,%ecx
80101e78:	29 d1                	sub    %edx,%ecx
80101e7a:	89 ca                	mov    %ecx,%edx
80101e7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e7f:	8b 4d 14             	mov    0x14(%ebp),%ecx
80101e82:	89 cb                	mov    %ecx,%ebx
80101e84:	29 c3                	sub    %eax,%ebx
80101e86:	89 d8                	mov    %ebx,%eax
80101e88:	39 c2                	cmp    %eax,%edx
80101e8a:	0f 46 c2             	cmovbe %edx,%eax
80101e8d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101e90:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e93:	8d 50 18             	lea    0x18(%eax),%edx
80101e96:	8b 45 10             	mov    0x10(%ebp),%eax
80101e99:	25 ff 01 00 00       	and    $0x1ff,%eax
80101e9e:	01 c2                	add    %eax,%edx
80101ea0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ea3:	89 44 24 08          	mov    %eax,0x8(%esp)
80101ea7:	89 54 24 04          	mov    %edx,0x4(%esp)
80101eab:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eae:	89 04 24             	mov    %eax,(%esp)
80101eb1:	e8 17 30 00 00       	call   80104ecd <memmove>
    brelse(bp);
80101eb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101eb9:	89 04 24             	mov    %eax,(%esp)
80101ebc:	e8 57 e3 ff ff       	call   80100218 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101ec1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ec4:	01 45 f4             	add    %eax,-0xc(%ebp)
80101ec7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101eca:	01 45 10             	add    %eax,0x10(%ebp)
80101ecd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ed0:	01 45 0c             	add    %eax,0xc(%ebp)
80101ed3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ed6:	3b 45 14             	cmp    0x14(%ebp),%eax
80101ed9:	0f 82 5e ff ff ff    	jb     80101e3d <readi+0xc1>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80101edf:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101ee2:	83 c4 24             	add    $0x24,%esp
80101ee5:	5b                   	pop    %ebx
80101ee6:	5d                   	pop    %ebp
80101ee7:	c3                   	ret    

80101ee8 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101ee8:	55                   	push   %ebp
80101ee9:	89 e5                	mov    %esp,%ebp
80101eeb:	53                   	push   %ebx
80101eec:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101eef:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef2:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101ef6:	66 83 f8 03          	cmp    $0x3,%ax
80101efa:	75 60                	jne    80101f5c <writei+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101efc:	8b 45 08             	mov    0x8(%ebp),%eax
80101eff:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f03:	66 85 c0             	test   %ax,%ax
80101f06:	78 20                	js     80101f28 <writei+0x40>
80101f08:	8b 45 08             	mov    0x8(%ebp),%eax
80101f0b:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f0f:	66 83 f8 09          	cmp    $0x9,%ax
80101f13:	7f 13                	jg     80101f28 <writei+0x40>
80101f15:	8b 45 08             	mov    0x8(%ebp),%eax
80101f18:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f1c:	98                   	cwtl   
80101f1d:	8b 04 c5 04 e8 10 80 	mov    -0x7fef17fc(,%eax,8),%eax
80101f24:	85 c0                	test   %eax,%eax
80101f26:	75 0a                	jne    80101f32 <writei+0x4a>
      return -1;
80101f28:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f2d:	e9 48 01 00 00       	jmp    8010207a <writei+0x192>
    return devsw[ip->major].write(ip, src, n);
80101f32:	8b 45 08             	mov    0x8(%ebp),%eax
80101f35:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f39:	98                   	cwtl   
80101f3a:	8b 14 c5 04 e8 10 80 	mov    -0x7fef17fc(,%eax,8),%edx
80101f41:	8b 45 14             	mov    0x14(%ebp),%eax
80101f44:	89 44 24 08          	mov    %eax,0x8(%esp)
80101f48:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f4b:	89 44 24 04          	mov    %eax,0x4(%esp)
80101f4f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f52:	89 04 24             	mov    %eax,(%esp)
80101f55:	ff d2                	call   *%edx
80101f57:	e9 1e 01 00 00       	jmp    8010207a <writei+0x192>
  }

  if(off > ip->size || off + n < off)
80101f5c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f5f:	8b 40 18             	mov    0x18(%eax),%eax
80101f62:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f65:	72 0e                	jb     80101f75 <writei+0x8d>
80101f67:	8b 45 14             	mov    0x14(%ebp),%eax
80101f6a:	8b 55 10             	mov    0x10(%ebp),%edx
80101f6d:	8d 04 02             	lea    (%edx,%eax,1),%eax
80101f70:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f73:	73 0a                	jae    80101f7f <writei+0x97>
    return -1;
80101f75:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f7a:	e9 fb 00 00 00       	jmp    8010207a <writei+0x192>
  if(off + n > MAXFILE*BSIZE)
80101f7f:	8b 45 14             	mov    0x14(%ebp),%eax
80101f82:	8b 55 10             	mov    0x10(%ebp),%edx
80101f85:	8d 04 02             	lea    (%edx,%eax,1),%eax
80101f88:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101f8d:	76 0a                	jbe    80101f99 <writei+0xb1>
    return -1;
80101f8f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f94:	e9 e1 00 00 00       	jmp    8010207a <writei+0x192>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101f99:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101fa0:	e9 a1 00 00 00       	jmp    80102046 <writei+0x15e>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101fa5:	8b 45 10             	mov    0x10(%ebp),%eax
80101fa8:	c1 e8 09             	shr    $0x9,%eax
80101fab:	89 44 24 04          	mov    %eax,0x4(%esp)
80101faf:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb2:	89 04 24             	mov    %eax,(%esp)
80101fb5:	e8 6e fb ff ff       	call   80101b28 <bmap>
80101fba:	8b 55 08             	mov    0x8(%ebp),%edx
80101fbd:	8b 12                	mov    (%edx),%edx
80101fbf:	89 44 24 04          	mov    %eax,0x4(%esp)
80101fc3:	89 14 24             	mov    %edx,(%esp)
80101fc6:	e8 dc e1 ff ff       	call   801001a7 <bread>
80101fcb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fce:	8b 45 10             	mov    0x10(%ebp),%eax
80101fd1:	89 c2                	mov    %eax,%edx
80101fd3:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80101fd9:	b8 00 02 00 00       	mov    $0x200,%eax
80101fde:	89 c1                	mov    %eax,%ecx
80101fe0:	29 d1                	sub    %edx,%ecx
80101fe2:	89 ca                	mov    %ecx,%edx
80101fe4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101fe7:	8b 4d 14             	mov    0x14(%ebp),%ecx
80101fea:	89 cb                	mov    %ecx,%ebx
80101fec:	29 c3                	sub    %eax,%ebx
80101fee:	89 d8                	mov    %ebx,%eax
80101ff0:	39 c2                	cmp    %eax,%edx
80101ff2:	0f 46 c2             	cmovbe %edx,%eax
80101ff5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80101ff8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ffb:	8d 50 18             	lea    0x18(%eax),%edx
80101ffe:	8b 45 10             	mov    0x10(%ebp),%eax
80102001:	25 ff 01 00 00       	and    $0x1ff,%eax
80102006:	01 c2                	add    %eax,%edx
80102008:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010200b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010200f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102012:	89 44 24 04          	mov    %eax,0x4(%esp)
80102016:	89 14 24             	mov    %edx,(%esp)
80102019:	e8 af 2e 00 00       	call   80104ecd <memmove>
    log_write(bp);
8010201e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102021:	89 04 24             	mov    %eax,(%esp)
80102024:	e8 b9 12 00 00       	call   801032e2 <log_write>
    brelse(bp);
80102029:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010202c:	89 04 24             	mov    %eax,(%esp)
8010202f:	e8 e4 e1 ff ff       	call   80100218 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102034:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102037:	01 45 f4             	add    %eax,-0xc(%ebp)
8010203a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010203d:	01 45 10             	add    %eax,0x10(%ebp)
80102040:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102043:	01 45 0c             	add    %eax,0xc(%ebp)
80102046:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102049:	3b 45 14             	cmp    0x14(%ebp),%eax
8010204c:	0f 82 53 ff ff ff    	jb     80101fa5 <writei+0xbd>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80102052:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102056:	74 1f                	je     80102077 <writei+0x18f>
80102058:	8b 45 08             	mov    0x8(%ebp),%eax
8010205b:	8b 40 18             	mov    0x18(%eax),%eax
8010205e:	3b 45 10             	cmp    0x10(%ebp),%eax
80102061:	73 14                	jae    80102077 <writei+0x18f>
    ip->size = off;
80102063:	8b 45 08             	mov    0x8(%ebp),%eax
80102066:	8b 55 10             	mov    0x10(%ebp),%edx
80102069:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
8010206c:	8b 45 08             	mov    0x8(%ebp),%eax
8010206f:	89 04 24             	mov    %eax,(%esp)
80102072:	e8 4c f6 ff ff       	call   801016c3 <iupdate>
  }
  return n;
80102077:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010207a:	83 c4 24             	add    $0x24,%esp
8010207d:	5b                   	pop    %ebx
8010207e:	5d                   	pop    %ebp
8010207f:	c3                   	ret    

80102080 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102080:	55                   	push   %ebp
80102081:	89 e5                	mov    %esp,%ebp
80102083:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
80102086:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
8010208d:	00 
8010208e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102091:	89 44 24 04          	mov    %eax,0x4(%esp)
80102095:	8b 45 08             	mov    0x8(%ebp),%eax
80102098:	89 04 24             	mov    %eax,(%esp)
8010209b:	e8 d5 2e 00 00       	call   80104f75 <strncmp>
}
801020a0:	c9                   	leave  
801020a1:	c3                   	ret    

801020a2 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801020a2:	55                   	push   %ebp
801020a3:	89 e5                	mov    %esp,%ebp
801020a5:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801020a8:	8b 45 08             	mov    0x8(%ebp),%eax
801020ab:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801020af:	66 83 f8 01          	cmp    $0x1,%ax
801020b3:	74 0c                	je     801020c1 <dirlookup+0x1f>
    panic("dirlookup not DIR");
801020b5:	c7 04 24 0d 83 10 80 	movl   $0x8010830d,(%esp)
801020bc:	e8 85 e4 ff ff       	call   80100546 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801020c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020c8:	e9 87 00 00 00       	jmp    80102154 <dirlookup+0xb2>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801020cd:	8d 45 e0             	lea    -0x20(%ebp),%eax
801020d0:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801020d7:	00 
801020d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801020db:	89 54 24 08          	mov    %edx,0x8(%esp)
801020df:	89 44 24 04          	mov    %eax,0x4(%esp)
801020e3:	8b 45 08             	mov    0x8(%ebp),%eax
801020e6:	89 04 24             	mov    %eax,(%esp)
801020e9:	e8 8e fc ff ff       	call   80101d7c <readi>
801020ee:	83 f8 10             	cmp    $0x10,%eax
801020f1:	74 0c                	je     801020ff <dirlookup+0x5d>
      panic("dirlink read");
801020f3:	c7 04 24 1f 83 10 80 	movl   $0x8010831f,(%esp)
801020fa:	e8 47 e4 ff ff       	call   80100546 <panic>
    if(de.inum == 0)
801020ff:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102103:	66 85 c0             	test   %ax,%ax
80102106:	74 47                	je     8010214f <dirlookup+0xad>
      continue;
    if(namecmp(name, de.name) == 0){
80102108:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010210b:	83 c0 02             	add    $0x2,%eax
8010210e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102112:	8b 45 0c             	mov    0xc(%ebp),%eax
80102115:	89 04 24             	mov    %eax,(%esp)
80102118:	e8 63 ff ff ff       	call   80102080 <namecmp>
8010211d:	85 c0                	test   %eax,%eax
8010211f:	75 2f                	jne    80102150 <dirlookup+0xae>
      // entry matches path element
      if(poff)
80102121:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102125:	74 08                	je     8010212f <dirlookup+0x8d>
        *poff = off;
80102127:	8b 45 10             	mov    0x10(%ebp),%eax
8010212a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010212d:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010212f:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102133:	0f b7 c0             	movzwl %ax,%eax
80102136:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102139:	8b 45 08             	mov    0x8(%ebp),%eax
8010213c:	8b 00                	mov    (%eax),%eax
8010213e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102141:	89 54 24 04          	mov    %edx,0x4(%esp)
80102145:	89 04 24             	mov    %eax,(%esp)
80102148:	e8 31 f6 ff ff       	call   8010177e <iget>
8010214d:	eb 19                	jmp    80102168 <dirlookup+0xc6>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
8010214f:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102150:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102154:	8b 45 08             	mov    0x8(%ebp),%eax
80102157:	8b 40 18             	mov    0x18(%eax),%eax
8010215a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010215d:	0f 87 6a ff ff ff    	ja     801020cd <dirlookup+0x2b>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80102163:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102168:	c9                   	leave  
80102169:	c3                   	ret    

8010216a <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
8010216a:	55                   	push   %ebp
8010216b:	89 e5                	mov    %esp,%ebp
8010216d:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102170:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80102177:	00 
80102178:	8b 45 0c             	mov    0xc(%ebp),%eax
8010217b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010217f:	8b 45 08             	mov    0x8(%ebp),%eax
80102182:	89 04 24             	mov    %eax,(%esp)
80102185:	e8 18 ff ff ff       	call   801020a2 <dirlookup>
8010218a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010218d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102191:	74 15                	je     801021a8 <dirlink+0x3e>
    iput(ip);
80102193:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102196:	89 04 24             	mov    %eax,(%esp)
80102199:	e8 9b f8 ff ff       	call   80101a39 <iput>
    return -1;
8010219e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021a3:	e9 b8 00 00 00       	jmp    80102260 <dirlink+0xf6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801021a8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021af:	eb 44                	jmp    801021f5 <dirlink+0x8b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801021b4:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021b7:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801021be:	00 
801021bf:	89 54 24 08          	mov    %edx,0x8(%esp)
801021c3:	89 44 24 04          	mov    %eax,0x4(%esp)
801021c7:	8b 45 08             	mov    0x8(%ebp),%eax
801021ca:	89 04 24             	mov    %eax,(%esp)
801021cd:	e8 aa fb ff ff       	call   80101d7c <readi>
801021d2:	83 f8 10             	cmp    $0x10,%eax
801021d5:	74 0c                	je     801021e3 <dirlink+0x79>
      panic("dirlink read");
801021d7:	c7 04 24 1f 83 10 80 	movl   $0x8010831f,(%esp)
801021de:	e8 63 e3 ff ff       	call   80100546 <panic>
    if(de.inum == 0)
801021e3:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801021e7:	66 85 c0             	test   %ax,%ax
801021ea:	74 18                	je     80102204 <dirlink+0x9a>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801021ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021ef:	83 c0 10             	add    $0x10,%eax
801021f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801021f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801021f8:	8b 45 08             	mov    0x8(%ebp),%eax
801021fb:	8b 40 18             	mov    0x18(%eax),%eax
801021fe:	39 c2                	cmp    %eax,%edx
80102200:	72 af                	jb     801021b1 <dirlink+0x47>
80102202:	eb 01                	jmp    80102205 <dirlink+0x9b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
80102204:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102205:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
8010220c:	00 
8010220d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102210:	89 44 24 04          	mov    %eax,0x4(%esp)
80102214:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102217:	83 c0 02             	add    $0x2,%eax
8010221a:	89 04 24             	mov    %eax,(%esp)
8010221d:	e8 ab 2d 00 00       	call   80104fcd <strncpy>
  de.inum = inum;
80102222:	8b 45 10             	mov    0x10(%ebp),%eax
80102225:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102229:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010222c:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010222f:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102236:	00 
80102237:	89 54 24 08          	mov    %edx,0x8(%esp)
8010223b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010223f:	8b 45 08             	mov    0x8(%ebp),%eax
80102242:	89 04 24             	mov    %eax,(%esp)
80102245:	e8 9e fc ff ff       	call   80101ee8 <writei>
8010224a:	83 f8 10             	cmp    $0x10,%eax
8010224d:	74 0c                	je     8010225b <dirlink+0xf1>
    panic("dirlink");
8010224f:	c7 04 24 2c 83 10 80 	movl   $0x8010832c,(%esp)
80102256:	e8 eb e2 ff ff       	call   80100546 <panic>
  
  return 0;
8010225b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102260:	c9                   	leave  
80102261:	c3                   	ret    

80102262 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102262:	55                   	push   %ebp
80102263:	89 e5                	mov    %esp,%ebp
80102265:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
80102268:	eb 04                	jmp    8010226e <skipelem+0xc>
    path++;
8010226a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
8010226e:	8b 45 08             	mov    0x8(%ebp),%eax
80102271:	0f b6 00             	movzbl (%eax),%eax
80102274:	3c 2f                	cmp    $0x2f,%al
80102276:	74 f2                	je     8010226a <skipelem+0x8>
    path++;
  if(*path == 0)
80102278:	8b 45 08             	mov    0x8(%ebp),%eax
8010227b:	0f b6 00             	movzbl (%eax),%eax
8010227e:	84 c0                	test   %al,%al
80102280:	75 0a                	jne    8010228c <skipelem+0x2a>
    return 0;
80102282:	b8 00 00 00 00       	mov    $0x0,%eax
80102287:	e9 86 00 00 00       	jmp    80102312 <skipelem+0xb0>
  s = path;
8010228c:	8b 45 08             	mov    0x8(%ebp),%eax
8010228f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102292:	eb 04                	jmp    80102298 <skipelem+0x36>
    path++;
80102294:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80102298:	8b 45 08             	mov    0x8(%ebp),%eax
8010229b:	0f b6 00             	movzbl (%eax),%eax
8010229e:	3c 2f                	cmp    $0x2f,%al
801022a0:	74 0a                	je     801022ac <skipelem+0x4a>
801022a2:	8b 45 08             	mov    0x8(%ebp),%eax
801022a5:	0f b6 00             	movzbl (%eax),%eax
801022a8:	84 c0                	test   %al,%al
801022aa:	75 e8                	jne    80102294 <skipelem+0x32>
    path++;
  len = path - s;
801022ac:	8b 55 08             	mov    0x8(%ebp),%edx
801022af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022b2:	89 d1                	mov    %edx,%ecx
801022b4:	29 c1                	sub    %eax,%ecx
801022b6:	89 c8                	mov    %ecx,%eax
801022b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801022bb:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801022bf:	7e 1c                	jle    801022dd <skipelem+0x7b>
    memmove(name, s, DIRSIZ);
801022c1:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801022c8:	00 
801022c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022cc:	89 44 24 04          	mov    %eax,0x4(%esp)
801022d0:	8b 45 0c             	mov    0xc(%ebp),%eax
801022d3:	89 04 24             	mov    %eax,(%esp)
801022d6:	e8 f2 2b 00 00       	call   80104ecd <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801022db:	eb 28                	jmp    80102305 <skipelem+0xa3>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
801022dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022e0:	89 44 24 08          	mov    %eax,0x8(%esp)
801022e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022e7:	89 44 24 04          	mov    %eax,0x4(%esp)
801022eb:	8b 45 0c             	mov    0xc(%ebp),%eax
801022ee:	89 04 24             	mov    %eax,(%esp)
801022f1:	e8 d7 2b 00 00       	call   80104ecd <memmove>
    name[len] = 0;
801022f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022f9:	03 45 0c             	add    0xc(%ebp),%eax
801022fc:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801022ff:	eb 04                	jmp    80102305 <skipelem+0xa3>
    path++;
80102301:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102305:	8b 45 08             	mov    0x8(%ebp),%eax
80102308:	0f b6 00             	movzbl (%eax),%eax
8010230b:	3c 2f                	cmp    $0x2f,%al
8010230d:	74 f2                	je     80102301 <skipelem+0x9f>
    path++;
  return path;
8010230f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102312:	c9                   	leave  
80102313:	c3                   	ret    

80102314 <namex>:
// Look up and return the inode for a path name.
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102314:	55                   	push   %ebp
80102315:	89 e5                	mov    %esp,%ebp
80102317:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
8010231a:	8b 45 08             	mov    0x8(%ebp),%eax
8010231d:	0f b6 00             	movzbl (%eax),%eax
80102320:	3c 2f                	cmp    $0x2f,%al
80102322:	75 1c                	jne    80102340 <namex+0x2c>
    ip = iget(ROOTDEV, ROOTINO);
80102324:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010232b:	00 
8010232c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102333:	e8 46 f4 ff ff       	call   8010177e <iget>
80102338:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
8010233b:	e9 af 00 00 00       	jmp    801023ef <namex+0xdb>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
80102340:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102346:	8b 40 68             	mov    0x68(%eax),%eax
80102349:	89 04 24             	mov    %eax,(%esp)
8010234c:	e8 00 f5 ff ff       	call   80101851 <idup>
80102351:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102354:	e9 96 00 00 00       	jmp    801023ef <namex+0xdb>
    ilock(ip);
80102359:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010235c:	89 04 24             	mov    %eax,(%esp)
8010235f:	e8 1f f5 ff ff       	call   80101883 <ilock>
    if(ip->type != T_DIR){
80102364:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102367:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010236b:	66 83 f8 01          	cmp    $0x1,%ax
8010236f:	74 15                	je     80102386 <namex+0x72>
      iunlockput(ip);
80102371:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102374:	89 04 24             	mov    %eax,(%esp)
80102377:	e8 8e f7 ff ff       	call   80101b0a <iunlockput>
      return 0;
8010237c:	b8 00 00 00 00       	mov    $0x0,%eax
80102381:	e9 a3 00 00 00       	jmp    80102429 <namex+0x115>
    }
    if(nameiparent && *path == '\0'){
80102386:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010238a:	74 1d                	je     801023a9 <namex+0x95>
8010238c:	8b 45 08             	mov    0x8(%ebp),%eax
8010238f:	0f b6 00             	movzbl (%eax),%eax
80102392:	84 c0                	test   %al,%al
80102394:	75 13                	jne    801023a9 <namex+0x95>
      // Stop one level early.
      iunlock(ip);
80102396:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102399:	89 04 24             	mov    %eax,(%esp)
8010239c:	e8 33 f6 ff ff       	call   801019d4 <iunlock>
      return ip;
801023a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023a4:	e9 80 00 00 00       	jmp    80102429 <namex+0x115>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801023a9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801023b0:	00 
801023b1:	8b 45 10             	mov    0x10(%ebp),%eax
801023b4:	89 44 24 04          	mov    %eax,0x4(%esp)
801023b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023bb:	89 04 24             	mov    %eax,(%esp)
801023be:	e8 df fc ff ff       	call   801020a2 <dirlookup>
801023c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
801023c6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801023ca:	75 12                	jne    801023de <namex+0xca>
      iunlockput(ip);
801023cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023cf:	89 04 24             	mov    %eax,(%esp)
801023d2:	e8 33 f7 ff ff       	call   80101b0a <iunlockput>
      return 0;
801023d7:	b8 00 00 00 00       	mov    $0x0,%eax
801023dc:	eb 4b                	jmp    80102429 <namex+0x115>
    }
    iunlockput(ip);
801023de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023e1:	89 04 24             	mov    %eax,(%esp)
801023e4:	e8 21 f7 ff ff       	call   80101b0a <iunlockput>
    ip = next;
801023e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
801023ef:	8b 45 10             	mov    0x10(%ebp),%eax
801023f2:	89 44 24 04          	mov    %eax,0x4(%esp)
801023f6:	8b 45 08             	mov    0x8(%ebp),%eax
801023f9:	89 04 24             	mov    %eax,(%esp)
801023fc:	e8 61 fe ff ff       	call   80102262 <skipelem>
80102401:	89 45 08             	mov    %eax,0x8(%ebp)
80102404:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102408:	0f 85 4b ff ff ff    	jne    80102359 <namex+0x45>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
8010240e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102412:	74 12                	je     80102426 <namex+0x112>
    iput(ip);
80102414:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102417:	89 04 24             	mov    %eax,(%esp)
8010241a:	e8 1a f6 ff ff       	call   80101a39 <iput>
    return 0;
8010241f:	b8 00 00 00 00       	mov    $0x0,%eax
80102424:	eb 03                	jmp    80102429 <namex+0x115>
  }
  return ip;
80102426:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102429:	c9                   	leave  
8010242a:	c3                   	ret    

8010242b <namei>:

struct inode*
namei(char *path)
{
8010242b:	55                   	push   %ebp
8010242c:	89 e5                	mov    %esp,%ebp
8010242e:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102431:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102434:	89 44 24 08          	mov    %eax,0x8(%esp)
80102438:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010243f:	00 
80102440:	8b 45 08             	mov    0x8(%ebp),%eax
80102443:	89 04 24             	mov    %eax,(%esp)
80102446:	e8 c9 fe ff ff       	call   80102314 <namex>
}
8010244b:	c9                   	leave  
8010244c:	c3                   	ret    

8010244d <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
8010244d:	55                   	push   %ebp
8010244e:	89 e5                	mov    %esp,%ebp
80102450:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
80102453:	8b 45 0c             	mov    0xc(%ebp),%eax
80102456:	89 44 24 08          	mov    %eax,0x8(%esp)
8010245a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102461:	00 
80102462:	8b 45 08             	mov    0x8(%ebp),%eax
80102465:	89 04 24             	mov    %eax,(%esp)
80102468:	e8 a7 fe ff ff       	call   80102314 <namex>
}
8010246d:	c9                   	leave  
8010246e:	c3                   	ret    
	...

80102470 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102470:	55                   	push   %ebp
80102471:	89 e5                	mov    %esp,%ebp
80102473:	53                   	push   %ebx
80102474:	83 ec 18             	sub    $0x18,%esp
80102477:	8b 45 08             	mov    0x8(%ebp),%eax
8010247a:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010247e:	0f b7 45 e8          	movzwl -0x18(%ebp),%eax
80102482:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
80102486:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
8010248a:	ec                   	in     (%dx),%al
8010248b:	89 c3                	mov    %eax,%ebx
8010248d:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80102490:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80102494:	83 c4 18             	add    $0x18,%esp
80102497:	5b                   	pop    %ebx
80102498:	5d                   	pop    %ebp
80102499:	c3                   	ret    

8010249a <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
8010249a:	55                   	push   %ebp
8010249b:	89 e5                	mov    %esp,%ebp
8010249d:	57                   	push   %edi
8010249e:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
8010249f:	8b 55 08             	mov    0x8(%ebp),%edx
801024a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801024a5:	8b 45 10             	mov    0x10(%ebp),%eax
801024a8:	89 cb                	mov    %ecx,%ebx
801024aa:	89 df                	mov    %ebx,%edi
801024ac:	89 c1                	mov    %eax,%ecx
801024ae:	fc                   	cld    
801024af:	f3 6d                	rep insl (%dx),%es:(%edi)
801024b1:	89 c8                	mov    %ecx,%eax
801024b3:	89 fb                	mov    %edi,%ebx
801024b5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801024b8:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
801024bb:	5b                   	pop    %ebx
801024bc:	5f                   	pop    %edi
801024bd:	5d                   	pop    %ebp
801024be:	c3                   	ret    

801024bf <outb>:

static inline void
outb(ushort port, uchar data)
{
801024bf:	55                   	push   %ebp
801024c0:	89 e5                	mov    %esp,%ebp
801024c2:	83 ec 08             	sub    $0x8,%esp
801024c5:	8b 55 08             	mov    0x8(%ebp),%edx
801024c8:	8b 45 0c             	mov    0xc(%ebp),%eax
801024cb:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801024cf:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801024d2:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801024d6:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801024da:	ee                   	out    %al,(%dx)
}
801024db:	c9                   	leave  
801024dc:	c3                   	ret    

801024dd <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
801024dd:	55                   	push   %ebp
801024de:	89 e5                	mov    %esp,%ebp
801024e0:	56                   	push   %esi
801024e1:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801024e2:	8b 55 08             	mov    0x8(%ebp),%edx
801024e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801024e8:	8b 45 10             	mov    0x10(%ebp),%eax
801024eb:	89 cb                	mov    %ecx,%ebx
801024ed:	89 de                	mov    %ebx,%esi
801024ef:	89 c1                	mov    %eax,%ecx
801024f1:	fc                   	cld    
801024f2:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801024f4:	89 c8                	mov    %ecx,%eax
801024f6:	89 f3                	mov    %esi,%ebx
801024f8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801024fb:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
801024fe:	5b                   	pop    %ebx
801024ff:	5e                   	pop    %esi
80102500:	5d                   	pop    %ebp
80102501:	c3                   	ret    

80102502 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102502:	55                   	push   %ebp
80102503:	89 e5                	mov    %esp,%ebp
80102505:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
80102508:	90                   	nop
80102509:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102510:	e8 5b ff ff ff       	call   80102470 <inb>
80102515:	0f b6 c0             	movzbl %al,%eax
80102518:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010251b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010251e:	25 c0 00 00 00       	and    $0xc0,%eax
80102523:	83 f8 40             	cmp    $0x40,%eax
80102526:	75 e1                	jne    80102509 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102528:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010252c:	74 11                	je     8010253f <idewait+0x3d>
8010252e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102531:	83 e0 21             	and    $0x21,%eax
80102534:	85 c0                	test   %eax,%eax
80102536:	74 07                	je     8010253f <idewait+0x3d>
    return -1;
80102538:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010253d:	eb 05                	jmp    80102544 <idewait+0x42>
  return 0;
8010253f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102544:	c9                   	leave  
80102545:	c3                   	ret    

80102546 <ideinit>:

void
ideinit(void)
{
80102546:	55                   	push   %ebp
80102547:	89 e5                	mov    %esp,%ebp
80102549:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
8010254c:	c7 44 24 04 34 83 10 	movl   $0x80108334,0x4(%esp)
80102553:	80 
80102554:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
8010255b:	e8 2a 26 00 00       	call   80104b8a <initlock>
  picenable(IRQ_IDE);
80102560:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102567:	e8 7d 15 00 00       	call   80103ae9 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
8010256c:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
80102571:	83 e8 01             	sub    $0x1,%eax
80102574:	89 44 24 04          	mov    %eax,0x4(%esp)
80102578:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
8010257f:	e8 12 04 00 00       	call   80102996 <ioapicenable>
  idewait(0);
80102584:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010258b:	e8 72 ff ff ff       	call   80102502 <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102590:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
80102597:	00 
80102598:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
8010259f:	e8 1b ff ff ff       	call   801024bf <outb>
  for(i=0; i<1000; i++){
801025a4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801025ab:	eb 20                	jmp    801025cd <ideinit+0x87>
    if(inb(0x1f7) != 0){
801025ad:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801025b4:	e8 b7 fe ff ff       	call   80102470 <inb>
801025b9:	84 c0                	test   %al,%al
801025bb:	74 0c                	je     801025c9 <ideinit+0x83>
      havedisk1 = 1;
801025bd:	c7 05 38 b6 10 80 01 	movl   $0x1,0x8010b638
801025c4:	00 00 00 
      break;
801025c7:	eb 0d                	jmp    801025d6 <ideinit+0x90>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
801025c9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801025cd:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801025d4:	7e d7                	jle    801025ad <ideinit+0x67>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801025d6:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
801025dd:	00 
801025de:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801025e5:	e8 d5 fe ff ff       	call   801024bf <outb>
}
801025ea:	c9                   	leave  
801025eb:	c3                   	ret    

801025ec <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801025ec:	55                   	push   %ebp
801025ed:	89 e5                	mov    %esp,%ebp
801025ef:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801025f2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025f6:	75 0c                	jne    80102604 <idestart+0x18>
    panic("idestart");
801025f8:	c7 04 24 38 83 10 80 	movl   $0x80108338,(%esp)
801025ff:	e8 42 df ff ff       	call   80100546 <panic>

  idewait(0);
80102604:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010260b:	e8 f2 fe ff ff       	call   80102502 <idewait>
  outb(0x3f6, 0);  // generate interrupt
80102610:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102617:	00 
80102618:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
8010261f:	e8 9b fe ff ff       	call   801024bf <outb>
  outb(0x1f2, 1);  // number of sectors
80102624:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010262b:	00 
8010262c:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
80102633:	e8 87 fe ff ff       	call   801024bf <outb>
  outb(0x1f3, b->sector & 0xff);
80102638:	8b 45 08             	mov    0x8(%ebp),%eax
8010263b:	8b 40 08             	mov    0x8(%eax),%eax
8010263e:	0f b6 c0             	movzbl %al,%eax
80102641:	89 44 24 04          	mov    %eax,0x4(%esp)
80102645:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
8010264c:	e8 6e fe ff ff       	call   801024bf <outb>
  outb(0x1f4, (b->sector >> 8) & 0xff);
80102651:	8b 45 08             	mov    0x8(%ebp),%eax
80102654:	8b 40 08             	mov    0x8(%eax),%eax
80102657:	c1 e8 08             	shr    $0x8,%eax
8010265a:	0f b6 c0             	movzbl %al,%eax
8010265d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102661:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
80102668:	e8 52 fe ff ff       	call   801024bf <outb>
  outb(0x1f5, (b->sector >> 16) & 0xff);
8010266d:	8b 45 08             	mov    0x8(%ebp),%eax
80102670:	8b 40 08             	mov    0x8(%eax),%eax
80102673:	c1 e8 10             	shr    $0x10,%eax
80102676:	0f b6 c0             	movzbl %al,%eax
80102679:	89 44 24 04          	mov    %eax,0x4(%esp)
8010267d:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
80102684:	e8 36 fe ff ff       	call   801024bf <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
80102689:	8b 45 08             	mov    0x8(%ebp),%eax
8010268c:	8b 40 04             	mov    0x4(%eax),%eax
8010268f:	83 e0 01             	and    $0x1,%eax
80102692:	89 c2                	mov    %eax,%edx
80102694:	c1 e2 04             	shl    $0x4,%edx
80102697:	8b 45 08             	mov    0x8(%ebp),%eax
8010269a:	8b 40 08             	mov    0x8(%eax),%eax
8010269d:	c1 e8 18             	shr    $0x18,%eax
801026a0:	83 e0 0f             	and    $0xf,%eax
801026a3:	09 d0                	or     %edx,%eax
801026a5:	83 c8 e0             	or     $0xffffffe0,%eax
801026a8:	0f b6 c0             	movzbl %al,%eax
801026ab:	89 44 24 04          	mov    %eax,0x4(%esp)
801026af:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801026b6:	e8 04 fe ff ff       	call   801024bf <outb>
  if(b->flags & B_DIRTY){
801026bb:	8b 45 08             	mov    0x8(%ebp),%eax
801026be:	8b 00                	mov    (%eax),%eax
801026c0:	83 e0 04             	and    $0x4,%eax
801026c3:	85 c0                	test   %eax,%eax
801026c5:	74 34                	je     801026fb <idestart+0x10f>
    outb(0x1f7, IDE_CMD_WRITE);
801026c7:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
801026ce:	00 
801026cf:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801026d6:	e8 e4 fd ff ff       	call   801024bf <outb>
    outsl(0x1f0, b->data, 512/4);
801026db:	8b 45 08             	mov    0x8(%ebp),%eax
801026de:	83 c0 18             	add    $0x18,%eax
801026e1:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801026e8:	00 
801026e9:	89 44 24 04          	mov    %eax,0x4(%esp)
801026ed:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
801026f4:	e8 e4 fd ff ff       	call   801024dd <outsl>
801026f9:	eb 14                	jmp    8010270f <idestart+0x123>
  } else {
    outb(0x1f7, IDE_CMD_READ);
801026fb:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80102702:	00 
80102703:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010270a:	e8 b0 fd ff ff       	call   801024bf <outb>
  }
}
8010270f:	c9                   	leave  
80102710:	c3                   	ret    

80102711 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102711:	55                   	push   %ebp
80102712:	89 e5                	mov    %esp,%ebp
80102714:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102717:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
8010271e:	e8 88 24 00 00       	call   80104bab <acquire>
  if((b = idequeue) == 0){
80102723:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102728:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010272b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010272f:	75 11                	jne    80102742 <ideintr+0x31>
    release(&idelock);
80102731:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102738:	e8 d0 24 00 00       	call   80104c0d <release>
    // cprintf("spurious IDE interrupt\n");
    return;
8010273d:	e9 90 00 00 00       	jmp    801027d2 <ideintr+0xc1>
  }
  idequeue = b->qnext;
80102742:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102745:	8b 40 14             	mov    0x14(%eax),%eax
80102748:	a3 34 b6 10 80       	mov    %eax,0x8010b634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
8010274d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102750:	8b 00                	mov    (%eax),%eax
80102752:	83 e0 04             	and    $0x4,%eax
80102755:	85 c0                	test   %eax,%eax
80102757:	75 2e                	jne    80102787 <ideintr+0x76>
80102759:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102760:	e8 9d fd ff ff       	call   80102502 <idewait>
80102765:	85 c0                	test   %eax,%eax
80102767:	78 1e                	js     80102787 <ideintr+0x76>
    insl(0x1f0, b->data, 512/4);
80102769:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010276c:	83 c0 18             	add    $0x18,%eax
8010276f:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102776:	00 
80102777:	89 44 24 04          	mov    %eax,0x4(%esp)
8010277b:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102782:	e8 13 fd ff ff       	call   8010249a <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102787:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010278a:	8b 00                	mov    (%eax),%eax
8010278c:	89 c2                	mov    %eax,%edx
8010278e:	83 ca 02             	or     $0x2,%edx
80102791:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102794:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102796:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102799:	8b 00                	mov    (%eax),%eax
8010279b:	89 c2                	mov    %eax,%edx
8010279d:	83 e2 fb             	and    $0xfffffffb,%edx
801027a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027a3:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801027a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027a8:	89 04 24             	mov    %eax,(%esp)
801027ab:	e8 e5 21 00 00       	call   80104995 <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
801027b0:	a1 34 b6 10 80       	mov    0x8010b634,%eax
801027b5:	85 c0                	test   %eax,%eax
801027b7:	74 0d                	je     801027c6 <ideintr+0xb5>
    idestart(idequeue);
801027b9:	a1 34 b6 10 80       	mov    0x8010b634,%eax
801027be:	89 04 24             	mov    %eax,(%esp)
801027c1:	e8 26 fe ff ff       	call   801025ec <idestart>

  release(&idelock);
801027c6:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
801027cd:	e8 3b 24 00 00       	call   80104c0d <release>
}
801027d2:	c9                   	leave  
801027d3:	c3                   	ret    

801027d4 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
801027d4:	55                   	push   %ebp
801027d5:	89 e5                	mov    %esp,%ebp
801027d7:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
801027da:	8b 45 08             	mov    0x8(%ebp),%eax
801027dd:	8b 00                	mov    (%eax),%eax
801027df:	83 e0 01             	and    $0x1,%eax
801027e2:	85 c0                	test   %eax,%eax
801027e4:	75 0c                	jne    801027f2 <iderw+0x1e>
    panic("iderw: buf not busy");
801027e6:	c7 04 24 41 83 10 80 	movl   $0x80108341,(%esp)
801027ed:	e8 54 dd ff ff       	call   80100546 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801027f2:	8b 45 08             	mov    0x8(%ebp),%eax
801027f5:	8b 00                	mov    (%eax),%eax
801027f7:	83 e0 06             	and    $0x6,%eax
801027fa:	83 f8 02             	cmp    $0x2,%eax
801027fd:	75 0c                	jne    8010280b <iderw+0x37>
    panic("iderw: nothing to do");
801027ff:	c7 04 24 55 83 10 80 	movl   $0x80108355,(%esp)
80102806:	e8 3b dd ff ff       	call   80100546 <panic>
  if(b->dev != 0 && !havedisk1)
8010280b:	8b 45 08             	mov    0x8(%ebp),%eax
8010280e:	8b 40 04             	mov    0x4(%eax),%eax
80102811:	85 c0                	test   %eax,%eax
80102813:	74 15                	je     8010282a <iderw+0x56>
80102815:	a1 38 b6 10 80       	mov    0x8010b638,%eax
8010281a:	85 c0                	test   %eax,%eax
8010281c:	75 0c                	jne    8010282a <iderw+0x56>
    panic("iderw: ide disk 1 not present");
8010281e:	c7 04 24 6a 83 10 80 	movl   $0x8010836a,(%esp)
80102825:	e8 1c dd ff ff       	call   80100546 <panic>

  acquire(&idelock);  //DOC: acquire-lock
8010282a:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102831:	e8 75 23 00 00       	call   80104bab <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102836:	8b 45 08             	mov    0x8(%ebp),%eax
80102839:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC: insert-queue
80102840:	c7 45 f4 34 b6 10 80 	movl   $0x8010b634,-0xc(%ebp)
80102847:	eb 0b                	jmp    80102854 <iderw+0x80>
80102849:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010284c:	8b 00                	mov    (%eax),%eax
8010284e:	83 c0 14             	add    $0x14,%eax
80102851:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102854:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102857:	8b 00                	mov    (%eax),%eax
80102859:	85 c0                	test   %eax,%eax
8010285b:	75 ec                	jne    80102849 <iderw+0x75>
    ;
  *pp = b;
8010285d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102860:	8b 55 08             	mov    0x8(%ebp),%edx
80102863:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102865:	a1 34 b6 10 80       	mov    0x8010b634,%eax
8010286a:	3b 45 08             	cmp    0x8(%ebp),%eax
8010286d:	75 22                	jne    80102891 <iderw+0xbd>
    idestart(b);
8010286f:	8b 45 08             	mov    0x8(%ebp),%eax
80102872:	89 04 24             	mov    %eax,(%esp)
80102875:	e8 72 fd ff ff       	call   801025ec <idestart>
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010287a:	eb 16                	jmp    80102892 <iderw+0xbe>
    sleep(b, &idelock);
8010287c:	c7 44 24 04 00 b6 10 	movl   $0x8010b600,0x4(%esp)
80102883:	80 
80102884:	8b 45 08             	mov    0x8(%ebp),%eax
80102887:	89 04 24             	mov    %eax,(%esp)
8010288a:	e8 20 20 00 00       	call   801048af <sleep>
8010288f:	eb 01                	jmp    80102892 <iderw+0xbe>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102891:	90                   	nop
80102892:	8b 45 08             	mov    0x8(%ebp),%eax
80102895:	8b 00                	mov    (%eax),%eax
80102897:	83 e0 06             	and    $0x6,%eax
8010289a:	83 f8 02             	cmp    $0x2,%eax
8010289d:	75 dd                	jne    8010287c <iderw+0xa8>
    sleep(b, &idelock);
  }

  release(&idelock);
8010289f:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
801028a6:	e8 62 23 00 00       	call   80104c0d <release>
}
801028ab:	c9                   	leave  
801028ac:	c3                   	ret    
801028ad:	00 00                	add    %al,(%eax)
	...

801028b0 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
801028b0:	55                   	push   %ebp
801028b1:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801028b3:	a1 34 f8 10 80       	mov    0x8010f834,%eax
801028b8:	8b 55 08             	mov    0x8(%ebp),%edx
801028bb:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
801028bd:	a1 34 f8 10 80       	mov    0x8010f834,%eax
801028c2:	8b 40 10             	mov    0x10(%eax),%eax
}
801028c5:	5d                   	pop    %ebp
801028c6:	c3                   	ret    

801028c7 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
801028c7:	55                   	push   %ebp
801028c8:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801028ca:	a1 34 f8 10 80       	mov    0x8010f834,%eax
801028cf:	8b 55 08             	mov    0x8(%ebp),%edx
801028d2:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
801028d4:	a1 34 f8 10 80       	mov    0x8010f834,%eax
801028d9:	8b 55 0c             	mov    0xc(%ebp),%edx
801028dc:	89 50 10             	mov    %edx,0x10(%eax)
}
801028df:	5d                   	pop    %ebp
801028e0:	c3                   	ret    

801028e1 <ioapicinit>:

void
ioapicinit(void)
{
801028e1:	55                   	push   %ebp
801028e2:	89 e5                	mov    %esp,%ebp
801028e4:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
801028e7:	a1 04 f9 10 80       	mov    0x8010f904,%eax
801028ec:	85 c0                	test   %eax,%eax
801028ee:	0f 84 9f 00 00 00    	je     80102993 <ioapicinit+0xb2>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
801028f4:	c7 05 34 f8 10 80 00 	movl   $0xfec00000,0x8010f834
801028fb:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
801028fe:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102905:	e8 a6 ff ff ff       	call   801028b0 <ioapicread>
8010290a:	c1 e8 10             	shr    $0x10,%eax
8010290d:	25 ff 00 00 00       	and    $0xff,%eax
80102912:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102915:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010291c:	e8 8f ff ff ff       	call   801028b0 <ioapicread>
80102921:	c1 e8 18             	shr    $0x18,%eax
80102924:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102927:	0f b6 05 00 f9 10 80 	movzbl 0x8010f900,%eax
8010292e:	0f b6 c0             	movzbl %al,%eax
80102931:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102934:	74 0c                	je     80102942 <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102936:	c7 04 24 88 83 10 80 	movl   $0x80108388,(%esp)
8010293d:	e8 63 da ff ff       	call   801003a5 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102942:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102949:	eb 3e                	jmp    80102989 <ioapicinit+0xa8>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
8010294b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010294e:	83 c0 20             	add    $0x20,%eax
80102951:	0d 00 00 01 00       	or     $0x10000,%eax
80102956:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102959:	83 c2 08             	add    $0x8,%edx
8010295c:	01 d2                	add    %edx,%edx
8010295e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102962:	89 14 24             	mov    %edx,(%esp)
80102965:	e8 5d ff ff ff       	call   801028c7 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
8010296a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010296d:	83 c0 08             	add    $0x8,%eax
80102970:	01 c0                	add    %eax,%eax
80102972:	83 c0 01             	add    $0x1,%eax
80102975:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010297c:	00 
8010297d:	89 04 24             	mov    %eax,(%esp)
80102980:	e8 42 ff ff ff       	call   801028c7 <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102985:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102989:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010298c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010298f:	7e ba                	jle    8010294b <ioapicinit+0x6a>
80102991:	eb 01                	jmp    80102994 <ioapicinit+0xb3>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
80102993:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102994:	c9                   	leave  
80102995:	c3                   	ret    

80102996 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102996:	55                   	push   %ebp
80102997:	89 e5                	mov    %esp,%ebp
80102999:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
8010299c:	a1 04 f9 10 80       	mov    0x8010f904,%eax
801029a1:	85 c0                	test   %eax,%eax
801029a3:	74 39                	je     801029de <ioapicenable+0x48>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
801029a5:	8b 45 08             	mov    0x8(%ebp),%eax
801029a8:	83 c0 20             	add    $0x20,%eax
801029ab:	8b 55 08             	mov    0x8(%ebp),%edx
801029ae:	83 c2 08             	add    $0x8,%edx
801029b1:	01 d2                	add    %edx,%edx
801029b3:	89 44 24 04          	mov    %eax,0x4(%esp)
801029b7:	89 14 24             	mov    %edx,(%esp)
801029ba:	e8 08 ff ff ff       	call   801028c7 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801029bf:	8b 45 0c             	mov    0xc(%ebp),%eax
801029c2:	c1 e0 18             	shl    $0x18,%eax
801029c5:	8b 55 08             	mov    0x8(%ebp),%edx
801029c8:	83 c2 08             	add    $0x8,%edx
801029cb:	01 d2                	add    %edx,%edx
801029cd:	83 c2 01             	add    $0x1,%edx
801029d0:	89 44 24 04          	mov    %eax,0x4(%esp)
801029d4:	89 14 24             	mov    %edx,(%esp)
801029d7:	e8 eb fe ff ff       	call   801028c7 <ioapicwrite>
801029dc:	eb 01                	jmp    801029df <ioapicenable+0x49>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
801029de:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
801029df:	c9                   	leave  
801029e0:	c3                   	ret    
801029e1:	00 00                	add    %al,(%eax)
	...

801029e4 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801029e4:	55                   	push   %ebp
801029e5:	89 e5                	mov    %esp,%ebp
801029e7:	8b 45 08             	mov    0x8(%ebp),%eax
801029ea:	2d 00 00 00 80       	sub    $0x80000000,%eax
801029ef:	5d                   	pop    %ebp
801029f0:	c3                   	ret    

801029f1 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
801029f1:	55                   	push   %ebp
801029f2:	89 e5                	mov    %esp,%ebp
801029f4:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
801029f7:	c7 44 24 04 ba 83 10 	movl   $0x801083ba,0x4(%esp)
801029fe:	80 
801029ff:	c7 04 24 40 f8 10 80 	movl   $0x8010f840,(%esp)
80102a06:	e8 7f 21 00 00       	call   80104b8a <initlock>
  kmem.use_lock = 0;
80102a0b:	c7 05 74 f8 10 80 00 	movl   $0x0,0x8010f874
80102a12:	00 00 00 
  freerange(vstart, vend);
80102a15:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a18:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a1c:	8b 45 08             	mov    0x8(%ebp),%eax
80102a1f:	89 04 24             	mov    %eax,(%esp)
80102a22:	e8 26 00 00 00       	call   80102a4d <freerange>
}
80102a27:	c9                   	leave  
80102a28:	c3                   	ret    

80102a29 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102a29:	55                   	push   %ebp
80102a2a:	89 e5                	mov    %esp,%ebp
80102a2c:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102a2f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a32:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a36:	8b 45 08             	mov    0x8(%ebp),%eax
80102a39:	89 04 24             	mov    %eax,(%esp)
80102a3c:	e8 0c 00 00 00       	call   80102a4d <freerange>
  kmem.use_lock = 1;
80102a41:	c7 05 74 f8 10 80 01 	movl   $0x1,0x8010f874
80102a48:	00 00 00 
}
80102a4b:	c9                   	leave  
80102a4c:	c3                   	ret    

80102a4d <freerange>:

void
freerange(void *vstart, void *vend)
{
80102a4d:	55                   	push   %ebp
80102a4e:	89 e5                	mov    %esp,%ebp
80102a50:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102a53:	8b 45 08             	mov    0x8(%ebp),%eax
80102a56:	05 ff 0f 00 00       	add    $0xfff,%eax
80102a5b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102a60:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102a63:	eb 12                	jmp    80102a77 <freerange+0x2a>
    kfree(p);
80102a65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a68:	89 04 24             	mov    %eax,(%esp)
80102a6b:	e8 19 00 00 00       	call   80102a89 <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102a70:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a7a:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
80102a80:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a83:	39 c2                	cmp    %eax,%edx
80102a85:	76 de                	jbe    80102a65 <freerange+0x18>
    kfree(p);
}
80102a87:	c9                   	leave  
80102a88:	c3                   	ret    

80102a89 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102a89:	55                   	push   %ebp
80102a8a:	89 e5                	mov    %esp,%ebp
80102a8c:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102a8f:	8b 45 08             	mov    0x8(%ebp),%eax
80102a92:	25 ff 0f 00 00       	and    $0xfff,%eax
80102a97:	85 c0                	test   %eax,%eax
80102a99:	75 1b                	jne    80102ab6 <kfree+0x2d>
80102a9b:	81 7d 08 1c 2a 11 80 	cmpl   $0x80112a1c,0x8(%ebp)
80102aa2:	72 12                	jb     80102ab6 <kfree+0x2d>
80102aa4:	8b 45 08             	mov    0x8(%ebp),%eax
80102aa7:	89 04 24             	mov    %eax,(%esp)
80102aaa:	e8 35 ff ff ff       	call   801029e4 <v2p>
80102aaf:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102ab4:	76 0c                	jbe    80102ac2 <kfree+0x39>
    panic("kfree");
80102ab6:	c7 04 24 bf 83 10 80 	movl   $0x801083bf,(%esp)
80102abd:	e8 84 da ff ff       	call   80100546 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102ac2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102ac9:	00 
80102aca:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102ad1:	00 
80102ad2:	8b 45 08             	mov    0x8(%ebp),%eax
80102ad5:	89 04 24             	mov    %eax,(%esp)
80102ad8:	e8 1d 23 00 00       	call   80104dfa <memset>

  if(kmem.use_lock)
80102add:	a1 74 f8 10 80       	mov    0x8010f874,%eax
80102ae2:	85 c0                	test   %eax,%eax
80102ae4:	74 0c                	je     80102af2 <kfree+0x69>
    acquire(&kmem.lock);
80102ae6:	c7 04 24 40 f8 10 80 	movl   $0x8010f840,(%esp)
80102aed:	e8 b9 20 00 00       	call   80104bab <acquire>
  r = (struct run*)v;
80102af2:	8b 45 08             	mov    0x8(%ebp),%eax
80102af5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102af8:	8b 15 78 f8 10 80    	mov    0x8010f878,%edx
80102afe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b01:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102b03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b06:	a3 78 f8 10 80       	mov    %eax,0x8010f878
  if(kmem.use_lock)
80102b0b:	a1 74 f8 10 80       	mov    0x8010f874,%eax
80102b10:	85 c0                	test   %eax,%eax
80102b12:	74 0c                	je     80102b20 <kfree+0x97>
    release(&kmem.lock);
80102b14:	c7 04 24 40 f8 10 80 	movl   $0x8010f840,(%esp)
80102b1b:	e8 ed 20 00 00       	call   80104c0d <release>
}
80102b20:	c9                   	leave  
80102b21:	c3                   	ret    

80102b22 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102b22:	55                   	push   %ebp
80102b23:	89 e5                	mov    %esp,%ebp
80102b25:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102b28:	a1 74 f8 10 80       	mov    0x8010f874,%eax
80102b2d:	85 c0                	test   %eax,%eax
80102b2f:	74 0c                	je     80102b3d <kalloc+0x1b>
    acquire(&kmem.lock);
80102b31:	c7 04 24 40 f8 10 80 	movl   $0x8010f840,(%esp)
80102b38:	e8 6e 20 00 00       	call   80104bab <acquire>
  r = kmem.freelist;
80102b3d:	a1 78 f8 10 80       	mov    0x8010f878,%eax
80102b42:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102b45:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102b49:	74 0a                	je     80102b55 <kalloc+0x33>
    kmem.freelist = r->next;
80102b4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b4e:	8b 00                	mov    (%eax),%eax
80102b50:	a3 78 f8 10 80       	mov    %eax,0x8010f878
  if(kmem.use_lock)
80102b55:	a1 74 f8 10 80       	mov    0x8010f874,%eax
80102b5a:	85 c0                	test   %eax,%eax
80102b5c:	74 0c                	je     80102b6a <kalloc+0x48>
    release(&kmem.lock);
80102b5e:	c7 04 24 40 f8 10 80 	movl   $0x8010f840,(%esp)
80102b65:	e8 a3 20 00 00       	call   80104c0d <release>
  return (char*)r;
80102b6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102b6d:	c9                   	leave  
80102b6e:	c3                   	ret    
	...

80102b70 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102b70:	55                   	push   %ebp
80102b71:	89 e5                	mov    %esp,%ebp
80102b73:	53                   	push   %ebx
80102b74:	83 ec 18             	sub    $0x18,%esp
80102b77:	8b 45 08             	mov    0x8(%ebp),%eax
80102b7a:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102b7e:	0f b7 45 e8          	movzwl -0x18(%ebp),%eax
80102b82:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
80102b86:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
80102b8a:	ec                   	in     (%dx),%al
80102b8b:	89 c3                	mov    %eax,%ebx
80102b8d:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80102b90:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80102b94:	83 c4 18             	add    $0x18,%esp
80102b97:	5b                   	pop    %ebx
80102b98:	5d                   	pop    %ebp
80102b99:	c3                   	ret    

80102b9a <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102b9a:	55                   	push   %ebp
80102b9b:	89 e5                	mov    %esp,%ebp
80102b9d:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102ba0:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102ba7:	e8 c4 ff ff ff       	call   80102b70 <inb>
80102bac:	0f b6 c0             	movzbl %al,%eax
80102baf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102bb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bb5:	83 e0 01             	and    $0x1,%eax
80102bb8:	85 c0                	test   %eax,%eax
80102bba:	75 0a                	jne    80102bc6 <kbdgetc+0x2c>
    return -1;
80102bbc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102bc1:	e9 23 01 00 00       	jmp    80102ce9 <kbdgetc+0x14f>
  data = inb(KBDATAP);
80102bc6:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102bcd:	e8 9e ff ff ff       	call   80102b70 <inb>
80102bd2:	0f b6 c0             	movzbl %al,%eax
80102bd5:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102bd8:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102bdf:	75 17                	jne    80102bf8 <kbdgetc+0x5e>
    shift |= E0ESC;
80102be1:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102be6:	83 c8 40             	or     $0x40,%eax
80102be9:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102bee:	b8 00 00 00 00       	mov    $0x0,%eax
80102bf3:	e9 f1 00 00 00       	jmp    80102ce9 <kbdgetc+0x14f>
  } else if(data & 0x80){
80102bf8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102bfb:	25 80 00 00 00       	and    $0x80,%eax
80102c00:	85 c0                	test   %eax,%eax
80102c02:	74 45                	je     80102c49 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102c04:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c09:	83 e0 40             	and    $0x40,%eax
80102c0c:	85 c0                	test   %eax,%eax
80102c0e:	75 08                	jne    80102c18 <kbdgetc+0x7e>
80102c10:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c13:	83 e0 7f             	and    $0x7f,%eax
80102c16:	eb 03                	jmp    80102c1b <kbdgetc+0x81>
80102c18:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c1b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102c1e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c21:	05 20 90 10 80       	add    $0x80109020,%eax
80102c26:	0f b6 00             	movzbl (%eax),%eax
80102c29:	83 c8 40             	or     $0x40,%eax
80102c2c:	0f b6 c0             	movzbl %al,%eax
80102c2f:	f7 d0                	not    %eax
80102c31:	89 c2                	mov    %eax,%edx
80102c33:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c38:	21 d0                	and    %edx,%eax
80102c3a:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102c3f:	b8 00 00 00 00       	mov    $0x0,%eax
80102c44:	e9 a0 00 00 00       	jmp    80102ce9 <kbdgetc+0x14f>
  } else if(shift & E0ESC){
80102c49:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c4e:	83 e0 40             	and    $0x40,%eax
80102c51:	85 c0                	test   %eax,%eax
80102c53:	74 14                	je     80102c69 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102c55:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102c5c:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c61:	83 e0 bf             	and    $0xffffffbf,%eax
80102c64:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  }

  shift |= shiftcode[data];
80102c69:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c6c:	05 20 90 10 80       	add    $0x80109020,%eax
80102c71:	0f b6 00             	movzbl (%eax),%eax
80102c74:	0f b6 d0             	movzbl %al,%edx
80102c77:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c7c:	09 d0                	or     %edx,%eax
80102c7e:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  shift ^= togglecode[data];
80102c83:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c86:	05 20 91 10 80       	add    $0x80109120,%eax
80102c8b:	0f b6 00             	movzbl (%eax),%eax
80102c8e:	0f b6 d0             	movzbl %al,%edx
80102c91:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c96:	31 d0                	xor    %edx,%eax
80102c98:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102c9d:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102ca2:	83 e0 03             	and    $0x3,%eax
80102ca5:	8b 04 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%eax
80102cac:	03 45 fc             	add    -0x4(%ebp),%eax
80102caf:	0f b6 00             	movzbl (%eax),%eax
80102cb2:	0f b6 c0             	movzbl %al,%eax
80102cb5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102cb8:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102cbd:	83 e0 08             	and    $0x8,%eax
80102cc0:	85 c0                	test   %eax,%eax
80102cc2:	74 22                	je     80102ce6 <kbdgetc+0x14c>
    if('a' <= c && c <= 'z')
80102cc4:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102cc8:	76 0c                	jbe    80102cd6 <kbdgetc+0x13c>
80102cca:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102cce:	77 06                	ja     80102cd6 <kbdgetc+0x13c>
      c += 'A' - 'a';
80102cd0:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102cd4:	eb 10                	jmp    80102ce6 <kbdgetc+0x14c>
    else if('A' <= c && c <= 'Z')
80102cd6:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102cda:	76 0a                	jbe    80102ce6 <kbdgetc+0x14c>
80102cdc:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102ce0:	77 04                	ja     80102ce6 <kbdgetc+0x14c>
      c += 'a' - 'A';
80102ce2:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102ce6:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102ce9:	c9                   	leave  
80102cea:	c3                   	ret    

80102ceb <kbdintr>:

void
kbdintr(void)
{
80102ceb:	55                   	push   %ebp
80102cec:	89 e5                	mov    %esp,%ebp
80102cee:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102cf1:	c7 04 24 9a 2b 10 80 	movl   $0x80102b9a,(%esp)
80102cf8:	e8 ba da ff ff       	call   801007b7 <consoleintr>
}
80102cfd:	c9                   	leave  
80102cfe:	c3                   	ret    
	...

80102d00 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102d00:	55                   	push   %ebp
80102d01:	89 e5                	mov    %esp,%ebp
80102d03:	83 ec 08             	sub    $0x8,%esp
80102d06:	8b 55 08             	mov    0x8(%ebp),%edx
80102d09:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d0c:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102d10:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d13:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102d17:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102d1b:	ee                   	out    %al,(%dx)
}
80102d1c:	c9                   	leave  
80102d1d:	c3                   	ret    

80102d1e <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102d1e:	55                   	push   %ebp
80102d1f:	89 e5                	mov    %esp,%ebp
80102d21:	53                   	push   %ebx
80102d22:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102d25:	9c                   	pushf  
80102d26:	5b                   	pop    %ebx
80102d27:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80102d2a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102d2d:	83 c4 10             	add    $0x10,%esp
80102d30:	5b                   	pop    %ebx
80102d31:	5d                   	pop    %ebp
80102d32:	c3                   	ret    

80102d33 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102d33:	55                   	push   %ebp
80102d34:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102d36:	a1 7c f8 10 80       	mov    0x8010f87c,%eax
80102d3b:	8b 55 08             	mov    0x8(%ebp),%edx
80102d3e:	c1 e2 02             	shl    $0x2,%edx
80102d41:	8d 14 10             	lea    (%eax,%edx,1),%edx
80102d44:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d47:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102d49:	a1 7c f8 10 80       	mov    0x8010f87c,%eax
80102d4e:	83 c0 20             	add    $0x20,%eax
80102d51:	8b 00                	mov    (%eax),%eax
}
80102d53:	5d                   	pop    %ebp
80102d54:	c3                   	ret    

80102d55 <lapicinit>:
//PAGEBREAK!

void
lapicinit(int c)
{
80102d55:	55                   	push   %ebp
80102d56:	89 e5                	mov    %esp,%ebp
80102d58:	83 ec 08             	sub    $0x8,%esp
  if(!lapic) 
80102d5b:	a1 7c f8 10 80       	mov    0x8010f87c,%eax
80102d60:	85 c0                	test   %eax,%eax
80102d62:	0f 84 47 01 00 00    	je     80102eaf <lapicinit+0x15a>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102d68:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80102d6f:	00 
80102d70:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80102d77:	e8 b7 ff ff ff       	call   80102d33 <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102d7c:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80102d83:	00 
80102d84:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80102d8b:	e8 a3 ff ff ff       	call   80102d33 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102d90:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80102d97:	00 
80102d98:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102d9f:	e8 8f ff ff ff       	call   80102d33 <lapicw>
  lapicw(TICR, 10000000); 
80102da4:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80102dab:	00 
80102dac:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
80102db3:	e8 7b ff ff ff       	call   80102d33 <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102db8:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102dbf:	00 
80102dc0:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80102dc7:	e8 67 ff ff ff       	call   80102d33 <lapicw>
  lapicw(LINT1, MASKED);
80102dcc:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102dd3:	00 
80102dd4:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80102ddb:	e8 53 ff ff ff       	call   80102d33 <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102de0:	a1 7c f8 10 80       	mov    0x8010f87c,%eax
80102de5:	83 c0 30             	add    $0x30,%eax
80102de8:	8b 00                	mov    (%eax),%eax
80102dea:	c1 e8 10             	shr    $0x10,%eax
80102ded:	25 ff 00 00 00       	and    $0xff,%eax
80102df2:	83 f8 03             	cmp    $0x3,%eax
80102df5:	76 14                	jbe    80102e0b <lapicinit+0xb6>
    lapicw(PCINT, MASKED);
80102df7:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102dfe:	00 
80102dff:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80102e06:	e8 28 ff ff ff       	call   80102d33 <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102e0b:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80102e12:	00 
80102e13:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80102e1a:	e8 14 ff ff ff       	call   80102d33 <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102e1f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e26:	00 
80102e27:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102e2e:	e8 00 ff ff ff       	call   80102d33 <lapicw>
  lapicw(ESR, 0);
80102e33:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e3a:	00 
80102e3b:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102e42:	e8 ec fe ff ff       	call   80102d33 <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102e47:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e4e:	00 
80102e4f:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102e56:	e8 d8 fe ff ff       	call   80102d33 <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102e5b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e62:	00 
80102e63:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102e6a:	e8 c4 fe ff ff       	call   80102d33 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102e6f:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80102e76:	00 
80102e77:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102e7e:	e8 b0 fe ff ff       	call   80102d33 <lapicw>
  while(lapic[ICRLO] & DELIVS)
80102e83:	90                   	nop
80102e84:	a1 7c f8 10 80       	mov    0x8010f87c,%eax
80102e89:	05 00 03 00 00       	add    $0x300,%eax
80102e8e:	8b 00                	mov    (%eax),%eax
80102e90:	25 00 10 00 00       	and    $0x1000,%eax
80102e95:	85 c0                	test   %eax,%eax
80102e97:	75 eb                	jne    80102e84 <lapicinit+0x12f>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102e99:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102ea0:	00 
80102ea1:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80102ea8:	e8 86 fe ff ff       	call   80102d33 <lapicw>
80102ead:	eb 01                	jmp    80102eb0 <lapicinit+0x15b>

void
lapicinit(int c)
{
  if(!lapic) 
    return;
80102eaf:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
80102eb0:	c9                   	leave  
80102eb1:	c3                   	ret    

80102eb2 <cpunum>:

int
cpunum(void)
{
80102eb2:	55                   	push   %ebp
80102eb3:	89 e5                	mov    %esp,%ebp
80102eb5:	83 ec 18             	sub    $0x18,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102eb8:	e8 61 fe ff ff       	call   80102d1e <readeflags>
80102ebd:	25 00 02 00 00       	and    $0x200,%eax
80102ec2:	85 c0                	test   %eax,%eax
80102ec4:	74 29                	je     80102eef <cpunum+0x3d>
    static int n;
    if(n++ == 0)
80102ec6:	a1 40 b6 10 80       	mov    0x8010b640,%eax
80102ecb:	85 c0                	test   %eax,%eax
80102ecd:	0f 94 c2             	sete   %dl
80102ed0:	83 c0 01             	add    $0x1,%eax
80102ed3:	a3 40 b6 10 80       	mov    %eax,0x8010b640
80102ed8:	84 d2                	test   %dl,%dl
80102eda:	74 13                	je     80102eef <cpunum+0x3d>
      cprintf("cpu called from %x with interrupts enabled\n",
80102edc:	8b 45 04             	mov    0x4(%ebp),%eax
80102edf:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ee3:	c7 04 24 c8 83 10 80 	movl   $0x801083c8,(%esp)
80102eea:	e8 b6 d4 ff ff       	call   801003a5 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
80102eef:	a1 7c f8 10 80       	mov    0x8010f87c,%eax
80102ef4:	85 c0                	test   %eax,%eax
80102ef6:	74 0f                	je     80102f07 <cpunum+0x55>
    return lapic[ID]>>24;
80102ef8:	a1 7c f8 10 80       	mov    0x8010f87c,%eax
80102efd:	83 c0 20             	add    $0x20,%eax
80102f00:	8b 00                	mov    (%eax),%eax
80102f02:	c1 e8 18             	shr    $0x18,%eax
80102f05:	eb 05                	jmp    80102f0c <cpunum+0x5a>
  return 0;
80102f07:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102f0c:	c9                   	leave  
80102f0d:	c3                   	ret    

80102f0e <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102f0e:	55                   	push   %ebp
80102f0f:	89 e5                	mov    %esp,%ebp
80102f11:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80102f14:	a1 7c f8 10 80       	mov    0x8010f87c,%eax
80102f19:	85 c0                	test   %eax,%eax
80102f1b:	74 14                	je     80102f31 <lapiceoi+0x23>
    lapicw(EOI, 0);
80102f1d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102f24:	00 
80102f25:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102f2c:	e8 02 fe ff ff       	call   80102d33 <lapicw>
}
80102f31:	c9                   	leave  
80102f32:	c3                   	ret    

80102f33 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102f33:	55                   	push   %ebp
80102f34:	89 e5                	mov    %esp,%ebp
}
80102f36:	5d                   	pop    %ebp
80102f37:	c3                   	ret    

80102f38 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102f38:	55                   	push   %ebp
80102f39:	89 e5                	mov    %esp,%ebp
80102f3b:	83 ec 1c             	sub    $0x1c,%esp
80102f3e:	8b 45 08             	mov    0x8(%ebp),%eax
80102f41:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
80102f44:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80102f4b:	00 
80102f4c:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80102f53:	e8 a8 fd ff ff       	call   80102d00 <outb>
  outb(IO_RTC+1, 0x0A);
80102f58:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80102f5f:	00 
80102f60:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80102f67:	e8 94 fd ff ff       	call   80102d00 <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102f6c:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102f73:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102f76:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102f7b:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102f7e:	8d 50 02             	lea    0x2(%eax),%edx
80102f81:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f84:	c1 e8 04             	shr    $0x4,%eax
80102f87:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102f8a:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102f8e:	c1 e0 18             	shl    $0x18,%eax
80102f91:	89 44 24 04          	mov    %eax,0x4(%esp)
80102f95:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102f9c:	e8 92 fd ff ff       	call   80102d33 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102fa1:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
80102fa8:	00 
80102fa9:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102fb0:	e8 7e fd ff ff       	call   80102d33 <lapicw>
  microdelay(200);
80102fb5:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102fbc:	e8 72 ff ff ff       	call   80102f33 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
80102fc1:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
80102fc8:	00 
80102fc9:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102fd0:	e8 5e fd ff ff       	call   80102d33 <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102fd5:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102fdc:	e8 52 ff ff ff       	call   80102f33 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102fe1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102fe8:	eb 40                	jmp    8010302a <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
80102fea:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102fee:	c1 e0 18             	shl    $0x18,%eax
80102ff1:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ff5:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102ffc:	e8 32 fd ff ff       	call   80102d33 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80103001:	8b 45 0c             	mov    0xc(%ebp),%eax
80103004:	c1 e8 0c             	shr    $0xc,%eax
80103007:	80 cc 06             	or     $0x6,%ah
8010300a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010300e:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103015:	e8 19 fd ff ff       	call   80102d33 <lapicw>
    microdelay(200);
8010301a:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103021:	e8 0d ff ff ff       	call   80102f33 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103026:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010302a:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
8010302e:	7e ba                	jle    80102fea <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80103030:	c9                   	leave  
80103031:	c3                   	ret    
	...

80103034 <initlog>:

static void recover_from_log(void);

void
initlog(void)
{
80103034:	55                   	push   %ebp
80103035:	89 e5                	mov    %esp,%ebp
80103037:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
8010303a:	c7 44 24 04 f4 83 10 	movl   $0x801083f4,0x4(%esp)
80103041:	80 
80103042:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
80103049:	e8 3c 1b 00 00       	call   80104b8a <initlock>
  readsb(ROOTDEV, &sb);
8010304e:	8d 45 e8             	lea    -0x18(%ebp),%eax
80103051:	89 44 24 04          	mov    %eax,0x4(%esp)
80103055:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010305c:	e8 9f e2 ff ff       	call   80101300 <readsb>
  log.start = sb.size - sb.nlog;
80103061:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103064:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103067:	89 d1                	mov    %edx,%ecx
80103069:	29 c1                	sub    %eax,%ecx
8010306b:	89 c8                	mov    %ecx,%eax
8010306d:	a3 b4 f8 10 80       	mov    %eax,0x8010f8b4
  log.size = sb.nlog;
80103072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103075:	a3 b8 f8 10 80       	mov    %eax,0x8010f8b8
  log.dev = ROOTDEV;
8010307a:	c7 05 c0 f8 10 80 01 	movl   $0x1,0x8010f8c0
80103081:	00 00 00 
  recover_from_log();
80103084:	e8 97 01 00 00       	call   80103220 <recover_from_log>
}
80103089:	c9                   	leave  
8010308a:	c3                   	ret    

8010308b <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
8010308b:	55                   	push   %ebp
8010308c:	89 e5                	mov    %esp,%ebp
8010308e:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103091:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103098:	e9 89 00 00 00       	jmp    80103126 <install_trans+0x9b>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
8010309d:	a1 b4 f8 10 80       	mov    0x8010f8b4,%eax
801030a2:	03 45 f4             	add    -0xc(%ebp),%eax
801030a5:	83 c0 01             	add    $0x1,%eax
801030a8:	89 c2                	mov    %eax,%edx
801030aa:	a1 c0 f8 10 80       	mov    0x8010f8c0,%eax
801030af:	89 54 24 04          	mov    %edx,0x4(%esp)
801030b3:	89 04 24             	mov    %eax,(%esp)
801030b6:	e8 ec d0 ff ff       	call   801001a7 <bread>
801030bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
801030be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030c1:	83 c0 10             	add    $0x10,%eax
801030c4:	8b 04 85 88 f8 10 80 	mov    -0x7fef0778(,%eax,4),%eax
801030cb:	89 c2                	mov    %eax,%edx
801030cd:	a1 c0 f8 10 80       	mov    0x8010f8c0,%eax
801030d2:	89 54 24 04          	mov    %edx,0x4(%esp)
801030d6:	89 04 24             	mov    %eax,(%esp)
801030d9:	e8 c9 d0 ff ff       	call   801001a7 <bread>
801030de:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801030e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801030e4:	8d 50 18             	lea    0x18(%eax),%edx
801030e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801030ea:	83 c0 18             	add    $0x18,%eax
801030ed:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801030f4:	00 
801030f5:	89 54 24 04          	mov    %edx,0x4(%esp)
801030f9:	89 04 24             	mov    %eax,(%esp)
801030fc:	e8 cc 1d 00 00       	call   80104ecd <memmove>
    bwrite(dbuf);  // write dst to disk
80103101:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103104:	89 04 24             	mov    %eax,(%esp)
80103107:	e8 d2 d0 ff ff       	call   801001de <bwrite>
    brelse(lbuf); 
8010310c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010310f:	89 04 24             	mov    %eax,(%esp)
80103112:	e8 01 d1 ff ff       	call   80100218 <brelse>
    brelse(dbuf);
80103117:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010311a:	89 04 24             	mov    %eax,(%esp)
8010311d:	e8 f6 d0 ff ff       	call   80100218 <brelse>
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103122:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103126:	a1 c4 f8 10 80       	mov    0x8010f8c4,%eax
8010312b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010312e:	0f 8f 69 ff ff ff    	jg     8010309d <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103134:	c9                   	leave  
80103135:	c3                   	ret    

80103136 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103136:	55                   	push   %ebp
80103137:	89 e5                	mov    %esp,%ebp
80103139:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
8010313c:	a1 b4 f8 10 80       	mov    0x8010f8b4,%eax
80103141:	89 c2                	mov    %eax,%edx
80103143:	a1 c0 f8 10 80       	mov    0x8010f8c0,%eax
80103148:	89 54 24 04          	mov    %edx,0x4(%esp)
8010314c:	89 04 24             	mov    %eax,(%esp)
8010314f:	e8 53 d0 ff ff       	call   801001a7 <bread>
80103154:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103157:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010315a:	83 c0 18             	add    $0x18,%eax
8010315d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103160:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103163:	8b 00                	mov    (%eax),%eax
80103165:	a3 c4 f8 10 80       	mov    %eax,0x8010f8c4
  for (i = 0; i < log.lh.n; i++) {
8010316a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103171:	eb 1b                	jmp    8010318e <read_head+0x58>
    log.lh.sector[i] = lh->sector[i];
80103173:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103176:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103179:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010317d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103180:	83 c2 10             	add    $0x10,%edx
80103183:	89 04 95 88 f8 10 80 	mov    %eax,-0x7fef0778(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
8010318a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010318e:	a1 c4 f8 10 80       	mov    0x8010f8c4,%eax
80103193:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103196:	7f db                	jg     80103173 <read_head+0x3d>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
80103198:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010319b:	89 04 24             	mov    %eax,(%esp)
8010319e:	e8 75 d0 ff ff       	call   80100218 <brelse>
}
801031a3:	c9                   	leave  
801031a4:	c3                   	ret    

801031a5 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801031a5:	55                   	push   %ebp
801031a6:	89 e5                	mov    %esp,%ebp
801031a8:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
801031ab:	a1 b4 f8 10 80       	mov    0x8010f8b4,%eax
801031b0:	89 c2                	mov    %eax,%edx
801031b2:	a1 c0 f8 10 80       	mov    0x8010f8c0,%eax
801031b7:	89 54 24 04          	mov    %edx,0x4(%esp)
801031bb:	89 04 24             	mov    %eax,(%esp)
801031be:	e8 e4 cf ff ff       	call   801001a7 <bread>
801031c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801031c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801031c9:	83 c0 18             	add    $0x18,%eax
801031cc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801031cf:	8b 15 c4 f8 10 80    	mov    0x8010f8c4,%edx
801031d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031d8:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801031da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801031e1:	eb 1b                	jmp    801031fe <write_head+0x59>
    hb->sector[i] = log.lh.sector[i];
801031e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031e6:	83 c0 10             	add    $0x10,%eax
801031e9:	8b 0c 85 88 f8 10 80 	mov    -0x7fef0778(,%eax,4),%ecx
801031f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801031f6:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
801031fa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801031fe:	a1 c4 f8 10 80       	mov    0x8010f8c4,%eax
80103203:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103206:	7f db                	jg     801031e3 <write_head+0x3e>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
80103208:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010320b:	89 04 24             	mov    %eax,(%esp)
8010320e:	e8 cb cf ff ff       	call   801001de <bwrite>
  brelse(buf);
80103213:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103216:	89 04 24             	mov    %eax,(%esp)
80103219:	e8 fa cf ff ff       	call   80100218 <brelse>
}
8010321e:	c9                   	leave  
8010321f:	c3                   	ret    

80103220 <recover_from_log>:

static void
recover_from_log(void)
{
80103220:	55                   	push   %ebp
80103221:	89 e5                	mov    %esp,%ebp
80103223:	83 ec 08             	sub    $0x8,%esp
  read_head();      
80103226:	e8 0b ff ff ff       	call   80103136 <read_head>
  install_trans(); // if committed, copy from log to disk
8010322b:	e8 5b fe ff ff       	call   8010308b <install_trans>
  log.lh.n = 0;
80103230:	c7 05 c4 f8 10 80 00 	movl   $0x0,0x8010f8c4
80103237:	00 00 00 
  write_head(); // clear the log
8010323a:	e8 66 ff ff ff       	call   801031a5 <write_head>
}
8010323f:	c9                   	leave  
80103240:	c3                   	ret    

80103241 <begin_trans>:

void
begin_trans(void)
{
80103241:	55                   	push   %ebp
80103242:	89 e5                	mov    %esp,%ebp
80103244:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
80103247:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
8010324e:	e8 58 19 00 00       	call   80104bab <acquire>
  while (log.busy) {
80103253:	eb 14                	jmp    80103269 <begin_trans+0x28>
    sleep(&log, &log.lock);
80103255:	c7 44 24 04 80 f8 10 	movl   $0x8010f880,0x4(%esp)
8010325c:	80 
8010325d:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
80103264:	e8 46 16 00 00       	call   801048af <sleep>

void
begin_trans(void)
{
  acquire(&log.lock);
  while (log.busy) {
80103269:	a1 bc f8 10 80       	mov    0x8010f8bc,%eax
8010326e:	85 c0                	test   %eax,%eax
80103270:	75 e3                	jne    80103255 <begin_trans+0x14>
    sleep(&log, &log.lock);
  }
  log.busy = 1;
80103272:	c7 05 bc f8 10 80 01 	movl   $0x1,0x8010f8bc
80103279:	00 00 00 
  release(&log.lock);
8010327c:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
80103283:	e8 85 19 00 00       	call   80104c0d <release>
}
80103288:	c9                   	leave  
80103289:	c3                   	ret    

8010328a <commit_trans>:

void
commit_trans(void)
{
8010328a:	55                   	push   %ebp
8010328b:	89 e5                	mov    %esp,%ebp
8010328d:	83 ec 18             	sub    $0x18,%esp
  if (log.lh.n > 0) {
80103290:	a1 c4 f8 10 80       	mov    0x8010f8c4,%eax
80103295:	85 c0                	test   %eax,%eax
80103297:	7e 19                	jle    801032b2 <commit_trans+0x28>
    write_head();    // Write header to disk -- the real commit
80103299:	e8 07 ff ff ff       	call   801031a5 <write_head>
    install_trans(); // Now install writes to home locations
8010329e:	e8 e8 fd ff ff       	call   8010308b <install_trans>
    log.lh.n = 0; 
801032a3:	c7 05 c4 f8 10 80 00 	movl   $0x0,0x8010f8c4
801032aa:	00 00 00 
    write_head();    // Erase the transaction from the log
801032ad:	e8 f3 fe ff ff       	call   801031a5 <write_head>
  }
  
  acquire(&log.lock);
801032b2:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
801032b9:	e8 ed 18 00 00       	call   80104bab <acquire>
  log.busy = 0;
801032be:	c7 05 bc f8 10 80 00 	movl   $0x0,0x8010f8bc
801032c5:	00 00 00 
  wakeup(&log);
801032c8:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
801032cf:	e8 c1 16 00 00       	call   80104995 <wakeup>
  release(&log.lock);
801032d4:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
801032db:	e8 2d 19 00 00       	call   80104c0d <release>
}
801032e0:	c9                   	leave  
801032e1:	c3                   	ret    

801032e2 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801032e2:	55                   	push   %ebp
801032e3:	89 e5                	mov    %esp,%ebp
801032e5:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801032e8:	a1 c4 f8 10 80       	mov    0x8010f8c4,%eax
801032ed:	83 f8 09             	cmp    $0x9,%eax
801032f0:	7f 12                	jg     80103304 <log_write+0x22>
801032f2:	a1 c4 f8 10 80       	mov    0x8010f8c4,%eax
801032f7:	8b 15 b8 f8 10 80    	mov    0x8010f8b8,%edx
801032fd:	83 ea 01             	sub    $0x1,%edx
80103300:	39 d0                	cmp    %edx,%eax
80103302:	7c 0c                	jl     80103310 <log_write+0x2e>
    panic("too big a transaction");
80103304:	c7 04 24 f8 83 10 80 	movl   $0x801083f8,(%esp)
8010330b:	e8 36 d2 ff ff       	call   80100546 <panic>
  if (!log.busy)
80103310:	a1 bc f8 10 80       	mov    0x8010f8bc,%eax
80103315:	85 c0                	test   %eax,%eax
80103317:	75 0c                	jne    80103325 <log_write+0x43>
    panic("write outside of trans");
80103319:	c7 04 24 0e 84 10 80 	movl   $0x8010840e,(%esp)
80103320:	e8 21 d2 ff ff       	call   80100546 <panic>

  for (i = 0; i < log.lh.n; i++) {
80103325:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010332c:	eb 1d                	jmp    8010334b <log_write+0x69>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
8010332e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103331:	83 c0 10             	add    $0x10,%eax
80103334:	8b 04 85 88 f8 10 80 	mov    -0x7fef0778(,%eax,4),%eax
8010333b:	89 c2                	mov    %eax,%edx
8010333d:	8b 45 08             	mov    0x8(%ebp),%eax
80103340:	8b 40 08             	mov    0x8(%eax),%eax
80103343:	39 c2                	cmp    %eax,%edx
80103345:	74 10                	je     80103357 <log_write+0x75>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    panic("too big a transaction");
  if (!log.busy)
    panic("write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
80103347:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010334b:	a1 c4 f8 10 80       	mov    0x8010f8c4,%eax
80103350:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103353:	7f d9                	jg     8010332e <log_write+0x4c>
80103355:	eb 01                	jmp    80103358 <log_write+0x76>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
      break;
80103357:	90                   	nop
  }
  log.lh.sector[i] = b->sector;
80103358:	8b 45 08             	mov    0x8(%ebp),%eax
8010335b:	8b 40 08             	mov    0x8(%eax),%eax
8010335e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103361:	83 c2 10             	add    $0x10,%edx
80103364:	89 04 95 88 f8 10 80 	mov    %eax,-0x7fef0778(,%edx,4)
  struct buf *lbuf = bread(b->dev, log.start+i+1);
8010336b:	a1 b4 f8 10 80       	mov    0x8010f8b4,%eax
80103370:	03 45 f4             	add    -0xc(%ebp),%eax
80103373:	83 c0 01             	add    $0x1,%eax
80103376:	89 c2                	mov    %eax,%edx
80103378:	8b 45 08             	mov    0x8(%ebp),%eax
8010337b:	8b 40 04             	mov    0x4(%eax),%eax
8010337e:	89 54 24 04          	mov    %edx,0x4(%esp)
80103382:	89 04 24             	mov    %eax,(%esp)
80103385:	e8 1d ce ff ff       	call   801001a7 <bread>
8010338a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(lbuf->data, b->data, BSIZE);
8010338d:	8b 45 08             	mov    0x8(%ebp),%eax
80103390:	8d 50 18             	lea    0x18(%eax),%edx
80103393:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103396:	83 c0 18             	add    $0x18,%eax
80103399:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801033a0:	00 
801033a1:	89 54 24 04          	mov    %edx,0x4(%esp)
801033a5:	89 04 24             	mov    %eax,(%esp)
801033a8:	e8 20 1b 00 00       	call   80104ecd <memmove>
  bwrite(lbuf);
801033ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033b0:	89 04 24             	mov    %eax,(%esp)
801033b3:	e8 26 ce ff ff       	call   801001de <bwrite>
  brelse(lbuf);
801033b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033bb:	89 04 24             	mov    %eax,(%esp)
801033be:	e8 55 ce ff ff       	call   80100218 <brelse>
  if (i == log.lh.n)
801033c3:	a1 c4 f8 10 80       	mov    0x8010f8c4,%eax
801033c8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801033cb:	75 0d                	jne    801033da <log_write+0xf8>
    log.lh.n++;
801033cd:	a1 c4 f8 10 80       	mov    0x8010f8c4,%eax
801033d2:	83 c0 01             	add    $0x1,%eax
801033d5:	a3 c4 f8 10 80       	mov    %eax,0x8010f8c4
  b->flags |= B_DIRTY; // XXX prevent eviction
801033da:	8b 45 08             	mov    0x8(%ebp),%eax
801033dd:	8b 00                	mov    (%eax),%eax
801033df:	89 c2                	mov    %eax,%edx
801033e1:	83 ca 04             	or     $0x4,%edx
801033e4:	8b 45 08             	mov    0x8(%ebp),%eax
801033e7:	89 10                	mov    %edx,(%eax)
}
801033e9:	c9                   	leave  
801033ea:	c3                   	ret    
	...

801033ec <v2p>:
801033ec:	55                   	push   %ebp
801033ed:	89 e5                	mov    %esp,%ebp
801033ef:	8b 45 08             	mov    0x8(%ebp),%eax
801033f2:	2d 00 00 00 80       	sub    $0x80000000,%eax
801033f7:	5d                   	pop    %ebp
801033f8:	c3                   	ret    

801033f9 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801033f9:	55                   	push   %ebp
801033fa:	89 e5                	mov    %esp,%ebp
801033fc:	8b 45 08             	mov    0x8(%ebp),%eax
801033ff:	2d 00 00 00 80       	sub    $0x80000000,%eax
80103404:	5d                   	pop    %ebp
80103405:	c3                   	ret    

80103406 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103406:	55                   	push   %ebp
80103407:	89 e5                	mov    %esp,%ebp
80103409:	53                   	push   %ebx
8010340a:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
8010340d:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103410:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
80103413:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103416:	89 c3                	mov    %eax,%ebx
80103418:	89 d8                	mov    %ebx,%eax
8010341a:	f0 87 02             	lock xchg %eax,(%edx)
8010341d:	89 c3                	mov    %eax,%ebx
8010341f:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103422:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103425:	83 c4 10             	add    $0x10,%esp
80103428:	5b                   	pop    %ebx
80103429:	5d                   	pop    %ebp
8010342a:	c3                   	ret    

8010342b <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
8010342b:	55                   	push   %ebp
8010342c:	89 e5                	mov    %esp,%ebp
8010342e:	83 e4 f0             	and    $0xfffffff0,%esp
80103431:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103434:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
8010343b:	80 
8010343c:	c7 04 24 1c 2a 11 80 	movl   $0x80112a1c,(%esp)
80103443:	e8 a9 f5 ff ff       	call   801029f1 <kinit1>
  kvmalloc();      // kernel page table
80103448:	e8 03 46 00 00       	call   80107a50 <kvmalloc>
  mpinit();        // collect info about this machine
8010344d:	e8 63 04 00 00       	call   801038b5 <mpinit>
  lapicinit(mpbcpu());
80103452:	e8 2e 02 00 00       	call   80103685 <mpbcpu>
80103457:	89 04 24             	mov    %eax,(%esp)
8010345a:	e8 f6 f8 ff ff       	call   80102d55 <lapicinit>
  seginit();       // set up segments
8010345f:	e8 8d 3f 00 00       	call   801073f1 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103464:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010346a:	0f b6 00             	movzbl (%eax),%eax
8010346d:	0f b6 c0             	movzbl %al,%eax
80103470:	89 44 24 04          	mov    %eax,0x4(%esp)
80103474:	c7 04 24 25 84 10 80 	movl   $0x80108425,(%esp)
8010347b:	e8 25 cf ff ff       	call   801003a5 <cprintf>
  picinit();       // interrupt controller
80103480:	e8 99 06 00 00       	call   80103b1e <picinit>
  ioapicinit();    // another interrupt controller
80103485:	e8 57 f4 ff ff       	call   801028e1 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
8010348a:	e8 0e d6 ff ff       	call   80100a9d <consoleinit>
  uartinit();      // serial port
8010348f:	e8 a8 32 00 00       	call   8010673c <uartinit>
  pinit();         // process table
80103494:	e8 c6 0b 00 00       	call   8010405f <pinit>
  tvinit();        // trap vectors
80103499:	e8 f5 2d 00 00       	call   80106293 <tvinit>
  binit();         // buffer cache
8010349e:	e8 91 cb ff ff       	call   80100034 <binit>
  fileinit();      // file table
801034a3:	e8 6c da ff ff       	call   80100f14 <fileinit>
  iinit();         // inode cache
801034a8:	e8 1d e1 ff ff       	call   801015ca <iinit>
  ideinit();       // disk
801034ad:	e8 94 f0 ff ff       	call   80102546 <ideinit>
  if(!ismp)
801034b2:	a1 04 f9 10 80       	mov    0x8010f904,%eax
801034b7:	85 c0                	test   %eax,%eax
801034b9:	75 05                	jne    801034c0 <main+0x95>
    timerinit();   // uniprocessor timer
801034bb:	e8 16 2d 00 00       	call   801061d6 <timerinit>
  startothers();   // start other processors
801034c0:	e8 87 00 00 00       	call   8010354c <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801034c5:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
801034cc:	8e 
801034cd:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
801034d4:	e8 50 f5 ff ff       	call   80102a29 <kinit2>
  userinit();      // first user process
801034d9:	e8 a0 0c 00 00       	call   8010417e <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
801034de:	e8 22 00 00 00       	call   80103505 <mpmain>

801034e3 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801034e3:	55                   	push   %ebp
801034e4:	89 e5                	mov    %esp,%ebp
801034e6:	83 ec 18             	sub    $0x18,%esp
  switchkvm(); 
801034e9:	e8 79 45 00 00       	call   80107a67 <switchkvm>
  seginit();
801034ee:	e8 fe 3e 00 00       	call   801073f1 <seginit>
  lapicinit(cpunum());
801034f3:	e8 ba f9 ff ff       	call   80102eb2 <cpunum>
801034f8:	89 04 24             	mov    %eax,(%esp)
801034fb:	e8 55 f8 ff ff       	call   80102d55 <lapicinit>
  mpmain();
80103500:	e8 00 00 00 00       	call   80103505 <mpmain>

80103505 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103505:	55                   	push   %ebp
80103506:	89 e5                	mov    %esp,%ebp
80103508:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
8010350b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103511:	0f b6 00             	movzbl (%eax),%eax
80103514:	0f b6 c0             	movzbl %al,%eax
80103517:	89 44 24 04          	mov    %eax,0x4(%esp)
8010351b:	c7 04 24 3c 84 10 80 	movl   $0x8010843c,(%esp)
80103522:	e8 7e ce ff ff       	call   801003a5 <cprintf>
  idtinit();       // load idt register
80103527:	e8 db 2e 00 00       	call   80106407 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
8010352c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103532:	05 a8 00 00 00       	add    $0xa8,%eax
80103537:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010353e:	00 
8010353f:	89 04 24             	mov    %eax,(%esp)
80103542:	e8 bf fe ff ff       	call   80103406 <xchg>
  scheduler();     // start running processes
80103547:	e8 a2 11 00 00       	call   801046ee <scheduler>

8010354c <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
8010354c:	55                   	push   %ebp
8010354d:	89 e5                	mov    %esp,%ebp
8010354f:	53                   	push   %ebx
80103550:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
80103553:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
8010355a:	e8 9a fe ff ff       	call   801033f9 <p2v>
8010355f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103562:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103567:	89 44 24 08          	mov    %eax,0x8(%esp)
8010356b:	c7 44 24 04 0c b5 10 	movl   $0x8010b50c,0x4(%esp)
80103572:	80 
80103573:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103576:	89 04 24             	mov    %eax,(%esp)
80103579:	e8 4f 19 00 00       	call   80104ecd <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
8010357e:	c7 45 f4 20 f9 10 80 	movl   $0x8010f920,-0xc(%ebp)
80103585:	e9 87 00 00 00       	jmp    80103611 <startothers+0xc5>
    if(c == cpus+cpunum())  // We've started already.
8010358a:	e8 23 f9 ff ff       	call   80102eb2 <cpunum>
8010358f:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103595:	05 20 f9 10 80       	add    $0x8010f920,%eax
8010359a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010359d:	74 6a                	je     80103609 <startothers+0xbd>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
8010359f:	e8 7e f5 ff ff       	call   80102b22 <kalloc>
801035a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801035a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035aa:	83 e8 04             	sub    $0x4,%eax
801035ad:	8b 55 ec             	mov    -0x14(%ebp),%edx
801035b0:	81 c2 00 10 00 00    	add    $0x1000,%edx
801035b6:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801035b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035bb:	83 e8 08             	sub    $0x8,%eax
801035be:	c7 00 e3 34 10 80    	movl   $0x801034e3,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
801035c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035c7:	8d 58 f4             	lea    -0xc(%eax),%ebx
801035ca:	b8 00 a0 10 80       	mov    $0x8010a000,%eax
801035cf:	89 04 24             	mov    %eax,(%esp)
801035d2:	e8 15 fe ff ff       	call   801033ec <v2p>
801035d7:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
801035d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035dc:	89 04 24             	mov    %eax,(%esp)
801035df:	e8 08 fe ff ff       	call   801033ec <v2p>
801035e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801035e7:	0f b6 12             	movzbl (%edx),%edx
801035ea:	0f b6 d2             	movzbl %dl,%edx
801035ed:	89 44 24 04          	mov    %eax,0x4(%esp)
801035f1:	89 14 24             	mov    %edx,(%esp)
801035f4:	e8 3f f9 ff ff       	call   80102f38 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801035f9:	90                   	nop
801035fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035fd:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103603:	85 c0                	test   %eax,%eax
80103605:	74 f3                	je     801035fa <startothers+0xae>
80103607:	eb 01                	jmp    8010360a <startothers+0xbe>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
80103609:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
8010360a:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103611:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
80103616:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010361c:	05 20 f9 10 80       	add    $0x8010f920,%eax
80103621:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103624:	0f 87 60 ff ff ff    	ja     8010358a <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
8010362a:	83 c4 24             	add    $0x24,%esp
8010362d:	5b                   	pop    %ebx
8010362e:	5d                   	pop    %ebp
8010362f:	c3                   	ret    

80103630 <p2v>:
80103630:	55                   	push   %ebp
80103631:	89 e5                	mov    %esp,%ebp
80103633:	8b 45 08             	mov    0x8(%ebp),%eax
80103636:	2d 00 00 00 80       	sub    $0x80000000,%eax
8010363b:	5d                   	pop    %ebp
8010363c:	c3                   	ret    

8010363d <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010363d:	55                   	push   %ebp
8010363e:	89 e5                	mov    %esp,%ebp
80103640:	53                   	push   %ebx
80103641:	83 ec 18             	sub    $0x18,%esp
80103644:	8b 45 08             	mov    0x8(%ebp),%eax
80103647:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010364b:	0f b7 45 e8          	movzwl -0x18(%ebp),%eax
8010364f:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
80103653:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
80103657:	ec                   	in     (%dx),%al
80103658:	89 c3                	mov    %eax,%ebx
8010365a:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
8010365d:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80103661:	83 c4 18             	add    $0x18,%esp
80103664:	5b                   	pop    %ebx
80103665:	5d                   	pop    %ebp
80103666:	c3                   	ret    

80103667 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103667:	55                   	push   %ebp
80103668:	89 e5                	mov    %esp,%ebp
8010366a:	83 ec 08             	sub    $0x8,%esp
8010366d:	8b 55 08             	mov    0x8(%ebp),%edx
80103670:	8b 45 0c             	mov    0xc(%ebp),%eax
80103673:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103677:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010367a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010367e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103682:	ee                   	out    %al,(%dx)
}
80103683:	c9                   	leave  
80103684:	c3                   	ret    

80103685 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103685:	55                   	push   %ebp
80103686:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103688:	a1 44 b6 10 80       	mov    0x8010b644,%eax
8010368d:	89 c2                	mov    %eax,%edx
8010368f:	b8 20 f9 10 80       	mov    $0x8010f920,%eax
80103694:	89 d1                	mov    %edx,%ecx
80103696:	29 c1                	sub    %eax,%ecx
80103698:	89 c8                	mov    %ecx,%eax
8010369a:	c1 f8 02             	sar    $0x2,%eax
8010369d:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
801036a3:	5d                   	pop    %ebp
801036a4:	c3                   	ret    

801036a5 <sum>:

static uchar
sum(uchar *addr, int len)
{
801036a5:	55                   	push   %ebp
801036a6:	89 e5                	mov    %esp,%ebp
801036a8:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
801036ab:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
801036b2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801036b9:	eb 13                	jmp    801036ce <sum+0x29>
    sum += addr[i];
801036bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801036be:	03 45 08             	add    0x8(%ebp),%eax
801036c1:	0f b6 00             	movzbl (%eax),%eax
801036c4:	0f b6 c0             	movzbl %al,%eax
801036c7:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
801036ca:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801036ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
801036d1:	3b 45 0c             	cmp    0xc(%ebp),%eax
801036d4:	7c e5                	jl     801036bb <sum+0x16>
    sum += addr[i];
  return sum;
801036d6:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801036d9:	c9                   	leave  
801036da:	c3                   	ret    

801036db <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
801036db:	55                   	push   %ebp
801036dc:	89 e5                	mov    %esp,%ebp
801036de:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
801036e1:	8b 45 08             	mov    0x8(%ebp),%eax
801036e4:	89 04 24             	mov    %eax,(%esp)
801036e7:	e8 44 ff ff ff       	call   80103630 <p2v>
801036ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
801036ef:	8b 45 0c             	mov    0xc(%ebp),%eax
801036f2:	03 45 f0             	add    -0x10(%ebp),%eax
801036f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
801036f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
801036fe:	eb 3f                	jmp    8010373f <mpsearch1+0x64>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103700:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103707:	00 
80103708:	c7 44 24 04 50 84 10 	movl   $0x80108450,0x4(%esp)
8010370f:	80 
80103710:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103713:	89 04 24             	mov    %eax,(%esp)
80103716:	e8 56 17 00 00       	call   80104e71 <memcmp>
8010371b:	85 c0                	test   %eax,%eax
8010371d:	75 1c                	jne    8010373b <mpsearch1+0x60>
8010371f:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103726:	00 
80103727:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010372a:	89 04 24             	mov    %eax,(%esp)
8010372d:	e8 73 ff ff ff       	call   801036a5 <sum>
80103732:	84 c0                	test   %al,%al
80103734:	75 05                	jne    8010373b <mpsearch1+0x60>
      return (struct mp*)p;
80103736:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103739:	eb 11                	jmp    8010374c <mpsearch1+0x71>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
8010373b:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010373f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103742:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103745:	72 b9                	jb     80103700 <mpsearch1+0x25>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103747:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010374c:	c9                   	leave  
8010374d:	c3                   	ret    

8010374e <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
8010374e:	55                   	push   %ebp
8010374f:	89 e5                	mov    %esp,%ebp
80103751:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103754:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
8010375b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010375e:	83 c0 0f             	add    $0xf,%eax
80103761:	0f b6 00             	movzbl (%eax),%eax
80103764:	0f b6 c0             	movzbl %al,%eax
80103767:	89 c2                	mov    %eax,%edx
80103769:	c1 e2 08             	shl    $0x8,%edx
8010376c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010376f:	83 c0 0e             	add    $0xe,%eax
80103772:	0f b6 00             	movzbl (%eax),%eax
80103775:	0f b6 c0             	movzbl %al,%eax
80103778:	09 d0                	or     %edx,%eax
8010377a:	c1 e0 04             	shl    $0x4,%eax
8010377d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103780:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103784:	74 21                	je     801037a7 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103786:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
8010378d:	00 
8010378e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103791:	89 04 24             	mov    %eax,(%esp)
80103794:	e8 42 ff ff ff       	call   801036db <mpsearch1>
80103799:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010379c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801037a0:	74 50                	je     801037f2 <mpsearch+0xa4>
      return mp;
801037a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801037a5:	eb 5f                	jmp    80103806 <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
801037a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037aa:	83 c0 14             	add    $0x14,%eax
801037ad:	0f b6 00             	movzbl (%eax),%eax
801037b0:	0f b6 c0             	movzbl %al,%eax
801037b3:	89 c2                	mov    %eax,%edx
801037b5:	c1 e2 08             	shl    $0x8,%edx
801037b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037bb:	83 c0 13             	add    $0x13,%eax
801037be:	0f b6 00             	movzbl (%eax),%eax
801037c1:	0f b6 c0             	movzbl %al,%eax
801037c4:	09 d0                	or     %edx,%eax
801037c6:	c1 e0 0a             	shl    $0xa,%eax
801037c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
801037cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801037cf:	2d 00 04 00 00       	sub    $0x400,%eax
801037d4:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
801037db:	00 
801037dc:	89 04 24             	mov    %eax,(%esp)
801037df:	e8 f7 fe ff ff       	call   801036db <mpsearch1>
801037e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801037e7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801037eb:	74 05                	je     801037f2 <mpsearch+0xa4>
      return mp;
801037ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
801037f0:	eb 14                	jmp    80103806 <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
801037f2:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801037f9:	00 
801037fa:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103801:	e8 d5 fe ff ff       	call   801036db <mpsearch1>
}
80103806:	c9                   	leave  
80103807:	c3                   	ret    

80103808 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103808:	55                   	push   %ebp
80103809:	89 e5                	mov    %esp,%ebp
8010380b:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
8010380e:	e8 3b ff ff ff       	call   8010374e <mpsearch>
80103813:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103816:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010381a:	74 0a                	je     80103826 <mpconfig+0x1e>
8010381c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010381f:	8b 40 04             	mov    0x4(%eax),%eax
80103822:	85 c0                	test   %eax,%eax
80103824:	75 0a                	jne    80103830 <mpconfig+0x28>
    return 0;
80103826:	b8 00 00 00 00       	mov    $0x0,%eax
8010382b:	e9 83 00 00 00       	jmp    801038b3 <mpconfig+0xab>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103830:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103833:	8b 40 04             	mov    0x4(%eax),%eax
80103836:	89 04 24             	mov    %eax,(%esp)
80103839:	e8 f2 fd ff ff       	call   80103630 <p2v>
8010383e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103841:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103848:	00 
80103849:	c7 44 24 04 55 84 10 	movl   $0x80108455,0x4(%esp)
80103850:	80 
80103851:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103854:	89 04 24             	mov    %eax,(%esp)
80103857:	e8 15 16 00 00       	call   80104e71 <memcmp>
8010385c:	85 c0                	test   %eax,%eax
8010385e:	74 07                	je     80103867 <mpconfig+0x5f>
    return 0;
80103860:	b8 00 00 00 00       	mov    $0x0,%eax
80103865:	eb 4c                	jmp    801038b3 <mpconfig+0xab>
  if(conf->version != 1 && conf->version != 4)
80103867:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010386a:	0f b6 40 06          	movzbl 0x6(%eax),%eax
8010386e:	3c 01                	cmp    $0x1,%al
80103870:	74 12                	je     80103884 <mpconfig+0x7c>
80103872:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103875:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103879:	3c 04                	cmp    $0x4,%al
8010387b:	74 07                	je     80103884 <mpconfig+0x7c>
    return 0;
8010387d:	b8 00 00 00 00       	mov    $0x0,%eax
80103882:	eb 2f                	jmp    801038b3 <mpconfig+0xab>
  if(sum((uchar*)conf, conf->length) != 0)
80103884:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103887:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010388b:	0f b7 d0             	movzwl %ax,%edx
8010388e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103891:	89 54 24 04          	mov    %edx,0x4(%esp)
80103895:	89 04 24             	mov    %eax,(%esp)
80103898:	e8 08 fe ff ff       	call   801036a5 <sum>
8010389d:	84 c0                	test   %al,%al
8010389f:	74 07                	je     801038a8 <mpconfig+0xa0>
    return 0;
801038a1:	b8 00 00 00 00       	mov    $0x0,%eax
801038a6:	eb 0b                	jmp    801038b3 <mpconfig+0xab>
  *pmp = mp;
801038a8:	8b 45 08             	mov    0x8(%ebp),%eax
801038ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
801038ae:	89 10                	mov    %edx,(%eax)
  return conf;
801038b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801038b3:	c9                   	leave  
801038b4:	c3                   	ret    

801038b5 <mpinit>:

void
mpinit(void)
{
801038b5:	55                   	push   %ebp
801038b6:	89 e5                	mov    %esp,%ebp
801038b8:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
801038bb:	c7 05 44 b6 10 80 20 	movl   $0x8010f920,0x8010b644
801038c2:	f9 10 80 
  if((conf = mpconfig(&mp)) == 0)
801038c5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801038c8:	89 04 24             	mov    %eax,(%esp)
801038cb:	e8 38 ff ff ff       	call   80103808 <mpconfig>
801038d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
801038d3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801038d7:	0f 84 9f 01 00 00    	je     80103a7c <mpinit+0x1c7>
    return;
  ismp = 1;
801038dd:	c7 05 04 f9 10 80 01 	movl   $0x1,0x8010f904
801038e4:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
801038e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038ea:	8b 40 24             	mov    0x24(%eax),%eax
801038ed:	a3 7c f8 10 80       	mov    %eax,0x8010f87c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801038f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038f5:	83 c0 2c             	add    $0x2c,%eax
801038f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801038fb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801038fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103901:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103905:	0f b7 c0             	movzwl %ax,%eax
80103908:	8d 04 02             	lea    (%edx,%eax,1),%eax
8010390b:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010390e:	e9 f4 00 00 00       	jmp    80103a07 <mpinit+0x152>
    switch(*p){
80103913:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103916:	0f b6 00             	movzbl (%eax),%eax
80103919:	0f b6 c0             	movzbl %al,%eax
8010391c:	83 f8 04             	cmp    $0x4,%eax
8010391f:	0f 87 bf 00 00 00    	ja     801039e4 <mpinit+0x12f>
80103925:	8b 04 85 98 84 10 80 	mov    -0x7fef7b68(,%eax,4),%eax
8010392c:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
8010392e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103931:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103934:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103937:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010393b:	0f b6 d0             	movzbl %al,%edx
8010393e:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
80103943:	39 c2                	cmp    %eax,%edx
80103945:	74 2d                	je     80103974 <mpinit+0xbf>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103947:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010394a:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010394e:	0f b6 d0             	movzbl %al,%edx
80103951:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
80103956:	89 54 24 08          	mov    %edx,0x8(%esp)
8010395a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010395e:	c7 04 24 5a 84 10 80 	movl   $0x8010845a,(%esp)
80103965:	e8 3b ca ff ff       	call   801003a5 <cprintf>
        ismp = 0;
8010396a:	c7 05 04 f9 10 80 00 	movl   $0x0,0x8010f904
80103971:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103974:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103977:	0f b6 40 03          	movzbl 0x3(%eax),%eax
8010397b:	0f b6 c0             	movzbl %al,%eax
8010397e:	83 e0 02             	and    $0x2,%eax
80103981:	85 c0                	test   %eax,%eax
80103983:	74 15                	je     8010399a <mpinit+0xe5>
        bcpu = &cpus[ncpu];
80103985:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
8010398a:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103990:	05 20 f9 10 80       	add    $0x8010f920,%eax
80103995:	a3 44 b6 10 80       	mov    %eax,0x8010b644
      cpus[ncpu].id = ncpu;
8010399a:	8b 15 00 ff 10 80    	mov    0x8010ff00,%edx
801039a0:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
801039a5:	69 d2 bc 00 00 00    	imul   $0xbc,%edx,%edx
801039ab:	81 c2 20 f9 10 80    	add    $0x8010f920,%edx
801039b1:	88 02                	mov    %al,(%edx)
      ncpu++;
801039b3:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
801039b8:	83 c0 01             	add    $0x1,%eax
801039bb:	a3 00 ff 10 80       	mov    %eax,0x8010ff00
      p += sizeof(struct mpproc);
801039c0:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
801039c4:	eb 41                	jmp    80103a07 <mpinit+0x152>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
801039c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
801039cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801039cf:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801039d3:	a2 00 f9 10 80       	mov    %al,0x8010f900
      p += sizeof(struct mpioapic);
801039d8:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
801039dc:	eb 29                	jmp    80103a07 <mpinit+0x152>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
801039de:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
801039e2:	eb 23                	jmp    80103a07 <mpinit+0x152>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
801039e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039e7:	0f b6 00             	movzbl (%eax),%eax
801039ea:	0f b6 c0             	movzbl %al,%eax
801039ed:	89 44 24 04          	mov    %eax,0x4(%esp)
801039f1:	c7 04 24 78 84 10 80 	movl   $0x80108478,(%esp)
801039f8:	e8 a8 c9 ff ff       	call   801003a5 <cprintf>
      ismp = 0;
801039fd:	c7 05 04 f9 10 80 00 	movl   $0x0,0x8010f904
80103a04:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103a07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a0a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103a0d:	0f 82 00 ff ff ff    	jb     80103913 <mpinit+0x5e>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103a13:	a1 04 f9 10 80       	mov    0x8010f904,%eax
80103a18:	85 c0                	test   %eax,%eax
80103a1a:	75 1d                	jne    80103a39 <mpinit+0x184>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103a1c:	c7 05 00 ff 10 80 01 	movl   $0x1,0x8010ff00
80103a23:	00 00 00 
    lapic = 0;
80103a26:	c7 05 7c f8 10 80 00 	movl   $0x0,0x8010f87c
80103a2d:	00 00 00 
    ioapicid = 0;
80103a30:	c6 05 00 f9 10 80 00 	movb   $0x0,0x8010f900
    return;
80103a37:	eb 44                	jmp    80103a7d <mpinit+0x1c8>
  }

  if(mp->imcrp){
80103a39:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103a3c:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103a40:	84 c0                	test   %al,%al
80103a42:	74 39                	je     80103a7d <mpinit+0x1c8>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103a44:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103a4b:	00 
80103a4c:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103a53:	e8 0f fc ff ff       	call   80103667 <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103a58:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103a5f:	e8 d9 fb ff ff       	call   8010363d <inb>
80103a64:	83 c8 01             	or     $0x1,%eax
80103a67:	0f b6 c0             	movzbl %al,%eax
80103a6a:	89 44 24 04          	mov    %eax,0x4(%esp)
80103a6e:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103a75:	e8 ed fb ff ff       	call   80103667 <outb>
80103a7a:	eb 01                	jmp    80103a7d <mpinit+0x1c8>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80103a7c:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80103a7d:	c9                   	leave  
80103a7e:	c3                   	ret    
	...

80103a80 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103a80:	55                   	push   %ebp
80103a81:	89 e5                	mov    %esp,%ebp
80103a83:	83 ec 08             	sub    $0x8,%esp
80103a86:	8b 55 08             	mov    0x8(%ebp),%edx
80103a89:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a8c:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103a90:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103a93:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103a97:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103a9b:	ee                   	out    %al,(%dx)
}
80103a9c:	c9                   	leave  
80103a9d:	c3                   	ret    

80103a9e <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103a9e:	55                   	push   %ebp
80103a9f:	89 e5                	mov    %esp,%ebp
80103aa1:	83 ec 0c             	sub    $0xc,%esp
80103aa4:	8b 45 08             	mov    0x8(%ebp),%eax
80103aa7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103aab:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103aaf:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
80103ab5:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103ab9:	0f b6 c0             	movzbl %al,%eax
80103abc:	89 44 24 04          	mov    %eax,0x4(%esp)
80103ac0:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103ac7:	e8 b4 ff ff ff       	call   80103a80 <outb>
  outb(IO_PIC2+1, mask >> 8);
80103acc:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103ad0:	66 c1 e8 08          	shr    $0x8,%ax
80103ad4:	0f b6 c0             	movzbl %al,%eax
80103ad7:	89 44 24 04          	mov    %eax,0x4(%esp)
80103adb:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103ae2:	e8 99 ff ff ff       	call   80103a80 <outb>
}
80103ae7:	c9                   	leave  
80103ae8:	c3                   	ret    

80103ae9 <picenable>:

void
picenable(int irq)
{
80103ae9:	55                   	push   %ebp
80103aea:	89 e5                	mov    %esp,%ebp
80103aec:	53                   	push   %ebx
80103aed:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
80103af0:	8b 45 08             	mov    0x8(%ebp),%eax
80103af3:	ba 01 00 00 00       	mov    $0x1,%edx
80103af8:	89 d3                	mov    %edx,%ebx
80103afa:	89 c1                	mov    %eax,%ecx
80103afc:	d3 e3                	shl    %cl,%ebx
80103afe:	89 d8                	mov    %ebx,%eax
80103b00:	89 c2                	mov    %eax,%edx
80103b02:	f7 d2                	not    %edx
80103b04:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103b0b:	21 d0                	and    %edx,%eax
80103b0d:	0f b7 c0             	movzwl %ax,%eax
80103b10:	89 04 24             	mov    %eax,(%esp)
80103b13:	e8 86 ff ff ff       	call   80103a9e <picsetmask>
}
80103b18:	83 c4 04             	add    $0x4,%esp
80103b1b:	5b                   	pop    %ebx
80103b1c:	5d                   	pop    %ebp
80103b1d:	c3                   	ret    

80103b1e <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103b1e:	55                   	push   %ebp
80103b1f:	89 e5                	mov    %esp,%ebp
80103b21:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103b24:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103b2b:	00 
80103b2c:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103b33:	e8 48 ff ff ff       	call   80103a80 <outb>
  outb(IO_PIC2+1, 0xFF);
80103b38:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103b3f:	00 
80103b40:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103b47:	e8 34 ff ff ff       	call   80103a80 <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103b4c:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103b53:	00 
80103b54:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103b5b:	e8 20 ff ff ff       	call   80103a80 <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103b60:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80103b67:	00 
80103b68:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103b6f:	e8 0c ff ff ff       	call   80103a80 <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103b74:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80103b7b:	00 
80103b7c:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103b83:	e8 f8 fe ff ff       	call   80103a80 <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103b88:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103b8f:	00 
80103b90:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103b97:	e8 e4 fe ff ff       	call   80103a80 <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103b9c:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103ba3:	00 
80103ba4:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103bab:	e8 d0 fe ff ff       	call   80103a80 <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103bb0:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
80103bb7:	00 
80103bb8:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103bbf:	e8 bc fe ff ff       	call   80103a80 <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103bc4:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80103bcb:	00 
80103bcc:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103bd3:	e8 a8 fe ff ff       	call   80103a80 <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103bd8:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103bdf:	00 
80103be0:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103be7:	e8 94 fe ff ff       	call   80103a80 <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103bec:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103bf3:	00 
80103bf4:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103bfb:	e8 80 fe ff ff       	call   80103a80 <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103c00:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103c07:	00 
80103c08:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103c0f:	e8 6c fe ff ff       	call   80103a80 <outb>

  outb(IO_PIC2, 0x68);             // OCW3
80103c14:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103c1b:	00 
80103c1c:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103c23:	e8 58 fe ff ff       	call   80103a80 <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
80103c28:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103c2f:	00 
80103c30:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103c37:	e8 44 fe ff ff       	call   80103a80 <outb>

  if(irqmask != 0xFFFF)
80103c3c:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103c43:	66 83 f8 ff          	cmp    $0xffffffff,%ax
80103c47:	74 12                	je     80103c5b <picinit+0x13d>
    picsetmask(irqmask);
80103c49:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103c50:	0f b7 c0             	movzwl %ax,%eax
80103c53:	89 04 24             	mov    %eax,(%esp)
80103c56:	e8 43 fe ff ff       	call   80103a9e <picsetmask>
}
80103c5b:	c9                   	leave  
80103c5c:	c3                   	ret    
80103c5d:	00 00                	add    %al,(%eax)
	...

80103c60 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103c60:	55                   	push   %ebp
80103c61:	89 e5                	mov    %esp,%ebp
80103c63:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103c66:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103c6d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c70:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103c76:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c79:	8b 10                	mov    (%eax),%edx
80103c7b:	8b 45 08             	mov    0x8(%ebp),%eax
80103c7e:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103c80:	e8 ab d2 ff ff       	call   80100f30 <filealloc>
80103c85:	8b 55 08             	mov    0x8(%ebp),%edx
80103c88:	89 02                	mov    %eax,(%edx)
80103c8a:	8b 45 08             	mov    0x8(%ebp),%eax
80103c8d:	8b 00                	mov    (%eax),%eax
80103c8f:	85 c0                	test   %eax,%eax
80103c91:	0f 84 c8 00 00 00    	je     80103d5f <pipealloc+0xff>
80103c97:	e8 94 d2 ff ff       	call   80100f30 <filealloc>
80103c9c:	8b 55 0c             	mov    0xc(%ebp),%edx
80103c9f:	89 02                	mov    %eax,(%edx)
80103ca1:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ca4:	8b 00                	mov    (%eax),%eax
80103ca6:	85 c0                	test   %eax,%eax
80103ca8:	0f 84 b1 00 00 00    	je     80103d5f <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103cae:	e8 6f ee ff ff       	call   80102b22 <kalloc>
80103cb3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103cb6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103cba:	0f 84 9e 00 00 00    	je     80103d5e <pipealloc+0xfe>
    goto bad;
  p->readopen = 1;
80103cc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cc3:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103cca:	00 00 00 
  p->writeopen = 1;
80103ccd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cd0:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103cd7:	00 00 00 
  p->nwrite = 0;
80103cda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cdd:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103ce4:	00 00 00 
  p->nread = 0;
80103ce7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cea:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103cf1:	00 00 00 
  initlock(&p->lock, "pipe");
80103cf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cf7:	c7 44 24 04 ac 84 10 	movl   $0x801084ac,0x4(%esp)
80103cfe:	80 
80103cff:	89 04 24             	mov    %eax,(%esp)
80103d02:	e8 83 0e 00 00       	call   80104b8a <initlock>
  (*f0)->type = FD_PIPE;
80103d07:	8b 45 08             	mov    0x8(%ebp),%eax
80103d0a:	8b 00                	mov    (%eax),%eax
80103d0c:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103d12:	8b 45 08             	mov    0x8(%ebp),%eax
80103d15:	8b 00                	mov    (%eax),%eax
80103d17:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103d1b:	8b 45 08             	mov    0x8(%ebp),%eax
80103d1e:	8b 00                	mov    (%eax),%eax
80103d20:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103d24:	8b 45 08             	mov    0x8(%ebp),%eax
80103d27:	8b 00                	mov    (%eax),%eax
80103d29:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d2c:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103d2f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d32:	8b 00                	mov    (%eax),%eax
80103d34:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103d3a:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d3d:	8b 00                	mov    (%eax),%eax
80103d3f:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103d43:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d46:	8b 00                	mov    (%eax),%eax
80103d48:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103d4c:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d4f:	8b 00                	mov    (%eax),%eax
80103d51:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d54:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103d57:	b8 00 00 00 00       	mov    $0x0,%eax
80103d5c:	eb 43                	jmp    80103da1 <pipealloc+0x141>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
80103d5e:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
80103d5f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d63:	74 0b                	je     80103d70 <pipealloc+0x110>
    kfree((char*)p);
80103d65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d68:	89 04 24             	mov    %eax,(%esp)
80103d6b:	e8 19 ed ff ff       	call   80102a89 <kfree>
  if(*f0)
80103d70:	8b 45 08             	mov    0x8(%ebp),%eax
80103d73:	8b 00                	mov    (%eax),%eax
80103d75:	85 c0                	test   %eax,%eax
80103d77:	74 0d                	je     80103d86 <pipealloc+0x126>
    fileclose(*f0);
80103d79:	8b 45 08             	mov    0x8(%ebp),%eax
80103d7c:	8b 00                	mov    (%eax),%eax
80103d7e:	89 04 24             	mov    %eax,(%esp)
80103d81:	e8 53 d2 ff ff       	call   80100fd9 <fileclose>
  if(*f1)
80103d86:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d89:	8b 00                	mov    (%eax),%eax
80103d8b:	85 c0                	test   %eax,%eax
80103d8d:	74 0d                	je     80103d9c <pipealloc+0x13c>
    fileclose(*f1);
80103d8f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d92:	8b 00                	mov    (%eax),%eax
80103d94:	89 04 24             	mov    %eax,(%esp)
80103d97:	e8 3d d2 ff ff       	call   80100fd9 <fileclose>
  return -1;
80103d9c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103da1:	c9                   	leave  
80103da2:	c3                   	ret    

80103da3 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103da3:	55                   	push   %ebp
80103da4:	89 e5                	mov    %esp,%ebp
80103da6:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80103da9:	8b 45 08             	mov    0x8(%ebp),%eax
80103dac:	89 04 24             	mov    %eax,(%esp)
80103daf:	e8 f7 0d 00 00       	call   80104bab <acquire>
  if(writable){
80103db4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103db8:	74 1f                	je     80103dd9 <pipeclose+0x36>
    p->writeopen = 0;
80103dba:	8b 45 08             	mov    0x8(%ebp),%eax
80103dbd:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103dc4:	00 00 00 
    wakeup(&p->nread);
80103dc7:	8b 45 08             	mov    0x8(%ebp),%eax
80103dca:	05 34 02 00 00       	add    $0x234,%eax
80103dcf:	89 04 24             	mov    %eax,(%esp)
80103dd2:	e8 be 0b 00 00       	call   80104995 <wakeup>
80103dd7:	eb 1d                	jmp    80103df6 <pipeclose+0x53>
  } else {
    p->readopen = 0;
80103dd9:	8b 45 08             	mov    0x8(%ebp),%eax
80103ddc:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103de3:	00 00 00 
    wakeup(&p->nwrite);
80103de6:	8b 45 08             	mov    0x8(%ebp),%eax
80103de9:	05 38 02 00 00       	add    $0x238,%eax
80103dee:	89 04 24             	mov    %eax,(%esp)
80103df1:	e8 9f 0b 00 00       	call   80104995 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103df6:	8b 45 08             	mov    0x8(%ebp),%eax
80103df9:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103dff:	85 c0                	test   %eax,%eax
80103e01:	75 25                	jne    80103e28 <pipeclose+0x85>
80103e03:	8b 45 08             	mov    0x8(%ebp),%eax
80103e06:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103e0c:	85 c0                	test   %eax,%eax
80103e0e:	75 18                	jne    80103e28 <pipeclose+0x85>
    release(&p->lock);
80103e10:	8b 45 08             	mov    0x8(%ebp),%eax
80103e13:	89 04 24             	mov    %eax,(%esp)
80103e16:	e8 f2 0d 00 00       	call   80104c0d <release>
    kfree((char*)p);
80103e1b:	8b 45 08             	mov    0x8(%ebp),%eax
80103e1e:	89 04 24             	mov    %eax,(%esp)
80103e21:	e8 63 ec ff ff       	call   80102a89 <kfree>
80103e26:	eb 0b                	jmp    80103e33 <pipeclose+0x90>
  } else
    release(&p->lock);
80103e28:	8b 45 08             	mov    0x8(%ebp),%eax
80103e2b:	89 04 24             	mov    %eax,(%esp)
80103e2e:	e8 da 0d 00 00       	call   80104c0d <release>
}
80103e33:	c9                   	leave  
80103e34:	c3                   	ret    

80103e35 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103e35:	55                   	push   %ebp
80103e36:	89 e5                	mov    %esp,%ebp
80103e38:	53                   	push   %ebx
80103e39:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80103e3c:	8b 45 08             	mov    0x8(%ebp),%eax
80103e3f:	89 04 24             	mov    %eax,(%esp)
80103e42:	e8 64 0d 00 00       	call   80104bab <acquire>
  for(i = 0; i < n; i++){
80103e47:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103e4e:	e9 a6 00 00 00       	jmp    80103ef9 <pipewrite+0xc4>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
80103e53:	8b 45 08             	mov    0x8(%ebp),%eax
80103e56:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103e5c:	85 c0                	test   %eax,%eax
80103e5e:	74 0d                	je     80103e6d <pipewrite+0x38>
80103e60:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103e66:	8b 40 24             	mov    0x24(%eax),%eax
80103e69:	85 c0                	test   %eax,%eax
80103e6b:	74 15                	je     80103e82 <pipewrite+0x4d>
        release(&p->lock);
80103e6d:	8b 45 08             	mov    0x8(%ebp),%eax
80103e70:	89 04 24             	mov    %eax,(%esp)
80103e73:	e8 95 0d 00 00       	call   80104c0d <release>
        return -1;
80103e78:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e7d:	e9 9d 00 00 00       	jmp    80103f1f <pipewrite+0xea>
      }
      wakeup(&p->nread);
80103e82:	8b 45 08             	mov    0x8(%ebp),%eax
80103e85:	05 34 02 00 00       	add    $0x234,%eax
80103e8a:	89 04 24             	mov    %eax,(%esp)
80103e8d:	e8 03 0b 00 00       	call   80104995 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103e92:	8b 45 08             	mov    0x8(%ebp),%eax
80103e95:	8b 55 08             	mov    0x8(%ebp),%edx
80103e98:	81 c2 38 02 00 00    	add    $0x238,%edx
80103e9e:	89 44 24 04          	mov    %eax,0x4(%esp)
80103ea2:	89 14 24             	mov    %edx,(%esp)
80103ea5:	e8 05 0a 00 00       	call   801048af <sleep>
80103eaa:	eb 01                	jmp    80103ead <pipewrite+0x78>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103eac:	90                   	nop
80103ead:	8b 45 08             	mov    0x8(%ebp),%eax
80103eb0:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80103eb6:	8b 45 08             	mov    0x8(%ebp),%eax
80103eb9:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103ebf:	05 00 02 00 00       	add    $0x200,%eax
80103ec4:	39 c2                	cmp    %eax,%edx
80103ec6:	74 8b                	je     80103e53 <pipewrite+0x1e>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103ec8:	8b 45 08             	mov    0x8(%ebp),%eax
80103ecb:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103ed1:	89 c3                	mov    %eax,%ebx
80103ed3:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
80103ed9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103edc:	03 55 0c             	add    0xc(%ebp),%edx
80103edf:	0f b6 0a             	movzbl (%edx),%ecx
80103ee2:	8b 55 08             	mov    0x8(%ebp),%edx
80103ee5:	88 4c 1a 34          	mov    %cl,0x34(%edx,%ebx,1)
80103ee9:	8d 50 01             	lea    0x1(%eax),%edx
80103eec:	8b 45 08             	mov    0x8(%ebp),%eax
80103eef:	89 90 38 02 00 00    	mov    %edx,0x238(%eax)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80103ef5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103ef9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103efc:	3b 45 10             	cmp    0x10(%ebp),%eax
80103eff:	7c ab                	jl     80103eac <pipewrite+0x77>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103f01:	8b 45 08             	mov    0x8(%ebp),%eax
80103f04:	05 34 02 00 00       	add    $0x234,%eax
80103f09:	89 04 24             	mov    %eax,(%esp)
80103f0c:	e8 84 0a 00 00       	call   80104995 <wakeup>
  release(&p->lock);
80103f11:	8b 45 08             	mov    0x8(%ebp),%eax
80103f14:	89 04 24             	mov    %eax,(%esp)
80103f17:	e8 f1 0c 00 00       	call   80104c0d <release>
  return n;
80103f1c:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103f1f:	83 c4 24             	add    $0x24,%esp
80103f22:	5b                   	pop    %ebx
80103f23:	5d                   	pop    %ebp
80103f24:	c3                   	ret    

80103f25 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103f25:	55                   	push   %ebp
80103f26:	89 e5                	mov    %esp,%ebp
80103f28:	53                   	push   %ebx
80103f29:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80103f2c:	8b 45 08             	mov    0x8(%ebp),%eax
80103f2f:	89 04 24             	mov    %eax,(%esp)
80103f32:	e8 74 0c 00 00       	call   80104bab <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103f37:	eb 3a                	jmp    80103f73 <piperead+0x4e>
    if(proc->killed){
80103f39:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103f3f:	8b 40 24             	mov    0x24(%eax),%eax
80103f42:	85 c0                	test   %eax,%eax
80103f44:	74 15                	je     80103f5b <piperead+0x36>
      release(&p->lock);
80103f46:	8b 45 08             	mov    0x8(%ebp),%eax
80103f49:	89 04 24             	mov    %eax,(%esp)
80103f4c:	e8 bc 0c 00 00       	call   80104c0d <release>
      return -1;
80103f51:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f56:	e9 b6 00 00 00       	jmp    80104011 <piperead+0xec>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103f5b:	8b 45 08             	mov    0x8(%ebp),%eax
80103f5e:	8b 55 08             	mov    0x8(%ebp),%edx
80103f61:	81 c2 34 02 00 00    	add    $0x234,%edx
80103f67:	89 44 24 04          	mov    %eax,0x4(%esp)
80103f6b:	89 14 24             	mov    %edx,(%esp)
80103f6e:	e8 3c 09 00 00       	call   801048af <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103f73:	8b 45 08             	mov    0x8(%ebp),%eax
80103f76:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103f7c:	8b 45 08             	mov    0x8(%ebp),%eax
80103f7f:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103f85:	39 c2                	cmp    %eax,%edx
80103f87:	75 0d                	jne    80103f96 <piperead+0x71>
80103f89:	8b 45 08             	mov    0x8(%ebp),%eax
80103f8c:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103f92:	85 c0                	test   %eax,%eax
80103f94:	75 a3                	jne    80103f39 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103f96:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103f9d:	eb 49                	jmp    80103fe8 <piperead+0xc3>
    if(p->nread == p->nwrite)
80103f9f:	8b 45 08             	mov    0x8(%ebp),%eax
80103fa2:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103fa8:	8b 45 08             	mov    0x8(%ebp),%eax
80103fab:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103fb1:	39 c2                	cmp    %eax,%edx
80103fb3:	74 3d                	je     80103ff2 <piperead+0xcd>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103fb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fb8:	89 c2                	mov    %eax,%edx
80103fba:	03 55 0c             	add    0xc(%ebp),%edx
80103fbd:	8b 45 08             	mov    0x8(%ebp),%eax
80103fc0:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103fc6:	89 c3                	mov    %eax,%ebx
80103fc8:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
80103fce:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103fd1:	0f b6 4c 19 34       	movzbl 0x34(%ecx,%ebx,1),%ecx
80103fd6:	88 0a                	mov    %cl,(%edx)
80103fd8:	8d 50 01             	lea    0x1(%eax),%edx
80103fdb:	8b 45 08             	mov    0x8(%ebp),%eax
80103fde:	89 90 34 02 00 00    	mov    %edx,0x234(%eax)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103fe4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103fe8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103feb:	3b 45 10             	cmp    0x10(%ebp),%eax
80103fee:	7c af                	jl     80103f9f <piperead+0x7a>
80103ff0:	eb 01                	jmp    80103ff3 <piperead+0xce>
    if(p->nread == p->nwrite)
      break;
80103ff2:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103ff3:	8b 45 08             	mov    0x8(%ebp),%eax
80103ff6:	05 38 02 00 00       	add    $0x238,%eax
80103ffb:	89 04 24             	mov    %eax,(%esp)
80103ffe:	e8 92 09 00 00       	call   80104995 <wakeup>
  release(&p->lock);
80104003:	8b 45 08             	mov    0x8(%ebp),%eax
80104006:	89 04 24             	mov    %eax,(%esp)
80104009:	e8 ff 0b 00 00       	call   80104c0d <release>
  return i;
8010400e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104011:	83 c4 24             	add    $0x24,%esp
80104014:	5b                   	pop    %ebx
80104015:	5d                   	pop    %ebp
80104016:	c3                   	ret    
	...

80104018 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104018:	55                   	push   %ebp
80104019:	89 e5                	mov    %esp,%ebp
8010401b:	53                   	push   %ebx
8010401c:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010401f:	9c                   	pushf  
80104020:	5b                   	pop    %ebx
80104021:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80104024:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104027:	83 c4 10             	add    $0x10,%esp
8010402a:	5b                   	pop    %ebx
8010402b:	5d                   	pop    %ebp
8010402c:	c3                   	ret    

8010402d <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
8010402d:	55                   	push   %ebp
8010402e:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104030:	fb                   	sti    
}
80104031:	5d                   	pop    %ebp
80104032:	c3                   	ret    

80104033 <make_runnable>:
static void wakeup1(void *chan);


static void 
make_runnable(struct proc *p,int level)
{
80104033:	55                   	push   %ebp
80104034:	89 e5                	mov    %esp,%ebp
  if (level==0)
80104036:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010403a:	75 08                	jne    80104044 <make_runnable+0x11>
  {
    ptable.mlf[0].first = p;  
8010403c:	8b 45 08             	mov    0x8(%ebp),%eax
8010403f:	a3 54 21 11 80       	mov    %eax,0x80112154
  }
  p->state= RUNNABLE;
80104044:	8b 45 08             	mov    0x8(%ebp),%eax
80104047:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
8010404e:	5d                   	pop    %ebp
8010404f:	c3                   	ret    

80104050 <make_running>:

static void 
make_running(struct proc *p)
{
80104050:	55                   	push   %ebp
80104051:	89 e5                	mov    %esp,%ebp
  //desencolamos el proceso
  p->state= RUNNING;
80104053:	8b 45 08             	mov    0x8(%ebp),%eax
80104056:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
}
8010405d:	5d                   	pop    %ebp
8010405e:	c3                   	ret    

8010405f <pinit>:


void
pinit(void)
{
8010405f:	55                   	push   %ebp
80104060:	89 e5                	mov    %esp,%ebp
80104062:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80104065:	c7 44 24 04 b1 84 10 	movl   $0x801084b1,0x4(%esp)
8010406c:	80 
8010406d:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
80104074:	e8 11 0b 00 00       	call   80104b8a <initlock>
}
80104079:	c9                   	leave  
8010407a:	c3                   	ret    

8010407b <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
8010407b:	55                   	push   %ebp
8010407c:	89 e5                	mov    %esp,%ebp
8010407e:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104081:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
80104088:	e8 1e 0b 00 00       	call   80104bab <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010408d:	c7 45 f4 54 ff 10 80 	movl   $0x8010ff54,-0xc(%ebp)
80104094:	eb 11                	jmp    801040a7 <allocproc+0x2c>
    if(p->state == UNUSED)
80104096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104099:	8b 40 0c             	mov    0xc(%eax),%eax
8010409c:	85 c0                	test   %eax,%eax
8010409e:	74 27                	je     801040c7 <allocproc+0x4c>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801040a0:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
801040a7:	b8 54 21 11 80       	mov    $0x80112154,%eax
801040ac:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801040af:	72 e5                	jb     80104096 <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
801040b1:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
801040b8:	e8 50 0b 00 00       	call   80104c0d <release>
  return 0;
801040bd:	b8 00 00 00 00       	mov    $0x0,%eax
801040c2:	e9 b5 00 00 00       	jmp    8010417c <allocproc+0x101>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
801040c7:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
801040c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040cb:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801040d2:	a1 04 b0 10 80       	mov    0x8010b004,%eax
801040d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040da:	89 42 10             	mov    %eax,0x10(%edx)
801040dd:	83 c0 01             	add    $0x1,%eax
801040e0:	a3 04 b0 10 80       	mov    %eax,0x8010b004
  release(&ptable.lock);
801040e5:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
801040ec:	e8 1c 0b 00 00       	call   80104c0d <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801040f1:	e8 2c ea ff ff       	call   80102b22 <kalloc>
801040f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040f9:	89 42 08             	mov    %eax,0x8(%edx)
801040fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040ff:	8b 40 08             	mov    0x8(%eax),%eax
80104102:	85 c0                	test   %eax,%eax
80104104:	75 11                	jne    80104117 <allocproc+0x9c>
    p->state = UNUSED;
80104106:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104109:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104110:	b8 00 00 00 00       	mov    $0x0,%eax
80104115:	eb 65                	jmp    8010417c <allocproc+0x101>
  }
  sp = p->kstack + KSTACKSIZE;
80104117:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010411a:	8b 40 08             	mov    0x8(%eax),%eax
8010411d:	05 00 10 00 00       	add    $0x1000,%eax
80104122:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104125:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104129:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010412c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010412f:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104132:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104136:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104139:	ba 48 62 10 80       	mov    $0x80106248,%edx
8010413e:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104140:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104144:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104147:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010414a:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
8010414d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104150:	8b 40 1c             	mov    0x1c(%eax),%eax
80104153:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
8010415a:	00 
8010415b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104162:	00 
80104163:	89 04 24             	mov    %eax,(%esp)
80104166:	e8 8f 0c 00 00       	call   80104dfa <memset>
  p->context->eip = (uint)forkret;
8010416b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010416e:	8b 40 1c             	mov    0x1c(%eax),%eax
80104171:	ba 83 48 10 80       	mov    $0x80104883,%edx
80104176:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80104179:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010417c:	c9                   	leave  
8010417d:	c3                   	ret    

8010417e <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
8010417e:	55                   	push   %ebp
8010417f:	89 e5                	mov    %esp,%ebp
80104181:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
80104184:	e8 f2 fe ff ff       	call   8010407b <allocproc>
80104189:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
8010418c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010418f:	a3 48 b6 10 80       	mov    %eax,0x8010b648
  if((p->pgdir = setupkvm(kalloc)) == 0)
80104194:	c7 04 24 22 2b 10 80 	movl   $0x80102b22,(%esp)
8010419b:	e8 f2 37 00 00       	call   80107992 <setupkvm>
801041a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041a3:	89 42 04             	mov    %eax,0x4(%edx)
801041a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041a9:	8b 40 04             	mov    0x4(%eax),%eax
801041ac:	85 c0                	test   %eax,%eax
801041ae:	75 0c                	jne    801041bc <userinit+0x3e>
    panic("userinit: out of memory?");
801041b0:	c7 04 24 b8 84 10 80 	movl   $0x801084b8,(%esp)
801041b7:	e8 8a c3 ff ff       	call   80100546 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801041bc:	ba 2c 00 00 00       	mov    $0x2c,%edx
801041c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041c4:	8b 40 04             	mov    0x4(%eax),%eax
801041c7:	89 54 24 08          	mov    %edx,0x8(%esp)
801041cb:	c7 44 24 04 e0 b4 10 	movl   $0x8010b4e0,0x4(%esp)
801041d2:	80 
801041d3:	89 04 24             	mov    %eax,(%esp)
801041d6:	e8 10 3a 00 00       	call   80107beb <inituvm>
  p->sz = PGSIZE;
801041db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041de:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801041e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041e7:	8b 40 18             	mov    0x18(%eax),%eax
801041ea:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
801041f1:	00 
801041f2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801041f9:	00 
801041fa:	89 04 24             	mov    %eax,(%esp)
801041fd:	e8 f8 0b 00 00       	call   80104dfa <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104202:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104205:	8b 40 18             	mov    0x18(%eax),%eax
80104208:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
8010420e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104211:	8b 40 18             	mov    0x18(%eax),%eax
80104214:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010421a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010421d:	8b 40 18             	mov    0x18(%eax),%eax
80104220:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104223:	8b 52 18             	mov    0x18(%edx),%edx
80104226:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010422a:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
8010422e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104231:	8b 40 18             	mov    0x18(%eax),%eax
80104234:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104237:	8b 52 18             	mov    0x18(%edx),%edx
8010423a:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010423e:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104242:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104245:	8b 40 18             	mov    0x18(%eax),%eax
80104248:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010424f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104252:	8b 40 18             	mov    0x18(%eax),%eax
80104255:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010425c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010425f:	8b 40 18             	mov    0x18(%eax),%eax
80104262:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104269:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010426c:	83 c0 6c             	add    $0x6c,%eax
8010426f:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104276:	00 
80104277:	c7 44 24 04 d1 84 10 	movl   $0x801084d1,0x4(%esp)
8010427e:	80 
8010427f:	89 04 24             	mov    %eax,(%esp)
80104282:	e8 a7 0d 00 00       	call   8010502e <safestrcpy>
  p->cwd = namei("/");
80104287:	c7 04 24 da 84 10 80 	movl   $0x801084da,(%esp)
8010428e:	e8 98 e1 ff ff       	call   8010242b <namei>
80104293:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104296:	89 42 68             	mov    %eax,0x68(%edx)

  make_runnable(p,0);
80104299:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801042a0:	00 
801042a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042a4:	89 04 24             	mov    %eax,(%esp)
801042a7:	e8 87 fd ff ff       	call   80104033 <make_runnable>
  //p->state = RUNNABLE;
}
801042ac:	c9                   	leave  
801042ad:	c3                   	ret    

801042ae <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801042ae:	55                   	push   %ebp
801042af:	89 e5                	mov    %esp,%ebp
801042b1:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
801042b4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801042ba:	8b 00                	mov    (%eax),%eax
801042bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801042bf:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801042c3:	7e 34                	jle    801042f9 <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801042c5:	8b 45 08             	mov    0x8(%ebp),%eax
801042c8:	89 c2                	mov    %eax,%edx
801042ca:	03 55 f4             	add    -0xc(%ebp),%edx
801042cd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801042d3:	8b 40 04             	mov    0x4(%eax),%eax
801042d6:	89 54 24 08          	mov    %edx,0x8(%esp)
801042da:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042dd:	89 54 24 04          	mov    %edx,0x4(%esp)
801042e1:	89 04 24             	mov    %eax,(%esp)
801042e4:	e8 7d 3a 00 00       	call   80107d66 <allocuvm>
801042e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801042ec:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801042f0:	75 41                	jne    80104333 <growproc+0x85>
      return -1;
801042f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042f7:	eb 58                	jmp    80104351 <growproc+0xa3>
  } else if(n < 0){
801042f9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801042fd:	79 34                	jns    80104333 <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
801042ff:	8b 45 08             	mov    0x8(%ebp),%eax
80104302:	89 c2                	mov    %eax,%edx
80104304:	03 55 f4             	add    -0xc(%ebp),%edx
80104307:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010430d:	8b 40 04             	mov    0x4(%eax),%eax
80104310:	89 54 24 08          	mov    %edx,0x8(%esp)
80104314:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104317:	89 54 24 04          	mov    %edx,0x4(%esp)
8010431b:	89 04 24             	mov    %eax,(%esp)
8010431e:	e8 1d 3b 00 00       	call   80107e40 <deallocuvm>
80104323:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104326:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010432a:	75 07                	jne    80104333 <growproc+0x85>
      return -1;
8010432c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104331:	eb 1e                	jmp    80104351 <growproc+0xa3>
  }
  proc->sz = sz;
80104333:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104339:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010433c:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
8010433e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104344:	89 04 24             	mov    %eax,(%esp)
80104347:	e8 38 37 00 00       	call   80107a84 <switchuvm>
  return 0;
8010434c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104351:	c9                   	leave  
80104352:	c3                   	ret    

80104353 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104353:	55                   	push   %ebp
80104354:	89 e5                	mov    %esp,%ebp
80104356:	57                   	push   %edi
80104357:	56                   	push   %esi
80104358:	53                   	push   %ebx
80104359:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
8010435c:	e8 1a fd ff ff       	call   8010407b <allocproc>
80104361:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104364:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104368:	75 0a                	jne    80104374 <fork+0x21>
    return -1;
8010436a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010436f:	e9 43 01 00 00       	jmp    801044b7 <fork+0x164>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104374:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010437a:	8b 10                	mov    (%eax),%edx
8010437c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104382:	8b 40 04             	mov    0x4(%eax),%eax
80104385:	89 54 24 04          	mov    %edx,0x4(%esp)
80104389:	89 04 24             	mov    %eax,(%esp)
8010438c:	e8 3f 3c 00 00       	call   80107fd0 <copyuvm>
80104391:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104394:	89 42 04             	mov    %eax,0x4(%edx)
80104397:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010439a:	8b 40 04             	mov    0x4(%eax),%eax
8010439d:	85 c0                	test   %eax,%eax
8010439f:	75 2c                	jne    801043cd <fork+0x7a>
    kfree(np->kstack);
801043a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801043a4:	8b 40 08             	mov    0x8(%eax),%eax
801043a7:	89 04 24             	mov    %eax,(%esp)
801043aa:	e8 da e6 ff ff       	call   80102a89 <kfree>
    np->kstack = 0;
801043af:	8b 45 e0             	mov    -0x20(%ebp),%eax
801043b2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801043b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801043bc:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801043c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043c8:	e9 ea 00 00 00       	jmp    801044b7 <fork+0x164>
  }
  np->sz = proc->sz;
801043cd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801043d3:	8b 10                	mov    (%eax),%edx
801043d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801043d8:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
801043da:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801043e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801043e4:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
801043e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801043ea:	8b 50 18             	mov    0x18(%eax),%edx
801043ed:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801043f3:	8b 40 18             	mov    0x18(%eax),%eax
801043f6:	89 c3                	mov    %eax,%ebx
801043f8:	b8 13 00 00 00       	mov    $0x13,%eax
801043fd:	89 d7                	mov    %edx,%edi
801043ff:	89 de                	mov    %ebx,%esi
80104401:	89 c1                	mov    %eax,%ecx
80104403:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104405:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104408:	8b 40 18             	mov    0x18(%eax),%eax
8010440b:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104412:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104419:	eb 3d                	jmp    80104458 <fork+0x105>
    if(proc->ofile[i])
8010441b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104421:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104424:	83 c2 08             	add    $0x8,%edx
80104427:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010442b:	85 c0                	test   %eax,%eax
8010442d:	74 25                	je     80104454 <fork+0x101>
      np->ofile[i] = filedup(proc->ofile[i]);
8010442f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104435:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104438:	83 c2 08             	add    $0x8,%edx
8010443b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010443f:	89 04 24             	mov    %eax,(%esp)
80104442:	e8 4a cb ff ff       	call   80100f91 <filedup>
80104447:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010444a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010444d:	83 c1 08             	add    $0x8,%ecx
80104450:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104454:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104458:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
8010445c:	7e bd                	jle    8010441b <fork+0xc8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
8010445e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104464:	8b 40 68             	mov    0x68(%eax),%eax
80104467:	89 04 24             	mov    %eax,(%esp)
8010446a:	e8 e2 d3 ff ff       	call   80101851 <idup>
8010446f:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104472:	89 42 68             	mov    %eax,0x68(%edx)
 
  pid = np->pid;
80104475:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104478:	8b 40 10             	mov    0x10(%eax),%eax
8010447b:	89 45 dc             	mov    %eax,-0x24(%ebp)
  make_runnable(np,0);
8010447e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104485:	00 
80104486:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104489:	89 04 24             	mov    %eax,(%esp)
8010448c:	e8 a2 fb ff ff       	call   80104033 <make_runnable>
  //np->state = RUNNABLE;
  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104491:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104497:	8d 50 6c             	lea    0x6c(%eax),%edx
8010449a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010449d:	83 c0 6c             	add    $0x6c,%eax
801044a0:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801044a7:	00 
801044a8:	89 54 24 04          	mov    %edx,0x4(%esp)
801044ac:	89 04 24             	mov    %eax,(%esp)
801044af:	e8 7a 0b 00 00       	call   8010502e <safestrcpy>
  return pid;
801044b4:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801044b7:	83 c4 2c             	add    $0x2c,%esp
801044ba:	5b                   	pop    %ebx
801044bb:	5e                   	pop    %esi
801044bc:	5f                   	pop    %edi
801044bd:	5d                   	pop    %ebp
801044be:	c3                   	ret    

801044bf <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801044bf:	55                   	push   %ebp
801044c0:	89 e5                	mov    %esp,%ebp
801044c2:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
801044c5:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801044cc:	a1 48 b6 10 80       	mov    0x8010b648,%eax
801044d1:	39 c2                	cmp    %eax,%edx
801044d3:	75 0c                	jne    801044e1 <exit+0x22>
    panic("init exiting");
801044d5:	c7 04 24 dc 84 10 80 	movl   $0x801084dc,(%esp)
801044dc:	e8 65 c0 ff ff       	call   80100546 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801044e1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801044e8:	eb 44                	jmp    8010452e <exit+0x6f>
    if(proc->ofile[fd]){
801044ea:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801044f0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801044f3:	83 c2 08             	add    $0x8,%edx
801044f6:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801044fa:	85 c0                	test   %eax,%eax
801044fc:	74 2c                	je     8010452a <exit+0x6b>
      fileclose(proc->ofile[fd]);
801044fe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104504:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104507:	83 c2 08             	add    $0x8,%edx
8010450a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010450e:	89 04 24             	mov    %eax,(%esp)
80104511:	e8 c3 ca ff ff       	call   80100fd9 <fileclose>
      proc->ofile[fd] = 0;
80104516:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010451c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010451f:	83 c2 08             	add    $0x8,%edx
80104522:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104529:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010452a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010452e:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104532:	7e b6                	jle    801044ea <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  iput(proc->cwd);
80104534:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010453a:	8b 40 68             	mov    0x68(%eax),%eax
8010453d:	89 04 24             	mov    %eax,(%esp)
80104540:	e8 f4 d4 ff ff       	call   80101a39 <iput>
  proc->cwd = 0;
80104545:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010454b:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104552:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
80104559:	e8 4d 06 00 00       	call   80104bab <acquire>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
8010455e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104564:	8b 40 14             	mov    0x14(%eax),%eax
80104567:	89 04 24             	mov    %eax,(%esp)
8010456a:	e8 db 03 00 00       	call   8010494a <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010456f:	c7 45 f4 54 ff 10 80 	movl   $0x8010ff54,-0xc(%ebp)
80104576:	eb 3b                	jmp    801045b3 <exit+0xf4>
    if(p->parent == proc){
80104578:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010457b:	8b 50 14             	mov    0x14(%eax),%edx
8010457e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104584:	39 c2                	cmp    %eax,%edx
80104586:	75 24                	jne    801045ac <exit+0xed>
      p->parent = initproc;
80104588:	8b 15 48 b6 10 80    	mov    0x8010b648,%edx
8010458e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104591:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104594:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104597:	8b 40 0c             	mov    0xc(%eax),%eax
8010459a:	83 f8 05             	cmp    $0x5,%eax
8010459d:	75 0d                	jne    801045ac <exit+0xed>
        wakeup1(initproc);
8010459f:	a1 48 b6 10 80       	mov    0x8010b648,%eax
801045a4:	89 04 24             	mov    %eax,(%esp)
801045a7:	e8 9e 03 00 00       	call   8010494a <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801045ac:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
801045b3:	b8 54 21 11 80       	mov    $0x80112154,%eax
801045b8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801045bb:	72 bb                	jb     80104578 <exit+0xb9>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
801045bd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045c3:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801045ca:	e8 c7 01 00 00       	call   80104796 <sched>
  panic("zombie exit");
801045cf:	c7 04 24 e9 84 10 80 	movl   $0x801084e9,(%esp)
801045d6:	e8 6b bf ff ff       	call   80100546 <panic>

801045db <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801045db:	55                   	push   %ebp
801045dc:	89 e5                	mov    %esp,%ebp
801045de:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
801045e1:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
801045e8:	e8 be 05 00 00       	call   80104bab <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
801045ed:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801045f4:	c7 45 f4 54 ff 10 80 	movl   $0x8010ff54,-0xc(%ebp)
801045fb:	e9 9d 00 00 00       	jmp    8010469d <wait+0xc2>
      if(p->parent != proc)
80104600:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104603:	8b 50 14             	mov    0x14(%eax),%edx
80104606:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010460c:	39 c2                	cmp    %eax,%edx
8010460e:	0f 85 81 00 00 00    	jne    80104695 <wait+0xba>
        continue;
      havekids = 1;
80104614:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
8010461b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010461e:	8b 40 0c             	mov    0xc(%eax),%eax
80104621:	83 f8 05             	cmp    $0x5,%eax
80104624:	75 70                	jne    80104696 <wait+0xbb>
        // Found one.
        pid = p->pid;
80104626:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104629:	8b 40 10             	mov    0x10(%eax),%eax
8010462c:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
8010462f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104632:	8b 40 08             	mov    0x8(%eax),%eax
80104635:	89 04 24             	mov    %eax,(%esp)
80104638:	e8 4c e4 ff ff       	call   80102a89 <kfree>
        p->kstack = 0;
8010463d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104640:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104647:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010464a:	8b 40 04             	mov    0x4(%eax),%eax
8010464d:	89 04 24             	mov    %eax,(%esp)
80104650:	e8 a7 38 00 00       	call   80107efc <freevm>
        p->state = UNUSED;
80104655:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104658:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
8010465f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104662:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104669:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010466c:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104673:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104676:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010467a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010467d:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104684:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
8010468b:	e8 7d 05 00 00       	call   80104c0d <release>
        return pid;
80104690:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104693:	eb 57                	jmp    801046ec <wait+0x111>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80104695:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104696:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
8010469d:	b8 54 21 11 80       	mov    $0x80112154,%eax
801046a2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801046a5:	0f 82 55 ff ff ff    	jb     80104600 <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
801046ab:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801046af:	74 0d                	je     801046be <wait+0xe3>
801046b1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046b7:	8b 40 24             	mov    0x24(%eax),%eax
801046ba:	85 c0                	test   %eax,%eax
801046bc:	74 13                	je     801046d1 <wait+0xf6>
      release(&ptable.lock);
801046be:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
801046c5:	e8 43 05 00 00       	call   80104c0d <release>
      return -1;
801046ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046cf:	eb 1b                	jmp    801046ec <wait+0x111>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
801046d1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046d7:	c7 44 24 04 20 ff 10 	movl   $0x8010ff20,0x4(%esp)
801046de:	80 
801046df:	89 04 24             	mov    %eax,(%esp)
801046e2:	e8 c8 01 00 00       	call   801048af <sleep>
  }
801046e7:	e9 01 ff ff ff       	jmp    801045ed <wait+0x12>
}
801046ec:	c9                   	leave  
801046ed:	c3                   	ret    

801046ee <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801046ee:	55                   	push   %ebp
801046ef:	89 e5                	mov    %esp,%ebp
801046f1:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
801046f4:	e8 34 f9 ff ff       	call   8010402d <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
801046f9:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
80104700:	e8 a6 04 00 00       	call   80104bab <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104705:	c7 45 f4 54 ff 10 80 	movl   $0x8010ff54,-0xc(%ebp)
8010470c:	eb 6d                	jmp    8010477b <scheduler+0x8d>
      if(p->state != RUNNABLE)
8010470e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104711:	8b 40 0c             	mov    0xc(%eax),%eax
80104714:	83 f8 03             	cmp    $0x3,%eax
80104717:	75 5a                	jne    80104773 <scheduler+0x85>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104719:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010471c:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104722:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104725:	89 04 24             	mov    %eax,(%esp)
80104728:	e8 57 33 00 00       	call   80107a84 <switchuvm>
      make_running(p);
8010472d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104730:	89 04 24             	mov    %eax,(%esp)
80104733:	e8 18 f9 ff ff       	call   80104050 <make_running>
      //p->state = RUNNING;
	  p->quantum = 0;
80104738:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010473b:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)
      swtch(&cpu->scheduler, proc->context);
80104742:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104748:	8b 40 1c             	mov    0x1c(%eax),%eax
8010474b:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104752:	83 c2 04             	add    $0x4,%edx
80104755:	89 44 24 04          	mov    %eax,0x4(%esp)
80104759:	89 14 24             	mov    %edx,(%esp)
8010475c:	e8 43 09 00 00       	call   801050a4 <swtch>
      switchkvm();
80104761:	e8 01 33 00 00       	call   80107a67 <switchkvm>
	  // cprintf("%s  JOSE \n",p->quantum);
      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104766:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
8010476d:	00 00 00 00 
80104771:	eb 01                	jmp    80104774 <scheduler+0x86>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
80104773:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104774:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
8010477b:	b8 54 21 11 80       	mov    $0x80112154,%eax
80104780:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80104783:	72 89                	jb     8010470e <scheduler+0x20>
	  // cprintf("%s  JOSE \n",p->quantum);
      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80104785:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
8010478c:	e8 7c 04 00 00       	call   80104c0d <release>

  }
80104791:	e9 5e ff ff ff       	jmp    801046f4 <scheduler+0x6>

80104796 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104796:	55                   	push   %ebp
80104797:	89 e5                	mov    %esp,%ebp
80104799:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
8010479c:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
801047a3:	e8 23 05 00 00       	call   80104ccb <holding>
801047a8:	85 c0                	test   %eax,%eax
801047aa:	75 0c                	jne    801047b8 <sched+0x22>
    panic("sched ptable.lock");
801047ac:	c7 04 24 f5 84 10 80 	movl   $0x801084f5,(%esp)
801047b3:	e8 8e bd ff ff       	call   80100546 <panic>
  if(cpu->ncli != 1)
801047b8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801047be:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801047c4:	83 f8 01             	cmp    $0x1,%eax
801047c7:	74 0c                	je     801047d5 <sched+0x3f>
    panic("sched locks");
801047c9:	c7 04 24 07 85 10 80 	movl   $0x80108507,(%esp)
801047d0:	e8 71 bd ff ff       	call   80100546 <panic>
  if(proc->state == RUNNING)
801047d5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047db:	8b 40 0c             	mov    0xc(%eax),%eax
801047de:	83 f8 04             	cmp    $0x4,%eax
801047e1:	75 0c                	jne    801047ef <sched+0x59>
    panic("sched running");
801047e3:	c7 04 24 13 85 10 80 	movl   $0x80108513,(%esp)
801047ea:	e8 57 bd ff ff       	call   80100546 <panic>
  if(readeflags()&FL_IF)
801047ef:	e8 24 f8 ff ff       	call   80104018 <readeflags>
801047f4:	25 00 02 00 00       	and    $0x200,%eax
801047f9:	85 c0                	test   %eax,%eax
801047fb:	74 0c                	je     80104809 <sched+0x73>
    panic("sched interruptible");
801047fd:	c7 04 24 21 85 10 80 	movl   $0x80108521,(%esp)
80104804:	e8 3d bd ff ff       	call   80100546 <panic>
  intena = cpu->intena;
80104809:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010480f:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104815:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104818:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010481e:	8b 40 04             	mov    0x4(%eax),%eax
80104821:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104828:	83 c2 1c             	add    $0x1c,%edx
8010482b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010482f:	89 14 24             	mov    %edx,(%esp)
80104832:	e8 6d 08 00 00       	call   801050a4 <swtch>
  cpu->intena = intena;
80104837:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010483d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104840:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104846:	c9                   	leave  
80104847:	c3                   	ret    

80104848 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104848:	55                   	push   %ebp
80104849:	89 e5                	mov    %esp,%ebp
8010484b:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
8010484e:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
80104855:	e8 51 03 00 00       	call   80104bab <acquire>
  make_runnable(proc,1);//baja de nivel en la cola
8010485a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104860:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80104867:	00 
80104868:	89 04 24             	mov    %eax,(%esp)
8010486b:	e8 c3 f7 ff ff       	call   80104033 <make_runnable>
  //proc->state = RUNNABLE;
  sched();
80104870:	e8 21 ff ff ff       	call   80104796 <sched>
  release(&ptable.lock);
80104875:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
8010487c:	e8 8c 03 00 00       	call   80104c0d <release>
}
80104881:	c9                   	leave  
80104882:	c3                   	ret    

80104883 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104883:	55                   	push   %ebp
80104884:	89 e5                	mov    %esp,%ebp
80104886:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104889:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
80104890:	e8 78 03 00 00       	call   80104c0d <release>

  if (first) {
80104895:	a1 20 b0 10 80       	mov    0x8010b020,%eax
8010489a:	85 c0                	test   %eax,%eax
8010489c:	74 0f                	je     801048ad <forkret+0x2a>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
8010489e:	c7 05 20 b0 10 80 00 	movl   $0x0,0x8010b020
801048a5:	00 00 00 
    initlog();
801048a8:	e8 87 e7 ff ff       	call   80103034 <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
801048ad:	c9                   	leave  
801048ae:	c3                   	ret    

801048af <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801048af:	55                   	push   %ebp
801048b0:	89 e5                	mov    %esp,%ebp
801048b2:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
801048b5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048bb:	85 c0                	test   %eax,%eax
801048bd:	75 0c                	jne    801048cb <sleep+0x1c>
    panic("sleep");
801048bf:	c7 04 24 35 85 10 80 	movl   $0x80108535,(%esp)
801048c6:	e8 7b bc ff ff       	call   80100546 <panic>

  if(lk == 0)
801048cb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801048cf:	75 0c                	jne    801048dd <sleep+0x2e>
    panic("sleep without lk");
801048d1:	c7 04 24 3b 85 10 80 	movl   $0x8010853b,(%esp)
801048d8:	e8 69 bc ff ff       	call   80100546 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801048dd:	81 7d 0c 20 ff 10 80 	cmpl   $0x8010ff20,0xc(%ebp)
801048e4:	74 17                	je     801048fd <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
801048e6:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
801048ed:	e8 b9 02 00 00       	call   80104bab <acquire>
    release(lk);
801048f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801048f5:	89 04 24             	mov    %eax,(%esp)
801048f8:	e8 10 03 00 00       	call   80104c0d <release>
  }

  // Go to sleep.
  proc->chan = chan;
801048fd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104903:	8b 55 08             	mov    0x8(%ebp),%edx
80104906:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104909:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010490f:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104916:	e8 7b fe ff ff       	call   80104796 <sched>

  // Tidy up.
  proc->chan = 0;
8010491b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104921:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104928:	81 7d 0c 20 ff 10 80 	cmpl   $0x8010ff20,0xc(%ebp)
8010492f:	74 17                	je     80104948 <sleep+0x99>
    release(&ptable.lock);
80104931:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
80104938:	e8 d0 02 00 00       	call   80104c0d <release>
    acquire(lk);
8010493d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104940:	89 04 24             	mov    %eax,(%esp)
80104943:	e8 63 02 00 00       	call   80104bab <acquire>
  }
}
80104948:	c9                   	leave  
80104949:	c3                   	ret    

8010494a <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
8010494a:	55                   	push   %ebp
8010494b:	89 e5                	mov    %esp,%ebp
8010494d:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104950:	c7 45 fc 54 ff 10 80 	movl   $0x8010ff54,-0x4(%ebp)
80104957:	eb 30                	jmp    80104989 <wakeup1+0x3f>
    if(p->state == SLEEPING && p->chan == chan)
80104959:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010495c:	8b 40 0c             	mov    0xc(%eax),%eax
8010495f:	83 f8 02             	cmp    $0x2,%eax
80104962:	75 1e                	jne    80104982 <wakeup1+0x38>
80104964:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104967:	8b 40 20             	mov    0x20(%eax),%eax
8010496a:	3b 45 08             	cmp    0x8(%ebp),%eax
8010496d:	75 13                	jne    80104982 <wakeup1+0x38>
      make_runnable(p,2);//Sube de nivel
8010496f:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80104976:	00 
80104977:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010497a:	89 04 24             	mov    %eax,(%esp)
8010497d:	e8 b1 f6 ff ff       	call   80104033 <make_runnable>
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104982:	81 45 fc 88 00 00 00 	addl   $0x88,-0x4(%ebp)
80104989:	b8 54 21 11 80       	mov    $0x80112154,%eax
8010498e:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80104991:	72 c6                	jb     80104959 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      make_runnable(p,2);//Sube de nivel
      //p->state = RUNNABLE;
}
80104993:	c9                   	leave  
80104994:	c3                   	ret    

80104995 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104995:	55                   	push   %ebp
80104996:	89 e5                	mov    %esp,%ebp
80104998:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
8010499b:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
801049a2:	e8 04 02 00 00       	call   80104bab <acquire>
  wakeup1(chan);
801049a7:	8b 45 08             	mov    0x8(%ebp),%eax
801049aa:	89 04 24             	mov    %eax,(%esp)
801049ad:	e8 98 ff ff ff       	call   8010494a <wakeup1>
  release(&ptable.lock);
801049b2:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
801049b9:	e8 4f 02 00 00       	call   80104c0d <release>
}
801049be:	c9                   	leave  
801049bf:	c3                   	ret    

801049c0 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801049c0:	55                   	push   %ebp
801049c1:	89 e5                	mov    %esp,%ebp
801049c3:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
801049c6:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
801049cd:	e8 d9 01 00 00       	call   80104bab <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049d2:	c7 45 f4 54 ff 10 80 	movl   $0x8010ff54,-0xc(%ebp)
801049d9:	eb 4d                	jmp    80104a28 <kill+0x68>
    if(p->pid == pid){
801049db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049de:	8b 40 10             	mov    0x10(%eax),%eax
801049e1:	3b 45 08             	cmp    0x8(%ebp),%eax
801049e4:	75 3b                	jne    80104a21 <kill+0x61>
      p->killed = 1;
801049e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049e9:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801049f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049f3:	8b 40 0c             	mov    0xc(%eax),%eax
801049f6:	83 f8 02             	cmp    $0x2,%eax
801049f9:	75 13                	jne    80104a0e <kill+0x4e>
        make_runnable(p,3);//Queda el nivel q estaba
801049fb:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80104a02:	00 
80104a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a06:	89 04 24             	mov    %eax,(%esp)
80104a09:	e8 25 f6 ff ff       	call   80104033 <make_runnable>
        //p->state = RUNNABLE;
      release(&ptable.lock);
80104a0e:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
80104a15:	e8 f3 01 00 00       	call   80104c0d <release>
      return 0;
80104a1a:	b8 00 00 00 00       	mov    $0x0,%eax
80104a1f:	eb 22                	jmp    80104a43 <kill+0x83>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a21:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104a28:	b8 54 21 11 80       	mov    $0x80112154,%eax
80104a2d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80104a30:	72 a9                	jb     801049db <kill+0x1b>
        //p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104a32:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
80104a39:	e8 cf 01 00 00       	call   80104c0d <release>
  return -1;
80104a3e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104a43:	c9                   	leave  
80104a44:	c3                   	ret    

80104a45 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104a45:	55                   	push   %ebp
80104a46:	89 e5                	mov    %esp,%ebp
80104a48:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a4b:	c7 45 f0 54 ff 10 80 	movl   $0x8010ff54,-0x10(%ebp)
80104a52:	e9 db 00 00 00       	jmp    80104b32 <procdump+0xed>
    if(p->state == UNUSED)
80104a57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a5a:	8b 40 0c             	mov    0xc(%eax),%eax
80104a5d:	85 c0                	test   %eax,%eax
80104a5f:	0f 84 c5 00 00 00    	je     80104b2a <procdump+0xe5>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104a65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a68:	8b 40 0c             	mov    0xc(%eax),%eax
80104a6b:	83 f8 05             	cmp    $0x5,%eax
80104a6e:	77 23                	ja     80104a93 <procdump+0x4e>
80104a70:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a73:	8b 40 0c             	mov    0xc(%eax),%eax
80104a76:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104a7d:	85 c0                	test   %eax,%eax
80104a7f:	74 12                	je     80104a93 <procdump+0x4e>
      state = states[p->state];
80104a81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a84:	8b 40 0c             	mov    0xc(%eax),%eax
80104a87:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104a8e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104a91:	eb 07                	jmp    80104a9a <procdump+0x55>
    else
      state = "???";
80104a93:	c7 45 ec 4c 85 10 80 	movl   $0x8010854c,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104a9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a9d:	8d 50 6c             	lea    0x6c(%eax),%edx
80104aa0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104aa3:	8b 40 10             	mov    0x10(%eax),%eax
80104aa6:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104aaa:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104aad:	89 54 24 08          	mov    %edx,0x8(%esp)
80104ab1:	89 44 24 04          	mov    %eax,0x4(%esp)
80104ab5:	c7 04 24 50 85 10 80 	movl   $0x80108550,(%esp)
80104abc:	e8 e4 b8 ff ff       	call   801003a5 <cprintf>
    if(p->state == SLEEPING){
80104ac1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ac4:	8b 40 0c             	mov    0xc(%eax),%eax
80104ac7:	83 f8 02             	cmp    $0x2,%eax
80104aca:	75 50                	jne    80104b1c <procdump+0xd7>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104acc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104acf:	8b 40 1c             	mov    0x1c(%eax),%eax
80104ad2:	8b 40 0c             	mov    0xc(%eax),%eax
80104ad5:	83 c0 08             	add    $0x8,%eax
80104ad8:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80104adb:	89 54 24 04          	mov    %edx,0x4(%esp)
80104adf:	89 04 24             	mov    %eax,(%esp)
80104ae2:	e8 75 01 00 00       	call   80104c5c <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104ae7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104aee:	eb 1b                	jmp    80104b0b <procdump+0xc6>
        cprintf(" %p", pc[i]);
80104af0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104af3:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104af7:	89 44 24 04          	mov    %eax,0x4(%esp)
80104afb:	c7 04 24 59 85 10 80 	movl   $0x80108559,(%esp)
80104b02:	e8 9e b8 ff ff       	call   801003a5 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104b07:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104b0b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104b0f:	7f 0b                	jg     80104b1c <procdump+0xd7>
80104b11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b14:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104b18:	85 c0                	test   %eax,%eax
80104b1a:	75 d4                	jne    80104af0 <procdump+0xab>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104b1c:	c7 04 24 5d 85 10 80 	movl   $0x8010855d,(%esp)
80104b23:	e8 7d b8 ff ff       	call   801003a5 <cprintf>
80104b28:	eb 01                	jmp    80104b2b <procdump+0xe6>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80104b2a:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b2b:	81 45 f0 88 00 00 00 	addl   $0x88,-0x10(%ebp)
80104b32:	b8 54 21 11 80       	mov    $0x80112154,%eax
80104b37:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80104b3a:	0f 82 17 ff ff ff    	jb     80104a57 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104b40:	c9                   	leave  
80104b41:	c3                   	ret    
	...

80104b44 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104b44:	55                   	push   %ebp
80104b45:	89 e5                	mov    %esp,%ebp
80104b47:	53                   	push   %ebx
80104b48:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104b4b:	9c                   	pushf  
80104b4c:	5b                   	pop    %ebx
80104b4d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80104b50:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104b53:	83 c4 10             	add    $0x10,%esp
80104b56:	5b                   	pop    %ebx
80104b57:	5d                   	pop    %ebp
80104b58:	c3                   	ret    

80104b59 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80104b59:	55                   	push   %ebp
80104b5a:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104b5c:	fa                   	cli    
}
80104b5d:	5d                   	pop    %ebp
80104b5e:	c3                   	ret    

80104b5f <sti>:

static inline void
sti(void)
{
80104b5f:	55                   	push   %ebp
80104b60:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104b62:	fb                   	sti    
}
80104b63:	5d                   	pop    %ebp
80104b64:	c3                   	ret    

80104b65 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80104b65:	55                   	push   %ebp
80104b66:	89 e5                	mov    %esp,%ebp
80104b68:	53                   	push   %ebx
80104b69:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
80104b6c:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104b6f:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
80104b72:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104b75:	89 c3                	mov    %eax,%ebx
80104b77:	89 d8                	mov    %ebx,%eax
80104b79:	f0 87 02             	lock xchg %eax,(%edx)
80104b7c:	89 c3                	mov    %eax,%ebx
80104b7e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80104b81:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104b84:	83 c4 10             	add    $0x10,%esp
80104b87:	5b                   	pop    %ebx
80104b88:	5d                   	pop    %ebp
80104b89:	c3                   	ret    

80104b8a <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104b8a:	55                   	push   %ebp
80104b8b:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104b8d:	8b 45 08             	mov    0x8(%ebp),%eax
80104b90:	8b 55 0c             	mov    0xc(%ebp),%edx
80104b93:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104b96:	8b 45 08             	mov    0x8(%ebp),%eax
80104b99:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104b9f:	8b 45 08             	mov    0x8(%ebp),%eax
80104ba2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104ba9:	5d                   	pop    %ebp
80104baa:	c3                   	ret    

80104bab <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104bab:	55                   	push   %ebp
80104bac:	89 e5                	mov    %esp,%ebp
80104bae:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104bb1:	e8 3f 01 00 00       	call   80104cf5 <pushcli>
  if(holding(lk))
80104bb6:	8b 45 08             	mov    0x8(%ebp),%eax
80104bb9:	89 04 24             	mov    %eax,(%esp)
80104bbc:	e8 0a 01 00 00       	call   80104ccb <holding>
80104bc1:	85 c0                	test   %eax,%eax
80104bc3:	74 0c                	je     80104bd1 <acquire+0x26>
    panic("acquire");
80104bc5:	c7 04 24 89 85 10 80 	movl   $0x80108589,(%esp)
80104bcc:	e8 75 b9 ff ff       	call   80100546 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80104bd1:	90                   	nop
80104bd2:	8b 45 08             	mov    0x8(%ebp),%eax
80104bd5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80104bdc:	00 
80104bdd:	89 04 24             	mov    %eax,(%esp)
80104be0:	e8 80 ff ff ff       	call   80104b65 <xchg>
80104be5:	85 c0                	test   %eax,%eax
80104be7:	75 e9                	jne    80104bd2 <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80104be9:	8b 45 08             	mov    0x8(%ebp),%eax
80104bec:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104bf3:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80104bf6:	8b 45 08             	mov    0x8(%ebp),%eax
80104bf9:	83 c0 0c             	add    $0xc,%eax
80104bfc:	89 44 24 04          	mov    %eax,0x4(%esp)
80104c00:	8d 45 08             	lea    0x8(%ebp),%eax
80104c03:	89 04 24             	mov    %eax,(%esp)
80104c06:	e8 51 00 00 00       	call   80104c5c <getcallerpcs>
}
80104c0b:	c9                   	leave  
80104c0c:	c3                   	ret    

80104c0d <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104c0d:	55                   	push   %ebp
80104c0e:	89 e5                	mov    %esp,%ebp
80104c10:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80104c13:	8b 45 08             	mov    0x8(%ebp),%eax
80104c16:	89 04 24             	mov    %eax,(%esp)
80104c19:	e8 ad 00 00 00       	call   80104ccb <holding>
80104c1e:	85 c0                	test   %eax,%eax
80104c20:	75 0c                	jne    80104c2e <release+0x21>
    panic("release");
80104c22:	c7 04 24 91 85 10 80 	movl   $0x80108591,(%esp)
80104c29:	e8 18 b9 ff ff       	call   80100546 <panic>

  lk->pcs[0] = 0;
80104c2e:	8b 45 08             	mov    0x8(%ebp),%eax
80104c31:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104c38:	8b 45 08             	mov    0x8(%ebp),%eax
80104c3b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80104c42:	8b 45 08             	mov    0x8(%ebp),%eax
80104c45:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104c4c:	00 
80104c4d:	89 04 24             	mov    %eax,(%esp)
80104c50:	e8 10 ff ff ff       	call   80104b65 <xchg>

  popcli();
80104c55:	e8 e3 00 00 00       	call   80104d3d <popcli>
}
80104c5a:	c9                   	leave  
80104c5b:	c3                   	ret    

80104c5c <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104c5c:	55                   	push   %ebp
80104c5d:	89 e5                	mov    %esp,%ebp
80104c5f:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80104c62:	8b 45 08             	mov    0x8(%ebp),%eax
80104c65:	83 e8 08             	sub    $0x8,%eax
80104c68:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104c6b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104c72:	eb 34                	jmp    80104ca8 <getcallerpcs+0x4c>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104c74:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104c78:	74 49                	je     80104cc3 <getcallerpcs+0x67>
80104c7a:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104c81:	76 40                	jbe    80104cc3 <getcallerpcs+0x67>
80104c83:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104c87:	74 3a                	je     80104cc3 <getcallerpcs+0x67>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104c89:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c8c:	c1 e0 02             	shl    $0x2,%eax
80104c8f:	03 45 0c             	add    0xc(%ebp),%eax
80104c92:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104c95:	83 c2 04             	add    $0x4,%edx
80104c98:	8b 12                	mov    (%edx),%edx
80104c9a:	89 10                	mov    %edx,(%eax)
    ebp = (uint*)ebp[0]; // saved %ebp
80104c9c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c9f:	8b 00                	mov    (%eax),%eax
80104ca1:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80104ca4:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104ca8:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104cac:	7e c6                	jle    80104c74 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80104cae:	eb 13                	jmp    80104cc3 <getcallerpcs+0x67>
    pcs[i] = 0;
80104cb0:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104cb3:	c1 e0 02             	shl    $0x2,%eax
80104cb6:	03 45 0c             	add    0xc(%ebp),%eax
80104cb9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80104cbf:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104cc3:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104cc7:	7e e7                	jle    80104cb0 <getcallerpcs+0x54>
    pcs[i] = 0;
}
80104cc9:	c9                   	leave  
80104cca:	c3                   	ret    

80104ccb <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104ccb:	55                   	push   %ebp
80104ccc:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80104cce:	8b 45 08             	mov    0x8(%ebp),%eax
80104cd1:	8b 00                	mov    (%eax),%eax
80104cd3:	85 c0                	test   %eax,%eax
80104cd5:	74 17                	je     80104cee <holding+0x23>
80104cd7:	8b 45 08             	mov    0x8(%ebp),%eax
80104cda:	8b 50 08             	mov    0x8(%eax),%edx
80104cdd:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104ce3:	39 c2                	cmp    %eax,%edx
80104ce5:	75 07                	jne    80104cee <holding+0x23>
80104ce7:	b8 01 00 00 00       	mov    $0x1,%eax
80104cec:	eb 05                	jmp    80104cf3 <holding+0x28>
80104cee:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104cf3:	5d                   	pop    %ebp
80104cf4:	c3                   	ret    

80104cf5 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104cf5:	55                   	push   %ebp
80104cf6:	89 e5                	mov    %esp,%ebp
80104cf8:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80104cfb:	e8 44 fe ff ff       	call   80104b44 <readeflags>
80104d00:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80104d03:	e8 51 fe ff ff       	call   80104b59 <cli>
  if(cpu->ncli++ == 0)
80104d08:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d0e:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80104d14:	85 d2                	test   %edx,%edx
80104d16:	0f 94 c1             	sete   %cl
80104d19:	83 c2 01             	add    $0x1,%edx
80104d1c:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80104d22:	84 c9                	test   %cl,%cl
80104d24:	74 15                	je     80104d3b <pushcli+0x46>
    cpu->intena = eflags & FL_IF;
80104d26:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d2c:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104d2f:	81 e2 00 02 00 00    	and    $0x200,%edx
80104d35:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104d3b:	c9                   	leave  
80104d3c:	c3                   	ret    

80104d3d <popcli>:

void
popcli(void)
{
80104d3d:	55                   	push   %ebp
80104d3e:	89 e5                	mov    %esp,%ebp
80104d40:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
80104d43:	e8 fc fd ff ff       	call   80104b44 <readeflags>
80104d48:	25 00 02 00 00       	and    $0x200,%eax
80104d4d:	85 c0                	test   %eax,%eax
80104d4f:	74 0c                	je     80104d5d <popcli+0x20>
    panic("popcli - interruptible");
80104d51:	c7 04 24 99 85 10 80 	movl   $0x80108599,(%esp)
80104d58:	e8 e9 b7 ff ff       	call   80100546 <panic>
  if(--cpu->ncli < 0)
80104d5d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d63:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80104d69:	83 ea 01             	sub    $0x1,%edx
80104d6c:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80104d72:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104d78:	85 c0                	test   %eax,%eax
80104d7a:	79 0c                	jns    80104d88 <popcli+0x4b>
    panic("popcli");
80104d7c:	c7 04 24 b0 85 10 80 	movl   $0x801085b0,(%esp)
80104d83:	e8 be b7 ff ff       	call   80100546 <panic>
  if(cpu->ncli == 0 && cpu->intena)
80104d88:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d8e:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104d94:	85 c0                	test   %eax,%eax
80104d96:	75 15                	jne    80104dad <popcli+0x70>
80104d98:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d9e:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104da4:	85 c0                	test   %eax,%eax
80104da6:	74 05                	je     80104dad <popcli+0x70>
    sti();
80104da8:	e8 b2 fd ff ff       	call   80104b5f <sti>
}
80104dad:	c9                   	leave  
80104dae:	c3                   	ret    
	...

80104db0 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80104db0:	55                   	push   %ebp
80104db1:	89 e5                	mov    %esp,%ebp
80104db3:	57                   	push   %edi
80104db4:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104db5:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104db8:	8b 55 10             	mov    0x10(%ebp),%edx
80104dbb:	8b 45 0c             	mov    0xc(%ebp),%eax
80104dbe:	89 cb                	mov    %ecx,%ebx
80104dc0:	89 df                	mov    %ebx,%edi
80104dc2:	89 d1                	mov    %edx,%ecx
80104dc4:	fc                   	cld    
80104dc5:	f3 aa                	rep stos %al,%es:(%edi)
80104dc7:	89 ca                	mov    %ecx,%edx
80104dc9:	89 fb                	mov    %edi,%ebx
80104dcb:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104dce:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80104dd1:	5b                   	pop    %ebx
80104dd2:	5f                   	pop    %edi
80104dd3:	5d                   	pop    %ebp
80104dd4:	c3                   	ret    

80104dd5 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80104dd5:	55                   	push   %ebp
80104dd6:	89 e5                	mov    %esp,%ebp
80104dd8:	57                   	push   %edi
80104dd9:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104dda:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104ddd:	8b 55 10             	mov    0x10(%ebp),%edx
80104de0:	8b 45 0c             	mov    0xc(%ebp),%eax
80104de3:	89 cb                	mov    %ecx,%ebx
80104de5:	89 df                	mov    %ebx,%edi
80104de7:	89 d1                	mov    %edx,%ecx
80104de9:	fc                   	cld    
80104dea:	f3 ab                	rep stos %eax,%es:(%edi)
80104dec:	89 ca                	mov    %ecx,%edx
80104dee:	89 fb                	mov    %edi,%ebx
80104df0:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104df3:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80104df6:	5b                   	pop    %ebx
80104df7:	5f                   	pop    %edi
80104df8:	5d                   	pop    %ebp
80104df9:	c3                   	ret    

80104dfa <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104dfa:	55                   	push   %ebp
80104dfb:	89 e5                	mov    %esp,%ebp
80104dfd:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
80104e00:	8b 45 08             	mov    0x8(%ebp),%eax
80104e03:	83 e0 03             	and    $0x3,%eax
80104e06:	85 c0                	test   %eax,%eax
80104e08:	75 49                	jne    80104e53 <memset+0x59>
80104e0a:	8b 45 10             	mov    0x10(%ebp),%eax
80104e0d:	83 e0 03             	and    $0x3,%eax
80104e10:	85 c0                	test   %eax,%eax
80104e12:	75 3f                	jne    80104e53 <memset+0x59>
    c &= 0xFF;
80104e14:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104e1b:	8b 45 10             	mov    0x10(%ebp),%eax
80104e1e:	c1 e8 02             	shr    $0x2,%eax
80104e21:	89 c2                	mov    %eax,%edx
80104e23:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e26:	89 c1                	mov    %eax,%ecx
80104e28:	c1 e1 18             	shl    $0x18,%ecx
80104e2b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e2e:	c1 e0 10             	shl    $0x10,%eax
80104e31:	09 c1                	or     %eax,%ecx
80104e33:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e36:	c1 e0 08             	shl    $0x8,%eax
80104e39:	09 c8                	or     %ecx,%eax
80104e3b:	0b 45 0c             	or     0xc(%ebp),%eax
80104e3e:	89 54 24 08          	mov    %edx,0x8(%esp)
80104e42:	89 44 24 04          	mov    %eax,0x4(%esp)
80104e46:	8b 45 08             	mov    0x8(%ebp),%eax
80104e49:	89 04 24             	mov    %eax,(%esp)
80104e4c:	e8 84 ff ff ff       	call   80104dd5 <stosl>
80104e51:	eb 19                	jmp    80104e6c <memset+0x72>
  } else
    stosb(dst, c, n);
80104e53:	8b 45 10             	mov    0x10(%ebp),%eax
80104e56:	89 44 24 08          	mov    %eax,0x8(%esp)
80104e5a:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e5d:	89 44 24 04          	mov    %eax,0x4(%esp)
80104e61:	8b 45 08             	mov    0x8(%ebp),%eax
80104e64:	89 04 24             	mov    %eax,(%esp)
80104e67:	e8 44 ff ff ff       	call   80104db0 <stosb>
  return dst;
80104e6c:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104e6f:	c9                   	leave  
80104e70:	c3                   	ret    

80104e71 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104e71:	55                   	push   %ebp
80104e72:	89 e5                	mov    %esp,%ebp
80104e74:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80104e77:	8b 45 08             	mov    0x8(%ebp),%eax
80104e7a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104e7d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e80:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104e83:	eb 32                	jmp    80104eb7 <memcmp+0x46>
    if(*s1 != *s2)
80104e85:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e88:	0f b6 10             	movzbl (%eax),%edx
80104e8b:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e8e:	0f b6 00             	movzbl (%eax),%eax
80104e91:	38 c2                	cmp    %al,%dl
80104e93:	74 1a                	je     80104eaf <memcmp+0x3e>
      return *s1 - *s2;
80104e95:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e98:	0f b6 00             	movzbl (%eax),%eax
80104e9b:	0f b6 d0             	movzbl %al,%edx
80104e9e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ea1:	0f b6 00             	movzbl (%eax),%eax
80104ea4:	0f b6 c0             	movzbl %al,%eax
80104ea7:	89 d1                	mov    %edx,%ecx
80104ea9:	29 c1                	sub    %eax,%ecx
80104eab:	89 c8                	mov    %ecx,%eax
80104ead:	eb 1c                	jmp    80104ecb <memcmp+0x5a>
    s1++, s2++;
80104eaf:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104eb3:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80104eb7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104ebb:	0f 95 c0             	setne  %al
80104ebe:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104ec2:	84 c0                	test   %al,%al
80104ec4:	75 bf                	jne    80104e85 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80104ec6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104ecb:	c9                   	leave  
80104ecc:	c3                   	ret    

80104ecd <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104ecd:	55                   	push   %ebp
80104ece:	89 e5                	mov    %esp,%ebp
80104ed0:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104ed3:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ed6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104ed9:	8b 45 08             	mov    0x8(%ebp),%eax
80104edc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104edf:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ee2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104ee5:	73 55                	jae    80104f3c <memmove+0x6f>
80104ee7:	8b 45 10             	mov    0x10(%ebp),%eax
80104eea:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104eed:	8d 04 02             	lea    (%edx,%eax,1),%eax
80104ef0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104ef3:	76 4a                	jbe    80104f3f <memmove+0x72>
    s += n;
80104ef5:	8b 45 10             	mov    0x10(%ebp),%eax
80104ef8:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104efb:	8b 45 10             	mov    0x10(%ebp),%eax
80104efe:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104f01:	eb 13                	jmp    80104f16 <memmove+0x49>
      *--d = *--s;
80104f03:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104f07:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104f0b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f0e:	0f b6 10             	movzbl (%eax),%edx
80104f11:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104f14:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80104f16:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f1a:	0f 95 c0             	setne  %al
80104f1d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104f21:	84 c0                	test   %al,%al
80104f23:	75 de                	jne    80104f03 <memmove+0x36>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80104f25:	eb 28                	jmp    80104f4f <memmove+0x82>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80104f27:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f2a:	0f b6 10             	movzbl (%eax),%edx
80104f2d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104f30:	88 10                	mov    %dl,(%eax)
80104f32:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104f36:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104f3a:	eb 04                	jmp    80104f40 <memmove+0x73>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80104f3c:	90                   	nop
80104f3d:	eb 01                	jmp    80104f40 <memmove+0x73>
80104f3f:	90                   	nop
80104f40:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f44:	0f 95 c0             	setne  %al
80104f47:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104f4b:	84 c0                	test   %al,%al
80104f4d:	75 d8                	jne    80104f27 <memmove+0x5a>
      *d++ = *s++;

  return dst;
80104f4f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104f52:	c9                   	leave  
80104f53:	c3                   	ret    

80104f54 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104f54:	55                   	push   %ebp
80104f55:	89 e5                	mov    %esp,%ebp
80104f57:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80104f5a:	8b 45 10             	mov    0x10(%ebp),%eax
80104f5d:	89 44 24 08          	mov    %eax,0x8(%esp)
80104f61:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f64:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f68:	8b 45 08             	mov    0x8(%ebp),%eax
80104f6b:	89 04 24             	mov    %eax,(%esp)
80104f6e:	e8 5a ff ff ff       	call   80104ecd <memmove>
}
80104f73:	c9                   	leave  
80104f74:	c3                   	ret    

80104f75 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104f75:	55                   	push   %ebp
80104f76:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104f78:	eb 0c                	jmp    80104f86 <strncmp+0x11>
    n--, p++, q++;
80104f7a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104f7e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104f82:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80104f86:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f8a:	74 1a                	je     80104fa6 <strncmp+0x31>
80104f8c:	8b 45 08             	mov    0x8(%ebp),%eax
80104f8f:	0f b6 00             	movzbl (%eax),%eax
80104f92:	84 c0                	test   %al,%al
80104f94:	74 10                	je     80104fa6 <strncmp+0x31>
80104f96:	8b 45 08             	mov    0x8(%ebp),%eax
80104f99:	0f b6 10             	movzbl (%eax),%edx
80104f9c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f9f:	0f b6 00             	movzbl (%eax),%eax
80104fa2:	38 c2                	cmp    %al,%dl
80104fa4:	74 d4                	je     80104f7a <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80104fa6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104faa:	75 07                	jne    80104fb3 <strncmp+0x3e>
    return 0;
80104fac:	b8 00 00 00 00       	mov    $0x0,%eax
80104fb1:	eb 18                	jmp    80104fcb <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
80104fb3:	8b 45 08             	mov    0x8(%ebp),%eax
80104fb6:	0f b6 00             	movzbl (%eax),%eax
80104fb9:	0f b6 d0             	movzbl %al,%edx
80104fbc:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fbf:	0f b6 00             	movzbl (%eax),%eax
80104fc2:	0f b6 c0             	movzbl %al,%eax
80104fc5:	89 d1                	mov    %edx,%ecx
80104fc7:	29 c1                	sub    %eax,%ecx
80104fc9:	89 c8                	mov    %ecx,%eax
}
80104fcb:	5d                   	pop    %ebp
80104fcc:	c3                   	ret    

80104fcd <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104fcd:	55                   	push   %ebp
80104fce:	89 e5                	mov    %esp,%ebp
80104fd0:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80104fd3:	8b 45 08             	mov    0x8(%ebp),%eax
80104fd6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104fd9:	90                   	nop
80104fda:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104fde:	0f 9f c0             	setg   %al
80104fe1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104fe5:	84 c0                	test   %al,%al
80104fe7:	74 30                	je     80105019 <strncpy+0x4c>
80104fe9:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fec:	0f b6 10             	movzbl (%eax),%edx
80104fef:	8b 45 08             	mov    0x8(%ebp),%eax
80104ff2:	88 10                	mov    %dl,(%eax)
80104ff4:	8b 45 08             	mov    0x8(%ebp),%eax
80104ff7:	0f b6 00             	movzbl (%eax),%eax
80104ffa:	84 c0                	test   %al,%al
80104ffc:	0f 95 c0             	setne  %al
80104fff:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105003:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
80105007:	84 c0                	test   %al,%al
80105009:	75 cf                	jne    80104fda <strncpy+0xd>
    ;
  while(n-- > 0)
8010500b:	eb 0d                	jmp    8010501a <strncpy+0x4d>
    *s++ = 0;
8010500d:	8b 45 08             	mov    0x8(%ebp),%eax
80105010:	c6 00 00             	movb   $0x0,(%eax)
80105013:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105017:	eb 01                	jmp    8010501a <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105019:	90                   	nop
8010501a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010501e:	0f 9f c0             	setg   %al
80105021:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105025:	84 c0                	test   %al,%al
80105027:	75 e4                	jne    8010500d <strncpy+0x40>
    *s++ = 0;
  return os;
80105029:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010502c:	c9                   	leave  
8010502d:	c3                   	ret    

8010502e <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
8010502e:	55                   	push   %ebp
8010502f:	89 e5                	mov    %esp,%ebp
80105031:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105034:	8b 45 08             	mov    0x8(%ebp),%eax
80105037:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
8010503a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010503e:	7f 05                	jg     80105045 <safestrcpy+0x17>
    return os;
80105040:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105043:	eb 35                	jmp    8010507a <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
80105045:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105049:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010504d:	7e 22                	jle    80105071 <safestrcpy+0x43>
8010504f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105052:	0f b6 10             	movzbl (%eax),%edx
80105055:	8b 45 08             	mov    0x8(%ebp),%eax
80105058:	88 10                	mov    %dl,(%eax)
8010505a:	8b 45 08             	mov    0x8(%ebp),%eax
8010505d:	0f b6 00             	movzbl (%eax),%eax
80105060:	84 c0                	test   %al,%al
80105062:	0f 95 c0             	setne  %al
80105065:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105069:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
8010506d:	84 c0                	test   %al,%al
8010506f:	75 d4                	jne    80105045 <safestrcpy+0x17>
    ;
  *s = 0;
80105071:	8b 45 08             	mov    0x8(%ebp),%eax
80105074:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105077:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010507a:	c9                   	leave  
8010507b:	c3                   	ret    

8010507c <strlen>:

int
strlen(const char *s)
{
8010507c:	55                   	push   %ebp
8010507d:	89 e5                	mov    %esp,%ebp
8010507f:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105082:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105089:	eb 04                	jmp    8010508f <strlen+0x13>
8010508b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010508f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105092:	03 45 08             	add    0x8(%ebp),%eax
80105095:	0f b6 00             	movzbl (%eax),%eax
80105098:	84 c0                	test   %al,%al
8010509a:	75 ef                	jne    8010508b <strlen+0xf>
    ;
  return n;
8010509c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010509f:	c9                   	leave  
801050a0:	c3                   	ret    
801050a1:	00 00                	add    %al,(%eax)
	...

801050a4 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
801050a4:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801050a8:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801050ac:	55                   	push   %ebp
  pushl %ebx
801050ad:	53                   	push   %ebx
  pushl %esi
801050ae:	56                   	push   %esi
  pushl %edi
801050af:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801050b0:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801050b2:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801050b4:	5f                   	pop    %edi
  popl %esi
801050b5:	5e                   	pop    %esi
  popl %ebx
801050b6:	5b                   	pop    %ebx
  popl %ebp
801050b7:	5d                   	pop    %ebp
  ret
801050b8:	c3                   	ret    
801050b9:	00 00                	add    %al,(%eax)
	...

801050bc <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801050bc:	55                   	push   %ebp
801050bd:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
801050bf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050c5:	8b 00                	mov    (%eax),%eax
801050c7:	3b 45 08             	cmp    0x8(%ebp),%eax
801050ca:	76 12                	jbe    801050de <fetchint+0x22>
801050cc:	8b 45 08             	mov    0x8(%ebp),%eax
801050cf:	8d 50 04             	lea    0x4(%eax),%edx
801050d2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050d8:	8b 00                	mov    (%eax),%eax
801050da:	39 c2                	cmp    %eax,%edx
801050dc:	76 07                	jbe    801050e5 <fetchint+0x29>
    return -1;
801050de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050e3:	eb 0f                	jmp    801050f4 <fetchint+0x38>
  *ip = *(int*)(addr);
801050e5:	8b 45 08             	mov    0x8(%ebp),%eax
801050e8:	8b 10                	mov    (%eax),%edx
801050ea:	8b 45 0c             	mov    0xc(%ebp),%eax
801050ed:	89 10                	mov    %edx,(%eax)
  return 0;
801050ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
801050f4:	5d                   	pop    %ebp
801050f5:	c3                   	ret    

801050f6 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801050f6:	55                   	push   %ebp
801050f7:	89 e5                	mov    %esp,%ebp
801050f9:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
801050fc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105102:	8b 00                	mov    (%eax),%eax
80105104:	3b 45 08             	cmp    0x8(%ebp),%eax
80105107:	77 07                	ja     80105110 <fetchstr+0x1a>
    return -1;
80105109:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010510e:	eb 48                	jmp    80105158 <fetchstr+0x62>
  *pp = (char*)addr;
80105110:	8b 55 08             	mov    0x8(%ebp),%edx
80105113:	8b 45 0c             	mov    0xc(%ebp),%eax
80105116:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80105118:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010511e:	8b 00                	mov    (%eax),%eax
80105120:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80105123:	8b 45 0c             	mov    0xc(%ebp),%eax
80105126:	8b 00                	mov    (%eax),%eax
80105128:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010512b:	eb 1e                	jmp    8010514b <fetchstr+0x55>
    if(*s == 0)
8010512d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105130:	0f b6 00             	movzbl (%eax),%eax
80105133:	84 c0                	test   %al,%al
80105135:	75 10                	jne    80105147 <fetchstr+0x51>
      return s - *pp;
80105137:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010513a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010513d:	8b 00                	mov    (%eax),%eax
8010513f:	89 d1                	mov    %edx,%ecx
80105141:	29 c1                	sub    %eax,%ecx
80105143:	89 c8                	mov    %ecx,%eax
80105145:	eb 11                	jmp    80105158 <fetchstr+0x62>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80105147:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010514b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010514e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105151:	72 da                	jb     8010512d <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80105153:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105158:	c9                   	leave  
80105159:	c3                   	ret    

8010515a <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010515a:	55                   	push   %ebp
8010515b:	89 e5                	mov    %esp,%ebp
8010515d:	83 ec 08             	sub    $0x8,%esp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105160:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105166:	8b 40 18             	mov    0x18(%eax),%eax
80105169:	8b 50 44             	mov    0x44(%eax),%edx
8010516c:	8b 45 08             	mov    0x8(%ebp),%eax
8010516f:	c1 e0 02             	shl    $0x2,%eax
80105172:	8d 04 02             	lea    (%edx,%eax,1),%eax
80105175:	8d 50 04             	lea    0x4(%eax),%edx
80105178:	8b 45 0c             	mov    0xc(%ebp),%eax
8010517b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010517f:	89 14 24             	mov    %edx,(%esp)
80105182:	e8 35 ff ff ff       	call   801050bc <fetchint>
}
80105187:	c9                   	leave  
80105188:	c3                   	ret    

80105189 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105189:	55                   	push   %ebp
8010518a:	89 e5                	mov    %esp,%ebp
8010518c:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
8010518f:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105192:	89 44 24 04          	mov    %eax,0x4(%esp)
80105196:	8b 45 08             	mov    0x8(%ebp),%eax
80105199:	89 04 24             	mov    %eax,(%esp)
8010519c:	e8 b9 ff ff ff       	call   8010515a <argint>
801051a1:	85 c0                	test   %eax,%eax
801051a3:	79 07                	jns    801051ac <argptr+0x23>
    return -1;
801051a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051aa:	eb 3d                	jmp    801051e9 <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
801051ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051af:	89 c2                	mov    %eax,%edx
801051b1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051b7:	8b 00                	mov    (%eax),%eax
801051b9:	39 c2                	cmp    %eax,%edx
801051bb:	73 16                	jae    801051d3 <argptr+0x4a>
801051bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051c0:	89 c2                	mov    %eax,%edx
801051c2:	8b 45 10             	mov    0x10(%ebp),%eax
801051c5:	01 c2                	add    %eax,%edx
801051c7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051cd:	8b 00                	mov    (%eax),%eax
801051cf:	39 c2                	cmp    %eax,%edx
801051d1:	76 07                	jbe    801051da <argptr+0x51>
    return -1;
801051d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051d8:	eb 0f                	jmp    801051e9 <argptr+0x60>
  *pp = (char*)i;
801051da:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051dd:	89 c2                	mov    %eax,%edx
801051df:	8b 45 0c             	mov    0xc(%ebp),%eax
801051e2:	89 10                	mov    %edx,(%eax)
  return 0;
801051e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801051e9:	c9                   	leave  
801051ea:	c3                   	ret    

801051eb <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801051eb:	55                   	push   %ebp
801051ec:	89 e5                	mov    %esp,%ebp
801051ee:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
801051f1:	8d 45 fc             	lea    -0x4(%ebp),%eax
801051f4:	89 44 24 04          	mov    %eax,0x4(%esp)
801051f8:	8b 45 08             	mov    0x8(%ebp),%eax
801051fb:	89 04 24             	mov    %eax,(%esp)
801051fe:	e8 57 ff ff ff       	call   8010515a <argint>
80105203:	85 c0                	test   %eax,%eax
80105205:	79 07                	jns    8010520e <argstr+0x23>
    return -1;
80105207:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010520c:	eb 12                	jmp    80105220 <argstr+0x35>
  return fetchstr(addr, pp);
8010520e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105211:	8b 55 0c             	mov    0xc(%ebp),%edx
80105214:	89 54 24 04          	mov    %edx,0x4(%esp)
80105218:	89 04 24             	mov    %eax,(%esp)
8010521b:	e8 d6 fe ff ff       	call   801050f6 <fetchstr>
}
80105220:	c9                   	leave  
80105221:	c3                   	ret    

80105222 <syscall>:
[SYS_procstat]   sys_procstat,
};

void
syscall(void)
{
80105222:	55                   	push   %ebp
80105223:	89 e5                	mov    %esp,%ebp
80105225:	53                   	push   %ebx
80105226:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
80105229:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010522f:	8b 40 18             	mov    0x18(%eax),%eax
80105232:	8b 40 1c             	mov    0x1c(%eax),%eax
80105235:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num >= 0 && num < SYS_open && syscalls[num]) {
80105238:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010523c:	78 2e                	js     8010526c <syscall+0x4a>
8010523e:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
80105242:	7f 28                	jg     8010526c <syscall+0x4a>
80105244:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105247:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
8010524e:	85 c0                	test   %eax,%eax
80105250:	74 1a                	je     8010526c <syscall+0x4a>
    proc->tf->eax = syscalls[num]();
80105252:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105258:	8b 58 18             	mov    0x18(%eax),%ebx
8010525b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010525e:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105265:	ff d0                	call   *%eax
80105267:	89 43 1c             	mov    %eax,0x1c(%ebx)
8010526a:	eb 73                	jmp    801052df <syscall+0xbd>
  } else if (num >= SYS_open && num < NELEM(syscalls) && syscalls[num]) {
8010526c:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
80105270:	7e 30                	jle    801052a2 <syscall+0x80>
80105272:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105275:	83 f8 16             	cmp    $0x16,%eax
80105278:	77 28                	ja     801052a2 <syscall+0x80>
8010527a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010527d:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105284:	85 c0                	test   %eax,%eax
80105286:	74 1a                	je     801052a2 <syscall+0x80>
    proc->tf->eax = syscalls[num]();
80105288:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010528e:	8b 58 18             	mov    0x18(%eax),%ebx
80105291:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105294:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
8010529b:	ff d0                	call   *%eax
8010529d:	89 43 1c             	mov    %eax,0x1c(%ebx)
801052a0:	eb 3d                	jmp    801052df <syscall+0xbd>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
801052a2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  if(num >= 0 && num < SYS_open && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else if (num >= SYS_open && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
801052a8:	8d 48 6c             	lea    0x6c(%eax),%ecx
            proc->pid, proc->name, num);
801052ab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  if(num >= 0 && num < SYS_open && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else if (num >= SYS_open && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
801052b1:	8b 40 10             	mov    0x10(%eax),%eax
801052b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801052b7:	89 54 24 0c          	mov    %edx,0xc(%esp)
801052bb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801052bf:	89 44 24 04          	mov    %eax,0x4(%esp)
801052c3:	c7 04 24 b7 85 10 80 	movl   $0x801085b7,(%esp)
801052ca:	e8 d6 b0 ff ff       	call   801003a5 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
801052cf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052d5:	8b 40 18             	mov    0x18(%eax),%eax
801052d8:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801052df:	83 c4 24             	add    $0x24,%esp
801052e2:	5b                   	pop    %ebx
801052e3:	5d                   	pop    %ebp
801052e4:	c3                   	ret    
801052e5:	00 00                	add    %al,(%eax)
	...

801052e8 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801052e8:	55                   	push   %ebp
801052e9:	89 e5                	mov    %esp,%ebp
801052eb:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801052ee:	8d 45 f0             	lea    -0x10(%ebp),%eax
801052f1:	89 44 24 04          	mov    %eax,0x4(%esp)
801052f5:	8b 45 08             	mov    0x8(%ebp),%eax
801052f8:	89 04 24             	mov    %eax,(%esp)
801052fb:	e8 5a fe ff ff       	call   8010515a <argint>
80105300:	85 c0                	test   %eax,%eax
80105302:	79 07                	jns    8010530b <argfd+0x23>
    return -1;
80105304:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105309:	eb 50                	jmp    8010535b <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
8010530b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010530e:	85 c0                	test   %eax,%eax
80105310:	78 21                	js     80105333 <argfd+0x4b>
80105312:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105315:	83 f8 0f             	cmp    $0xf,%eax
80105318:	7f 19                	jg     80105333 <argfd+0x4b>
8010531a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105320:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105323:	83 c2 08             	add    $0x8,%edx
80105326:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010532a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010532d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105331:	75 07                	jne    8010533a <argfd+0x52>
    return -1;
80105333:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105338:	eb 21                	jmp    8010535b <argfd+0x73>
  if(pfd)
8010533a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010533e:	74 08                	je     80105348 <argfd+0x60>
    *pfd = fd;
80105340:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105343:	8b 45 0c             	mov    0xc(%ebp),%eax
80105346:	89 10                	mov    %edx,(%eax)
  if(pf)
80105348:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010534c:	74 08                	je     80105356 <argfd+0x6e>
    *pf = f;
8010534e:	8b 45 10             	mov    0x10(%ebp),%eax
80105351:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105354:	89 10                	mov    %edx,(%eax)
  return 0;
80105356:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010535b:	c9                   	leave  
8010535c:	c3                   	ret    

8010535d <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010535d:	55                   	push   %ebp
8010535e:	89 e5                	mov    %esp,%ebp
80105360:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105363:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010536a:	eb 30                	jmp    8010539c <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
8010536c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105372:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105375:	83 c2 08             	add    $0x8,%edx
80105378:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010537c:	85 c0                	test   %eax,%eax
8010537e:	75 18                	jne    80105398 <fdalloc+0x3b>
      proc->ofile[fd] = f;
80105380:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105386:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105389:	8d 4a 08             	lea    0x8(%edx),%ecx
8010538c:	8b 55 08             	mov    0x8(%ebp),%edx
8010538f:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105393:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105396:	eb 0f                	jmp    801053a7 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105398:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010539c:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
801053a0:	7e ca                	jle    8010536c <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
801053a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801053a7:	c9                   	leave  
801053a8:	c3                   	ret    

801053a9 <sys_dup>:

int
sys_dup(void)
{
801053a9:	55                   	push   %ebp
801053aa:	89 e5                	mov    %esp,%ebp
801053ac:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
801053af:	8d 45 f0             	lea    -0x10(%ebp),%eax
801053b2:	89 44 24 08          	mov    %eax,0x8(%esp)
801053b6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801053bd:	00 
801053be:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801053c5:	e8 1e ff ff ff       	call   801052e8 <argfd>
801053ca:	85 c0                	test   %eax,%eax
801053cc:	79 07                	jns    801053d5 <sys_dup+0x2c>
    return -1;
801053ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053d3:	eb 29                	jmp    801053fe <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801053d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053d8:	89 04 24             	mov    %eax,(%esp)
801053db:	e8 7d ff ff ff       	call   8010535d <fdalloc>
801053e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801053e3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801053e7:	79 07                	jns    801053f0 <sys_dup+0x47>
    return -1;
801053e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053ee:	eb 0e                	jmp    801053fe <sys_dup+0x55>
  filedup(f);
801053f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053f3:	89 04 24             	mov    %eax,(%esp)
801053f6:	e8 96 bb ff ff       	call   80100f91 <filedup>
  return fd;
801053fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801053fe:	c9                   	leave  
801053ff:	c3                   	ret    

80105400 <sys_read>:

int
sys_read(void)
{
80105400:	55                   	push   %ebp
80105401:	89 e5                	mov    %esp,%ebp
80105403:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105406:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105409:	89 44 24 08          	mov    %eax,0x8(%esp)
8010540d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105414:	00 
80105415:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010541c:	e8 c7 fe ff ff       	call   801052e8 <argfd>
80105421:	85 c0                	test   %eax,%eax
80105423:	78 35                	js     8010545a <sys_read+0x5a>
80105425:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105428:	89 44 24 04          	mov    %eax,0x4(%esp)
8010542c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105433:	e8 22 fd ff ff       	call   8010515a <argint>
80105438:	85 c0                	test   %eax,%eax
8010543a:	78 1e                	js     8010545a <sys_read+0x5a>
8010543c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010543f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105443:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105446:	89 44 24 04          	mov    %eax,0x4(%esp)
8010544a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105451:	e8 33 fd ff ff       	call   80105189 <argptr>
80105456:	85 c0                	test   %eax,%eax
80105458:	79 07                	jns    80105461 <sys_read+0x61>
    return -1;
8010545a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010545f:	eb 19                	jmp    8010547a <sys_read+0x7a>
  return fileread(f, p, n);
80105461:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105464:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105467:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010546a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010546e:	89 54 24 04          	mov    %edx,0x4(%esp)
80105472:	89 04 24             	mov    %eax,(%esp)
80105475:	e8 84 bc ff ff       	call   801010fe <fileread>
}
8010547a:	c9                   	leave  
8010547b:	c3                   	ret    

8010547c <sys_write>:

int
sys_write(void)
{
8010547c:	55                   	push   %ebp
8010547d:	89 e5                	mov    %esp,%ebp
8010547f:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105482:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105485:	89 44 24 08          	mov    %eax,0x8(%esp)
80105489:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105490:	00 
80105491:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105498:	e8 4b fe ff ff       	call   801052e8 <argfd>
8010549d:	85 c0                	test   %eax,%eax
8010549f:	78 35                	js     801054d6 <sys_write+0x5a>
801054a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801054a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801054a8:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801054af:	e8 a6 fc ff ff       	call   8010515a <argint>
801054b4:	85 c0                	test   %eax,%eax
801054b6:	78 1e                	js     801054d6 <sys_write+0x5a>
801054b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054bb:	89 44 24 08          	mov    %eax,0x8(%esp)
801054bf:	8d 45 ec             	lea    -0x14(%ebp),%eax
801054c2:	89 44 24 04          	mov    %eax,0x4(%esp)
801054c6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801054cd:	e8 b7 fc ff ff       	call   80105189 <argptr>
801054d2:	85 c0                	test   %eax,%eax
801054d4:	79 07                	jns    801054dd <sys_write+0x61>
    return -1;
801054d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054db:	eb 19                	jmp    801054f6 <sys_write+0x7a>
  return filewrite(f, p, n);
801054dd:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801054e0:	8b 55 ec             	mov    -0x14(%ebp),%edx
801054e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054e6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801054ea:	89 54 24 04          	mov    %edx,0x4(%esp)
801054ee:	89 04 24             	mov    %eax,(%esp)
801054f1:	e8 c4 bc ff ff       	call   801011ba <filewrite>
}
801054f6:	c9                   	leave  
801054f7:	c3                   	ret    

801054f8 <sys_close>:

int
sys_close(void)
{
801054f8:	55                   	push   %ebp
801054f9:	89 e5                	mov    %esp,%ebp
801054fb:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
801054fe:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105501:	89 44 24 08          	mov    %eax,0x8(%esp)
80105505:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105508:	89 44 24 04          	mov    %eax,0x4(%esp)
8010550c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105513:	e8 d0 fd ff ff       	call   801052e8 <argfd>
80105518:	85 c0                	test   %eax,%eax
8010551a:	79 07                	jns    80105523 <sys_close+0x2b>
    return -1;
8010551c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105521:	eb 24                	jmp    80105547 <sys_close+0x4f>
  proc->ofile[fd] = 0;
80105523:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105529:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010552c:	83 c2 08             	add    $0x8,%edx
8010552f:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105536:	00 
  fileclose(f);
80105537:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010553a:	89 04 24             	mov    %eax,(%esp)
8010553d:	e8 97 ba ff ff       	call   80100fd9 <fileclose>
  return 0;
80105542:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105547:	c9                   	leave  
80105548:	c3                   	ret    

80105549 <sys_fstat>:

int
sys_fstat(void)
{
80105549:	55                   	push   %ebp
8010554a:	89 e5                	mov    %esp,%ebp
8010554c:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010554f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105552:	89 44 24 08          	mov    %eax,0x8(%esp)
80105556:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010555d:	00 
8010555e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105565:	e8 7e fd ff ff       	call   801052e8 <argfd>
8010556a:	85 c0                	test   %eax,%eax
8010556c:	78 1f                	js     8010558d <sys_fstat+0x44>
8010556e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105571:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105578:	00 
80105579:	89 44 24 04          	mov    %eax,0x4(%esp)
8010557d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105584:	e8 00 fc ff ff       	call   80105189 <argptr>
80105589:	85 c0                	test   %eax,%eax
8010558b:	79 07                	jns    80105594 <sys_fstat+0x4b>
    return -1;
8010558d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105592:	eb 12                	jmp    801055a6 <sys_fstat+0x5d>
  return filestat(f, st);
80105594:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105597:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010559a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010559e:	89 04 24             	mov    %eax,(%esp)
801055a1:	e8 09 bb ff ff       	call   801010af <filestat>
}
801055a6:	c9                   	leave  
801055a7:	c3                   	ret    

801055a8 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801055a8:	55                   	push   %ebp
801055a9:	89 e5                	mov    %esp,%ebp
801055ab:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801055ae:	8d 45 d8             	lea    -0x28(%ebp),%eax
801055b1:	89 44 24 04          	mov    %eax,0x4(%esp)
801055b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801055bc:	e8 2a fc ff ff       	call   801051eb <argstr>
801055c1:	85 c0                	test   %eax,%eax
801055c3:	78 17                	js     801055dc <sys_link+0x34>
801055c5:	8d 45 dc             	lea    -0x24(%ebp),%eax
801055c8:	89 44 24 04          	mov    %eax,0x4(%esp)
801055cc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801055d3:	e8 13 fc ff ff       	call   801051eb <argstr>
801055d8:	85 c0                	test   %eax,%eax
801055da:	79 0a                	jns    801055e6 <sys_link+0x3e>
    return -1;
801055dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055e1:	e9 3c 01 00 00       	jmp    80105722 <sys_link+0x17a>
  if((ip = namei(old)) == 0)
801055e6:	8b 45 d8             	mov    -0x28(%ebp),%eax
801055e9:	89 04 24             	mov    %eax,(%esp)
801055ec:	e8 3a ce ff ff       	call   8010242b <namei>
801055f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801055f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801055f8:	75 0a                	jne    80105604 <sys_link+0x5c>
    return -1;
801055fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055ff:	e9 1e 01 00 00       	jmp    80105722 <sys_link+0x17a>

  begin_trans();
80105604:	e8 38 dc ff ff       	call   80103241 <begin_trans>

  ilock(ip);
80105609:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010560c:	89 04 24             	mov    %eax,(%esp)
8010560f:	e8 6f c2 ff ff       	call   80101883 <ilock>
  if(ip->type == T_DIR){
80105614:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105617:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010561b:	66 83 f8 01          	cmp    $0x1,%ax
8010561f:	75 1a                	jne    8010563b <sys_link+0x93>
    iunlockput(ip);
80105621:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105624:	89 04 24             	mov    %eax,(%esp)
80105627:	e8 de c4 ff ff       	call   80101b0a <iunlockput>
    commit_trans();
8010562c:	e8 59 dc ff ff       	call   8010328a <commit_trans>
    return -1;
80105631:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105636:	e9 e7 00 00 00       	jmp    80105722 <sys_link+0x17a>
  }

  ip->nlink++;
8010563b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010563e:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105642:	8d 50 01             	lea    0x1(%eax),%edx
80105645:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105648:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
8010564c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010564f:	89 04 24             	mov    %eax,(%esp)
80105652:	e8 6c c0 ff ff       	call   801016c3 <iupdate>
  iunlock(ip);
80105657:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010565a:	89 04 24             	mov    %eax,(%esp)
8010565d:	e8 72 c3 ff ff       	call   801019d4 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105662:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105665:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105668:	89 54 24 04          	mov    %edx,0x4(%esp)
8010566c:	89 04 24             	mov    %eax,(%esp)
8010566f:	e8 d9 cd ff ff       	call   8010244d <nameiparent>
80105674:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105677:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010567b:	74 68                	je     801056e5 <sys_link+0x13d>
    goto bad;
  ilock(dp);
8010567d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105680:	89 04 24             	mov    %eax,(%esp)
80105683:	e8 fb c1 ff ff       	call   80101883 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105688:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010568b:	8b 10                	mov    (%eax),%edx
8010568d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105690:	8b 00                	mov    (%eax),%eax
80105692:	39 c2                	cmp    %eax,%edx
80105694:	75 20                	jne    801056b6 <sys_link+0x10e>
80105696:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105699:	8b 40 04             	mov    0x4(%eax),%eax
8010569c:	89 44 24 08          	mov    %eax,0x8(%esp)
801056a0:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801056a3:	89 44 24 04          	mov    %eax,0x4(%esp)
801056a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056aa:	89 04 24             	mov    %eax,(%esp)
801056ad:	e8 b8 ca ff ff       	call   8010216a <dirlink>
801056b2:	85 c0                	test   %eax,%eax
801056b4:	79 0d                	jns    801056c3 <sys_link+0x11b>
    iunlockput(dp);
801056b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056b9:	89 04 24             	mov    %eax,(%esp)
801056bc:	e8 49 c4 ff ff       	call   80101b0a <iunlockput>
    goto bad;
801056c1:	eb 23                	jmp    801056e6 <sys_link+0x13e>
  }
  iunlockput(dp);
801056c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056c6:	89 04 24             	mov    %eax,(%esp)
801056c9:	e8 3c c4 ff ff       	call   80101b0a <iunlockput>
  iput(ip);
801056ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056d1:	89 04 24             	mov    %eax,(%esp)
801056d4:	e8 60 c3 ff ff       	call   80101a39 <iput>

  commit_trans();
801056d9:	e8 ac db ff ff       	call   8010328a <commit_trans>

  return 0;
801056de:	b8 00 00 00 00       	mov    $0x0,%eax
801056e3:	eb 3d                	jmp    80105722 <sys_link+0x17a>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
801056e5:	90                   	nop
  commit_trans();

  return 0;

bad:
  ilock(ip);
801056e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056e9:	89 04 24             	mov    %eax,(%esp)
801056ec:	e8 92 c1 ff ff       	call   80101883 <ilock>
  ip->nlink--;
801056f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056f4:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801056f8:	8d 50 ff             	lea    -0x1(%eax),%edx
801056fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056fe:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105702:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105705:	89 04 24             	mov    %eax,(%esp)
80105708:	e8 b6 bf ff ff       	call   801016c3 <iupdate>
  iunlockput(ip);
8010570d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105710:	89 04 24             	mov    %eax,(%esp)
80105713:	e8 f2 c3 ff ff       	call   80101b0a <iunlockput>
  commit_trans();
80105718:	e8 6d db ff ff       	call   8010328a <commit_trans>
  return -1;
8010571d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105722:	c9                   	leave  
80105723:	c3                   	ret    

80105724 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105724:	55                   	push   %ebp
80105725:	89 e5                	mov    %esp,%ebp
80105727:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010572a:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105731:	eb 4b                	jmp    8010577e <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105733:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105736:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105739:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105740:	00 
80105741:	89 54 24 08          	mov    %edx,0x8(%esp)
80105745:	89 44 24 04          	mov    %eax,0x4(%esp)
80105749:	8b 45 08             	mov    0x8(%ebp),%eax
8010574c:	89 04 24             	mov    %eax,(%esp)
8010574f:	e8 28 c6 ff ff       	call   80101d7c <readi>
80105754:	83 f8 10             	cmp    $0x10,%eax
80105757:	74 0c                	je     80105765 <isdirempty+0x41>
      panic("isdirempty: readi");
80105759:	c7 04 24 d3 85 10 80 	movl   $0x801085d3,(%esp)
80105760:	e8 e1 ad ff ff       	call   80100546 <panic>
    if(de.inum != 0)
80105765:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105769:	66 85 c0             	test   %ax,%ax
8010576c:	74 07                	je     80105775 <isdirempty+0x51>
      return 0;
8010576e:	b8 00 00 00 00       	mov    $0x0,%eax
80105773:	eb 1b                	jmp    80105790 <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105775:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105778:	83 c0 10             	add    $0x10,%eax
8010577b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010577e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105781:	8b 45 08             	mov    0x8(%ebp),%eax
80105784:	8b 40 18             	mov    0x18(%eax),%eax
80105787:	39 c2                	cmp    %eax,%edx
80105789:	72 a8                	jb     80105733 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
8010578b:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105790:	c9                   	leave  
80105791:	c3                   	ret    

80105792 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105792:	55                   	push   %ebp
80105793:	89 e5                	mov    %esp,%ebp
80105795:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105798:	8d 45 cc             	lea    -0x34(%ebp),%eax
8010579b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010579f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801057a6:	e8 40 fa ff ff       	call   801051eb <argstr>
801057ab:	85 c0                	test   %eax,%eax
801057ad:	79 0a                	jns    801057b9 <sys_unlink+0x27>
    return -1;
801057af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057b4:	e9 aa 01 00 00       	jmp    80105963 <sys_unlink+0x1d1>
  if((dp = nameiparent(path, name)) == 0)
801057b9:	8b 45 cc             	mov    -0x34(%ebp),%eax
801057bc:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801057bf:	89 54 24 04          	mov    %edx,0x4(%esp)
801057c3:	89 04 24             	mov    %eax,(%esp)
801057c6:	e8 82 cc ff ff       	call   8010244d <nameiparent>
801057cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
801057ce:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801057d2:	75 0a                	jne    801057de <sys_unlink+0x4c>
    return -1;
801057d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057d9:	e9 85 01 00 00       	jmp    80105963 <sys_unlink+0x1d1>

  begin_trans();
801057de:	e8 5e da ff ff       	call   80103241 <begin_trans>

  ilock(dp);
801057e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057e6:	89 04 24             	mov    %eax,(%esp)
801057e9:	e8 95 c0 ff ff       	call   80101883 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801057ee:	c7 44 24 04 e5 85 10 	movl   $0x801085e5,0x4(%esp)
801057f5:	80 
801057f6:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801057f9:	89 04 24             	mov    %eax,(%esp)
801057fc:	e8 7f c8 ff ff       	call   80102080 <namecmp>
80105801:	85 c0                	test   %eax,%eax
80105803:	0f 84 45 01 00 00    	je     8010594e <sys_unlink+0x1bc>
80105809:	c7 44 24 04 e7 85 10 	movl   $0x801085e7,0x4(%esp)
80105810:	80 
80105811:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105814:	89 04 24             	mov    %eax,(%esp)
80105817:	e8 64 c8 ff ff       	call   80102080 <namecmp>
8010581c:	85 c0                	test   %eax,%eax
8010581e:	0f 84 2a 01 00 00    	je     8010594e <sys_unlink+0x1bc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105824:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105827:	89 44 24 08          	mov    %eax,0x8(%esp)
8010582b:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010582e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105832:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105835:	89 04 24             	mov    %eax,(%esp)
80105838:	e8 65 c8 ff ff       	call   801020a2 <dirlookup>
8010583d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105840:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105844:	0f 84 03 01 00 00    	je     8010594d <sys_unlink+0x1bb>
    goto bad;
  ilock(ip);
8010584a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010584d:	89 04 24             	mov    %eax,(%esp)
80105850:	e8 2e c0 ff ff       	call   80101883 <ilock>

  if(ip->nlink < 1)
80105855:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105858:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010585c:	66 85 c0             	test   %ax,%ax
8010585f:	7f 0c                	jg     8010586d <sys_unlink+0xdb>
    panic("unlink: nlink < 1");
80105861:	c7 04 24 ea 85 10 80 	movl   $0x801085ea,(%esp)
80105868:	e8 d9 ac ff ff       	call   80100546 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010586d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105870:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105874:	66 83 f8 01          	cmp    $0x1,%ax
80105878:	75 1f                	jne    80105899 <sys_unlink+0x107>
8010587a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010587d:	89 04 24             	mov    %eax,(%esp)
80105880:	e8 9f fe ff ff       	call   80105724 <isdirempty>
80105885:	85 c0                	test   %eax,%eax
80105887:	75 10                	jne    80105899 <sys_unlink+0x107>
    iunlockput(ip);
80105889:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010588c:	89 04 24             	mov    %eax,(%esp)
8010588f:	e8 76 c2 ff ff       	call   80101b0a <iunlockput>
    goto bad;
80105894:	e9 b5 00 00 00       	jmp    8010594e <sys_unlink+0x1bc>
  }

  memset(&de, 0, sizeof(de));
80105899:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801058a0:	00 
801058a1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801058a8:	00 
801058a9:	8d 45 e0             	lea    -0x20(%ebp),%eax
801058ac:	89 04 24             	mov    %eax,(%esp)
801058af:	e8 46 f5 ff ff       	call   80104dfa <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801058b4:	8b 55 c8             	mov    -0x38(%ebp),%edx
801058b7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801058ba:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801058c1:	00 
801058c2:	89 54 24 08          	mov    %edx,0x8(%esp)
801058c6:	89 44 24 04          	mov    %eax,0x4(%esp)
801058ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058cd:	89 04 24             	mov    %eax,(%esp)
801058d0:	e8 13 c6 ff ff       	call   80101ee8 <writei>
801058d5:	83 f8 10             	cmp    $0x10,%eax
801058d8:	74 0c                	je     801058e6 <sys_unlink+0x154>
    panic("unlink: writei");
801058da:	c7 04 24 fc 85 10 80 	movl   $0x801085fc,(%esp)
801058e1:	e8 60 ac ff ff       	call   80100546 <panic>
  if(ip->type == T_DIR){
801058e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058e9:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801058ed:	66 83 f8 01          	cmp    $0x1,%ax
801058f1:	75 1c                	jne    8010590f <sys_unlink+0x17d>
    dp->nlink--;
801058f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058f6:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801058fa:	8d 50 ff             	lea    -0x1(%eax),%edx
801058fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105900:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105904:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105907:	89 04 24             	mov    %eax,(%esp)
8010590a:	e8 b4 bd ff ff       	call   801016c3 <iupdate>
  }
  iunlockput(dp);
8010590f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105912:	89 04 24             	mov    %eax,(%esp)
80105915:	e8 f0 c1 ff ff       	call   80101b0a <iunlockput>

  ip->nlink--;
8010591a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010591d:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105921:	8d 50 ff             	lea    -0x1(%eax),%edx
80105924:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105927:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
8010592b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010592e:	89 04 24             	mov    %eax,(%esp)
80105931:	e8 8d bd ff ff       	call   801016c3 <iupdate>
  iunlockput(ip);
80105936:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105939:	89 04 24             	mov    %eax,(%esp)
8010593c:	e8 c9 c1 ff ff       	call   80101b0a <iunlockput>

  commit_trans();
80105941:	e8 44 d9 ff ff       	call   8010328a <commit_trans>

  return 0;
80105946:	b8 00 00 00 00       	mov    $0x0,%eax
8010594b:	eb 16                	jmp    80105963 <sys_unlink+0x1d1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
8010594d:	90                   	nop
  commit_trans();

  return 0;

bad:
  iunlockput(dp);
8010594e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105951:	89 04 24             	mov    %eax,(%esp)
80105954:	e8 b1 c1 ff ff       	call   80101b0a <iunlockput>
  commit_trans();
80105959:	e8 2c d9 ff ff       	call   8010328a <commit_trans>
  return -1;
8010595e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105963:	c9                   	leave  
80105964:	c3                   	ret    

80105965 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105965:	55                   	push   %ebp
80105966:	89 e5                	mov    %esp,%ebp
80105968:	83 ec 48             	sub    $0x48,%esp
8010596b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010596e:	8b 55 10             	mov    0x10(%ebp),%edx
80105971:	8b 45 14             	mov    0x14(%ebp),%eax
80105974:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105978:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
8010597c:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105980:	8d 45 de             	lea    -0x22(%ebp),%eax
80105983:	89 44 24 04          	mov    %eax,0x4(%esp)
80105987:	8b 45 08             	mov    0x8(%ebp),%eax
8010598a:	89 04 24             	mov    %eax,(%esp)
8010598d:	e8 bb ca ff ff       	call   8010244d <nameiparent>
80105992:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105995:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105999:	75 0a                	jne    801059a5 <create+0x40>
    return 0;
8010599b:	b8 00 00 00 00       	mov    $0x0,%eax
801059a0:	e9 7e 01 00 00       	jmp    80105b23 <create+0x1be>
  ilock(dp);
801059a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059a8:	89 04 24             	mov    %eax,(%esp)
801059ab:	e8 d3 be ff ff       	call   80101883 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
801059b0:	8d 45 ec             	lea    -0x14(%ebp),%eax
801059b3:	89 44 24 08          	mov    %eax,0x8(%esp)
801059b7:	8d 45 de             	lea    -0x22(%ebp),%eax
801059ba:	89 44 24 04          	mov    %eax,0x4(%esp)
801059be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059c1:	89 04 24             	mov    %eax,(%esp)
801059c4:	e8 d9 c6 ff ff       	call   801020a2 <dirlookup>
801059c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801059cc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801059d0:	74 47                	je     80105a19 <create+0xb4>
    iunlockput(dp);
801059d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059d5:	89 04 24             	mov    %eax,(%esp)
801059d8:	e8 2d c1 ff ff       	call   80101b0a <iunlockput>
    ilock(ip);
801059dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059e0:	89 04 24             	mov    %eax,(%esp)
801059e3:	e8 9b be ff ff       	call   80101883 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
801059e8:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801059ed:	75 15                	jne    80105a04 <create+0x9f>
801059ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059f2:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801059f6:	66 83 f8 02          	cmp    $0x2,%ax
801059fa:	75 08                	jne    80105a04 <create+0x9f>
      return ip;
801059fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059ff:	e9 1f 01 00 00       	jmp    80105b23 <create+0x1be>
    iunlockput(ip);
80105a04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a07:	89 04 24             	mov    %eax,(%esp)
80105a0a:	e8 fb c0 ff ff       	call   80101b0a <iunlockput>
    return 0;
80105a0f:	b8 00 00 00 00       	mov    $0x0,%eax
80105a14:	e9 0a 01 00 00       	jmp    80105b23 <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105a19:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105a1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a20:	8b 00                	mov    (%eax),%eax
80105a22:	89 54 24 04          	mov    %edx,0x4(%esp)
80105a26:	89 04 24             	mov    %eax,(%esp)
80105a29:	e8 b8 bb ff ff       	call   801015e6 <ialloc>
80105a2e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105a31:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105a35:	75 0c                	jne    80105a43 <create+0xde>
    panic("create: ialloc");
80105a37:	c7 04 24 0b 86 10 80 	movl   $0x8010860b,(%esp)
80105a3e:	e8 03 ab ff ff       	call   80100546 <panic>

  ilock(ip);
80105a43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a46:	89 04 24             	mov    %eax,(%esp)
80105a49:	e8 35 be ff ff       	call   80101883 <ilock>
  ip->major = major;
80105a4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a51:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105a55:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80105a59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a5c:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105a60:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80105a64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a67:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80105a6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a70:	89 04 24             	mov    %eax,(%esp)
80105a73:	e8 4b bc ff ff       	call   801016c3 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80105a78:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105a7d:	75 6a                	jne    80105ae9 <create+0x184>
    dp->nlink++;  // for ".."
80105a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a82:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105a86:	8d 50 01             	lea    0x1(%eax),%edx
80105a89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a8c:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105a90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a93:	89 04 24             	mov    %eax,(%esp)
80105a96:	e8 28 bc ff ff       	call   801016c3 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105a9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a9e:	8b 40 04             	mov    0x4(%eax),%eax
80105aa1:	89 44 24 08          	mov    %eax,0x8(%esp)
80105aa5:	c7 44 24 04 e5 85 10 	movl   $0x801085e5,0x4(%esp)
80105aac:	80 
80105aad:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ab0:	89 04 24             	mov    %eax,(%esp)
80105ab3:	e8 b2 c6 ff ff       	call   8010216a <dirlink>
80105ab8:	85 c0                	test   %eax,%eax
80105aba:	78 21                	js     80105add <create+0x178>
80105abc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105abf:	8b 40 04             	mov    0x4(%eax),%eax
80105ac2:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ac6:	c7 44 24 04 e7 85 10 	movl   $0x801085e7,0x4(%esp)
80105acd:	80 
80105ace:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ad1:	89 04 24             	mov    %eax,(%esp)
80105ad4:	e8 91 c6 ff ff       	call   8010216a <dirlink>
80105ad9:	85 c0                	test   %eax,%eax
80105adb:	79 0c                	jns    80105ae9 <create+0x184>
      panic("create dots");
80105add:	c7 04 24 1a 86 10 80 	movl   $0x8010861a,(%esp)
80105ae4:	e8 5d aa ff ff       	call   80100546 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105ae9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aec:	8b 40 04             	mov    0x4(%eax),%eax
80105aef:	89 44 24 08          	mov    %eax,0x8(%esp)
80105af3:	8d 45 de             	lea    -0x22(%ebp),%eax
80105af6:	89 44 24 04          	mov    %eax,0x4(%esp)
80105afa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105afd:	89 04 24             	mov    %eax,(%esp)
80105b00:	e8 65 c6 ff ff       	call   8010216a <dirlink>
80105b05:	85 c0                	test   %eax,%eax
80105b07:	79 0c                	jns    80105b15 <create+0x1b0>
    panic("create: dirlink");
80105b09:	c7 04 24 26 86 10 80 	movl   $0x80108626,(%esp)
80105b10:	e8 31 aa ff ff       	call   80100546 <panic>

  iunlockput(dp);
80105b15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b18:	89 04 24             	mov    %eax,(%esp)
80105b1b:	e8 ea bf ff ff       	call   80101b0a <iunlockput>

  return ip;
80105b20:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105b23:	c9                   	leave  
80105b24:	c3                   	ret    

80105b25 <sys_open>:

int
sys_open(void)
{
80105b25:	55                   	push   %ebp
80105b26:	89 e5                	mov    %esp,%ebp
80105b28:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105b2b:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105b2e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b32:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105b39:	e8 ad f6 ff ff       	call   801051eb <argstr>
80105b3e:	85 c0                	test   %eax,%eax
80105b40:	78 17                	js     80105b59 <sys_open+0x34>
80105b42:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105b45:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b49:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105b50:	e8 05 f6 ff ff       	call   8010515a <argint>
80105b55:	85 c0                	test   %eax,%eax
80105b57:	79 0a                	jns    80105b63 <sys_open+0x3e>
    return -1;
80105b59:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b5e:	e9 46 01 00 00       	jmp    80105ca9 <sys_open+0x184>
  if(omode & O_CREATE){
80105b63:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b66:	25 00 02 00 00       	and    $0x200,%eax
80105b6b:	85 c0                	test   %eax,%eax
80105b6d:	74 40                	je     80105baf <sys_open+0x8a>
    begin_trans();
80105b6f:	e8 cd d6 ff ff       	call   80103241 <begin_trans>
    ip = create(path, T_FILE, 0, 0);
80105b74:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105b77:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105b7e:	00 
80105b7f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105b86:	00 
80105b87:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80105b8e:	00 
80105b8f:	89 04 24             	mov    %eax,(%esp)
80105b92:	e8 ce fd ff ff       	call   80105965 <create>
80105b97:	89 45 f4             	mov    %eax,-0xc(%ebp)
    commit_trans();
80105b9a:	e8 eb d6 ff ff       	call   8010328a <commit_trans>
    if(ip == 0)
80105b9f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ba3:	75 5c                	jne    80105c01 <sys_open+0xdc>
      return -1;
80105ba5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105baa:	e9 fa 00 00 00       	jmp    80105ca9 <sys_open+0x184>
  } else {
    if((ip = namei(path)) == 0)
80105baf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105bb2:	89 04 24             	mov    %eax,(%esp)
80105bb5:	e8 71 c8 ff ff       	call   8010242b <namei>
80105bba:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105bbd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105bc1:	75 0a                	jne    80105bcd <sys_open+0xa8>
      return -1;
80105bc3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bc8:	e9 dc 00 00 00       	jmp    80105ca9 <sys_open+0x184>
    ilock(ip);
80105bcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bd0:	89 04 24             	mov    %eax,(%esp)
80105bd3:	e8 ab bc ff ff       	call   80101883 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80105bd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bdb:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105bdf:	66 83 f8 01          	cmp    $0x1,%ax
80105be3:	75 1c                	jne    80105c01 <sys_open+0xdc>
80105be5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105be8:	85 c0                	test   %eax,%eax
80105bea:	74 15                	je     80105c01 <sys_open+0xdc>
      iunlockput(ip);
80105bec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bef:	89 04 24             	mov    %eax,(%esp)
80105bf2:	e8 13 bf ff ff       	call   80101b0a <iunlockput>
      return -1;
80105bf7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bfc:	e9 a8 00 00 00       	jmp    80105ca9 <sys_open+0x184>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105c01:	e8 2a b3 ff ff       	call   80100f30 <filealloc>
80105c06:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c09:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c0d:	74 14                	je     80105c23 <sys_open+0xfe>
80105c0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c12:	89 04 24             	mov    %eax,(%esp)
80105c15:	e8 43 f7 ff ff       	call   8010535d <fdalloc>
80105c1a:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105c1d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105c21:	79 23                	jns    80105c46 <sys_open+0x121>
    if(f)
80105c23:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c27:	74 0b                	je     80105c34 <sys_open+0x10f>
      fileclose(f);
80105c29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c2c:	89 04 24             	mov    %eax,(%esp)
80105c2f:	e8 a5 b3 ff ff       	call   80100fd9 <fileclose>
    iunlockput(ip);
80105c34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c37:	89 04 24             	mov    %eax,(%esp)
80105c3a:	e8 cb be ff ff       	call   80101b0a <iunlockput>
    return -1;
80105c3f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c44:	eb 63                	jmp    80105ca9 <sys_open+0x184>
  }
  iunlock(ip);
80105c46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c49:	89 04 24             	mov    %eax,(%esp)
80105c4c:	e8 83 bd ff ff       	call   801019d4 <iunlock>

  f->type = FD_INODE;
80105c51:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c54:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105c5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c5d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c60:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105c63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c66:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105c6d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c70:	83 e0 01             	and    $0x1,%eax
80105c73:	85 c0                	test   %eax,%eax
80105c75:	0f 94 c2             	sete   %dl
80105c78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c7b:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105c7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c81:	83 e0 01             	and    $0x1,%eax
80105c84:	84 c0                	test   %al,%al
80105c86:	75 0a                	jne    80105c92 <sys_open+0x16d>
80105c88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c8b:	83 e0 02             	and    $0x2,%eax
80105c8e:	85 c0                	test   %eax,%eax
80105c90:	74 07                	je     80105c99 <sys_open+0x174>
80105c92:	b8 01 00 00 00       	mov    $0x1,%eax
80105c97:	eb 05                	jmp    80105c9e <sys_open+0x179>
80105c99:	b8 00 00 00 00       	mov    $0x0,%eax
80105c9e:	89 c2                	mov    %eax,%edx
80105ca0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ca3:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105ca6:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105ca9:	c9                   	leave  
80105caa:	c3                   	ret    

80105cab <sys_mkdir>:

int
sys_mkdir(void)
{
80105cab:	55                   	push   %ebp
80105cac:	89 e5                	mov    %esp,%ebp
80105cae:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_trans();
80105cb1:	e8 8b d5 ff ff       	call   80103241 <begin_trans>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105cb6:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105cb9:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cbd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105cc4:	e8 22 f5 ff ff       	call   801051eb <argstr>
80105cc9:	85 c0                	test   %eax,%eax
80105ccb:	78 2c                	js     80105cf9 <sys_mkdir+0x4e>
80105ccd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cd0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105cd7:	00 
80105cd8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105cdf:	00 
80105ce0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80105ce7:	00 
80105ce8:	89 04 24             	mov    %eax,(%esp)
80105ceb:	e8 75 fc ff ff       	call   80105965 <create>
80105cf0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105cf3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105cf7:	75 0c                	jne    80105d05 <sys_mkdir+0x5a>
    commit_trans();
80105cf9:	e8 8c d5 ff ff       	call   8010328a <commit_trans>
    return -1;
80105cfe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d03:	eb 15                	jmp    80105d1a <sys_mkdir+0x6f>
  }
  iunlockput(ip);
80105d05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d08:	89 04 24             	mov    %eax,(%esp)
80105d0b:	e8 fa bd ff ff       	call   80101b0a <iunlockput>
  commit_trans();
80105d10:	e8 75 d5 ff ff       	call   8010328a <commit_trans>
  return 0;
80105d15:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d1a:	c9                   	leave  
80105d1b:	c3                   	ret    

80105d1c <sys_mknod>:

int
sys_mknod(void)
{
80105d1c:	55                   	push   %ebp
80105d1d:	89 e5                	mov    %esp,%ebp
80105d1f:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
80105d22:	e8 1a d5 ff ff       	call   80103241 <begin_trans>
  if((len=argstr(0, &path)) < 0 ||
80105d27:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105d2a:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d2e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105d35:	e8 b1 f4 ff ff       	call   801051eb <argstr>
80105d3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d3d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d41:	78 5e                	js     80105da1 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
80105d43:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105d46:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d4a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105d51:	e8 04 f4 ff ff       	call   8010515a <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
80105d56:	85 c0                	test   %eax,%eax
80105d58:	78 47                	js     80105da1 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80105d5a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105d5d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d61:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105d68:	e8 ed f3 ff ff       	call   8010515a <argint>
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80105d6d:	85 c0                	test   %eax,%eax
80105d6f:	78 30                	js     80105da1 <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80105d71:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105d74:	0f bf c8             	movswl %ax,%ecx
80105d77:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105d7a:	0f bf d0             	movswl %ax,%edx
80105d7d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80105d80:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80105d84:	89 54 24 08          	mov    %edx,0x8(%esp)
80105d88:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80105d8f:	00 
80105d90:	89 04 24             	mov    %eax,(%esp)
80105d93:	e8 cd fb ff ff       	call   80105965 <create>
80105d98:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d9b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d9f:	75 0c                	jne    80105dad <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    commit_trans();
80105da1:	e8 e4 d4 ff ff       	call   8010328a <commit_trans>
    return -1;
80105da6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dab:	eb 15                	jmp    80105dc2 <sys_mknod+0xa6>
  }
  iunlockput(ip);
80105dad:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105db0:	89 04 24             	mov    %eax,(%esp)
80105db3:	e8 52 bd ff ff       	call   80101b0a <iunlockput>
  commit_trans();
80105db8:	e8 cd d4 ff ff       	call   8010328a <commit_trans>
  return 0;
80105dbd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105dc2:	c9                   	leave  
80105dc3:	c3                   	ret    

80105dc4 <sys_chdir>:

int
sys_chdir(void)
{
80105dc4:	55                   	push   %ebp
80105dc5:	89 e5                	mov    %esp,%ebp
80105dc7:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0)
80105dca:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105dcd:	89 44 24 04          	mov    %eax,0x4(%esp)
80105dd1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105dd8:	e8 0e f4 ff ff       	call   801051eb <argstr>
80105ddd:	85 c0                	test   %eax,%eax
80105ddf:	78 14                	js     80105df5 <sys_chdir+0x31>
80105de1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105de4:	89 04 24             	mov    %eax,(%esp)
80105de7:	e8 3f c6 ff ff       	call   8010242b <namei>
80105dec:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105def:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105df3:	75 07                	jne    80105dfc <sys_chdir+0x38>
    return -1;
80105df5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dfa:	eb 57                	jmp    80105e53 <sys_chdir+0x8f>
  ilock(ip);
80105dfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dff:	89 04 24             	mov    %eax,(%esp)
80105e02:	e8 7c ba ff ff       	call   80101883 <ilock>
  if(ip->type != T_DIR){
80105e07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e0a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105e0e:	66 83 f8 01          	cmp    $0x1,%ax
80105e12:	74 12                	je     80105e26 <sys_chdir+0x62>
    iunlockput(ip);
80105e14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e17:	89 04 24             	mov    %eax,(%esp)
80105e1a:	e8 eb bc ff ff       	call   80101b0a <iunlockput>
    return -1;
80105e1f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e24:	eb 2d                	jmp    80105e53 <sys_chdir+0x8f>
  }
  iunlock(ip);
80105e26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e29:	89 04 24             	mov    %eax,(%esp)
80105e2c:	e8 a3 bb ff ff       	call   801019d4 <iunlock>
  iput(proc->cwd);
80105e31:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105e37:	8b 40 68             	mov    0x68(%eax),%eax
80105e3a:	89 04 24             	mov    %eax,(%esp)
80105e3d:	e8 f7 bb ff ff       	call   80101a39 <iput>
  proc->cwd = ip;
80105e42:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105e48:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105e4b:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105e4e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e53:	c9                   	leave  
80105e54:	c3                   	ret    

80105e55 <sys_exec>:

int
sys_exec(void)
{
80105e55:	55                   	push   %ebp
80105e56:	89 e5                	mov    %esp,%ebp
80105e58:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105e5e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e61:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e65:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105e6c:	e8 7a f3 ff ff       	call   801051eb <argstr>
80105e71:	85 c0                	test   %eax,%eax
80105e73:	78 1a                	js     80105e8f <sys_exec+0x3a>
80105e75:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105e7b:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e7f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105e86:	e8 cf f2 ff ff       	call   8010515a <argint>
80105e8b:	85 c0                	test   %eax,%eax
80105e8d:	79 0a                	jns    80105e99 <sys_exec+0x44>
    return -1;
80105e8f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e94:	e9 cd 00 00 00       	jmp    80105f66 <sys_exec+0x111>
  }
  memset(argv, 0, sizeof(argv));
80105e99:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80105ea0:	00 
80105ea1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105ea8:	00 
80105ea9:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105eaf:	89 04 24             	mov    %eax,(%esp)
80105eb2:	e8 43 ef ff ff       	call   80104dfa <memset>
  for(i=0;; i++){
80105eb7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105ebe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ec1:	83 f8 1f             	cmp    $0x1f,%eax
80105ec4:	76 0a                	jbe    80105ed0 <sys_exec+0x7b>
      return -1;
80105ec6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ecb:	e9 96 00 00 00       	jmp    80105f66 <sys_exec+0x111>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105ed0:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105ed6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ed9:	c1 e2 02             	shl    $0x2,%edx
80105edc:	89 d1                	mov    %edx,%ecx
80105ede:	8b 95 6c ff ff ff    	mov    -0x94(%ebp),%edx
80105ee4:	8d 14 11             	lea    (%ecx,%edx,1),%edx
80105ee7:	89 44 24 04          	mov    %eax,0x4(%esp)
80105eeb:	89 14 24             	mov    %edx,(%esp)
80105eee:	e8 c9 f1 ff ff       	call   801050bc <fetchint>
80105ef3:	85 c0                	test   %eax,%eax
80105ef5:	79 07                	jns    80105efe <sys_exec+0xa9>
      return -1;
80105ef7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105efc:	eb 68                	jmp    80105f66 <sys_exec+0x111>
    if(uarg == 0){
80105efe:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105f04:	85 c0                	test   %eax,%eax
80105f06:	75 25                	jne    80105f2d <sys_exec+0xd8>
      argv[i] = 0;
80105f08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f0b:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105f12:	00 00 00 00 
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105f16:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f19:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105f1f:	89 54 24 04          	mov    %edx,0x4(%esp)
80105f23:	89 04 24             	mov    %eax,(%esp)
80105f26:	e8 e1 ab ff ff       	call   80100b0c <exec>
80105f2b:	eb 39                	jmp    80105f66 <sys_exec+0x111>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80105f2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f30:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105f37:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105f3d:	8d 14 10             	lea    (%eax,%edx,1),%edx
80105f40:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105f46:	89 54 24 04          	mov    %edx,0x4(%esp)
80105f4a:	89 04 24             	mov    %eax,(%esp)
80105f4d:	e8 a4 f1 ff ff       	call   801050f6 <fetchstr>
80105f52:	85 c0                	test   %eax,%eax
80105f54:	79 07                	jns    80105f5d <sys_exec+0x108>
      return -1;
80105f56:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f5b:	eb 09                	jmp    80105f66 <sys_exec+0x111>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80105f5d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80105f61:	e9 58 ff ff ff       	jmp    80105ebe <sys_exec+0x69>
  return exec(path, argv);
}
80105f66:	c9                   	leave  
80105f67:	c3                   	ret    

80105f68 <sys_pipe>:

int
sys_pipe(void)
{
80105f68:	55                   	push   %ebp
80105f69:	89 e5                	mov    %esp,%ebp
80105f6b:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105f6e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105f71:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80105f78:	00 
80105f79:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f7d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105f84:	e8 00 f2 ff ff       	call   80105189 <argptr>
80105f89:	85 c0                	test   %eax,%eax
80105f8b:	79 0a                	jns    80105f97 <sys_pipe+0x2f>
    return -1;
80105f8d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f92:	e9 9b 00 00 00       	jmp    80106032 <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
80105f97:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105f9a:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f9e:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105fa1:	89 04 24             	mov    %eax,(%esp)
80105fa4:	e8 b7 dc ff ff       	call   80103c60 <pipealloc>
80105fa9:	85 c0                	test   %eax,%eax
80105fab:	79 07                	jns    80105fb4 <sys_pipe+0x4c>
    return -1;
80105fad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fb2:	eb 7e                	jmp    80106032 <sys_pipe+0xca>
  fd0 = -1;
80105fb4:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105fbb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105fbe:	89 04 24             	mov    %eax,(%esp)
80105fc1:	e8 97 f3 ff ff       	call   8010535d <fdalloc>
80105fc6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105fc9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fcd:	78 14                	js     80105fe3 <sys_pipe+0x7b>
80105fcf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fd2:	89 04 24             	mov    %eax,(%esp)
80105fd5:	e8 83 f3 ff ff       	call   8010535d <fdalloc>
80105fda:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105fdd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105fe1:	79 37                	jns    8010601a <sys_pipe+0xb2>
    if(fd0 >= 0)
80105fe3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fe7:	78 14                	js     80105ffd <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
80105fe9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105fef:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ff2:	83 c2 08             	add    $0x8,%edx
80105ff5:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105ffc:	00 
    fileclose(rf);
80105ffd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106000:	89 04 24             	mov    %eax,(%esp)
80106003:	e8 d1 af ff ff       	call   80100fd9 <fileclose>
    fileclose(wf);
80106008:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010600b:	89 04 24             	mov    %eax,(%esp)
8010600e:	e8 c6 af ff ff       	call   80100fd9 <fileclose>
    return -1;
80106013:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106018:	eb 18                	jmp    80106032 <sys_pipe+0xca>
  }
  fd[0] = fd0;
8010601a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010601d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106020:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106022:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106025:	8d 50 04             	lea    0x4(%eax),%edx
80106028:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010602b:	89 02                	mov    %eax,(%edx)
  return 0;
8010602d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106032:	c9                   	leave  
80106033:	c3                   	ret    

80106034 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106034:	55                   	push   %ebp
80106035:	89 e5                	mov    %esp,%ebp
80106037:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010603a:	e8 14 e3 ff ff       	call   80104353 <fork>
}
8010603f:	c9                   	leave  
80106040:	c3                   	ret    

80106041 <sys_exit>:

int
sys_exit(void)
{
80106041:	55                   	push   %ebp
80106042:	89 e5                	mov    %esp,%ebp
80106044:	83 ec 08             	sub    $0x8,%esp
  exit();
80106047:	e8 73 e4 ff ff       	call   801044bf <exit>
  return 0;  // not reached
8010604c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106051:	c9                   	leave  
80106052:	c3                   	ret    

80106053 <sys_wait>:

int
sys_wait(void)
{
80106053:	55                   	push   %ebp
80106054:	89 e5                	mov    %esp,%ebp
80106056:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106059:	e8 7d e5 ff ff       	call   801045db <wait>
}
8010605e:	c9                   	leave  
8010605f:	c3                   	ret    

80106060 <sys_kill>:

int
sys_kill(void)
{
80106060:	55                   	push   %ebp
80106061:	89 e5                	mov    %esp,%ebp
80106063:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106066:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106069:	89 44 24 04          	mov    %eax,0x4(%esp)
8010606d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106074:	e8 e1 f0 ff ff       	call   8010515a <argint>
80106079:	85 c0                	test   %eax,%eax
8010607b:	79 07                	jns    80106084 <sys_kill+0x24>
    return -1;
8010607d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106082:	eb 0b                	jmp    8010608f <sys_kill+0x2f>
  return kill(pid);
80106084:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106087:	89 04 24             	mov    %eax,(%esp)
8010608a:	e8 31 e9 ff ff       	call   801049c0 <kill>
}
8010608f:	c9                   	leave  
80106090:	c3                   	ret    

80106091 <sys_getpid>:

int
sys_getpid(void)
{
80106091:	55                   	push   %ebp
80106092:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80106094:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010609a:	8b 40 10             	mov    0x10(%eax),%eax
}
8010609d:	5d                   	pop    %ebp
8010609e:	c3                   	ret    

8010609f <sys_sbrk>:

int
sys_sbrk(void)
{
8010609f:	55                   	push   %ebp
801060a0:	89 e5                	mov    %esp,%ebp
801060a2:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801060a5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801060a8:	89 44 24 04          	mov    %eax,0x4(%esp)
801060ac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801060b3:	e8 a2 f0 ff ff       	call   8010515a <argint>
801060b8:	85 c0                	test   %eax,%eax
801060ba:	79 07                	jns    801060c3 <sys_sbrk+0x24>
    return -1;
801060bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060c1:	eb 24                	jmp    801060e7 <sys_sbrk+0x48>
  addr = proc->sz;
801060c3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060c9:	8b 00                	mov    (%eax),%eax
801060cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801060ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060d1:	89 04 24             	mov    %eax,(%esp)
801060d4:	e8 d5 e1 ff ff       	call   801042ae <growproc>
801060d9:	85 c0                	test   %eax,%eax
801060db:	79 07                	jns    801060e4 <sys_sbrk+0x45>
    return -1;
801060dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060e2:	eb 03                	jmp    801060e7 <sys_sbrk+0x48>
  return addr;
801060e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801060e7:	c9                   	leave  
801060e8:	c3                   	ret    

801060e9 <sys_sleep>:

int
sys_sleep(void)
{
801060e9:	55                   	push   %ebp
801060ea:	89 e5                	mov    %esp,%ebp
801060ec:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
801060ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
801060f2:	89 44 24 04          	mov    %eax,0x4(%esp)
801060f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801060fd:	e8 58 f0 ff ff       	call   8010515a <argint>
80106102:	85 c0                	test   %eax,%eax
80106104:	79 07                	jns    8010610d <sys_sleep+0x24>
    return -1;
80106106:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010610b:	eb 6c                	jmp    80106179 <sys_sleep+0x90>
  acquire(&tickslock);
8010610d:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
80106114:	e8 92 ea ff ff       	call   80104bab <acquire>
  ticks0 = ticks;
80106119:	a1 c0 29 11 80       	mov    0x801129c0,%eax
8010611e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106121:	eb 34                	jmp    80106157 <sys_sleep+0x6e>
    if(proc->killed){
80106123:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106129:	8b 40 24             	mov    0x24(%eax),%eax
8010612c:	85 c0                	test   %eax,%eax
8010612e:	74 13                	je     80106143 <sys_sleep+0x5a>
      release(&tickslock);
80106130:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
80106137:	e8 d1 ea ff ff       	call   80104c0d <release>
      return -1;
8010613c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106141:	eb 36                	jmp    80106179 <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
80106143:	c7 44 24 04 80 21 11 	movl   $0x80112180,0x4(%esp)
8010614a:	80 
8010614b:	c7 04 24 c0 29 11 80 	movl   $0x801129c0,(%esp)
80106152:	e8 58 e7 ff ff       	call   801048af <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106157:	a1 c0 29 11 80       	mov    0x801129c0,%eax
8010615c:	89 c2                	mov    %eax,%edx
8010615e:	2b 55 f4             	sub    -0xc(%ebp),%edx
80106161:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106164:	39 c2                	cmp    %eax,%edx
80106166:	72 bb                	jb     80106123 <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106168:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
8010616f:	e8 99 ea ff ff       	call   80104c0d <release>
  return 0;
80106174:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106179:	c9                   	leave  
8010617a:	c3                   	ret    

8010617b <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010617b:	55                   	push   %ebp
8010617c:	89 e5                	mov    %esp,%ebp
8010617e:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
80106181:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
80106188:	e8 1e ea ff ff       	call   80104bab <acquire>
  xticks = ticks;
8010618d:	a1 c0 29 11 80       	mov    0x801129c0,%eax
80106192:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106195:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
8010619c:	e8 6c ea ff ff       	call   80104c0d <release>
  return xticks;
801061a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801061a4:	c9                   	leave  
801061a5:	c3                   	ret    

801061a6 <sys_procstat>:

int
sys_procstat(void)
{
801061a6:	55                   	push   %ebp
801061a7:	89 e5                	mov    %esp,%ebp
801061a9:	83 ec 08             	sub    $0x8,%esp
	procdump();
801061ac:	e8 94 e8 ff ff       	call   80104a45 <procdump>
	return(0);
801061b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061b6:	c9                   	leave  
801061b7:	c3                   	ret    

801061b8 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801061b8:	55                   	push   %ebp
801061b9:	89 e5                	mov    %esp,%ebp
801061bb:	83 ec 08             	sub    $0x8,%esp
801061be:	8b 55 08             	mov    0x8(%ebp),%edx
801061c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801061c4:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801061c8:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801061cb:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801061cf:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801061d3:	ee                   	out    %al,(%dx)
}
801061d4:	c9                   	leave  
801061d5:	c3                   	ret    

801061d6 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
801061d6:	55                   	push   %ebp
801061d7:	89 e5                	mov    %esp,%ebp
801061d9:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
801061dc:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
801061e3:	00 
801061e4:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
801061eb:	e8 c8 ff ff ff       	call   801061b8 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
801061f0:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
801061f7:	00 
801061f8:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
801061ff:	e8 b4 ff ff ff       	call   801061b8 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80106204:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
8010620b:	00 
8010620c:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106213:	e8 a0 ff ff ff       	call   801061b8 <outb>
  picenable(IRQ_TIMER);
80106218:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010621f:	e8 c5 d8 ff ff       	call   80103ae9 <picenable>
}
80106224:	c9                   	leave  
80106225:	c3                   	ret    
	...

80106228 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106228:	1e                   	push   %ds
  pushl %es
80106229:	06                   	push   %es
  pushl %fs
8010622a:	0f a0                	push   %fs
  pushl %gs
8010622c:	0f a8                	push   %gs
  pushal
8010622e:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
8010622f:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106233:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106235:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106237:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
8010623b:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
8010623d:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
8010623f:	54                   	push   %esp
  call trap
80106240:	e8 de 01 00 00       	call   80106423 <trap>
  addl $4, %esp
80106245:	83 c4 04             	add    $0x4,%esp

80106248 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106248:	61                   	popa   
  popl %gs
80106249:	0f a9                	pop    %gs
  popl %fs
8010624b:	0f a1                	pop    %fs
  popl %es
8010624d:	07                   	pop    %es
  popl %ds
8010624e:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010624f:	83 c4 08             	add    $0x8,%esp
  iret
80106252:	cf                   	iret   
	...

80106254 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106254:	55                   	push   %ebp
80106255:	89 e5                	mov    %esp,%ebp
80106257:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010625a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010625d:	83 e8 01             	sub    $0x1,%eax
80106260:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106264:	8b 45 08             	mov    0x8(%ebp),%eax
80106267:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010626b:	8b 45 08             	mov    0x8(%ebp),%eax
8010626e:	c1 e8 10             	shr    $0x10,%eax
80106271:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106275:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106278:	0f 01 18             	lidtl  (%eax)
}
8010627b:	c9                   	leave  
8010627c:	c3                   	ret    

8010627d <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
8010627d:	55                   	push   %ebp
8010627e:	89 e5                	mov    %esp,%ebp
80106280:	53                   	push   %ebx
80106281:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106284:	0f 20 d3             	mov    %cr2,%ebx
80106287:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return val;
8010628a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010628d:	83 c4 10             	add    $0x10,%esp
80106290:	5b                   	pop    %ebx
80106291:	5d                   	pop    %ebp
80106292:	c3                   	ret    

80106293 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106293:	55                   	push   %ebp
80106294:	89 e5                	mov    %esp,%ebp
80106296:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80106299:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801062a0:	e9 c3 00 00 00       	jmp    80106368 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801062a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062a8:	8b 04 85 9c b0 10 80 	mov    -0x7fef4f64(,%eax,4),%eax
801062af:	89 c2                	mov    %eax,%edx
801062b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062b4:	66 89 14 c5 c0 21 11 	mov    %dx,-0x7feede40(,%eax,8)
801062bb:	80 
801062bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062bf:	66 c7 04 c5 c2 21 11 	movw   $0x8,-0x7feede3e(,%eax,8)
801062c6:	80 08 00 
801062c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062cc:	0f b6 14 c5 c4 21 11 	movzbl -0x7feede3c(,%eax,8),%edx
801062d3:	80 
801062d4:	83 e2 e0             	and    $0xffffffe0,%edx
801062d7:	88 14 c5 c4 21 11 80 	mov    %dl,-0x7feede3c(,%eax,8)
801062de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062e1:	0f b6 14 c5 c4 21 11 	movzbl -0x7feede3c(,%eax,8),%edx
801062e8:	80 
801062e9:	83 e2 1f             	and    $0x1f,%edx
801062ec:	88 14 c5 c4 21 11 80 	mov    %dl,-0x7feede3c(,%eax,8)
801062f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062f6:	0f b6 14 c5 c5 21 11 	movzbl -0x7feede3b(,%eax,8),%edx
801062fd:	80 
801062fe:	83 e2 f0             	and    $0xfffffff0,%edx
80106301:	83 ca 0e             	or     $0xe,%edx
80106304:	88 14 c5 c5 21 11 80 	mov    %dl,-0x7feede3b(,%eax,8)
8010630b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010630e:	0f b6 14 c5 c5 21 11 	movzbl -0x7feede3b(,%eax,8),%edx
80106315:	80 
80106316:	83 e2 ef             	and    $0xffffffef,%edx
80106319:	88 14 c5 c5 21 11 80 	mov    %dl,-0x7feede3b(,%eax,8)
80106320:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106323:	0f b6 14 c5 c5 21 11 	movzbl -0x7feede3b(,%eax,8),%edx
8010632a:	80 
8010632b:	83 e2 9f             	and    $0xffffff9f,%edx
8010632e:	88 14 c5 c5 21 11 80 	mov    %dl,-0x7feede3b(,%eax,8)
80106335:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106338:	0f b6 14 c5 c5 21 11 	movzbl -0x7feede3b(,%eax,8),%edx
8010633f:	80 
80106340:	83 ca 80             	or     $0xffffff80,%edx
80106343:	88 14 c5 c5 21 11 80 	mov    %dl,-0x7feede3b(,%eax,8)
8010634a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010634d:	8b 04 85 9c b0 10 80 	mov    -0x7fef4f64(,%eax,4),%eax
80106354:	c1 e8 10             	shr    $0x10,%eax
80106357:	89 c2                	mov    %eax,%edx
80106359:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010635c:	66 89 14 c5 c6 21 11 	mov    %dx,-0x7feede3a(,%eax,8)
80106363:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106364:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106368:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010636f:	0f 8e 30 ff ff ff    	jle    801062a5 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106375:	a1 9c b1 10 80       	mov    0x8010b19c,%eax
8010637a:	66 a3 c0 23 11 80    	mov    %ax,0x801123c0
80106380:	66 c7 05 c2 23 11 80 	movw   $0x8,0x801123c2
80106387:	08 00 
80106389:	0f b6 05 c4 23 11 80 	movzbl 0x801123c4,%eax
80106390:	83 e0 e0             	and    $0xffffffe0,%eax
80106393:	a2 c4 23 11 80       	mov    %al,0x801123c4
80106398:	0f b6 05 c4 23 11 80 	movzbl 0x801123c4,%eax
8010639f:	83 e0 1f             	and    $0x1f,%eax
801063a2:	a2 c4 23 11 80       	mov    %al,0x801123c4
801063a7:	0f b6 05 c5 23 11 80 	movzbl 0x801123c5,%eax
801063ae:	83 c8 0f             	or     $0xf,%eax
801063b1:	a2 c5 23 11 80       	mov    %al,0x801123c5
801063b6:	0f b6 05 c5 23 11 80 	movzbl 0x801123c5,%eax
801063bd:	83 e0 ef             	and    $0xffffffef,%eax
801063c0:	a2 c5 23 11 80       	mov    %al,0x801123c5
801063c5:	0f b6 05 c5 23 11 80 	movzbl 0x801123c5,%eax
801063cc:	83 c8 60             	or     $0x60,%eax
801063cf:	a2 c5 23 11 80       	mov    %al,0x801123c5
801063d4:	0f b6 05 c5 23 11 80 	movzbl 0x801123c5,%eax
801063db:	83 c8 80             	or     $0xffffff80,%eax
801063de:	a2 c5 23 11 80       	mov    %al,0x801123c5
801063e3:	a1 9c b1 10 80       	mov    0x8010b19c,%eax
801063e8:	c1 e8 10             	shr    $0x10,%eax
801063eb:	66 a3 c6 23 11 80    	mov    %ax,0x801123c6
  
  initlock(&tickslock, "time");
801063f1:	c7 44 24 04 38 86 10 	movl   $0x80108638,0x4(%esp)
801063f8:	80 
801063f9:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
80106400:	e8 85 e7 ff ff       	call   80104b8a <initlock>
}
80106405:	c9                   	leave  
80106406:	c3                   	ret    

80106407 <idtinit>:

void
idtinit(void)
{
80106407:	55                   	push   %ebp
80106408:	89 e5                	mov    %esp,%ebp
8010640a:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
8010640d:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
80106414:	00 
80106415:	c7 04 24 c0 21 11 80 	movl   $0x801121c0,(%esp)
8010641c:	e8 33 fe ff ff       	call   80106254 <lidt>
}
80106421:	c9                   	leave  
80106422:	c3                   	ret    

80106423 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106423:	55                   	push   %ebp
80106424:	89 e5                	mov    %esp,%ebp
80106426:	57                   	push   %edi
80106427:	56                   	push   %esi
80106428:	53                   	push   %ebx
80106429:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
8010642c:	8b 45 08             	mov    0x8(%ebp),%eax
8010642f:	8b 40 30             	mov    0x30(%eax),%eax
80106432:	83 f8 40             	cmp    $0x40,%eax
80106435:	75 3e                	jne    80106475 <trap+0x52>
    if(proc->killed)
80106437:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010643d:	8b 40 24             	mov    0x24(%eax),%eax
80106440:	85 c0                	test   %eax,%eax
80106442:	74 05                	je     80106449 <trap+0x26>
      exit();
80106444:	e8 76 e0 ff ff       	call   801044bf <exit>
    proc->tf = tf;
80106449:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010644f:	8b 55 08             	mov    0x8(%ebp),%edx
80106452:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106455:	e8 c8 ed ff ff       	call   80105222 <syscall>
    if(proc->killed)
8010645a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106460:	8b 40 24             	mov    0x24(%eax),%eax
80106463:	85 c0                	test   %eax,%eax
80106465:	0f 84 7f 02 00 00    	je     801066ea <trap+0x2c7>
      exit();
8010646b:	e8 4f e0 ff ff       	call   801044bf <exit>
    return;
80106470:	e9 76 02 00 00       	jmp    801066eb <trap+0x2c8>
  }

  switch(tf->trapno){
80106475:	8b 45 08             	mov    0x8(%ebp),%eax
80106478:	8b 40 30             	mov    0x30(%eax),%eax
8010647b:	83 e8 20             	sub    $0x20,%eax
8010647e:	83 f8 1f             	cmp    $0x1f,%eax
80106481:	0f 87 bc 00 00 00    	ja     80106543 <trap+0x120>
80106487:	8b 04 85 0c 87 10 80 	mov    -0x7fef78f4(,%eax,4),%eax
8010648e:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80106490:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106496:	0f b6 00             	movzbl (%eax),%eax
80106499:	84 c0                	test   %al,%al
8010649b:	75 31                	jne    801064ce <trap+0xab>
      acquire(&tickslock);
8010649d:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
801064a4:	e8 02 e7 ff ff       	call   80104bab <acquire>
      ticks++;
801064a9:	a1 c0 29 11 80       	mov    0x801129c0,%eax
801064ae:	83 c0 01             	add    $0x1,%eax
801064b1:	a3 c0 29 11 80       	mov    %eax,0x801129c0
      wakeup(&ticks);
801064b6:	c7 04 24 c0 29 11 80 	movl   $0x801129c0,(%esp)
801064bd:	e8 d3 e4 ff ff       	call   80104995 <wakeup>
      release(&tickslock);
801064c2:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
801064c9:	e8 3f e7 ff ff       	call   80104c0d <release>
    }
    lapiceoi();
801064ce:	e8 3b ca ff ff       	call   80102f0e <lapiceoi>
    break;
801064d3:	e9 41 01 00 00       	jmp    80106619 <trap+0x1f6>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801064d8:	e8 34 c2 ff ff       	call   80102711 <ideintr>
    lapiceoi();
801064dd:	e8 2c ca ff ff       	call   80102f0e <lapiceoi>
    break;
801064e2:	e9 32 01 00 00       	jmp    80106619 <trap+0x1f6>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801064e7:	e8 ff c7 ff ff       	call   80102ceb <kbdintr>
    lapiceoi();
801064ec:	e8 1d ca ff ff       	call   80102f0e <lapiceoi>
    break;
801064f1:	e9 23 01 00 00       	jmp    80106619 <trap+0x1f6>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801064f6:	e8 f5 03 00 00       	call   801068f0 <uartintr>
    lapiceoi();
801064fb:	e8 0e ca ff ff       	call   80102f0e <lapiceoi>
    break;
80106500:	e9 14 01 00 00       	jmp    80106619 <trap+0x1f6>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
            cpu->id, tf->cs, tf->eip);
80106505:	8b 45 08             	mov    0x8(%ebp),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106508:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
8010650b:	8b 45 08             	mov    0x8(%ebp),%eax
8010650e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106512:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106515:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010651b:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010651e:	0f b6 c0             	movzbl %al,%eax
80106521:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106525:	89 54 24 08          	mov    %edx,0x8(%esp)
80106529:	89 44 24 04          	mov    %eax,0x4(%esp)
8010652d:	c7 04 24 40 86 10 80 	movl   $0x80108640,(%esp)
80106534:	e8 6c 9e ff ff       	call   801003a5 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106539:	e8 d0 c9 ff ff       	call   80102f0e <lapiceoi>
    break;
8010653e:	e9 d6 00 00 00       	jmp    80106619 <trap+0x1f6>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106543:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106549:	85 c0                	test   %eax,%eax
8010654b:	74 11                	je     8010655e <trap+0x13b>
8010654d:	8b 45 08             	mov    0x8(%ebp),%eax
80106550:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106554:	0f b7 c0             	movzwl %ax,%eax
80106557:	83 e0 03             	and    $0x3,%eax
8010655a:	85 c0                	test   %eax,%eax
8010655c:	75 46                	jne    801065a4 <trap+0x181>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010655e:	e8 1a fd ff ff       	call   8010627d <rcr2>
              tf->trapno, cpu->id, tf->eip, rcr2());
80106563:	8b 55 08             	mov    0x8(%ebp),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106566:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106569:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106570:	0f b6 12             	movzbl (%edx),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106573:	0f b6 ca             	movzbl %dl,%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106576:	8b 55 08             	mov    0x8(%ebp),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106579:	8b 52 30             	mov    0x30(%edx),%edx
8010657c:	89 44 24 10          	mov    %eax,0x10(%esp)
80106580:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80106584:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106588:	89 54 24 04          	mov    %edx,0x4(%esp)
8010658c:	c7 04 24 64 86 10 80 	movl   $0x80108664,(%esp)
80106593:	e8 0d 9e ff ff       	call   801003a5 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80106598:	c7 04 24 96 86 10 80 	movl   $0x80108696,(%esp)
8010659f:	e8 a2 9f ff ff       	call   80100546 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801065a4:	e8 d4 fc ff ff       	call   8010627d <rcr2>
801065a9:	89 c2                	mov    %eax,%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801065ab:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801065ae:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801065b1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801065b7:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801065ba:	0f b6 f0             	movzbl %al,%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801065bd:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801065c0:	8b 58 34             	mov    0x34(%eax),%ebx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801065c3:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801065c6:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801065c9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801065cf:	83 c0 6c             	add    $0x6c,%eax
801065d2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801065d5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801065db:	8b 40 10             	mov    0x10(%eax),%eax
801065de:	89 54 24 1c          	mov    %edx,0x1c(%esp)
801065e2:	89 7c 24 18          	mov    %edi,0x18(%esp)
801065e6:	89 74 24 14          	mov    %esi,0x14(%esp)
801065ea:	89 5c 24 10          	mov    %ebx,0x10(%esp)
801065ee:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801065f2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801065f5:	89 54 24 08          	mov    %edx,0x8(%esp)
801065f9:	89 44 24 04          	mov    %eax,0x4(%esp)
801065fd:	c7 04 24 9c 86 10 80 	movl   $0x8010869c,(%esp)
80106604:	e8 9c 9d ff ff       	call   801003a5 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80106609:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010660f:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106616:	eb 01                	jmp    80106619 <trap+0x1f6>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106618:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106619:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010661f:	85 c0                	test   %eax,%eax
80106621:	74 24                	je     80106647 <trap+0x224>
80106623:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106629:	8b 40 24             	mov    0x24(%eax),%eax
8010662c:	85 c0                	test   %eax,%eax
8010662e:	74 17                	je     80106647 <trap+0x224>
80106630:	8b 45 08             	mov    0x8(%ebp),%eax
80106633:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106637:	0f b7 c0             	movzwl %ax,%eax
8010663a:	83 e0 03             	and    $0x3,%eax
8010663d:	83 f8 03             	cmp    $0x3,%eax
80106640:	75 05                	jne    80106647 <trap+0x224>
    exit();
80106642:	e8 78 de ff ff       	call   801044bf <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER) {//ANOTAAARRRR
80106647:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010664d:	85 c0                	test   %eax,%eax
8010664f:	74 69                	je     801066ba <trap+0x297>
80106651:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106657:	8b 40 0c             	mov    0xc(%eax),%eax
8010665a:	83 f8 04             	cmp    $0x4,%eax
8010665d:	75 5b                	jne    801066ba <trap+0x297>
8010665f:	8b 45 08             	mov    0x8(%ebp),%eax
80106662:	8b 40 30             	mov    0x30(%eax),%eax
80106665:	83 f8 20             	cmp    $0x20,%eax
80106668:	75 50                	jne    801066ba <trap+0x297>
	  proc->quantum+=1;
8010666a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106670:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80106677:	8b 52 7c             	mov    0x7c(%edx),%edx
8010667a:	83 c2 01             	add    $0x1,%edx
8010667d:	89 50 7c             	mov    %edx,0x7c(%eax)
	  cprintf("El Proceso '%s', lleva el QUANTUM  %d    \n",proc->name,proc->quantum);
80106680:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106686:	8b 40 7c             	mov    0x7c(%eax),%eax
80106689:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80106690:	83 c2 6c             	add    $0x6c,%edx
80106693:	89 44 24 08          	mov    %eax,0x8(%esp)
80106697:	89 54 24 04          	mov    %edx,0x4(%esp)
8010669b:	c7 04 24 e0 86 10 80 	movl   $0x801086e0,(%esp)
801066a2:	e8 fe 9c ff ff       	call   801003a5 <cprintf>
	  if(proc->quantum == Quantum)
801066a7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801066ad:	8b 40 7c             	mov    0x7c(%eax),%eax
801066b0:	83 f8 05             	cmp    $0x5,%eax
801066b3:	75 05                	jne    801066ba <trap+0x297>
    	yield();
801066b5:	e8 8e e1 ff ff       	call   80104848 <yield>
	}

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801066ba:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801066c0:	85 c0                	test   %eax,%eax
801066c2:	74 27                	je     801066eb <trap+0x2c8>
801066c4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801066ca:	8b 40 24             	mov    0x24(%eax),%eax
801066cd:	85 c0                	test   %eax,%eax
801066cf:	74 1a                	je     801066eb <trap+0x2c8>
801066d1:	8b 45 08             	mov    0x8(%ebp),%eax
801066d4:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801066d8:	0f b7 c0             	movzwl %ax,%eax
801066db:	83 e0 03             	and    $0x3,%eax
801066de:	83 f8 03             	cmp    $0x3,%eax
801066e1:	75 08                	jne    801066eb <trap+0x2c8>
    exit();
801066e3:	e8 d7 dd ff ff       	call   801044bf <exit>
801066e8:	eb 01                	jmp    801066eb <trap+0x2c8>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
801066ea:	90                   	nop
	}

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
801066eb:	83 c4 3c             	add    $0x3c,%esp
801066ee:	5b                   	pop    %ebx
801066ef:	5e                   	pop    %esi
801066f0:	5f                   	pop    %edi
801066f1:	5d                   	pop    %ebp
801066f2:	c3                   	ret    
	...

801066f4 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801066f4:	55                   	push   %ebp
801066f5:	89 e5                	mov    %esp,%ebp
801066f7:	53                   	push   %ebx
801066f8:	83 ec 18             	sub    $0x18,%esp
801066fb:	8b 45 08             	mov    0x8(%ebp),%eax
801066fe:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106702:	0f b7 45 e8          	movzwl -0x18(%ebp),%eax
80106706:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
8010670a:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
8010670e:	ec                   	in     (%dx),%al
8010670f:	89 c3                	mov    %eax,%ebx
80106711:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80106714:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80106718:	83 c4 18             	add    $0x18,%esp
8010671b:	5b                   	pop    %ebx
8010671c:	5d                   	pop    %ebp
8010671d:	c3                   	ret    

8010671e <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010671e:	55                   	push   %ebp
8010671f:	89 e5                	mov    %esp,%ebp
80106721:	83 ec 08             	sub    $0x8,%esp
80106724:	8b 55 08             	mov    0x8(%ebp),%edx
80106727:	8b 45 0c             	mov    0xc(%ebp),%eax
8010672a:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010672e:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106731:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106735:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106739:	ee                   	out    %al,(%dx)
}
8010673a:	c9                   	leave  
8010673b:	c3                   	ret    

8010673c <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
8010673c:	55                   	push   %ebp
8010673d:	89 e5                	mov    %esp,%ebp
8010673f:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106742:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106749:	00 
8010674a:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106751:	e8 c8 ff ff ff       	call   8010671e <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106756:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
8010675d:	00 
8010675e:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106765:	e8 b4 ff ff ff       	call   8010671e <outb>
  outb(COM1+0, 115200/9600);
8010676a:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106771:	00 
80106772:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106779:	e8 a0 ff ff ff       	call   8010671e <outb>
  outb(COM1+1, 0);
8010677e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106785:	00 
80106786:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
8010678d:	e8 8c ff ff ff       	call   8010671e <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106792:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106799:	00 
8010679a:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
801067a1:	e8 78 ff ff ff       	call   8010671e <outb>
  outb(COM1+4, 0);
801067a6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801067ad:	00 
801067ae:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
801067b5:	e8 64 ff ff ff       	call   8010671e <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
801067ba:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801067c1:	00 
801067c2:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
801067c9:	e8 50 ff ff ff       	call   8010671e <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801067ce:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
801067d5:	e8 1a ff ff ff       	call   801066f4 <inb>
801067da:	3c ff                	cmp    $0xff,%al
801067dc:	74 6c                	je     8010684a <uartinit+0x10e>
    return;
  uart = 1;
801067de:	c7 05 4c b6 10 80 01 	movl   $0x1,0x8010b64c
801067e5:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801067e8:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
801067ef:	e8 00 ff ff ff       	call   801066f4 <inb>
  inb(COM1+0);
801067f4:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801067fb:	e8 f4 fe ff ff       	call   801066f4 <inb>
  picenable(IRQ_COM1);
80106800:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106807:	e8 dd d2 ff ff       	call   80103ae9 <picenable>
  ioapicenable(IRQ_COM1, 0);
8010680c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106813:	00 
80106814:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
8010681b:	e8 76 c1 ff ff       	call   80102996 <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106820:	c7 45 f4 8c 87 10 80 	movl   $0x8010878c,-0xc(%ebp)
80106827:	eb 15                	jmp    8010683e <uartinit+0x102>
    uartputc(*p);
80106829:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010682c:	0f b6 00             	movzbl (%eax),%eax
8010682f:	0f be c0             	movsbl %al,%eax
80106832:	89 04 24             	mov    %eax,(%esp)
80106835:	e8 13 00 00 00       	call   8010684d <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
8010683a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010683e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106841:	0f b6 00             	movzbl (%eax),%eax
80106844:	84 c0                	test   %al,%al
80106846:	75 e1                	jne    80106829 <uartinit+0xed>
80106848:	eb 01                	jmp    8010684b <uartinit+0x10f>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
8010684a:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
8010684b:	c9                   	leave  
8010684c:	c3                   	ret    

8010684d <uartputc>:

void
uartputc(int c)
{
8010684d:	55                   	push   %ebp
8010684e:	89 e5                	mov    %esp,%ebp
80106850:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80106853:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106858:	85 c0                	test   %eax,%eax
8010685a:	74 4d                	je     801068a9 <uartputc+0x5c>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010685c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106863:	eb 10                	jmp    80106875 <uartputc+0x28>
    microdelay(10);
80106865:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
8010686c:	e8 c2 c6 ff ff       	call   80102f33 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106871:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106875:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106879:	7f 16                	jg     80106891 <uartputc+0x44>
8010687b:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106882:	e8 6d fe ff ff       	call   801066f4 <inb>
80106887:	0f b6 c0             	movzbl %al,%eax
8010688a:	83 e0 20             	and    $0x20,%eax
8010688d:	85 c0                	test   %eax,%eax
8010688f:	74 d4                	je     80106865 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80106891:	8b 45 08             	mov    0x8(%ebp),%eax
80106894:	0f b6 c0             	movzbl %al,%eax
80106897:	89 44 24 04          	mov    %eax,0x4(%esp)
8010689b:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801068a2:	e8 77 fe ff ff       	call   8010671e <outb>
801068a7:	eb 01                	jmp    801068aa <uartputc+0x5d>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
801068a9:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
801068aa:	c9                   	leave  
801068ab:	c3                   	ret    

801068ac <uartgetc>:

static int
uartgetc(void)
{
801068ac:	55                   	push   %ebp
801068ad:	89 e5                	mov    %esp,%ebp
801068af:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
801068b2:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
801068b7:	85 c0                	test   %eax,%eax
801068b9:	75 07                	jne    801068c2 <uartgetc+0x16>
    return -1;
801068bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068c0:	eb 2c                	jmp    801068ee <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
801068c2:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
801068c9:	e8 26 fe ff ff       	call   801066f4 <inb>
801068ce:	0f b6 c0             	movzbl %al,%eax
801068d1:	83 e0 01             	and    $0x1,%eax
801068d4:	85 c0                	test   %eax,%eax
801068d6:	75 07                	jne    801068df <uartgetc+0x33>
    return -1;
801068d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068dd:	eb 0f                	jmp    801068ee <uartgetc+0x42>
  return inb(COM1+0);
801068df:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801068e6:	e8 09 fe ff ff       	call   801066f4 <inb>
801068eb:	0f b6 c0             	movzbl %al,%eax
}
801068ee:	c9                   	leave  
801068ef:	c3                   	ret    

801068f0 <uartintr>:

void
uartintr(void)
{
801068f0:	55                   	push   %ebp
801068f1:	89 e5                	mov    %esp,%ebp
801068f3:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
801068f6:	c7 04 24 ac 68 10 80 	movl   $0x801068ac,(%esp)
801068fd:	e8 b5 9e ff ff       	call   801007b7 <consoleintr>
}
80106902:	c9                   	leave  
80106903:	c3                   	ret    

80106904 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106904:	6a 00                	push   $0x0
  pushl $0
80106906:	6a 00                	push   $0x0
  jmp alltraps
80106908:	e9 1b f9 ff ff       	jmp    80106228 <alltraps>

8010690d <vector1>:
.globl vector1
vector1:
  pushl $0
8010690d:	6a 00                	push   $0x0
  pushl $1
8010690f:	6a 01                	push   $0x1
  jmp alltraps
80106911:	e9 12 f9 ff ff       	jmp    80106228 <alltraps>

80106916 <vector2>:
.globl vector2
vector2:
  pushl $0
80106916:	6a 00                	push   $0x0
  pushl $2
80106918:	6a 02                	push   $0x2
  jmp alltraps
8010691a:	e9 09 f9 ff ff       	jmp    80106228 <alltraps>

8010691f <vector3>:
.globl vector3
vector3:
  pushl $0
8010691f:	6a 00                	push   $0x0
  pushl $3
80106921:	6a 03                	push   $0x3
  jmp alltraps
80106923:	e9 00 f9 ff ff       	jmp    80106228 <alltraps>

80106928 <vector4>:
.globl vector4
vector4:
  pushl $0
80106928:	6a 00                	push   $0x0
  pushl $4
8010692a:	6a 04                	push   $0x4
  jmp alltraps
8010692c:	e9 f7 f8 ff ff       	jmp    80106228 <alltraps>

80106931 <vector5>:
.globl vector5
vector5:
  pushl $0
80106931:	6a 00                	push   $0x0
  pushl $5
80106933:	6a 05                	push   $0x5
  jmp alltraps
80106935:	e9 ee f8 ff ff       	jmp    80106228 <alltraps>

8010693a <vector6>:
.globl vector6
vector6:
  pushl $0
8010693a:	6a 00                	push   $0x0
  pushl $6
8010693c:	6a 06                	push   $0x6
  jmp alltraps
8010693e:	e9 e5 f8 ff ff       	jmp    80106228 <alltraps>

80106943 <vector7>:
.globl vector7
vector7:
  pushl $0
80106943:	6a 00                	push   $0x0
  pushl $7
80106945:	6a 07                	push   $0x7
  jmp alltraps
80106947:	e9 dc f8 ff ff       	jmp    80106228 <alltraps>

8010694c <vector8>:
.globl vector8
vector8:
  pushl $8
8010694c:	6a 08                	push   $0x8
  jmp alltraps
8010694e:	e9 d5 f8 ff ff       	jmp    80106228 <alltraps>

80106953 <vector9>:
.globl vector9
vector9:
  pushl $0
80106953:	6a 00                	push   $0x0
  pushl $9
80106955:	6a 09                	push   $0x9
  jmp alltraps
80106957:	e9 cc f8 ff ff       	jmp    80106228 <alltraps>

8010695c <vector10>:
.globl vector10
vector10:
  pushl $10
8010695c:	6a 0a                	push   $0xa
  jmp alltraps
8010695e:	e9 c5 f8 ff ff       	jmp    80106228 <alltraps>

80106963 <vector11>:
.globl vector11
vector11:
  pushl $11
80106963:	6a 0b                	push   $0xb
  jmp alltraps
80106965:	e9 be f8 ff ff       	jmp    80106228 <alltraps>

8010696a <vector12>:
.globl vector12
vector12:
  pushl $12
8010696a:	6a 0c                	push   $0xc
  jmp alltraps
8010696c:	e9 b7 f8 ff ff       	jmp    80106228 <alltraps>

80106971 <vector13>:
.globl vector13
vector13:
  pushl $13
80106971:	6a 0d                	push   $0xd
  jmp alltraps
80106973:	e9 b0 f8 ff ff       	jmp    80106228 <alltraps>

80106978 <vector14>:
.globl vector14
vector14:
  pushl $14
80106978:	6a 0e                	push   $0xe
  jmp alltraps
8010697a:	e9 a9 f8 ff ff       	jmp    80106228 <alltraps>

8010697f <vector15>:
.globl vector15
vector15:
  pushl $0
8010697f:	6a 00                	push   $0x0
  pushl $15
80106981:	6a 0f                	push   $0xf
  jmp alltraps
80106983:	e9 a0 f8 ff ff       	jmp    80106228 <alltraps>

80106988 <vector16>:
.globl vector16
vector16:
  pushl $0
80106988:	6a 00                	push   $0x0
  pushl $16
8010698a:	6a 10                	push   $0x10
  jmp alltraps
8010698c:	e9 97 f8 ff ff       	jmp    80106228 <alltraps>

80106991 <vector17>:
.globl vector17
vector17:
  pushl $17
80106991:	6a 11                	push   $0x11
  jmp alltraps
80106993:	e9 90 f8 ff ff       	jmp    80106228 <alltraps>

80106998 <vector18>:
.globl vector18
vector18:
  pushl $0
80106998:	6a 00                	push   $0x0
  pushl $18
8010699a:	6a 12                	push   $0x12
  jmp alltraps
8010699c:	e9 87 f8 ff ff       	jmp    80106228 <alltraps>

801069a1 <vector19>:
.globl vector19
vector19:
  pushl $0
801069a1:	6a 00                	push   $0x0
  pushl $19
801069a3:	6a 13                	push   $0x13
  jmp alltraps
801069a5:	e9 7e f8 ff ff       	jmp    80106228 <alltraps>

801069aa <vector20>:
.globl vector20
vector20:
  pushl $0
801069aa:	6a 00                	push   $0x0
  pushl $20
801069ac:	6a 14                	push   $0x14
  jmp alltraps
801069ae:	e9 75 f8 ff ff       	jmp    80106228 <alltraps>

801069b3 <vector21>:
.globl vector21
vector21:
  pushl $0
801069b3:	6a 00                	push   $0x0
  pushl $21
801069b5:	6a 15                	push   $0x15
  jmp alltraps
801069b7:	e9 6c f8 ff ff       	jmp    80106228 <alltraps>

801069bc <vector22>:
.globl vector22
vector22:
  pushl $0
801069bc:	6a 00                	push   $0x0
  pushl $22
801069be:	6a 16                	push   $0x16
  jmp alltraps
801069c0:	e9 63 f8 ff ff       	jmp    80106228 <alltraps>

801069c5 <vector23>:
.globl vector23
vector23:
  pushl $0
801069c5:	6a 00                	push   $0x0
  pushl $23
801069c7:	6a 17                	push   $0x17
  jmp alltraps
801069c9:	e9 5a f8 ff ff       	jmp    80106228 <alltraps>

801069ce <vector24>:
.globl vector24
vector24:
  pushl $0
801069ce:	6a 00                	push   $0x0
  pushl $24
801069d0:	6a 18                	push   $0x18
  jmp alltraps
801069d2:	e9 51 f8 ff ff       	jmp    80106228 <alltraps>

801069d7 <vector25>:
.globl vector25
vector25:
  pushl $0
801069d7:	6a 00                	push   $0x0
  pushl $25
801069d9:	6a 19                	push   $0x19
  jmp alltraps
801069db:	e9 48 f8 ff ff       	jmp    80106228 <alltraps>

801069e0 <vector26>:
.globl vector26
vector26:
  pushl $0
801069e0:	6a 00                	push   $0x0
  pushl $26
801069e2:	6a 1a                	push   $0x1a
  jmp alltraps
801069e4:	e9 3f f8 ff ff       	jmp    80106228 <alltraps>

801069e9 <vector27>:
.globl vector27
vector27:
  pushl $0
801069e9:	6a 00                	push   $0x0
  pushl $27
801069eb:	6a 1b                	push   $0x1b
  jmp alltraps
801069ed:	e9 36 f8 ff ff       	jmp    80106228 <alltraps>

801069f2 <vector28>:
.globl vector28
vector28:
  pushl $0
801069f2:	6a 00                	push   $0x0
  pushl $28
801069f4:	6a 1c                	push   $0x1c
  jmp alltraps
801069f6:	e9 2d f8 ff ff       	jmp    80106228 <alltraps>

801069fb <vector29>:
.globl vector29
vector29:
  pushl $0
801069fb:	6a 00                	push   $0x0
  pushl $29
801069fd:	6a 1d                	push   $0x1d
  jmp alltraps
801069ff:	e9 24 f8 ff ff       	jmp    80106228 <alltraps>

80106a04 <vector30>:
.globl vector30
vector30:
  pushl $0
80106a04:	6a 00                	push   $0x0
  pushl $30
80106a06:	6a 1e                	push   $0x1e
  jmp alltraps
80106a08:	e9 1b f8 ff ff       	jmp    80106228 <alltraps>

80106a0d <vector31>:
.globl vector31
vector31:
  pushl $0
80106a0d:	6a 00                	push   $0x0
  pushl $31
80106a0f:	6a 1f                	push   $0x1f
  jmp alltraps
80106a11:	e9 12 f8 ff ff       	jmp    80106228 <alltraps>

80106a16 <vector32>:
.globl vector32
vector32:
  pushl $0
80106a16:	6a 00                	push   $0x0
  pushl $32
80106a18:	6a 20                	push   $0x20
  jmp alltraps
80106a1a:	e9 09 f8 ff ff       	jmp    80106228 <alltraps>

80106a1f <vector33>:
.globl vector33
vector33:
  pushl $0
80106a1f:	6a 00                	push   $0x0
  pushl $33
80106a21:	6a 21                	push   $0x21
  jmp alltraps
80106a23:	e9 00 f8 ff ff       	jmp    80106228 <alltraps>

80106a28 <vector34>:
.globl vector34
vector34:
  pushl $0
80106a28:	6a 00                	push   $0x0
  pushl $34
80106a2a:	6a 22                	push   $0x22
  jmp alltraps
80106a2c:	e9 f7 f7 ff ff       	jmp    80106228 <alltraps>

80106a31 <vector35>:
.globl vector35
vector35:
  pushl $0
80106a31:	6a 00                	push   $0x0
  pushl $35
80106a33:	6a 23                	push   $0x23
  jmp alltraps
80106a35:	e9 ee f7 ff ff       	jmp    80106228 <alltraps>

80106a3a <vector36>:
.globl vector36
vector36:
  pushl $0
80106a3a:	6a 00                	push   $0x0
  pushl $36
80106a3c:	6a 24                	push   $0x24
  jmp alltraps
80106a3e:	e9 e5 f7 ff ff       	jmp    80106228 <alltraps>

80106a43 <vector37>:
.globl vector37
vector37:
  pushl $0
80106a43:	6a 00                	push   $0x0
  pushl $37
80106a45:	6a 25                	push   $0x25
  jmp alltraps
80106a47:	e9 dc f7 ff ff       	jmp    80106228 <alltraps>

80106a4c <vector38>:
.globl vector38
vector38:
  pushl $0
80106a4c:	6a 00                	push   $0x0
  pushl $38
80106a4e:	6a 26                	push   $0x26
  jmp alltraps
80106a50:	e9 d3 f7 ff ff       	jmp    80106228 <alltraps>

80106a55 <vector39>:
.globl vector39
vector39:
  pushl $0
80106a55:	6a 00                	push   $0x0
  pushl $39
80106a57:	6a 27                	push   $0x27
  jmp alltraps
80106a59:	e9 ca f7 ff ff       	jmp    80106228 <alltraps>

80106a5e <vector40>:
.globl vector40
vector40:
  pushl $0
80106a5e:	6a 00                	push   $0x0
  pushl $40
80106a60:	6a 28                	push   $0x28
  jmp alltraps
80106a62:	e9 c1 f7 ff ff       	jmp    80106228 <alltraps>

80106a67 <vector41>:
.globl vector41
vector41:
  pushl $0
80106a67:	6a 00                	push   $0x0
  pushl $41
80106a69:	6a 29                	push   $0x29
  jmp alltraps
80106a6b:	e9 b8 f7 ff ff       	jmp    80106228 <alltraps>

80106a70 <vector42>:
.globl vector42
vector42:
  pushl $0
80106a70:	6a 00                	push   $0x0
  pushl $42
80106a72:	6a 2a                	push   $0x2a
  jmp alltraps
80106a74:	e9 af f7 ff ff       	jmp    80106228 <alltraps>

80106a79 <vector43>:
.globl vector43
vector43:
  pushl $0
80106a79:	6a 00                	push   $0x0
  pushl $43
80106a7b:	6a 2b                	push   $0x2b
  jmp alltraps
80106a7d:	e9 a6 f7 ff ff       	jmp    80106228 <alltraps>

80106a82 <vector44>:
.globl vector44
vector44:
  pushl $0
80106a82:	6a 00                	push   $0x0
  pushl $44
80106a84:	6a 2c                	push   $0x2c
  jmp alltraps
80106a86:	e9 9d f7 ff ff       	jmp    80106228 <alltraps>

80106a8b <vector45>:
.globl vector45
vector45:
  pushl $0
80106a8b:	6a 00                	push   $0x0
  pushl $45
80106a8d:	6a 2d                	push   $0x2d
  jmp alltraps
80106a8f:	e9 94 f7 ff ff       	jmp    80106228 <alltraps>

80106a94 <vector46>:
.globl vector46
vector46:
  pushl $0
80106a94:	6a 00                	push   $0x0
  pushl $46
80106a96:	6a 2e                	push   $0x2e
  jmp alltraps
80106a98:	e9 8b f7 ff ff       	jmp    80106228 <alltraps>

80106a9d <vector47>:
.globl vector47
vector47:
  pushl $0
80106a9d:	6a 00                	push   $0x0
  pushl $47
80106a9f:	6a 2f                	push   $0x2f
  jmp alltraps
80106aa1:	e9 82 f7 ff ff       	jmp    80106228 <alltraps>

80106aa6 <vector48>:
.globl vector48
vector48:
  pushl $0
80106aa6:	6a 00                	push   $0x0
  pushl $48
80106aa8:	6a 30                	push   $0x30
  jmp alltraps
80106aaa:	e9 79 f7 ff ff       	jmp    80106228 <alltraps>

80106aaf <vector49>:
.globl vector49
vector49:
  pushl $0
80106aaf:	6a 00                	push   $0x0
  pushl $49
80106ab1:	6a 31                	push   $0x31
  jmp alltraps
80106ab3:	e9 70 f7 ff ff       	jmp    80106228 <alltraps>

80106ab8 <vector50>:
.globl vector50
vector50:
  pushl $0
80106ab8:	6a 00                	push   $0x0
  pushl $50
80106aba:	6a 32                	push   $0x32
  jmp alltraps
80106abc:	e9 67 f7 ff ff       	jmp    80106228 <alltraps>

80106ac1 <vector51>:
.globl vector51
vector51:
  pushl $0
80106ac1:	6a 00                	push   $0x0
  pushl $51
80106ac3:	6a 33                	push   $0x33
  jmp alltraps
80106ac5:	e9 5e f7 ff ff       	jmp    80106228 <alltraps>

80106aca <vector52>:
.globl vector52
vector52:
  pushl $0
80106aca:	6a 00                	push   $0x0
  pushl $52
80106acc:	6a 34                	push   $0x34
  jmp alltraps
80106ace:	e9 55 f7 ff ff       	jmp    80106228 <alltraps>

80106ad3 <vector53>:
.globl vector53
vector53:
  pushl $0
80106ad3:	6a 00                	push   $0x0
  pushl $53
80106ad5:	6a 35                	push   $0x35
  jmp alltraps
80106ad7:	e9 4c f7 ff ff       	jmp    80106228 <alltraps>

80106adc <vector54>:
.globl vector54
vector54:
  pushl $0
80106adc:	6a 00                	push   $0x0
  pushl $54
80106ade:	6a 36                	push   $0x36
  jmp alltraps
80106ae0:	e9 43 f7 ff ff       	jmp    80106228 <alltraps>

80106ae5 <vector55>:
.globl vector55
vector55:
  pushl $0
80106ae5:	6a 00                	push   $0x0
  pushl $55
80106ae7:	6a 37                	push   $0x37
  jmp alltraps
80106ae9:	e9 3a f7 ff ff       	jmp    80106228 <alltraps>

80106aee <vector56>:
.globl vector56
vector56:
  pushl $0
80106aee:	6a 00                	push   $0x0
  pushl $56
80106af0:	6a 38                	push   $0x38
  jmp alltraps
80106af2:	e9 31 f7 ff ff       	jmp    80106228 <alltraps>

80106af7 <vector57>:
.globl vector57
vector57:
  pushl $0
80106af7:	6a 00                	push   $0x0
  pushl $57
80106af9:	6a 39                	push   $0x39
  jmp alltraps
80106afb:	e9 28 f7 ff ff       	jmp    80106228 <alltraps>

80106b00 <vector58>:
.globl vector58
vector58:
  pushl $0
80106b00:	6a 00                	push   $0x0
  pushl $58
80106b02:	6a 3a                	push   $0x3a
  jmp alltraps
80106b04:	e9 1f f7 ff ff       	jmp    80106228 <alltraps>

80106b09 <vector59>:
.globl vector59
vector59:
  pushl $0
80106b09:	6a 00                	push   $0x0
  pushl $59
80106b0b:	6a 3b                	push   $0x3b
  jmp alltraps
80106b0d:	e9 16 f7 ff ff       	jmp    80106228 <alltraps>

80106b12 <vector60>:
.globl vector60
vector60:
  pushl $0
80106b12:	6a 00                	push   $0x0
  pushl $60
80106b14:	6a 3c                	push   $0x3c
  jmp alltraps
80106b16:	e9 0d f7 ff ff       	jmp    80106228 <alltraps>

80106b1b <vector61>:
.globl vector61
vector61:
  pushl $0
80106b1b:	6a 00                	push   $0x0
  pushl $61
80106b1d:	6a 3d                	push   $0x3d
  jmp alltraps
80106b1f:	e9 04 f7 ff ff       	jmp    80106228 <alltraps>

80106b24 <vector62>:
.globl vector62
vector62:
  pushl $0
80106b24:	6a 00                	push   $0x0
  pushl $62
80106b26:	6a 3e                	push   $0x3e
  jmp alltraps
80106b28:	e9 fb f6 ff ff       	jmp    80106228 <alltraps>

80106b2d <vector63>:
.globl vector63
vector63:
  pushl $0
80106b2d:	6a 00                	push   $0x0
  pushl $63
80106b2f:	6a 3f                	push   $0x3f
  jmp alltraps
80106b31:	e9 f2 f6 ff ff       	jmp    80106228 <alltraps>

80106b36 <vector64>:
.globl vector64
vector64:
  pushl $0
80106b36:	6a 00                	push   $0x0
  pushl $64
80106b38:	6a 40                	push   $0x40
  jmp alltraps
80106b3a:	e9 e9 f6 ff ff       	jmp    80106228 <alltraps>

80106b3f <vector65>:
.globl vector65
vector65:
  pushl $0
80106b3f:	6a 00                	push   $0x0
  pushl $65
80106b41:	6a 41                	push   $0x41
  jmp alltraps
80106b43:	e9 e0 f6 ff ff       	jmp    80106228 <alltraps>

80106b48 <vector66>:
.globl vector66
vector66:
  pushl $0
80106b48:	6a 00                	push   $0x0
  pushl $66
80106b4a:	6a 42                	push   $0x42
  jmp alltraps
80106b4c:	e9 d7 f6 ff ff       	jmp    80106228 <alltraps>

80106b51 <vector67>:
.globl vector67
vector67:
  pushl $0
80106b51:	6a 00                	push   $0x0
  pushl $67
80106b53:	6a 43                	push   $0x43
  jmp alltraps
80106b55:	e9 ce f6 ff ff       	jmp    80106228 <alltraps>

80106b5a <vector68>:
.globl vector68
vector68:
  pushl $0
80106b5a:	6a 00                	push   $0x0
  pushl $68
80106b5c:	6a 44                	push   $0x44
  jmp alltraps
80106b5e:	e9 c5 f6 ff ff       	jmp    80106228 <alltraps>

80106b63 <vector69>:
.globl vector69
vector69:
  pushl $0
80106b63:	6a 00                	push   $0x0
  pushl $69
80106b65:	6a 45                	push   $0x45
  jmp alltraps
80106b67:	e9 bc f6 ff ff       	jmp    80106228 <alltraps>

80106b6c <vector70>:
.globl vector70
vector70:
  pushl $0
80106b6c:	6a 00                	push   $0x0
  pushl $70
80106b6e:	6a 46                	push   $0x46
  jmp alltraps
80106b70:	e9 b3 f6 ff ff       	jmp    80106228 <alltraps>

80106b75 <vector71>:
.globl vector71
vector71:
  pushl $0
80106b75:	6a 00                	push   $0x0
  pushl $71
80106b77:	6a 47                	push   $0x47
  jmp alltraps
80106b79:	e9 aa f6 ff ff       	jmp    80106228 <alltraps>

80106b7e <vector72>:
.globl vector72
vector72:
  pushl $0
80106b7e:	6a 00                	push   $0x0
  pushl $72
80106b80:	6a 48                	push   $0x48
  jmp alltraps
80106b82:	e9 a1 f6 ff ff       	jmp    80106228 <alltraps>

80106b87 <vector73>:
.globl vector73
vector73:
  pushl $0
80106b87:	6a 00                	push   $0x0
  pushl $73
80106b89:	6a 49                	push   $0x49
  jmp alltraps
80106b8b:	e9 98 f6 ff ff       	jmp    80106228 <alltraps>

80106b90 <vector74>:
.globl vector74
vector74:
  pushl $0
80106b90:	6a 00                	push   $0x0
  pushl $74
80106b92:	6a 4a                	push   $0x4a
  jmp alltraps
80106b94:	e9 8f f6 ff ff       	jmp    80106228 <alltraps>

80106b99 <vector75>:
.globl vector75
vector75:
  pushl $0
80106b99:	6a 00                	push   $0x0
  pushl $75
80106b9b:	6a 4b                	push   $0x4b
  jmp alltraps
80106b9d:	e9 86 f6 ff ff       	jmp    80106228 <alltraps>

80106ba2 <vector76>:
.globl vector76
vector76:
  pushl $0
80106ba2:	6a 00                	push   $0x0
  pushl $76
80106ba4:	6a 4c                	push   $0x4c
  jmp alltraps
80106ba6:	e9 7d f6 ff ff       	jmp    80106228 <alltraps>

80106bab <vector77>:
.globl vector77
vector77:
  pushl $0
80106bab:	6a 00                	push   $0x0
  pushl $77
80106bad:	6a 4d                	push   $0x4d
  jmp alltraps
80106baf:	e9 74 f6 ff ff       	jmp    80106228 <alltraps>

80106bb4 <vector78>:
.globl vector78
vector78:
  pushl $0
80106bb4:	6a 00                	push   $0x0
  pushl $78
80106bb6:	6a 4e                	push   $0x4e
  jmp alltraps
80106bb8:	e9 6b f6 ff ff       	jmp    80106228 <alltraps>

80106bbd <vector79>:
.globl vector79
vector79:
  pushl $0
80106bbd:	6a 00                	push   $0x0
  pushl $79
80106bbf:	6a 4f                	push   $0x4f
  jmp alltraps
80106bc1:	e9 62 f6 ff ff       	jmp    80106228 <alltraps>

80106bc6 <vector80>:
.globl vector80
vector80:
  pushl $0
80106bc6:	6a 00                	push   $0x0
  pushl $80
80106bc8:	6a 50                	push   $0x50
  jmp alltraps
80106bca:	e9 59 f6 ff ff       	jmp    80106228 <alltraps>

80106bcf <vector81>:
.globl vector81
vector81:
  pushl $0
80106bcf:	6a 00                	push   $0x0
  pushl $81
80106bd1:	6a 51                	push   $0x51
  jmp alltraps
80106bd3:	e9 50 f6 ff ff       	jmp    80106228 <alltraps>

80106bd8 <vector82>:
.globl vector82
vector82:
  pushl $0
80106bd8:	6a 00                	push   $0x0
  pushl $82
80106bda:	6a 52                	push   $0x52
  jmp alltraps
80106bdc:	e9 47 f6 ff ff       	jmp    80106228 <alltraps>

80106be1 <vector83>:
.globl vector83
vector83:
  pushl $0
80106be1:	6a 00                	push   $0x0
  pushl $83
80106be3:	6a 53                	push   $0x53
  jmp alltraps
80106be5:	e9 3e f6 ff ff       	jmp    80106228 <alltraps>

80106bea <vector84>:
.globl vector84
vector84:
  pushl $0
80106bea:	6a 00                	push   $0x0
  pushl $84
80106bec:	6a 54                	push   $0x54
  jmp alltraps
80106bee:	e9 35 f6 ff ff       	jmp    80106228 <alltraps>

80106bf3 <vector85>:
.globl vector85
vector85:
  pushl $0
80106bf3:	6a 00                	push   $0x0
  pushl $85
80106bf5:	6a 55                	push   $0x55
  jmp alltraps
80106bf7:	e9 2c f6 ff ff       	jmp    80106228 <alltraps>

80106bfc <vector86>:
.globl vector86
vector86:
  pushl $0
80106bfc:	6a 00                	push   $0x0
  pushl $86
80106bfe:	6a 56                	push   $0x56
  jmp alltraps
80106c00:	e9 23 f6 ff ff       	jmp    80106228 <alltraps>

80106c05 <vector87>:
.globl vector87
vector87:
  pushl $0
80106c05:	6a 00                	push   $0x0
  pushl $87
80106c07:	6a 57                	push   $0x57
  jmp alltraps
80106c09:	e9 1a f6 ff ff       	jmp    80106228 <alltraps>

80106c0e <vector88>:
.globl vector88
vector88:
  pushl $0
80106c0e:	6a 00                	push   $0x0
  pushl $88
80106c10:	6a 58                	push   $0x58
  jmp alltraps
80106c12:	e9 11 f6 ff ff       	jmp    80106228 <alltraps>

80106c17 <vector89>:
.globl vector89
vector89:
  pushl $0
80106c17:	6a 00                	push   $0x0
  pushl $89
80106c19:	6a 59                	push   $0x59
  jmp alltraps
80106c1b:	e9 08 f6 ff ff       	jmp    80106228 <alltraps>

80106c20 <vector90>:
.globl vector90
vector90:
  pushl $0
80106c20:	6a 00                	push   $0x0
  pushl $90
80106c22:	6a 5a                	push   $0x5a
  jmp alltraps
80106c24:	e9 ff f5 ff ff       	jmp    80106228 <alltraps>

80106c29 <vector91>:
.globl vector91
vector91:
  pushl $0
80106c29:	6a 00                	push   $0x0
  pushl $91
80106c2b:	6a 5b                	push   $0x5b
  jmp alltraps
80106c2d:	e9 f6 f5 ff ff       	jmp    80106228 <alltraps>

80106c32 <vector92>:
.globl vector92
vector92:
  pushl $0
80106c32:	6a 00                	push   $0x0
  pushl $92
80106c34:	6a 5c                	push   $0x5c
  jmp alltraps
80106c36:	e9 ed f5 ff ff       	jmp    80106228 <alltraps>

80106c3b <vector93>:
.globl vector93
vector93:
  pushl $0
80106c3b:	6a 00                	push   $0x0
  pushl $93
80106c3d:	6a 5d                	push   $0x5d
  jmp alltraps
80106c3f:	e9 e4 f5 ff ff       	jmp    80106228 <alltraps>

80106c44 <vector94>:
.globl vector94
vector94:
  pushl $0
80106c44:	6a 00                	push   $0x0
  pushl $94
80106c46:	6a 5e                	push   $0x5e
  jmp alltraps
80106c48:	e9 db f5 ff ff       	jmp    80106228 <alltraps>

80106c4d <vector95>:
.globl vector95
vector95:
  pushl $0
80106c4d:	6a 00                	push   $0x0
  pushl $95
80106c4f:	6a 5f                	push   $0x5f
  jmp alltraps
80106c51:	e9 d2 f5 ff ff       	jmp    80106228 <alltraps>

80106c56 <vector96>:
.globl vector96
vector96:
  pushl $0
80106c56:	6a 00                	push   $0x0
  pushl $96
80106c58:	6a 60                	push   $0x60
  jmp alltraps
80106c5a:	e9 c9 f5 ff ff       	jmp    80106228 <alltraps>

80106c5f <vector97>:
.globl vector97
vector97:
  pushl $0
80106c5f:	6a 00                	push   $0x0
  pushl $97
80106c61:	6a 61                	push   $0x61
  jmp alltraps
80106c63:	e9 c0 f5 ff ff       	jmp    80106228 <alltraps>

80106c68 <vector98>:
.globl vector98
vector98:
  pushl $0
80106c68:	6a 00                	push   $0x0
  pushl $98
80106c6a:	6a 62                	push   $0x62
  jmp alltraps
80106c6c:	e9 b7 f5 ff ff       	jmp    80106228 <alltraps>

80106c71 <vector99>:
.globl vector99
vector99:
  pushl $0
80106c71:	6a 00                	push   $0x0
  pushl $99
80106c73:	6a 63                	push   $0x63
  jmp alltraps
80106c75:	e9 ae f5 ff ff       	jmp    80106228 <alltraps>

80106c7a <vector100>:
.globl vector100
vector100:
  pushl $0
80106c7a:	6a 00                	push   $0x0
  pushl $100
80106c7c:	6a 64                	push   $0x64
  jmp alltraps
80106c7e:	e9 a5 f5 ff ff       	jmp    80106228 <alltraps>

80106c83 <vector101>:
.globl vector101
vector101:
  pushl $0
80106c83:	6a 00                	push   $0x0
  pushl $101
80106c85:	6a 65                	push   $0x65
  jmp alltraps
80106c87:	e9 9c f5 ff ff       	jmp    80106228 <alltraps>

80106c8c <vector102>:
.globl vector102
vector102:
  pushl $0
80106c8c:	6a 00                	push   $0x0
  pushl $102
80106c8e:	6a 66                	push   $0x66
  jmp alltraps
80106c90:	e9 93 f5 ff ff       	jmp    80106228 <alltraps>

80106c95 <vector103>:
.globl vector103
vector103:
  pushl $0
80106c95:	6a 00                	push   $0x0
  pushl $103
80106c97:	6a 67                	push   $0x67
  jmp alltraps
80106c99:	e9 8a f5 ff ff       	jmp    80106228 <alltraps>

80106c9e <vector104>:
.globl vector104
vector104:
  pushl $0
80106c9e:	6a 00                	push   $0x0
  pushl $104
80106ca0:	6a 68                	push   $0x68
  jmp alltraps
80106ca2:	e9 81 f5 ff ff       	jmp    80106228 <alltraps>

80106ca7 <vector105>:
.globl vector105
vector105:
  pushl $0
80106ca7:	6a 00                	push   $0x0
  pushl $105
80106ca9:	6a 69                	push   $0x69
  jmp alltraps
80106cab:	e9 78 f5 ff ff       	jmp    80106228 <alltraps>

80106cb0 <vector106>:
.globl vector106
vector106:
  pushl $0
80106cb0:	6a 00                	push   $0x0
  pushl $106
80106cb2:	6a 6a                	push   $0x6a
  jmp alltraps
80106cb4:	e9 6f f5 ff ff       	jmp    80106228 <alltraps>

80106cb9 <vector107>:
.globl vector107
vector107:
  pushl $0
80106cb9:	6a 00                	push   $0x0
  pushl $107
80106cbb:	6a 6b                	push   $0x6b
  jmp alltraps
80106cbd:	e9 66 f5 ff ff       	jmp    80106228 <alltraps>

80106cc2 <vector108>:
.globl vector108
vector108:
  pushl $0
80106cc2:	6a 00                	push   $0x0
  pushl $108
80106cc4:	6a 6c                	push   $0x6c
  jmp alltraps
80106cc6:	e9 5d f5 ff ff       	jmp    80106228 <alltraps>

80106ccb <vector109>:
.globl vector109
vector109:
  pushl $0
80106ccb:	6a 00                	push   $0x0
  pushl $109
80106ccd:	6a 6d                	push   $0x6d
  jmp alltraps
80106ccf:	e9 54 f5 ff ff       	jmp    80106228 <alltraps>

80106cd4 <vector110>:
.globl vector110
vector110:
  pushl $0
80106cd4:	6a 00                	push   $0x0
  pushl $110
80106cd6:	6a 6e                	push   $0x6e
  jmp alltraps
80106cd8:	e9 4b f5 ff ff       	jmp    80106228 <alltraps>

80106cdd <vector111>:
.globl vector111
vector111:
  pushl $0
80106cdd:	6a 00                	push   $0x0
  pushl $111
80106cdf:	6a 6f                	push   $0x6f
  jmp alltraps
80106ce1:	e9 42 f5 ff ff       	jmp    80106228 <alltraps>

80106ce6 <vector112>:
.globl vector112
vector112:
  pushl $0
80106ce6:	6a 00                	push   $0x0
  pushl $112
80106ce8:	6a 70                	push   $0x70
  jmp alltraps
80106cea:	e9 39 f5 ff ff       	jmp    80106228 <alltraps>

80106cef <vector113>:
.globl vector113
vector113:
  pushl $0
80106cef:	6a 00                	push   $0x0
  pushl $113
80106cf1:	6a 71                	push   $0x71
  jmp alltraps
80106cf3:	e9 30 f5 ff ff       	jmp    80106228 <alltraps>

80106cf8 <vector114>:
.globl vector114
vector114:
  pushl $0
80106cf8:	6a 00                	push   $0x0
  pushl $114
80106cfa:	6a 72                	push   $0x72
  jmp alltraps
80106cfc:	e9 27 f5 ff ff       	jmp    80106228 <alltraps>

80106d01 <vector115>:
.globl vector115
vector115:
  pushl $0
80106d01:	6a 00                	push   $0x0
  pushl $115
80106d03:	6a 73                	push   $0x73
  jmp alltraps
80106d05:	e9 1e f5 ff ff       	jmp    80106228 <alltraps>

80106d0a <vector116>:
.globl vector116
vector116:
  pushl $0
80106d0a:	6a 00                	push   $0x0
  pushl $116
80106d0c:	6a 74                	push   $0x74
  jmp alltraps
80106d0e:	e9 15 f5 ff ff       	jmp    80106228 <alltraps>

80106d13 <vector117>:
.globl vector117
vector117:
  pushl $0
80106d13:	6a 00                	push   $0x0
  pushl $117
80106d15:	6a 75                	push   $0x75
  jmp alltraps
80106d17:	e9 0c f5 ff ff       	jmp    80106228 <alltraps>

80106d1c <vector118>:
.globl vector118
vector118:
  pushl $0
80106d1c:	6a 00                	push   $0x0
  pushl $118
80106d1e:	6a 76                	push   $0x76
  jmp alltraps
80106d20:	e9 03 f5 ff ff       	jmp    80106228 <alltraps>

80106d25 <vector119>:
.globl vector119
vector119:
  pushl $0
80106d25:	6a 00                	push   $0x0
  pushl $119
80106d27:	6a 77                	push   $0x77
  jmp alltraps
80106d29:	e9 fa f4 ff ff       	jmp    80106228 <alltraps>

80106d2e <vector120>:
.globl vector120
vector120:
  pushl $0
80106d2e:	6a 00                	push   $0x0
  pushl $120
80106d30:	6a 78                	push   $0x78
  jmp alltraps
80106d32:	e9 f1 f4 ff ff       	jmp    80106228 <alltraps>

80106d37 <vector121>:
.globl vector121
vector121:
  pushl $0
80106d37:	6a 00                	push   $0x0
  pushl $121
80106d39:	6a 79                	push   $0x79
  jmp alltraps
80106d3b:	e9 e8 f4 ff ff       	jmp    80106228 <alltraps>

80106d40 <vector122>:
.globl vector122
vector122:
  pushl $0
80106d40:	6a 00                	push   $0x0
  pushl $122
80106d42:	6a 7a                	push   $0x7a
  jmp alltraps
80106d44:	e9 df f4 ff ff       	jmp    80106228 <alltraps>

80106d49 <vector123>:
.globl vector123
vector123:
  pushl $0
80106d49:	6a 00                	push   $0x0
  pushl $123
80106d4b:	6a 7b                	push   $0x7b
  jmp alltraps
80106d4d:	e9 d6 f4 ff ff       	jmp    80106228 <alltraps>

80106d52 <vector124>:
.globl vector124
vector124:
  pushl $0
80106d52:	6a 00                	push   $0x0
  pushl $124
80106d54:	6a 7c                	push   $0x7c
  jmp alltraps
80106d56:	e9 cd f4 ff ff       	jmp    80106228 <alltraps>

80106d5b <vector125>:
.globl vector125
vector125:
  pushl $0
80106d5b:	6a 00                	push   $0x0
  pushl $125
80106d5d:	6a 7d                	push   $0x7d
  jmp alltraps
80106d5f:	e9 c4 f4 ff ff       	jmp    80106228 <alltraps>

80106d64 <vector126>:
.globl vector126
vector126:
  pushl $0
80106d64:	6a 00                	push   $0x0
  pushl $126
80106d66:	6a 7e                	push   $0x7e
  jmp alltraps
80106d68:	e9 bb f4 ff ff       	jmp    80106228 <alltraps>

80106d6d <vector127>:
.globl vector127
vector127:
  pushl $0
80106d6d:	6a 00                	push   $0x0
  pushl $127
80106d6f:	6a 7f                	push   $0x7f
  jmp alltraps
80106d71:	e9 b2 f4 ff ff       	jmp    80106228 <alltraps>

80106d76 <vector128>:
.globl vector128
vector128:
  pushl $0
80106d76:	6a 00                	push   $0x0
  pushl $128
80106d78:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106d7d:	e9 a6 f4 ff ff       	jmp    80106228 <alltraps>

80106d82 <vector129>:
.globl vector129
vector129:
  pushl $0
80106d82:	6a 00                	push   $0x0
  pushl $129
80106d84:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106d89:	e9 9a f4 ff ff       	jmp    80106228 <alltraps>

80106d8e <vector130>:
.globl vector130
vector130:
  pushl $0
80106d8e:	6a 00                	push   $0x0
  pushl $130
80106d90:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106d95:	e9 8e f4 ff ff       	jmp    80106228 <alltraps>

80106d9a <vector131>:
.globl vector131
vector131:
  pushl $0
80106d9a:	6a 00                	push   $0x0
  pushl $131
80106d9c:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106da1:	e9 82 f4 ff ff       	jmp    80106228 <alltraps>

80106da6 <vector132>:
.globl vector132
vector132:
  pushl $0
80106da6:	6a 00                	push   $0x0
  pushl $132
80106da8:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106dad:	e9 76 f4 ff ff       	jmp    80106228 <alltraps>

80106db2 <vector133>:
.globl vector133
vector133:
  pushl $0
80106db2:	6a 00                	push   $0x0
  pushl $133
80106db4:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106db9:	e9 6a f4 ff ff       	jmp    80106228 <alltraps>

80106dbe <vector134>:
.globl vector134
vector134:
  pushl $0
80106dbe:	6a 00                	push   $0x0
  pushl $134
80106dc0:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106dc5:	e9 5e f4 ff ff       	jmp    80106228 <alltraps>

80106dca <vector135>:
.globl vector135
vector135:
  pushl $0
80106dca:	6a 00                	push   $0x0
  pushl $135
80106dcc:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106dd1:	e9 52 f4 ff ff       	jmp    80106228 <alltraps>

80106dd6 <vector136>:
.globl vector136
vector136:
  pushl $0
80106dd6:	6a 00                	push   $0x0
  pushl $136
80106dd8:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106ddd:	e9 46 f4 ff ff       	jmp    80106228 <alltraps>

80106de2 <vector137>:
.globl vector137
vector137:
  pushl $0
80106de2:	6a 00                	push   $0x0
  pushl $137
80106de4:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106de9:	e9 3a f4 ff ff       	jmp    80106228 <alltraps>

80106dee <vector138>:
.globl vector138
vector138:
  pushl $0
80106dee:	6a 00                	push   $0x0
  pushl $138
80106df0:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106df5:	e9 2e f4 ff ff       	jmp    80106228 <alltraps>

80106dfa <vector139>:
.globl vector139
vector139:
  pushl $0
80106dfa:	6a 00                	push   $0x0
  pushl $139
80106dfc:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106e01:	e9 22 f4 ff ff       	jmp    80106228 <alltraps>

80106e06 <vector140>:
.globl vector140
vector140:
  pushl $0
80106e06:	6a 00                	push   $0x0
  pushl $140
80106e08:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106e0d:	e9 16 f4 ff ff       	jmp    80106228 <alltraps>

80106e12 <vector141>:
.globl vector141
vector141:
  pushl $0
80106e12:	6a 00                	push   $0x0
  pushl $141
80106e14:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106e19:	e9 0a f4 ff ff       	jmp    80106228 <alltraps>

80106e1e <vector142>:
.globl vector142
vector142:
  pushl $0
80106e1e:	6a 00                	push   $0x0
  pushl $142
80106e20:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106e25:	e9 fe f3 ff ff       	jmp    80106228 <alltraps>

80106e2a <vector143>:
.globl vector143
vector143:
  pushl $0
80106e2a:	6a 00                	push   $0x0
  pushl $143
80106e2c:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106e31:	e9 f2 f3 ff ff       	jmp    80106228 <alltraps>

80106e36 <vector144>:
.globl vector144
vector144:
  pushl $0
80106e36:	6a 00                	push   $0x0
  pushl $144
80106e38:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106e3d:	e9 e6 f3 ff ff       	jmp    80106228 <alltraps>

80106e42 <vector145>:
.globl vector145
vector145:
  pushl $0
80106e42:	6a 00                	push   $0x0
  pushl $145
80106e44:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106e49:	e9 da f3 ff ff       	jmp    80106228 <alltraps>

80106e4e <vector146>:
.globl vector146
vector146:
  pushl $0
80106e4e:	6a 00                	push   $0x0
  pushl $146
80106e50:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106e55:	e9 ce f3 ff ff       	jmp    80106228 <alltraps>

80106e5a <vector147>:
.globl vector147
vector147:
  pushl $0
80106e5a:	6a 00                	push   $0x0
  pushl $147
80106e5c:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106e61:	e9 c2 f3 ff ff       	jmp    80106228 <alltraps>

80106e66 <vector148>:
.globl vector148
vector148:
  pushl $0
80106e66:	6a 00                	push   $0x0
  pushl $148
80106e68:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106e6d:	e9 b6 f3 ff ff       	jmp    80106228 <alltraps>

80106e72 <vector149>:
.globl vector149
vector149:
  pushl $0
80106e72:	6a 00                	push   $0x0
  pushl $149
80106e74:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106e79:	e9 aa f3 ff ff       	jmp    80106228 <alltraps>

80106e7e <vector150>:
.globl vector150
vector150:
  pushl $0
80106e7e:	6a 00                	push   $0x0
  pushl $150
80106e80:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106e85:	e9 9e f3 ff ff       	jmp    80106228 <alltraps>

80106e8a <vector151>:
.globl vector151
vector151:
  pushl $0
80106e8a:	6a 00                	push   $0x0
  pushl $151
80106e8c:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106e91:	e9 92 f3 ff ff       	jmp    80106228 <alltraps>

80106e96 <vector152>:
.globl vector152
vector152:
  pushl $0
80106e96:	6a 00                	push   $0x0
  pushl $152
80106e98:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106e9d:	e9 86 f3 ff ff       	jmp    80106228 <alltraps>

80106ea2 <vector153>:
.globl vector153
vector153:
  pushl $0
80106ea2:	6a 00                	push   $0x0
  pushl $153
80106ea4:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106ea9:	e9 7a f3 ff ff       	jmp    80106228 <alltraps>

80106eae <vector154>:
.globl vector154
vector154:
  pushl $0
80106eae:	6a 00                	push   $0x0
  pushl $154
80106eb0:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106eb5:	e9 6e f3 ff ff       	jmp    80106228 <alltraps>

80106eba <vector155>:
.globl vector155
vector155:
  pushl $0
80106eba:	6a 00                	push   $0x0
  pushl $155
80106ebc:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106ec1:	e9 62 f3 ff ff       	jmp    80106228 <alltraps>

80106ec6 <vector156>:
.globl vector156
vector156:
  pushl $0
80106ec6:	6a 00                	push   $0x0
  pushl $156
80106ec8:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106ecd:	e9 56 f3 ff ff       	jmp    80106228 <alltraps>

80106ed2 <vector157>:
.globl vector157
vector157:
  pushl $0
80106ed2:	6a 00                	push   $0x0
  pushl $157
80106ed4:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106ed9:	e9 4a f3 ff ff       	jmp    80106228 <alltraps>

80106ede <vector158>:
.globl vector158
vector158:
  pushl $0
80106ede:	6a 00                	push   $0x0
  pushl $158
80106ee0:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106ee5:	e9 3e f3 ff ff       	jmp    80106228 <alltraps>

80106eea <vector159>:
.globl vector159
vector159:
  pushl $0
80106eea:	6a 00                	push   $0x0
  pushl $159
80106eec:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106ef1:	e9 32 f3 ff ff       	jmp    80106228 <alltraps>

80106ef6 <vector160>:
.globl vector160
vector160:
  pushl $0
80106ef6:	6a 00                	push   $0x0
  pushl $160
80106ef8:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106efd:	e9 26 f3 ff ff       	jmp    80106228 <alltraps>

80106f02 <vector161>:
.globl vector161
vector161:
  pushl $0
80106f02:	6a 00                	push   $0x0
  pushl $161
80106f04:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106f09:	e9 1a f3 ff ff       	jmp    80106228 <alltraps>

80106f0e <vector162>:
.globl vector162
vector162:
  pushl $0
80106f0e:	6a 00                	push   $0x0
  pushl $162
80106f10:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106f15:	e9 0e f3 ff ff       	jmp    80106228 <alltraps>

80106f1a <vector163>:
.globl vector163
vector163:
  pushl $0
80106f1a:	6a 00                	push   $0x0
  pushl $163
80106f1c:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106f21:	e9 02 f3 ff ff       	jmp    80106228 <alltraps>

80106f26 <vector164>:
.globl vector164
vector164:
  pushl $0
80106f26:	6a 00                	push   $0x0
  pushl $164
80106f28:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106f2d:	e9 f6 f2 ff ff       	jmp    80106228 <alltraps>

80106f32 <vector165>:
.globl vector165
vector165:
  pushl $0
80106f32:	6a 00                	push   $0x0
  pushl $165
80106f34:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106f39:	e9 ea f2 ff ff       	jmp    80106228 <alltraps>

80106f3e <vector166>:
.globl vector166
vector166:
  pushl $0
80106f3e:	6a 00                	push   $0x0
  pushl $166
80106f40:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106f45:	e9 de f2 ff ff       	jmp    80106228 <alltraps>

80106f4a <vector167>:
.globl vector167
vector167:
  pushl $0
80106f4a:	6a 00                	push   $0x0
  pushl $167
80106f4c:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106f51:	e9 d2 f2 ff ff       	jmp    80106228 <alltraps>

80106f56 <vector168>:
.globl vector168
vector168:
  pushl $0
80106f56:	6a 00                	push   $0x0
  pushl $168
80106f58:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106f5d:	e9 c6 f2 ff ff       	jmp    80106228 <alltraps>

80106f62 <vector169>:
.globl vector169
vector169:
  pushl $0
80106f62:	6a 00                	push   $0x0
  pushl $169
80106f64:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106f69:	e9 ba f2 ff ff       	jmp    80106228 <alltraps>

80106f6e <vector170>:
.globl vector170
vector170:
  pushl $0
80106f6e:	6a 00                	push   $0x0
  pushl $170
80106f70:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106f75:	e9 ae f2 ff ff       	jmp    80106228 <alltraps>

80106f7a <vector171>:
.globl vector171
vector171:
  pushl $0
80106f7a:	6a 00                	push   $0x0
  pushl $171
80106f7c:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106f81:	e9 a2 f2 ff ff       	jmp    80106228 <alltraps>

80106f86 <vector172>:
.globl vector172
vector172:
  pushl $0
80106f86:	6a 00                	push   $0x0
  pushl $172
80106f88:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106f8d:	e9 96 f2 ff ff       	jmp    80106228 <alltraps>

80106f92 <vector173>:
.globl vector173
vector173:
  pushl $0
80106f92:	6a 00                	push   $0x0
  pushl $173
80106f94:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106f99:	e9 8a f2 ff ff       	jmp    80106228 <alltraps>

80106f9e <vector174>:
.globl vector174
vector174:
  pushl $0
80106f9e:	6a 00                	push   $0x0
  pushl $174
80106fa0:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106fa5:	e9 7e f2 ff ff       	jmp    80106228 <alltraps>

80106faa <vector175>:
.globl vector175
vector175:
  pushl $0
80106faa:	6a 00                	push   $0x0
  pushl $175
80106fac:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106fb1:	e9 72 f2 ff ff       	jmp    80106228 <alltraps>

80106fb6 <vector176>:
.globl vector176
vector176:
  pushl $0
80106fb6:	6a 00                	push   $0x0
  pushl $176
80106fb8:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106fbd:	e9 66 f2 ff ff       	jmp    80106228 <alltraps>

80106fc2 <vector177>:
.globl vector177
vector177:
  pushl $0
80106fc2:	6a 00                	push   $0x0
  pushl $177
80106fc4:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106fc9:	e9 5a f2 ff ff       	jmp    80106228 <alltraps>

80106fce <vector178>:
.globl vector178
vector178:
  pushl $0
80106fce:	6a 00                	push   $0x0
  pushl $178
80106fd0:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106fd5:	e9 4e f2 ff ff       	jmp    80106228 <alltraps>

80106fda <vector179>:
.globl vector179
vector179:
  pushl $0
80106fda:	6a 00                	push   $0x0
  pushl $179
80106fdc:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106fe1:	e9 42 f2 ff ff       	jmp    80106228 <alltraps>

80106fe6 <vector180>:
.globl vector180
vector180:
  pushl $0
80106fe6:	6a 00                	push   $0x0
  pushl $180
80106fe8:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106fed:	e9 36 f2 ff ff       	jmp    80106228 <alltraps>

80106ff2 <vector181>:
.globl vector181
vector181:
  pushl $0
80106ff2:	6a 00                	push   $0x0
  pushl $181
80106ff4:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106ff9:	e9 2a f2 ff ff       	jmp    80106228 <alltraps>

80106ffe <vector182>:
.globl vector182
vector182:
  pushl $0
80106ffe:	6a 00                	push   $0x0
  pushl $182
80107000:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107005:	e9 1e f2 ff ff       	jmp    80106228 <alltraps>

8010700a <vector183>:
.globl vector183
vector183:
  pushl $0
8010700a:	6a 00                	push   $0x0
  pushl $183
8010700c:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107011:	e9 12 f2 ff ff       	jmp    80106228 <alltraps>

80107016 <vector184>:
.globl vector184
vector184:
  pushl $0
80107016:	6a 00                	push   $0x0
  pushl $184
80107018:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010701d:	e9 06 f2 ff ff       	jmp    80106228 <alltraps>

80107022 <vector185>:
.globl vector185
vector185:
  pushl $0
80107022:	6a 00                	push   $0x0
  pushl $185
80107024:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107029:	e9 fa f1 ff ff       	jmp    80106228 <alltraps>

8010702e <vector186>:
.globl vector186
vector186:
  pushl $0
8010702e:	6a 00                	push   $0x0
  pushl $186
80107030:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107035:	e9 ee f1 ff ff       	jmp    80106228 <alltraps>

8010703a <vector187>:
.globl vector187
vector187:
  pushl $0
8010703a:	6a 00                	push   $0x0
  pushl $187
8010703c:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107041:	e9 e2 f1 ff ff       	jmp    80106228 <alltraps>

80107046 <vector188>:
.globl vector188
vector188:
  pushl $0
80107046:	6a 00                	push   $0x0
  pushl $188
80107048:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010704d:	e9 d6 f1 ff ff       	jmp    80106228 <alltraps>

80107052 <vector189>:
.globl vector189
vector189:
  pushl $0
80107052:	6a 00                	push   $0x0
  pushl $189
80107054:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107059:	e9 ca f1 ff ff       	jmp    80106228 <alltraps>

8010705e <vector190>:
.globl vector190
vector190:
  pushl $0
8010705e:	6a 00                	push   $0x0
  pushl $190
80107060:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107065:	e9 be f1 ff ff       	jmp    80106228 <alltraps>

8010706a <vector191>:
.globl vector191
vector191:
  pushl $0
8010706a:	6a 00                	push   $0x0
  pushl $191
8010706c:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107071:	e9 b2 f1 ff ff       	jmp    80106228 <alltraps>

80107076 <vector192>:
.globl vector192
vector192:
  pushl $0
80107076:	6a 00                	push   $0x0
  pushl $192
80107078:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010707d:	e9 a6 f1 ff ff       	jmp    80106228 <alltraps>

80107082 <vector193>:
.globl vector193
vector193:
  pushl $0
80107082:	6a 00                	push   $0x0
  pushl $193
80107084:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107089:	e9 9a f1 ff ff       	jmp    80106228 <alltraps>

8010708e <vector194>:
.globl vector194
vector194:
  pushl $0
8010708e:	6a 00                	push   $0x0
  pushl $194
80107090:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107095:	e9 8e f1 ff ff       	jmp    80106228 <alltraps>

8010709a <vector195>:
.globl vector195
vector195:
  pushl $0
8010709a:	6a 00                	push   $0x0
  pushl $195
8010709c:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801070a1:	e9 82 f1 ff ff       	jmp    80106228 <alltraps>

801070a6 <vector196>:
.globl vector196
vector196:
  pushl $0
801070a6:	6a 00                	push   $0x0
  pushl $196
801070a8:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801070ad:	e9 76 f1 ff ff       	jmp    80106228 <alltraps>

801070b2 <vector197>:
.globl vector197
vector197:
  pushl $0
801070b2:	6a 00                	push   $0x0
  pushl $197
801070b4:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801070b9:	e9 6a f1 ff ff       	jmp    80106228 <alltraps>

801070be <vector198>:
.globl vector198
vector198:
  pushl $0
801070be:	6a 00                	push   $0x0
  pushl $198
801070c0:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801070c5:	e9 5e f1 ff ff       	jmp    80106228 <alltraps>

801070ca <vector199>:
.globl vector199
vector199:
  pushl $0
801070ca:	6a 00                	push   $0x0
  pushl $199
801070cc:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801070d1:	e9 52 f1 ff ff       	jmp    80106228 <alltraps>

801070d6 <vector200>:
.globl vector200
vector200:
  pushl $0
801070d6:	6a 00                	push   $0x0
  pushl $200
801070d8:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801070dd:	e9 46 f1 ff ff       	jmp    80106228 <alltraps>

801070e2 <vector201>:
.globl vector201
vector201:
  pushl $0
801070e2:	6a 00                	push   $0x0
  pushl $201
801070e4:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801070e9:	e9 3a f1 ff ff       	jmp    80106228 <alltraps>

801070ee <vector202>:
.globl vector202
vector202:
  pushl $0
801070ee:	6a 00                	push   $0x0
  pushl $202
801070f0:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801070f5:	e9 2e f1 ff ff       	jmp    80106228 <alltraps>

801070fa <vector203>:
.globl vector203
vector203:
  pushl $0
801070fa:	6a 00                	push   $0x0
  pushl $203
801070fc:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107101:	e9 22 f1 ff ff       	jmp    80106228 <alltraps>

80107106 <vector204>:
.globl vector204
vector204:
  pushl $0
80107106:	6a 00                	push   $0x0
  pushl $204
80107108:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010710d:	e9 16 f1 ff ff       	jmp    80106228 <alltraps>

80107112 <vector205>:
.globl vector205
vector205:
  pushl $0
80107112:	6a 00                	push   $0x0
  pushl $205
80107114:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107119:	e9 0a f1 ff ff       	jmp    80106228 <alltraps>

8010711e <vector206>:
.globl vector206
vector206:
  pushl $0
8010711e:	6a 00                	push   $0x0
  pushl $206
80107120:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107125:	e9 fe f0 ff ff       	jmp    80106228 <alltraps>

8010712a <vector207>:
.globl vector207
vector207:
  pushl $0
8010712a:	6a 00                	push   $0x0
  pushl $207
8010712c:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107131:	e9 f2 f0 ff ff       	jmp    80106228 <alltraps>

80107136 <vector208>:
.globl vector208
vector208:
  pushl $0
80107136:	6a 00                	push   $0x0
  pushl $208
80107138:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
8010713d:	e9 e6 f0 ff ff       	jmp    80106228 <alltraps>

80107142 <vector209>:
.globl vector209
vector209:
  pushl $0
80107142:	6a 00                	push   $0x0
  pushl $209
80107144:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107149:	e9 da f0 ff ff       	jmp    80106228 <alltraps>

8010714e <vector210>:
.globl vector210
vector210:
  pushl $0
8010714e:	6a 00                	push   $0x0
  pushl $210
80107150:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107155:	e9 ce f0 ff ff       	jmp    80106228 <alltraps>

8010715a <vector211>:
.globl vector211
vector211:
  pushl $0
8010715a:	6a 00                	push   $0x0
  pushl $211
8010715c:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107161:	e9 c2 f0 ff ff       	jmp    80106228 <alltraps>

80107166 <vector212>:
.globl vector212
vector212:
  pushl $0
80107166:	6a 00                	push   $0x0
  pushl $212
80107168:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
8010716d:	e9 b6 f0 ff ff       	jmp    80106228 <alltraps>

80107172 <vector213>:
.globl vector213
vector213:
  pushl $0
80107172:	6a 00                	push   $0x0
  pushl $213
80107174:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107179:	e9 aa f0 ff ff       	jmp    80106228 <alltraps>

8010717e <vector214>:
.globl vector214
vector214:
  pushl $0
8010717e:	6a 00                	push   $0x0
  pushl $214
80107180:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107185:	e9 9e f0 ff ff       	jmp    80106228 <alltraps>

8010718a <vector215>:
.globl vector215
vector215:
  pushl $0
8010718a:	6a 00                	push   $0x0
  pushl $215
8010718c:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107191:	e9 92 f0 ff ff       	jmp    80106228 <alltraps>

80107196 <vector216>:
.globl vector216
vector216:
  pushl $0
80107196:	6a 00                	push   $0x0
  pushl $216
80107198:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
8010719d:	e9 86 f0 ff ff       	jmp    80106228 <alltraps>

801071a2 <vector217>:
.globl vector217
vector217:
  pushl $0
801071a2:	6a 00                	push   $0x0
  pushl $217
801071a4:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801071a9:	e9 7a f0 ff ff       	jmp    80106228 <alltraps>

801071ae <vector218>:
.globl vector218
vector218:
  pushl $0
801071ae:	6a 00                	push   $0x0
  pushl $218
801071b0:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801071b5:	e9 6e f0 ff ff       	jmp    80106228 <alltraps>

801071ba <vector219>:
.globl vector219
vector219:
  pushl $0
801071ba:	6a 00                	push   $0x0
  pushl $219
801071bc:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801071c1:	e9 62 f0 ff ff       	jmp    80106228 <alltraps>

801071c6 <vector220>:
.globl vector220
vector220:
  pushl $0
801071c6:	6a 00                	push   $0x0
  pushl $220
801071c8:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801071cd:	e9 56 f0 ff ff       	jmp    80106228 <alltraps>

801071d2 <vector221>:
.globl vector221
vector221:
  pushl $0
801071d2:	6a 00                	push   $0x0
  pushl $221
801071d4:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801071d9:	e9 4a f0 ff ff       	jmp    80106228 <alltraps>

801071de <vector222>:
.globl vector222
vector222:
  pushl $0
801071de:	6a 00                	push   $0x0
  pushl $222
801071e0:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801071e5:	e9 3e f0 ff ff       	jmp    80106228 <alltraps>

801071ea <vector223>:
.globl vector223
vector223:
  pushl $0
801071ea:	6a 00                	push   $0x0
  pushl $223
801071ec:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801071f1:	e9 32 f0 ff ff       	jmp    80106228 <alltraps>

801071f6 <vector224>:
.globl vector224
vector224:
  pushl $0
801071f6:	6a 00                	push   $0x0
  pushl $224
801071f8:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801071fd:	e9 26 f0 ff ff       	jmp    80106228 <alltraps>

80107202 <vector225>:
.globl vector225
vector225:
  pushl $0
80107202:	6a 00                	push   $0x0
  pushl $225
80107204:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107209:	e9 1a f0 ff ff       	jmp    80106228 <alltraps>

8010720e <vector226>:
.globl vector226
vector226:
  pushl $0
8010720e:	6a 00                	push   $0x0
  pushl $226
80107210:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107215:	e9 0e f0 ff ff       	jmp    80106228 <alltraps>

8010721a <vector227>:
.globl vector227
vector227:
  pushl $0
8010721a:	6a 00                	push   $0x0
  pushl $227
8010721c:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107221:	e9 02 f0 ff ff       	jmp    80106228 <alltraps>

80107226 <vector228>:
.globl vector228
vector228:
  pushl $0
80107226:	6a 00                	push   $0x0
  pushl $228
80107228:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
8010722d:	e9 f6 ef ff ff       	jmp    80106228 <alltraps>

80107232 <vector229>:
.globl vector229
vector229:
  pushl $0
80107232:	6a 00                	push   $0x0
  pushl $229
80107234:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107239:	e9 ea ef ff ff       	jmp    80106228 <alltraps>

8010723e <vector230>:
.globl vector230
vector230:
  pushl $0
8010723e:	6a 00                	push   $0x0
  pushl $230
80107240:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107245:	e9 de ef ff ff       	jmp    80106228 <alltraps>

8010724a <vector231>:
.globl vector231
vector231:
  pushl $0
8010724a:	6a 00                	push   $0x0
  pushl $231
8010724c:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107251:	e9 d2 ef ff ff       	jmp    80106228 <alltraps>

80107256 <vector232>:
.globl vector232
vector232:
  pushl $0
80107256:	6a 00                	push   $0x0
  pushl $232
80107258:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
8010725d:	e9 c6 ef ff ff       	jmp    80106228 <alltraps>

80107262 <vector233>:
.globl vector233
vector233:
  pushl $0
80107262:	6a 00                	push   $0x0
  pushl $233
80107264:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107269:	e9 ba ef ff ff       	jmp    80106228 <alltraps>

8010726e <vector234>:
.globl vector234
vector234:
  pushl $0
8010726e:	6a 00                	push   $0x0
  pushl $234
80107270:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107275:	e9 ae ef ff ff       	jmp    80106228 <alltraps>

8010727a <vector235>:
.globl vector235
vector235:
  pushl $0
8010727a:	6a 00                	push   $0x0
  pushl $235
8010727c:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107281:	e9 a2 ef ff ff       	jmp    80106228 <alltraps>

80107286 <vector236>:
.globl vector236
vector236:
  pushl $0
80107286:	6a 00                	push   $0x0
  pushl $236
80107288:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
8010728d:	e9 96 ef ff ff       	jmp    80106228 <alltraps>

80107292 <vector237>:
.globl vector237
vector237:
  pushl $0
80107292:	6a 00                	push   $0x0
  pushl $237
80107294:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107299:	e9 8a ef ff ff       	jmp    80106228 <alltraps>

8010729e <vector238>:
.globl vector238
vector238:
  pushl $0
8010729e:	6a 00                	push   $0x0
  pushl $238
801072a0:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801072a5:	e9 7e ef ff ff       	jmp    80106228 <alltraps>

801072aa <vector239>:
.globl vector239
vector239:
  pushl $0
801072aa:	6a 00                	push   $0x0
  pushl $239
801072ac:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801072b1:	e9 72 ef ff ff       	jmp    80106228 <alltraps>

801072b6 <vector240>:
.globl vector240
vector240:
  pushl $0
801072b6:	6a 00                	push   $0x0
  pushl $240
801072b8:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801072bd:	e9 66 ef ff ff       	jmp    80106228 <alltraps>

801072c2 <vector241>:
.globl vector241
vector241:
  pushl $0
801072c2:	6a 00                	push   $0x0
  pushl $241
801072c4:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801072c9:	e9 5a ef ff ff       	jmp    80106228 <alltraps>

801072ce <vector242>:
.globl vector242
vector242:
  pushl $0
801072ce:	6a 00                	push   $0x0
  pushl $242
801072d0:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801072d5:	e9 4e ef ff ff       	jmp    80106228 <alltraps>

801072da <vector243>:
.globl vector243
vector243:
  pushl $0
801072da:	6a 00                	push   $0x0
  pushl $243
801072dc:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801072e1:	e9 42 ef ff ff       	jmp    80106228 <alltraps>

801072e6 <vector244>:
.globl vector244
vector244:
  pushl $0
801072e6:	6a 00                	push   $0x0
  pushl $244
801072e8:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801072ed:	e9 36 ef ff ff       	jmp    80106228 <alltraps>

801072f2 <vector245>:
.globl vector245
vector245:
  pushl $0
801072f2:	6a 00                	push   $0x0
  pushl $245
801072f4:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801072f9:	e9 2a ef ff ff       	jmp    80106228 <alltraps>

801072fe <vector246>:
.globl vector246
vector246:
  pushl $0
801072fe:	6a 00                	push   $0x0
  pushl $246
80107300:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107305:	e9 1e ef ff ff       	jmp    80106228 <alltraps>

8010730a <vector247>:
.globl vector247
vector247:
  pushl $0
8010730a:	6a 00                	push   $0x0
  pushl $247
8010730c:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107311:	e9 12 ef ff ff       	jmp    80106228 <alltraps>

80107316 <vector248>:
.globl vector248
vector248:
  pushl $0
80107316:	6a 00                	push   $0x0
  pushl $248
80107318:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010731d:	e9 06 ef ff ff       	jmp    80106228 <alltraps>

80107322 <vector249>:
.globl vector249
vector249:
  pushl $0
80107322:	6a 00                	push   $0x0
  pushl $249
80107324:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107329:	e9 fa ee ff ff       	jmp    80106228 <alltraps>

8010732e <vector250>:
.globl vector250
vector250:
  pushl $0
8010732e:	6a 00                	push   $0x0
  pushl $250
80107330:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107335:	e9 ee ee ff ff       	jmp    80106228 <alltraps>

8010733a <vector251>:
.globl vector251
vector251:
  pushl $0
8010733a:	6a 00                	push   $0x0
  pushl $251
8010733c:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107341:	e9 e2 ee ff ff       	jmp    80106228 <alltraps>

80107346 <vector252>:
.globl vector252
vector252:
  pushl $0
80107346:	6a 00                	push   $0x0
  pushl $252
80107348:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010734d:	e9 d6 ee ff ff       	jmp    80106228 <alltraps>

80107352 <vector253>:
.globl vector253
vector253:
  pushl $0
80107352:	6a 00                	push   $0x0
  pushl $253
80107354:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107359:	e9 ca ee ff ff       	jmp    80106228 <alltraps>

8010735e <vector254>:
.globl vector254
vector254:
  pushl $0
8010735e:	6a 00                	push   $0x0
  pushl $254
80107360:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107365:	e9 be ee ff ff       	jmp    80106228 <alltraps>

8010736a <vector255>:
.globl vector255
vector255:
  pushl $0
8010736a:	6a 00                	push   $0x0
  pushl $255
8010736c:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107371:	e9 b2 ee ff ff       	jmp    80106228 <alltraps>
	...

80107378 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107378:	55                   	push   %ebp
80107379:	89 e5                	mov    %esp,%ebp
8010737b:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010737e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107381:	83 e8 01             	sub    $0x1,%eax
80107384:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107388:	8b 45 08             	mov    0x8(%ebp),%eax
8010738b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010738f:	8b 45 08             	mov    0x8(%ebp),%eax
80107392:	c1 e8 10             	shr    $0x10,%eax
80107395:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107399:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010739c:	0f 01 10             	lgdtl  (%eax)
}
8010739f:	c9                   	leave  
801073a0:	c3                   	ret    

801073a1 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
801073a1:	55                   	push   %ebp
801073a2:	89 e5                	mov    %esp,%ebp
801073a4:	83 ec 04             	sub    $0x4,%esp
801073a7:	8b 45 08             	mov    0x8(%ebp),%eax
801073aa:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801073ae:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801073b2:	0f 00 d8             	ltr    %ax
}
801073b5:	c9                   	leave  
801073b6:	c3                   	ret    

801073b7 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
801073b7:	55                   	push   %ebp
801073b8:	89 e5                	mov    %esp,%ebp
801073ba:	83 ec 04             	sub    $0x4,%esp
801073bd:	8b 45 08             	mov    0x8(%ebp),%eax
801073c0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
801073c4:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801073c8:	8e e8                	mov    %eax,%gs
}
801073ca:	c9                   	leave  
801073cb:	c3                   	ret    

801073cc <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
801073cc:	55                   	push   %ebp
801073cd:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801073cf:	8b 45 08             	mov    0x8(%ebp),%eax
801073d2:	0f 22 d8             	mov    %eax,%cr3
}
801073d5:	5d                   	pop    %ebp
801073d6:	c3                   	ret    

801073d7 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801073d7:	55                   	push   %ebp
801073d8:	89 e5                	mov    %esp,%ebp
801073da:	8b 45 08             	mov    0x8(%ebp),%eax
801073dd:	2d 00 00 00 80       	sub    $0x80000000,%eax
801073e2:	5d                   	pop    %ebp
801073e3:	c3                   	ret    

801073e4 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801073e4:	55                   	push   %ebp
801073e5:	89 e5                	mov    %esp,%ebp
801073e7:	8b 45 08             	mov    0x8(%ebp),%eax
801073ea:	2d 00 00 00 80       	sub    $0x80000000,%eax
801073ef:	5d                   	pop    %ebp
801073f0:	c3                   	ret    

801073f1 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801073f1:	55                   	push   %ebp
801073f2:	89 e5                	mov    %esp,%ebp
801073f4:	53                   	push   %ebx
801073f5:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
801073f8:	e8 b5 ba ff ff       	call   80102eb2 <cpunum>
801073fd:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80107403:	05 20 f9 10 80       	add    $0x8010f920,%eax
80107408:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010740b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010740e:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107414:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107417:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
8010741d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107420:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107424:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107427:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010742b:	83 e2 f0             	and    $0xfffffff0,%edx
8010742e:	83 ca 0a             	or     $0xa,%edx
80107431:	88 50 7d             	mov    %dl,0x7d(%eax)
80107434:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107437:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010743b:	83 ca 10             	or     $0x10,%edx
8010743e:	88 50 7d             	mov    %dl,0x7d(%eax)
80107441:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107444:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107448:	83 e2 9f             	and    $0xffffff9f,%edx
8010744b:	88 50 7d             	mov    %dl,0x7d(%eax)
8010744e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107451:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107455:	83 ca 80             	or     $0xffffff80,%edx
80107458:	88 50 7d             	mov    %dl,0x7d(%eax)
8010745b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010745e:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107462:	83 ca 0f             	or     $0xf,%edx
80107465:	88 50 7e             	mov    %dl,0x7e(%eax)
80107468:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010746b:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010746f:	83 e2 ef             	and    $0xffffffef,%edx
80107472:	88 50 7e             	mov    %dl,0x7e(%eax)
80107475:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107478:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010747c:	83 e2 df             	and    $0xffffffdf,%edx
8010747f:	88 50 7e             	mov    %dl,0x7e(%eax)
80107482:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107485:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107489:	83 ca 40             	or     $0x40,%edx
8010748c:	88 50 7e             	mov    %dl,0x7e(%eax)
8010748f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107492:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107496:	83 ca 80             	or     $0xffffff80,%edx
80107499:	88 50 7e             	mov    %dl,0x7e(%eax)
8010749c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010749f:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801074a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074a6:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801074ad:	ff ff 
801074af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074b2:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801074b9:	00 00 
801074bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074be:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801074c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074c8:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801074cf:	83 e2 f0             	and    $0xfffffff0,%edx
801074d2:	83 ca 02             	or     $0x2,%edx
801074d5:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801074db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074de:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801074e5:	83 ca 10             	or     $0x10,%edx
801074e8:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801074ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074f1:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801074f8:	83 e2 9f             	and    $0xffffff9f,%edx
801074fb:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107501:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107504:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010750b:	83 ca 80             	or     $0xffffff80,%edx
8010750e:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107514:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107517:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010751e:	83 ca 0f             	or     $0xf,%edx
80107521:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107527:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010752a:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107531:	83 e2 ef             	and    $0xffffffef,%edx
80107534:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010753a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010753d:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107544:	83 e2 df             	and    $0xffffffdf,%edx
80107547:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010754d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107550:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107557:	83 ca 40             	or     $0x40,%edx
8010755a:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107560:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107563:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010756a:	83 ca 80             	or     $0xffffff80,%edx
8010756d:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107573:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107576:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
8010757d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107580:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107587:	ff ff 
80107589:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010758c:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107593:	00 00 
80107595:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107598:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
8010759f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075a2:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801075a9:	83 e2 f0             	and    $0xfffffff0,%edx
801075ac:	83 ca 0a             	or     $0xa,%edx
801075af:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801075b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075b8:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801075bf:	83 ca 10             	or     $0x10,%edx
801075c2:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801075c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075cb:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801075d2:	83 ca 60             	or     $0x60,%edx
801075d5:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801075db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075de:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801075e5:	83 ca 80             	or     $0xffffff80,%edx
801075e8:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801075ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075f1:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801075f8:	83 ca 0f             	or     $0xf,%edx
801075fb:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107601:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107604:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010760b:	83 e2 ef             	and    $0xffffffef,%edx
8010760e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107614:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107617:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010761e:	83 e2 df             	and    $0xffffffdf,%edx
80107621:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107627:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010762a:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107631:	83 ca 40             	or     $0x40,%edx
80107634:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010763a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010763d:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107644:	83 ca 80             	or     $0xffffff80,%edx
80107647:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010764d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107650:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107657:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010765a:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107661:	ff ff 
80107663:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107666:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
8010766d:	00 00 
8010766f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107672:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107679:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010767c:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107683:	83 e2 f0             	and    $0xfffffff0,%edx
80107686:	83 ca 02             	or     $0x2,%edx
80107689:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010768f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107692:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107699:	83 ca 10             	or     $0x10,%edx
8010769c:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801076a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076a5:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801076ac:	83 ca 60             	or     $0x60,%edx
801076af:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801076b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076b8:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801076bf:	83 ca 80             	or     $0xffffff80,%edx
801076c2:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801076c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076cb:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801076d2:	83 ca 0f             	or     $0xf,%edx
801076d5:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801076db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076de:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801076e5:	83 e2 ef             	and    $0xffffffef,%edx
801076e8:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801076ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076f1:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801076f8:	83 e2 df             	and    $0xffffffdf,%edx
801076fb:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107701:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107704:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010770b:	83 ca 40             	or     $0x40,%edx
8010770e:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107714:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107717:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010771e:	83 ca 80             	or     $0xffffff80,%edx
80107721:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107727:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010772a:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107731:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107734:	05 b4 00 00 00       	add    $0xb4,%eax
80107739:	89 c3                	mov    %eax,%ebx
8010773b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010773e:	05 b4 00 00 00       	add    $0xb4,%eax
80107743:	c1 e8 10             	shr    $0x10,%eax
80107746:	89 c1                	mov    %eax,%ecx
80107748:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010774b:	05 b4 00 00 00       	add    $0xb4,%eax
80107750:	c1 e8 18             	shr    $0x18,%eax
80107753:	89 c2                	mov    %eax,%edx
80107755:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107758:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
8010775f:	00 00 
80107761:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107764:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
8010776b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010776e:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
80107774:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107777:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
8010777e:	83 e1 f0             	and    $0xfffffff0,%ecx
80107781:	83 c9 02             	or     $0x2,%ecx
80107784:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
8010778a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010778d:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107794:	83 c9 10             	or     $0x10,%ecx
80107797:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
8010779d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077a0:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
801077a7:	83 e1 9f             	and    $0xffffff9f,%ecx
801077aa:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
801077b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077b3:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
801077ba:	83 c9 80             	or     $0xffffff80,%ecx
801077bd:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
801077c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077c6:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
801077cd:	83 e1 f0             	and    $0xfffffff0,%ecx
801077d0:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
801077d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077d9:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
801077e0:	83 e1 ef             	and    $0xffffffef,%ecx
801077e3:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
801077e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ec:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
801077f3:	83 e1 df             	and    $0xffffffdf,%ecx
801077f6:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
801077fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ff:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107806:	83 c9 40             	or     $0x40,%ecx
80107809:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
8010780f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107812:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107819:	83 c9 80             	or     $0xffffff80,%ecx
8010781c:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107822:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107825:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
8010782b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010782e:	83 c0 70             	add    $0x70,%eax
80107831:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
80107838:	00 
80107839:	89 04 24             	mov    %eax,(%esp)
8010783c:	e8 37 fb ff ff       	call   80107378 <lgdt>
  loadgs(SEG_KCPU << 3);
80107841:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80107848:	e8 6a fb ff ff       	call   801073b7 <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
8010784d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107850:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107856:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
8010785d:	00 00 00 00 
}
80107861:	83 c4 24             	add    $0x24,%esp
80107864:	5b                   	pop    %ebx
80107865:	5d                   	pop    %ebp
80107866:	c3                   	ret    

80107867 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107867:	55                   	push   %ebp
80107868:	89 e5                	mov    %esp,%ebp
8010786a:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
8010786d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107870:	c1 e8 16             	shr    $0x16,%eax
80107873:	c1 e0 02             	shl    $0x2,%eax
80107876:	03 45 08             	add    0x8(%ebp),%eax
80107879:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
8010787c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010787f:	8b 00                	mov    (%eax),%eax
80107881:	83 e0 01             	and    $0x1,%eax
80107884:	84 c0                	test   %al,%al
80107886:	74 17                	je     8010789f <walkpgdir+0x38>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107888:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010788b:	8b 00                	mov    (%eax),%eax
8010788d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107892:	89 04 24             	mov    %eax,(%esp)
80107895:	e8 4a fb ff ff       	call   801073e4 <p2v>
8010789a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010789d:	eb 4b                	jmp    801078ea <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
8010789f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801078a3:	74 0e                	je     801078b3 <walkpgdir+0x4c>
801078a5:	e8 78 b2 ff ff       	call   80102b22 <kalloc>
801078aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
801078ad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801078b1:	75 07                	jne    801078ba <walkpgdir+0x53>
      return 0;
801078b3:	b8 00 00 00 00       	mov    $0x0,%eax
801078b8:	eb 41                	jmp    801078fb <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801078ba:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801078c1:	00 
801078c2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801078c9:	00 
801078ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078cd:	89 04 24             	mov    %eax,(%esp)
801078d0:	e8 25 d5 ff ff       	call   80104dfa <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
801078d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078d8:	89 04 24             	mov    %eax,(%esp)
801078db:	e8 f7 fa ff ff       	call   801073d7 <v2p>
801078e0:	89 c2                	mov    %eax,%edx
801078e2:	83 ca 07             	or     $0x7,%edx
801078e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801078e8:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801078ea:	8b 45 0c             	mov    0xc(%ebp),%eax
801078ed:	c1 e8 0c             	shr    $0xc,%eax
801078f0:	25 ff 03 00 00       	and    $0x3ff,%eax
801078f5:	c1 e0 02             	shl    $0x2,%eax
801078f8:	03 45 f4             	add    -0xc(%ebp),%eax
}
801078fb:	c9                   	leave  
801078fc:	c3                   	ret    

801078fd <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
801078fd:	55                   	push   %ebp
801078fe:	89 e5                	mov    %esp,%ebp
80107900:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107903:	8b 45 0c             	mov    0xc(%ebp),%eax
80107906:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010790b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
8010790e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107911:	03 45 10             	add    0x10(%ebp),%eax
80107914:	83 e8 01             	sub    $0x1,%eax
80107917:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010791c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010791f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80107926:	00 
80107927:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010792a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010792e:	8b 45 08             	mov    0x8(%ebp),%eax
80107931:	89 04 24             	mov    %eax,(%esp)
80107934:	e8 2e ff ff ff       	call   80107867 <walkpgdir>
80107939:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010793c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107940:	75 07                	jne    80107949 <mappages+0x4c>
      return -1;
80107942:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107947:	eb 47                	jmp    80107990 <mappages+0x93>
    if(*pte & PTE_P)
80107949:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010794c:	8b 00                	mov    (%eax),%eax
8010794e:	83 e0 01             	and    $0x1,%eax
80107951:	84 c0                	test   %al,%al
80107953:	74 0c                	je     80107961 <mappages+0x64>
      panic("remap");
80107955:	c7 04 24 94 87 10 80 	movl   $0x80108794,(%esp)
8010795c:	e8 e5 8b ff ff       	call   80100546 <panic>
    *pte = pa | perm | PTE_P;
80107961:	8b 45 18             	mov    0x18(%ebp),%eax
80107964:	0b 45 14             	or     0x14(%ebp),%eax
80107967:	89 c2                	mov    %eax,%edx
80107969:	83 ca 01             	or     $0x1,%edx
8010796c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010796f:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107971:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107974:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107977:	75 07                	jne    80107980 <mappages+0x83>
      break;
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107979:	b8 00 00 00 00       	mov    $0x0,%eax
8010797e:	eb 10                	jmp    80107990 <mappages+0x93>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
80107980:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107987:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
8010798e:	eb 8f                	jmp    8010791f <mappages+0x22>
  return 0;
}
80107990:	c9                   	leave  
80107991:	c3                   	ret    

80107992 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm()
{
80107992:	55                   	push   %ebp
80107993:	89 e5                	mov    %esp,%ebp
80107995:	53                   	push   %ebx
80107996:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107999:	e8 84 b1 ff ff       	call   80102b22 <kalloc>
8010799e:	89 45 f0             	mov    %eax,-0x10(%ebp)
801079a1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801079a5:	75 0a                	jne    801079b1 <setupkvm+0x1f>
    return 0;
801079a7:	b8 00 00 00 00       	mov    $0x0,%eax
801079ac:	e9 99 00 00 00       	jmp    80107a4a <setupkvm+0xb8>
  memset(pgdir, 0, PGSIZE);
801079b1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801079b8:	00 
801079b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801079c0:	00 
801079c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801079c4:	89 04 24             	mov    %eax,(%esp)
801079c7:	e8 2e d4 ff ff       	call   80104dfa <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
801079cc:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
801079d3:	e8 0c fa ff ff       	call   801073e4 <p2v>
801079d8:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
801079dd:	76 0c                	jbe    801079eb <setupkvm+0x59>
    panic("PHYSTOP too high");
801079df:	c7 04 24 9a 87 10 80 	movl   $0x8010879a,(%esp)
801079e6:	e8 5b 8b ff ff       	call   80100546 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801079eb:	c7 45 f4 a0 b4 10 80 	movl   $0x8010b4a0,-0xc(%ebp)
801079f2:	eb 49                	jmp    80107a3d <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
801079f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
801079f7:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
801079fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
801079fd:	8b 50 04             	mov    0x4(%eax),%edx
80107a00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a03:	8b 58 08             	mov    0x8(%eax),%ebx
80107a06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a09:	8b 40 04             	mov    0x4(%eax),%eax
80107a0c:	29 c3                	sub    %eax,%ebx
80107a0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a11:	8b 00                	mov    (%eax),%eax
80107a13:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80107a17:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107a1b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107a1f:	89 44 24 04          	mov    %eax,0x4(%esp)
80107a23:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a26:	89 04 24             	mov    %eax,(%esp)
80107a29:	e8 cf fe ff ff       	call   801078fd <mappages>
80107a2e:	85 c0                	test   %eax,%eax
80107a30:	79 07                	jns    80107a39 <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80107a32:	b8 00 00 00 00       	mov    $0x0,%eax
80107a37:	eb 11                	jmp    80107a4a <setupkvm+0xb8>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107a39:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107a3d:	b8 e0 b4 10 80       	mov    $0x8010b4e0,%eax
80107a42:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80107a45:	72 ad                	jb     801079f4 <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80107a47:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107a4a:	83 c4 34             	add    $0x34,%esp
80107a4d:	5b                   	pop    %ebx
80107a4e:	5d                   	pop    %ebp
80107a4f:	c3                   	ret    

80107a50 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107a50:	55                   	push   %ebp
80107a51:	89 e5                	mov    %esp,%ebp
80107a53:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107a56:	e8 37 ff ff ff       	call   80107992 <setupkvm>
80107a5b:	a3 18 2a 11 80       	mov    %eax,0x80112a18
  switchkvm();
80107a60:	e8 02 00 00 00       	call   80107a67 <switchkvm>
}
80107a65:	c9                   	leave  
80107a66:	c3                   	ret    

80107a67 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107a67:	55                   	push   %ebp
80107a68:	89 e5                	mov    %esp,%ebp
80107a6a:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80107a6d:	a1 18 2a 11 80       	mov    0x80112a18,%eax
80107a72:	89 04 24             	mov    %eax,(%esp)
80107a75:	e8 5d f9 ff ff       	call   801073d7 <v2p>
80107a7a:	89 04 24             	mov    %eax,(%esp)
80107a7d:	e8 4a f9 ff ff       	call   801073cc <lcr3>
}
80107a82:	c9                   	leave  
80107a83:	c3                   	ret    

80107a84 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107a84:	55                   	push   %ebp
80107a85:	89 e5                	mov    %esp,%ebp
80107a87:	53                   	push   %ebx
80107a88:	83 ec 14             	sub    $0x14,%esp
  pushcli();
80107a8b:	e8 65 d2 ff ff       	call   80104cf5 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80107a90:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107a96:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107a9d:	83 c2 08             	add    $0x8,%edx
80107aa0:	89 d3                	mov    %edx,%ebx
80107aa2:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107aa9:	83 c2 08             	add    $0x8,%edx
80107aac:	c1 ea 10             	shr    $0x10,%edx
80107aaf:	89 d1                	mov    %edx,%ecx
80107ab1:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107ab8:	83 c2 08             	add    $0x8,%edx
80107abb:	c1 ea 18             	shr    $0x18,%edx
80107abe:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80107ac5:	67 00 
80107ac7:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
80107ace:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
80107ad4:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107adb:	83 e1 f0             	and    $0xfffffff0,%ecx
80107ade:	83 c9 09             	or     $0x9,%ecx
80107ae1:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107ae7:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107aee:	83 c9 10             	or     $0x10,%ecx
80107af1:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107af7:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107afe:	83 e1 9f             	and    $0xffffff9f,%ecx
80107b01:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107b07:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107b0e:	83 c9 80             	or     $0xffffff80,%ecx
80107b11:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107b17:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107b1e:	83 e1 f0             	and    $0xfffffff0,%ecx
80107b21:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107b27:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107b2e:	83 e1 ef             	and    $0xffffffef,%ecx
80107b31:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107b37:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107b3e:	83 e1 df             	and    $0xffffffdf,%ecx
80107b41:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107b47:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107b4e:	83 c9 40             	or     $0x40,%ecx
80107b51:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107b57:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107b5e:	83 e1 7f             	and    $0x7f,%ecx
80107b61:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107b67:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80107b6d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107b73:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107b7a:	83 e2 ef             	and    $0xffffffef,%edx
80107b7d:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80107b83:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107b89:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80107b8f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107b95:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80107b9c:	8b 52 08             	mov    0x8(%edx),%edx
80107b9f:	81 c2 00 10 00 00    	add    $0x1000,%edx
80107ba5:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80107ba8:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
80107baf:	e8 ed f7 ff ff       	call   801073a1 <ltr>
  if(p->pgdir == 0)
80107bb4:	8b 45 08             	mov    0x8(%ebp),%eax
80107bb7:	8b 40 04             	mov    0x4(%eax),%eax
80107bba:	85 c0                	test   %eax,%eax
80107bbc:	75 0c                	jne    80107bca <switchuvm+0x146>
    panic("switchuvm: no pgdir");
80107bbe:	c7 04 24 ab 87 10 80 	movl   $0x801087ab,(%esp)
80107bc5:	e8 7c 89 ff ff       	call   80100546 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80107bca:	8b 45 08             	mov    0x8(%ebp),%eax
80107bcd:	8b 40 04             	mov    0x4(%eax),%eax
80107bd0:	89 04 24             	mov    %eax,(%esp)
80107bd3:	e8 ff f7 ff ff       	call   801073d7 <v2p>
80107bd8:	89 04 24             	mov    %eax,(%esp)
80107bdb:	e8 ec f7 ff ff       	call   801073cc <lcr3>
  popcli();
80107be0:	e8 58 d1 ff ff       	call   80104d3d <popcli>
}
80107be5:	83 c4 14             	add    $0x14,%esp
80107be8:	5b                   	pop    %ebx
80107be9:	5d                   	pop    %ebp
80107bea:	c3                   	ret    

80107beb <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107beb:	55                   	push   %ebp
80107bec:	89 e5                	mov    %esp,%ebp
80107bee:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80107bf1:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107bf8:	76 0c                	jbe    80107c06 <inituvm+0x1b>
    panic("inituvm: more than a page");
80107bfa:	c7 04 24 bf 87 10 80 	movl   $0x801087bf,(%esp)
80107c01:	e8 40 89 ff ff       	call   80100546 <panic>
  mem = kalloc();
80107c06:	e8 17 af ff ff       	call   80102b22 <kalloc>
80107c0b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107c0e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107c15:	00 
80107c16:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107c1d:	00 
80107c1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c21:	89 04 24             	mov    %eax,(%esp)
80107c24:	e8 d1 d1 ff ff       	call   80104dfa <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80107c29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c2c:	89 04 24             	mov    %eax,(%esp)
80107c2f:	e8 a3 f7 ff ff       	call   801073d7 <v2p>
80107c34:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80107c3b:	00 
80107c3c:	89 44 24 0c          	mov    %eax,0xc(%esp)
80107c40:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107c47:	00 
80107c48:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107c4f:	00 
80107c50:	8b 45 08             	mov    0x8(%ebp),%eax
80107c53:	89 04 24             	mov    %eax,(%esp)
80107c56:	e8 a2 fc ff ff       	call   801078fd <mappages>
  memmove(mem, init, sz);
80107c5b:	8b 45 10             	mov    0x10(%ebp),%eax
80107c5e:	89 44 24 08          	mov    %eax,0x8(%esp)
80107c62:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c65:	89 44 24 04          	mov    %eax,0x4(%esp)
80107c69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c6c:	89 04 24             	mov    %eax,(%esp)
80107c6f:	e8 59 d2 ff ff       	call   80104ecd <memmove>
}
80107c74:	c9                   	leave  
80107c75:	c3                   	ret    

80107c76 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107c76:	55                   	push   %ebp
80107c77:	89 e5                	mov    %esp,%ebp
80107c79:	53                   	push   %ebx
80107c7a:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107c7d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c80:	25 ff 0f 00 00       	and    $0xfff,%eax
80107c85:	85 c0                	test   %eax,%eax
80107c87:	74 0c                	je     80107c95 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107c89:	c7 04 24 dc 87 10 80 	movl   $0x801087dc,(%esp)
80107c90:	e8 b1 88 ff ff       	call   80100546 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107c95:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107c9c:	e9 ae 00 00 00       	jmp    80107d4f <loaduvm+0xd9>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107ca1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca4:	8b 55 0c             	mov    0xc(%ebp),%edx
80107ca7:	8d 04 02             	lea    (%edx,%eax,1),%eax
80107caa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80107cb1:	00 
80107cb2:	89 44 24 04          	mov    %eax,0x4(%esp)
80107cb6:	8b 45 08             	mov    0x8(%ebp),%eax
80107cb9:	89 04 24             	mov    %eax,(%esp)
80107cbc:	e8 a6 fb ff ff       	call   80107867 <walkpgdir>
80107cc1:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107cc4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107cc8:	75 0c                	jne    80107cd6 <loaduvm+0x60>
      panic("loaduvm: address should exist");
80107cca:	c7 04 24 ff 87 10 80 	movl   $0x801087ff,(%esp)
80107cd1:	e8 70 88 ff ff       	call   80100546 <panic>
    pa = PTE_ADDR(*pte);
80107cd6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107cd9:	8b 00                	mov    (%eax),%eax
80107cdb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ce0:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107ce3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce6:	8b 55 18             	mov    0x18(%ebp),%edx
80107ce9:	89 d1                	mov    %edx,%ecx
80107ceb:	29 c1                	sub    %eax,%ecx
80107ced:	89 c8                	mov    %ecx,%eax
80107cef:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107cf4:	77 11                	ja     80107d07 <loaduvm+0x91>
      n = sz - i;
80107cf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cf9:	8b 55 18             	mov    0x18(%ebp),%edx
80107cfc:	89 d1                	mov    %edx,%ecx
80107cfe:	29 c1                	sub    %eax,%ecx
80107d00:	89 c8                	mov    %ecx,%eax
80107d02:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107d05:	eb 07                	jmp    80107d0e <loaduvm+0x98>
    else
      n = PGSIZE;
80107d07:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80107d0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d11:	8b 55 14             	mov    0x14(%ebp),%edx
80107d14:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80107d17:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107d1a:	89 04 24             	mov    %eax,(%esp)
80107d1d:	e8 c2 f6 ff ff       	call   801073e4 <p2v>
80107d22:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107d25:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107d29:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107d2d:	89 44 24 04          	mov    %eax,0x4(%esp)
80107d31:	8b 45 10             	mov    0x10(%ebp),%eax
80107d34:	89 04 24             	mov    %eax,(%esp)
80107d37:	e8 40 a0 ff ff       	call   80101d7c <readi>
80107d3c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107d3f:	74 07                	je     80107d48 <loaduvm+0xd2>
      return -1;
80107d41:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d46:	eb 18                	jmp    80107d60 <loaduvm+0xea>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80107d48:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107d4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d52:	3b 45 18             	cmp    0x18(%ebp),%eax
80107d55:	0f 82 46 ff ff ff    	jb     80107ca1 <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80107d5b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107d60:	83 c4 24             	add    $0x24,%esp
80107d63:	5b                   	pop    %ebx
80107d64:	5d                   	pop    %ebp
80107d65:	c3                   	ret    

80107d66 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107d66:	55                   	push   %ebp
80107d67:	89 e5                	mov    %esp,%ebp
80107d69:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107d6c:	8b 45 10             	mov    0x10(%ebp),%eax
80107d6f:	85 c0                	test   %eax,%eax
80107d71:	79 0a                	jns    80107d7d <allocuvm+0x17>
    return 0;
80107d73:	b8 00 00 00 00       	mov    $0x0,%eax
80107d78:	e9 c1 00 00 00       	jmp    80107e3e <allocuvm+0xd8>
  if(newsz < oldsz)
80107d7d:	8b 45 10             	mov    0x10(%ebp),%eax
80107d80:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107d83:	73 08                	jae    80107d8d <allocuvm+0x27>
    return oldsz;
80107d85:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d88:	e9 b1 00 00 00       	jmp    80107e3e <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
80107d8d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d90:	05 ff 0f 00 00       	add    $0xfff,%eax
80107d95:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d9a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107d9d:	e9 8d 00 00 00       	jmp    80107e2f <allocuvm+0xc9>
    mem = kalloc();
80107da2:	e8 7b ad ff ff       	call   80102b22 <kalloc>
80107da7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107daa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107dae:	75 2c                	jne    80107ddc <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
80107db0:	c7 04 24 1d 88 10 80 	movl   $0x8010881d,(%esp)
80107db7:	e8 e9 85 ff ff       	call   801003a5 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80107dbc:	8b 45 0c             	mov    0xc(%ebp),%eax
80107dbf:	89 44 24 08          	mov    %eax,0x8(%esp)
80107dc3:	8b 45 10             	mov    0x10(%ebp),%eax
80107dc6:	89 44 24 04          	mov    %eax,0x4(%esp)
80107dca:	8b 45 08             	mov    0x8(%ebp),%eax
80107dcd:	89 04 24             	mov    %eax,(%esp)
80107dd0:	e8 6b 00 00 00       	call   80107e40 <deallocuvm>
      return 0;
80107dd5:	b8 00 00 00 00       	mov    $0x0,%eax
80107dda:	eb 62                	jmp    80107e3e <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
80107ddc:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107de3:	00 
80107de4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107deb:	00 
80107dec:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107def:	89 04 24             	mov    %eax,(%esp)
80107df2:	e8 03 d0 ff ff       	call   80104dfa <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80107df7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107dfa:	89 04 24             	mov    %eax,(%esp)
80107dfd:	e8 d5 f5 ff ff       	call   801073d7 <v2p>
80107e02:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107e05:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80107e0c:	00 
80107e0d:	89 44 24 0c          	mov    %eax,0xc(%esp)
80107e11:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107e18:	00 
80107e19:	89 54 24 04          	mov    %edx,0x4(%esp)
80107e1d:	8b 45 08             	mov    0x8(%ebp),%eax
80107e20:	89 04 24             	mov    %eax,(%esp)
80107e23:	e8 d5 fa ff ff       	call   801078fd <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80107e28:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107e2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e32:	3b 45 10             	cmp    0x10(%ebp),%eax
80107e35:	0f 82 67 ff ff ff    	jb     80107da2 <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80107e3b:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107e3e:	c9                   	leave  
80107e3f:	c3                   	ret    

80107e40 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107e40:	55                   	push   %ebp
80107e41:	89 e5                	mov    %esp,%ebp
80107e43:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107e46:	8b 45 10             	mov    0x10(%ebp),%eax
80107e49:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107e4c:	72 08                	jb     80107e56 <deallocuvm+0x16>
    return oldsz;
80107e4e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e51:	e9 a4 00 00 00       	jmp    80107efa <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
80107e56:	8b 45 10             	mov    0x10(%ebp),%eax
80107e59:	05 ff 0f 00 00       	add    $0xfff,%eax
80107e5e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e63:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107e66:	e9 80 00 00 00       	jmp    80107eeb <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107e6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e6e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80107e75:	00 
80107e76:	89 44 24 04          	mov    %eax,0x4(%esp)
80107e7a:	8b 45 08             	mov    0x8(%ebp),%eax
80107e7d:	89 04 24             	mov    %eax,(%esp)
80107e80:	e8 e2 f9 ff ff       	call   80107867 <walkpgdir>
80107e85:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107e88:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107e8c:	75 09                	jne    80107e97 <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
80107e8e:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80107e95:	eb 4d                	jmp    80107ee4 <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
80107e97:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e9a:	8b 00                	mov    (%eax),%eax
80107e9c:	83 e0 01             	and    $0x1,%eax
80107e9f:	84 c0                	test   %al,%al
80107ea1:	74 41                	je     80107ee4 <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
80107ea3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ea6:	8b 00                	mov    (%eax),%eax
80107ea8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ead:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107eb0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107eb4:	75 0c                	jne    80107ec2 <deallocuvm+0x82>
        panic("kfree");
80107eb6:	c7 04 24 35 88 10 80 	movl   $0x80108835,(%esp)
80107ebd:	e8 84 86 ff ff       	call   80100546 <panic>
      char *v = p2v(pa);
80107ec2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ec5:	89 04 24             	mov    %eax,(%esp)
80107ec8:	e8 17 f5 ff ff       	call   801073e4 <p2v>
80107ecd:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107ed0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107ed3:	89 04 24             	mov    %eax,(%esp)
80107ed6:	e8 ae ab ff ff       	call   80102a89 <kfree>
      *pte = 0;
80107edb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ede:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80107ee4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107eeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eee:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107ef1:	0f 82 74 ff ff ff    	jb     80107e6b <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80107ef7:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107efa:	c9                   	leave  
80107efb:	c3                   	ret    

80107efc <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107efc:	55                   	push   %ebp
80107efd:	89 e5                	mov    %esp,%ebp
80107eff:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80107f02:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107f06:	75 0c                	jne    80107f14 <freevm+0x18>
    panic("freevm: no pgdir");
80107f08:	c7 04 24 3b 88 10 80 	movl   $0x8010883b,(%esp)
80107f0f:	e8 32 86 ff ff       	call   80100546 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107f14:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80107f1b:	00 
80107f1c:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80107f23:	80 
80107f24:	8b 45 08             	mov    0x8(%ebp),%eax
80107f27:	89 04 24             	mov    %eax,(%esp)
80107f2a:	e8 11 ff ff ff       	call   80107e40 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80107f2f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107f36:	eb 3c                	jmp    80107f74 <freevm+0x78>
    if(pgdir[i] & PTE_P){
80107f38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f3b:	c1 e0 02             	shl    $0x2,%eax
80107f3e:	03 45 08             	add    0x8(%ebp),%eax
80107f41:	8b 00                	mov    (%eax),%eax
80107f43:	83 e0 01             	and    $0x1,%eax
80107f46:	84 c0                	test   %al,%al
80107f48:	74 26                	je     80107f70 <freevm+0x74>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80107f4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f4d:	c1 e0 02             	shl    $0x2,%eax
80107f50:	03 45 08             	add    0x8(%ebp),%eax
80107f53:	8b 00                	mov    (%eax),%eax
80107f55:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f5a:	89 04 24             	mov    %eax,(%esp)
80107f5d:	e8 82 f4 ff ff       	call   801073e4 <p2v>
80107f62:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107f65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f68:	89 04 24             	mov    %eax,(%esp)
80107f6b:	e8 19 ab ff ff       	call   80102a89 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80107f70:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107f74:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107f7b:	76 bb                	jbe    80107f38 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80107f7d:	8b 45 08             	mov    0x8(%ebp),%eax
80107f80:	89 04 24             	mov    %eax,(%esp)
80107f83:	e8 01 ab ff ff       	call   80102a89 <kfree>
}
80107f88:	c9                   	leave  
80107f89:	c3                   	ret    

80107f8a <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107f8a:	55                   	push   %ebp
80107f8b:	89 e5                	mov    %esp,%ebp
80107f8d:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107f90:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80107f97:	00 
80107f98:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f9b:	89 44 24 04          	mov    %eax,0x4(%esp)
80107f9f:	8b 45 08             	mov    0x8(%ebp),%eax
80107fa2:	89 04 24             	mov    %eax,(%esp)
80107fa5:	e8 bd f8 ff ff       	call   80107867 <walkpgdir>
80107faa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107fad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107fb1:	75 0c                	jne    80107fbf <clearpteu+0x35>
    panic("clearpteu");
80107fb3:	c7 04 24 4c 88 10 80 	movl   $0x8010884c,(%esp)
80107fba:	e8 87 85 ff ff       	call   80100546 <panic>
  *pte &= ~PTE_U;
80107fbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fc2:	8b 00                	mov    (%eax),%eax
80107fc4:	89 c2                	mov    %eax,%edx
80107fc6:	83 e2 fb             	and    $0xfffffffb,%edx
80107fc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fcc:	89 10                	mov    %edx,(%eax)
}
80107fce:	c9                   	leave  
80107fcf:	c3                   	ret    

80107fd0 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107fd0:	55                   	push   %ebp
80107fd1:	89 e5                	mov    %esp,%ebp
80107fd3:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
80107fd6:	e8 b7 f9 ff ff       	call   80107992 <setupkvm>
80107fdb:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107fde:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107fe2:	75 0a                	jne    80107fee <copyuvm+0x1e>
    return 0;
80107fe4:	b8 00 00 00 00       	mov    $0x0,%eax
80107fe9:	e9 f1 00 00 00       	jmp    801080df <copyuvm+0x10f>
  for(i = 0; i < sz; i += PGSIZE){
80107fee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107ff5:	e9 c0 00 00 00       	jmp    801080ba <copyuvm+0xea>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107ffa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ffd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108004:	00 
80108005:	89 44 24 04          	mov    %eax,0x4(%esp)
80108009:	8b 45 08             	mov    0x8(%ebp),%eax
8010800c:	89 04 24             	mov    %eax,(%esp)
8010800f:	e8 53 f8 ff ff       	call   80107867 <walkpgdir>
80108014:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108017:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010801b:	75 0c                	jne    80108029 <copyuvm+0x59>
      panic("copyuvm: pte should exist");
8010801d:	c7 04 24 56 88 10 80 	movl   $0x80108856,(%esp)
80108024:	e8 1d 85 ff ff       	call   80100546 <panic>
    if(!(*pte & PTE_P))
80108029:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010802c:	8b 00                	mov    (%eax),%eax
8010802e:	83 e0 01             	and    $0x1,%eax
80108031:	85 c0                	test   %eax,%eax
80108033:	75 0c                	jne    80108041 <copyuvm+0x71>
      panic("copyuvm: page not present");
80108035:	c7 04 24 70 88 10 80 	movl   $0x80108870,(%esp)
8010803c:	e8 05 85 ff ff       	call   80100546 <panic>
    pa = PTE_ADDR(*pte);
80108041:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108044:	8b 00                	mov    (%eax),%eax
80108046:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010804b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if((mem = kalloc()) == 0)
8010804e:	e8 cf aa ff ff       	call   80102b22 <kalloc>
80108053:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80108056:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010805a:	74 6f                	je     801080cb <copyuvm+0xfb>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
8010805c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010805f:	89 04 24             	mov    %eax,(%esp)
80108062:	e8 7d f3 ff ff       	call   801073e4 <p2v>
80108067:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010806e:	00 
8010806f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108073:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108076:	89 04 24             	mov    %eax,(%esp)
80108079:	e8 4f ce ff ff       	call   80104ecd <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
8010807e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108081:	89 04 24             	mov    %eax,(%esp)
80108084:	e8 4e f3 ff ff       	call   801073d7 <v2p>
80108089:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010808c:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108093:	00 
80108094:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108098:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010809f:	00 
801080a0:	89 54 24 04          	mov    %edx,0x4(%esp)
801080a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080a7:	89 04 24             	mov    %eax,(%esp)
801080aa:	e8 4e f8 ff ff       	call   801078fd <mappages>
801080af:	85 c0                	test   %eax,%eax
801080b1:	78 1b                	js     801080ce <copyuvm+0xfe>
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801080b3:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801080ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080bd:	3b 45 0c             	cmp    0xc(%ebp),%eax
801080c0:	0f 82 34 ff ff ff    	jb     80107ffa <copyuvm+0x2a>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
      goto bad;
  }
  return d;
801080c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080c9:	eb 14                	jmp    801080df <copyuvm+0x10f>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
801080cb:	90                   	nop
801080cc:	eb 01                	jmp    801080cf <copyuvm+0xff>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
      goto bad;
801080ce:	90                   	nop
  }
  return d;

bad:
  freevm(d);
801080cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080d2:	89 04 24             	mov    %eax,(%esp)
801080d5:	e8 22 fe ff ff       	call   80107efc <freevm>
  return 0;
801080da:	b8 00 00 00 00       	mov    $0x0,%eax
}
801080df:	c9                   	leave  
801080e0:	c3                   	ret    

801080e1 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801080e1:	55                   	push   %ebp
801080e2:	89 e5                	mov    %esp,%ebp
801080e4:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801080e7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801080ee:	00 
801080ef:	8b 45 0c             	mov    0xc(%ebp),%eax
801080f2:	89 44 24 04          	mov    %eax,0x4(%esp)
801080f6:	8b 45 08             	mov    0x8(%ebp),%eax
801080f9:	89 04 24             	mov    %eax,(%esp)
801080fc:	e8 66 f7 ff ff       	call   80107867 <walkpgdir>
80108101:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108104:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108107:	8b 00                	mov    (%eax),%eax
80108109:	83 e0 01             	and    $0x1,%eax
8010810c:	85 c0                	test   %eax,%eax
8010810e:	75 07                	jne    80108117 <uva2ka+0x36>
    return 0;
80108110:	b8 00 00 00 00       	mov    $0x0,%eax
80108115:	eb 25                	jmp    8010813c <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
80108117:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010811a:	8b 00                	mov    (%eax),%eax
8010811c:	83 e0 04             	and    $0x4,%eax
8010811f:	85 c0                	test   %eax,%eax
80108121:	75 07                	jne    8010812a <uva2ka+0x49>
    return 0;
80108123:	b8 00 00 00 00       	mov    $0x0,%eax
80108128:	eb 12                	jmp    8010813c <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
8010812a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010812d:	8b 00                	mov    (%eax),%eax
8010812f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108134:	89 04 24             	mov    %eax,(%esp)
80108137:	e8 a8 f2 ff ff       	call   801073e4 <p2v>
}
8010813c:	c9                   	leave  
8010813d:	c3                   	ret    

8010813e <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010813e:	55                   	push   %ebp
8010813f:	89 e5                	mov    %esp,%ebp
80108141:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108144:	8b 45 10             	mov    0x10(%ebp),%eax
80108147:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
8010814a:	e9 8b 00 00 00       	jmp    801081da <copyout+0x9c>
    va0 = (uint)PGROUNDDOWN(va);
8010814f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108152:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108157:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
8010815a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010815d:	89 44 24 04          	mov    %eax,0x4(%esp)
80108161:	8b 45 08             	mov    0x8(%ebp),%eax
80108164:	89 04 24             	mov    %eax,(%esp)
80108167:	e8 75 ff ff ff       	call   801080e1 <uva2ka>
8010816c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010816f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108173:	75 07                	jne    8010817c <copyout+0x3e>
      return -1;
80108175:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010817a:	eb 6d                	jmp    801081e9 <copyout+0xab>
    n = PGSIZE - (va - va0);
8010817c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010817f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80108182:	89 d1                	mov    %edx,%ecx
80108184:	29 c1                	sub    %eax,%ecx
80108186:	89 c8                	mov    %ecx,%eax
80108188:	05 00 10 00 00       	add    $0x1000,%eax
8010818d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108190:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108193:	3b 45 14             	cmp    0x14(%ebp),%eax
80108196:	76 06                	jbe    8010819e <copyout+0x60>
      n = len;
80108198:	8b 45 14             	mov    0x14(%ebp),%eax
8010819b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
8010819e:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081a1:	8b 55 0c             	mov    0xc(%ebp),%edx
801081a4:	89 d1                	mov    %edx,%ecx
801081a6:	29 c1                	sub    %eax,%ecx
801081a8:	89 c8                	mov    %ecx,%eax
801081aa:	03 45 e8             	add    -0x18(%ebp),%eax
801081ad:	8b 55 f0             	mov    -0x10(%ebp),%edx
801081b0:	89 54 24 08          	mov    %edx,0x8(%esp)
801081b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801081b7:	89 54 24 04          	mov    %edx,0x4(%esp)
801081bb:	89 04 24             	mov    %eax,(%esp)
801081be:	e8 0a cd ff ff       	call   80104ecd <memmove>
    len -= n;
801081c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081c6:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801081c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081cc:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801081cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081d2:	05 00 10 00 00       	add    $0x1000,%eax
801081d7:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801081da:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801081de:	0f 85 6b ff ff ff    	jne    8010814f <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
801081e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801081e9:	c9                   	leave  
801081ea:	c3                   	ret    
