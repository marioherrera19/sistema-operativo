
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4 0f                	in     $0xf,%al

8010000c <entry>:
8010000c:	0f 20 e0             	mov    %cr4,%eax
8010000f:	83 c8 10             	or     $0x10,%eax
80100012:	0f 22 e0             	mov    %eax,%cr4
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
8010001a:	0f 22 d8             	mov    %eax,%cr3
8010001d:	0f 20 c0             	mov    %cr0,%eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
80100025:	0f 22 c0             	mov    %eax,%cr0
80100028:	bc 50 c6 10 80       	mov    $0x8010c650,%esp
8010002d:	b8 07 34 10 80       	mov    $0x80103407,%eax
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
8010003a:	c7 44 24 04 a4 83 10 	movl   $0x801083a4,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
80100049:	e8 fc 4c 00 00       	call   80104d4a <initlock>

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
801000a5:	81 7d f4 84 db 10 80 	cmpl   $0x8010db84,-0xc(%ebp)
801000ac:	72 bd                	jb     8010006b <binit+0x37>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000ae:	c9                   	leave  
801000af:	c3                   	ret    

801000b0 <bget>:
// Look through buffer cache for sector on device dev.
// If not found, allocate fresh block.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint sector)
{
801000b0:	55                   	push   %ebp
801000b1:	89 e5                	mov    %esp,%ebp
801000b3:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b6:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
801000bd:	e8 a9 4c 00 00       	call   80104d6b <acquire>

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c2:	a1 94 db 10 80       	mov    0x8010db94,%eax
801000c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000ca:	eb 63                	jmp    8010012f <bget+0x7f>
    if(b->dev == dev && b->sector == sector){
801000cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000cf:	8b 40 04             	mov    0x4(%eax),%eax
801000d2:	3b 45 08             	cmp    0x8(%ebp),%eax
801000d5:	75 4f                	jne    80100126 <bget+0x76>
801000d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000da:	8b 40 08             	mov    0x8(%eax),%eax
801000dd:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e0:	75 44                	jne    80100126 <bget+0x76>
      if(!(b->flags & B_BUSY)){
801000e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e5:	8b 00                	mov    (%eax),%eax
801000e7:	83 e0 01             	and    $0x1,%eax
801000ea:	85 c0                	test   %eax,%eax
801000ec:	75 23                	jne    80100111 <bget+0x61>
        b->flags |= B_BUSY;
801000ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f1:	8b 00                	mov    (%eax),%eax
801000f3:	89 c2                	mov    %eax,%edx
801000f5:	83 ca 01             	or     $0x1,%edx
801000f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000fb:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
801000fd:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
80100104:	e8 c4 4c 00 00       	call   80104dcd <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 60 c6 10 	movl   $0x8010c660,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 2d 49 00 00       	call   80104a51 <sleep>
      goto loop;
80100124:	eb 9c                	jmp    801000c2 <bget+0x12>

  acquire(&bcache.lock);

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100129:	8b 40 10             	mov    0x10(%eax),%eax
8010012c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010012f:	81 7d f4 84 db 10 80 	cmpl   $0x8010db84,-0xc(%ebp)
80100136:	75 94                	jne    801000cc <bget+0x1c>
      goto loop;
    }
  }

  // Not cached; recycle some non-busy and clean buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100138:	a1 90 db 10 80       	mov    0x8010db90,%eax
8010013d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100140:	eb 4d                	jmp    8010018f <bget+0xdf>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
80100142:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100145:	8b 00                	mov    (%eax),%eax
80100147:	83 e0 01             	and    $0x1,%eax
8010014a:	85 c0                	test   %eax,%eax
8010014c:	75 38                	jne    80100186 <bget+0xd6>
8010014e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100151:	8b 00                	mov    (%eax),%eax
80100153:	83 e0 04             	and    $0x4,%eax
80100156:	85 c0                	test   %eax,%eax
80100158:	75 2c                	jne    80100186 <bget+0xd6>
      b->dev = dev;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	8b 55 08             	mov    0x8(%ebp),%edx
80100160:	89 50 04             	mov    %edx,0x4(%eax)
      b->sector = sector;
80100163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100166:	8b 55 0c             	mov    0xc(%ebp),%edx
80100169:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
8010016c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016f:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100175:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
8010017c:	e8 4c 4c 00 00       	call   80104dcd <release>
      return b;
80100181:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100184:	eb 1e                	jmp    801001a4 <bget+0xf4>
      goto loop;
    }
  }

  // Not cached; recycle some non-busy and clean buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100186:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100189:	8b 40 0c             	mov    0xc(%eax),%eax
8010018c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010018f:	81 7d f4 84 db 10 80 	cmpl   $0x8010db84,-0xc(%ebp)
80100196:	75 aa                	jne    80100142 <bget+0x92>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
80100198:	c7 04 24 ab 83 10 80 	movl   $0x801083ab,(%esp)
8010019f:	e8 99 03 00 00       	call   8010053d <panic>
}
801001a4:	c9                   	leave  
801001a5:	c3                   	ret    

801001a6 <bread>:

// Return a B_BUSY buf with the contents of the indicated disk sector.
struct buf*
bread(uint dev, uint sector)
{
801001a6:	55                   	push   %ebp
801001a7:	89 e5                	mov    %esp,%ebp
801001a9:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  b = bget(dev, sector);
801001ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801001af:	89 44 24 04          	mov    %eax,0x4(%esp)
801001b3:	8b 45 08             	mov    0x8(%ebp),%eax
801001b6:	89 04 24             	mov    %eax,(%esp)
801001b9:	e8 f2 fe ff ff       	call   801000b0 <bget>
801001be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID))
801001c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001c4:	8b 00                	mov    (%eax),%eax
801001c6:	83 e0 02             	and    $0x2,%eax
801001c9:	85 c0                	test   %eax,%eax
801001cb:	75 0b                	jne    801001d8 <bread+0x32>
    iderw(b);
801001cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d0:	89 04 24             	mov    %eax,(%esp)
801001d3:	e8 dc 25 00 00       	call   801027b4 <iderw>
  return b;
801001d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001db:	c9                   	leave  
801001dc:	c3                   	ret    

801001dd <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001dd:	55                   	push   %ebp
801001de:	89 e5                	mov    %esp,%ebp
801001e0:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
801001e3:	8b 45 08             	mov    0x8(%ebp),%eax
801001e6:	8b 00                	mov    (%eax),%eax
801001e8:	83 e0 01             	and    $0x1,%eax
801001eb:	85 c0                	test   %eax,%eax
801001ed:	75 0c                	jne    801001fb <bwrite+0x1e>
    panic("bwrite");
801001ef:	c7 04 24 bc 83 10 80 	movl   $0x801083bc,(%esp)
801001f6:	e8 42 03 00 00       	call   8010053d <panic>
  b->flags |= B_DIRTY;
801001fb:	8b 45 08             	mov    0x8(%ebp),%eax
801001fe:	8b 00                	mov    (%eax),%eax
80100200:	89 c2                	mov    %eax,%edx
80100202:	83 ca 04             	or     $0x4,%edx
80100205:	8b 45 08             	mov    0x8(%ebp),%eax
80100208:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010020a:	8b 45 08             	mov    0x8(%ebp),%eax
8010020d:	89 04 24             	mov    %eax,(%esp)
80100210:	e8 9f 25 00 00       	call   801027b4 <iderw>
}
80100215:	c9                   	leave  
80100216:	c3                   	ret    

80100217 <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100217:	55                   	push   %ebp
80100218:	89 e5                	mov    %esp,%ebp
8010021a:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
8010021d:	8b 45 08             	mov    0x8(%ebp),%eax
80100220:	8b 00                	mov    (%eax),%eax
80100222:	83 e0 01             	and    $0x1,%eax
80100225:	85 c0                	test   %eax,%eax
80100227:	75 0c                	jne    80100235 <brelse+0x1e>
    panic("brelse");
80100229:	c7 04 24 c3 83 10 80 	movl   $0x801083c3,(%esp)
80100230:	e8 08 03 00 00       	call   8010053d <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
8010023c:	e8 2a 4b 00 00       	call   80104d6b <acquire>

  b->next->prev = b->prev;
80100241:	8b 45 08             	mov    0x8(%ebp),%eax
80100244:	8b 40 10             	mov    0x10(%eax),%eax
80100247:	8b 55 08             	mov    0x8(%ebp),%edx
8010024a:	8b 52 0c             	mov    0xc(%edx),%edx
8010024d:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	8b 40 0c             	mov    0xc(%eax),%eax
80100256:	8b 55 08             	mov    0x8(%ebp),%edx
80100259:	8b 52 10             	mov    0x10(%edx),%edx
8010025c:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010025f:	8b 15 94 db 10 80    	mov    0x8010db94,%edx
80100265:	8b 45 08             	mov    0x8(%ebp),%eax
80100268:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
8010026b:	8b 45 08             	mov    0x8(%ebp),%eax
8010026e:	c7 40 0c 84 db 10 80 	movl   $0x8010db84,0xc(%eax)
  bcache.head.next->prev = b;
80100275:	a1 94 db 10 80       	mov    0x8010db94,%eax
8010027a:	8b 55 08             	mov    0x8(%ebp),%edx
8010027d:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
80100280:	8b 45 08             	mov    0x8(%ebp),%eax
80100283:	a3 94 db 10 80       	mov    %eax,0x8010db94

  b->flags &= ~B_BUSY;
80100288:	8b 45 08             	mov    0x8(%ebp),%eax
8010028b:	8b 00                	mov    (%eax),%eax
8010028d:	89 c2                	mov    %eax,%edx
8010028f:	83 e2 fe             	and    $0xfffffffe,%edx
80100292:	8b 45 08             	mov    0x8(%ebp),%eax
80100295:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80100297:	8b 45 08             	mov    0x8(%ebp),%eax
8010029a:	89 04 24             	mov    %eax,(%esp)
8010029d:	e8 9b 48 00 00       	call   80104b3d <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
801002a9:	e8 1f 4b 00 00       	call   80104dcd <release>
}
801002ae:	c9                   	leave  
801002af:	c3                   	ret    

801002b0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002b0:	55                   	push   %ebp
801002b1:	89 e5                	mov    %esp,%ebp
801002b3:	53                   	push   %ebx
801002b4:	83 ec 14             	sub    $0x14,%esp
801002b7:	8b 45 08             	mov    0x8(%ebp),%eax
801002ba:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002be:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
801002c2:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
801002c6:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
801002ca:	ec                   	in     (%dx),%al
801002cb:	89 c3                	mov    %eax,%ebx
801002cd:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
801002d0:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
801002d4:	83 c4 14             	add    $0x14,%esp
801002d7:	5b                   	pop    %ebx
801002d8:	5d                   	pop    %ebp
801002d9:	c3                   	ret    

801002da <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002da:	55                   	push   %ebp
801002db:	89 e5                	mov    %esp,%ebp
801002dd:	83 ec 08             	sub    $0x8,%esp
801002e0:	8b 55 08             	mov    0x8(%ebp),%edx
801002e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801002e6:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801002ea:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801002ed:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801002f1:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801002f5:	ee                   	out    %al,(%dx)
}
801002f6:	c9                   	leave  
801002f7:	c3                   	ret    

801002f8 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801002f8:	55                   	push   %ebp
801002f9:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801002fb:	fa                   	cli    
}
801002fc:	5d                   	pop    %ebp
801002fd:	c3                   	ret    

801002fe <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
801002fe:	55                   	push   %ebp
801002ff:	89 e5                	mov    %esp,%ebp
80100301:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
80100304:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100308:	74 19                	je     80100323 <printint+0x25>
8010030a:	8b 45 08             	mov    0x8(%ebp),%eax
8010030d:	c1 e8 1f             	shr    $0x1f,%eax
80100310:	89 45 10             	mov    %eax,0x10(%ebp)
80100313:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100317:	74 0a                	je     80100323 <printint+0x25>
    x = -xx;
80100319:	8b 45 08             	mov    0x8(%ebp),%eax
8010031c:	f7 d8                	neg    %eax
8010031e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100321:	eb 06                	jmp    80100329 <printint+0x2b>
  else
    x = xx;
80100323:	8b 45 08             	mov    0x8(%ebp),%eax
80100326:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100329:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100330:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100333:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100336:	ba 00 00 00 00       	mov    $0x0,%edx
8010033b:	f7 f1                	div    %ecx
8010033d:	89 d0                	mov    %edx,%eax
8010033f:	0f b6 90 04 90 10 80 	movzbl -0x7fef6ffc(%eax),%edx
80100346:	8d 45 e0             	lea    -0x20(%ebp),%eax
80100349:	03 45 f4             	add    -0xc(%ebp),%eax
8010034c:	88 10                	mov    %dl,(%eax)
8010034e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
80100352:	8b 55 0c             	mov    0xc(%ebp),%edx
80100355:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80100358:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010035b:	ba 00 00 00 00       	mov    $0x0,%edx
80100360:	f7 75 d4             	divl   -0x2c(%ebp)
80100363:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100366:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010036a:	75 c4                	jne    80100330 <printint+0x32>

  if(sign)
8010036c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100370:	74 23                	je     80100395 <printint+0x97>
    buf[i++] = '-';
80100372:	8d 45 e0             	lea    -0x20(%ebp),%eax
80100375:	03 45 f4             	add    -0xc(%ebp),%eax
80100378:	c6 00 2d             	movb   $0x2d,(%eax)
8010037b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
8010037f:	eb 14                	jmp    80100395 <printint+0x97>
    consputc(buf[i]);
80100381:	8d 45 e0             	lea    -0x20(%ebp),%eax
80100384:	03 45 f4             	add    -0xc(%ebp),%eax
80100387:	0f b6 00             	movzbl (%eax),%eax
8010038a:	0f be c0             	movsbl %al,%eax
8010038d:	89 04 24             	mov    %eax,(%esp)
80100390:	e8 bb 03 00 00       	call   80100750 <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
80100395:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100399:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010039d:	79 e2                	jns    80100381 <printint+0x83>
    consputc(buf[i]);
}
8010039f:	c9                   	leave  
801003a0:	c3                   	ret    

801003a1 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003a1:	55                   	push   %ebp
801003a2:	89 e5                	mov    %esp,%ebp
801003a4:	83 ec 38             	sub    $0x38,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003a7:	a1 f4 b5 10 80       	mov    0x8010b5f4,%eax
801003ac:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003af:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003b3:	74 0c                	je     801003c1 <cprintf+0x20>
    acquire(&cons.lock);
801003b5:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
801003bc:	e8 aa 49 00 00       	call   80104d6b <acquire>

  if (fmt == 0)
801003c1:	8b 45 08             	mov    0x8(%ebp),%eax
801003c4:	85 c0                	test   %eax,%eax
801003c6:	75 0c                	jne    801003d4 <cprintf+0x33>
    panic("null fmt");
801003c8:	c7 04 24 ca 83 10 80 	movl   $0x801083ca,(%esp)
801003cf:	e8 69 01 00 00       	call   8010053d <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003d4:	8d 45 0c             	lea    0xc(%ebp),%eax
801003d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801003da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801003e1:	e9 20 01 00 00       	jmp    80100506 <cprintf+0x165>
    if(c != '%'){
801003e6:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801003ea:	74 10                	je     801003fc <cprintf+0x5b>
      consputc(c);
801003ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801003ef:	89 04 24             	mov    %eax,(%esp)
801003f2:	e8 59 03 00 00       	call   80100750 <consputc>
      continue;
801003f7:	e9 06 01 00 00       	jmp    80100502 <cprintf+0x161>
    }
    c = fmt[++i] & 0xff;
801003fc:	8b 55 08             	mov    0x8(%ebp),%edx
801003ff:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100403:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100406:	01 d0                	add    %edx,%eax
80100408:	0f b6 00             	movzbl (%eax),%eax
8010040b:	0f be c0             	movsbl %al,%eax
8010040e:	25 ff 00 00 00       	and    $0xff,%eax
80100413:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100416:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010041a:	0f 84 08 01 00 00    	je     80100528 <cprintf+0x187>
      break;
    switch(c){
80100420:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100423:	83 f8 70             	cmp    $0x70,%eax
80100426:	74 4d                	je     80100475 <cprintf+0xd4>
80100428:	83 f8 70             	cmp    $0x70,%eax
8010042b:	7f 13                	jg     80100440 <cprintf+0x9f>
8010042d:	83 f8 25             	cmp    $0x25,%eax
80100430:	0f 84 a6 00 00 00    	je     801004dc <cprintf+0x13b>
80100436:	83 f8 64             	cmp    $0x64,%eax
80100439:	74 14                	je     8010044f <cprintf+0xae>
8010043b:	e9 aa 00 00 00       	jmp    801004ea <cprintf+0x149>
80100440:	83 f8 73             	cmp    $0x73,%eax
80100443:	74 53                	je     80100498 <cprintf+0xf7>
80100445:	83 f8 78             	cmp    $0x78,%eax
80100448:	74 2b                	je     80100475 <cprintf+0xd4>
8010044a:	e9 9b 00 00 00       	jmp    801004ea <cprintf+0x149>
    case 'd':
      printint(*argp++, 10, 1);
8010044f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100452:	8b 00                	mov    (%eax),%eax
80100454:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
80100458:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
8010045f:	00 
80100460:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80100467:	00 
80100468:	89 04 24             	mov    %eax,(%esp)
8010046b:	e8 8e fe ff ff       	call   801002fe <printint>
      break;
80100470:	e9 8d 00 00 00       	jmp    80100502 <cprintf+0x161>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100475:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100478:	8b 00                	mov    (%eax),%eax
8010047a:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
8010047e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100485:	00 
80100486:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
8010048d:	00 
8010048e:	89 04 24             	mov    %eax,(%esp)
80100491:	e8 68 fe ff ff       	call   801002fe <printint>
      break;
80100496:	eb 6a                	jmp    80100502 <cprintf+0x161>
    case 's':
      if((s = (char*)*argp++) == 0)
80100498:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049b:	8b 00                	mov    (%eax),%eax
8010049d:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004a0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004a4:	0f 94 c0             	sete   %al
801004a7:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
801004ab:	84 c0                	test   %al,%al
801004ad:	74 20                	je     801004cf <cprintf+0x12e>
        s = "(null)";
801004af:	c7 45 ec d3 83 10 80 	movl   $0x801083d3,-0x14(%ebp)
      for(; *s; s++)
801004b6:	eb 17                	jmp    801004cf <cprintf+0x12e>
        consputc(*s);
801004b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004bb:	0f b6 00             	movzbl (%eax),%eax
801004be:	0f be c0             	movsbl %al,%eax
801004c1:	89 04 24             	mov    %eax,(%esp)
801004c4:	e8 87 02 00 00       	call   80100750 <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004c9:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004cd:	eb 01                	jmp    801004d0 <cprintf+0x12f>
801004cf:	90                   	nop
801004d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d3:	0f b6 00             	movzbl (%eax),%eax
801004d6:	84 c0                	test   %al,%al
801004d8:	75 de                	jne    801004b8 <cprintf+0x117>
        consputc(*s);
      break;
801004da:	eb 26                	jmp    80100502 <cprintf+0x161>
    case '%':
      consputc('%');
801004dc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004e3:	e8 68 02 00 00       	call   80100750 <consputc>
      break;
801004e8:	eb 18                	jmp    80100502 <cprintf+0x161>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
801004ea:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004f1:	e8 5a 02 00 00       	call   80100750 <consputc>
      consputc(c);
801004f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801004f9:	89 04 24             	mov    %eax,(%esp)
801004fc:	e8 4f 02 00 00       	call   80100750 <consputc>
      break;
80100501:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100502:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100506:	8b 55 08             	mov    0x8(%ebp),%edx
80100509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010050c:	01 d0                	add    %edx,%eax
8010050e:	0f b6 00             	movzbl (%eax),%eax
80100511:	0f be c0             	movsbl %al,%eax
80100514:	25 ff 00 00 00       	and    $0xff,%eax
80100519:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010051c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100520:	0f 85 c0 fe ff ff    	jne    801003e6 <cprintf+0x45>
80100526:	eb 01                	jmp    80100529 <cprintf+0x188>
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
80100528:	90                   	nop
      consputc(c);
      break;
    }
  }

  if(locking)
80100529:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010052d:	74 0c                	je     8010053b <cprintf+0x19a>
    release(&cons.lock);
8010052f:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100536:	e8 92 48 00 00       	call   80104dcd <release>
}
8010053b:	c9                   	leave  
8010053c:	c3                   	ret    

8010053d <panic>:

void
panic(char *s)
{
8010053d:	55                   	push   %ebp
8010053e:	89 e5                	mov    %esp,%ebp
80100540:	83 ec 48             	sub    $0x48,%esp
  int i;
  uint pcs[10];
  
  cli();
80100543:	e8 b0 fd ff ff       	call   801002f8 <cli>
  cons.locking = 0;
80100548:	c7 05 f4 b5 10 80 00 	movl   $0x0,0x8010b5f4
8010054f:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
80100552:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100558:	0f b6 00             	movzbl (%eax),%eax
8010055b:	0f b6 c0             	movzbl %al,%eax
8010055e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100562:	c7 04 24 da 83 10 80 	movl   $0x801083da,(%esp)
80100569:	e8 33 fe ff ff       	call   801003a1 <cprintf>
  cprintf(s);
8010056e:	8b 45 08             	mov    0x8(%ebp),%eax
80100571:	89 04 24             	mov    %eax,(%esp)
80100574:	e8 28 fe ff ff       	call   801003a1 <cprintf>
  cprintf("\n");
80100579:	c7 04 24 e9 83 10 80 	movl   $0x801083e9,(%esp)
80100580:	e8 1c fe ff ff       	call   801003a1 <cprintf>
  getcallerpcs(&s, pcs);
80100585:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100588:	89 44 24 04          	mov    %eax,0x4(%esp)
8010058c:	8d 45 08             	lea    0x8(%ebp),%eax
8010058f:	89 04 24             	mov    %eax,(%esp)
80100592:	e8 85 48 00 00       	call   80104e1c <getcallerpcs>
  for(i=0; i<10; i++)
80100597:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059e:	eb 1b                	jmp    801005bb <panic+0x7e>
    cprintf(" %p", pcs[i]);
801005a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005ab:	c7 04 24 eb 83 10 80 	movl   $0x801083eb,(%esp)
801005b2:	e8 ea fd ff ff       	call   801003a1 <cprintf>
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005b7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005bb:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005bf:	7e df                	jle    801005a0 <panic+0x63>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005c1:	c7 05 a0 b5 10 80 01 	movl   $0x1,0x8010b5a0
801005c8:	00 00 00 
  for(;;)
    ;
801005cb:	eb fe                	jmp    801005cb <panic+0x8e>

801005cd <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801005cd:	55                   	push   %ebp
801005ce:	89 e5                	mov    %esp,%ebp
801005d0:	83 ec 28             	sub    $0x28,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801005d3:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801005da:	00 
801005db:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801005e2:	e8 f3 fc ff ff       	call   801002da <outb>
  pos = inb(CRTPORT+1) << 8;
801005e7:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801005ee:	e8 bd fc ff ff       	call   801002b0 <inb>
801005f3:	0f b6 c0             	movzbl %al,%eax
801005f6:	c1 e0 08             	shl    $0x8,%eax
801005f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
801005fc:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100603:	00 
80100604:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010060b:	e8 ca fc ff ff       	call   801002da <outb>
  pos |= inb(CRTPORT+1);
80100610:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100617:	e8 94 fc ff ff       	call   801002b0 <inb>
8010061c:	0f b6 c0             	movzbl %al,%eax
8010061f:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
80100622:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100626:	75 30                	jne    80100658 <cgaputc+0x8b>
    pos += 80 - pos%80;
80100628:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010062b:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100630:	89 c8                	mov    %ecx,%eax
80100632:	f7 ea                	imul   %edx
80100634:	c1 fa 05             	sar    $0x5,%edx
80100637:	89 c8                	mov    %ecx,%eax
80100639:	c1 f8 1f             	sar    $0x1f,%eax
8010063c:	29 c2                	sub    %eax,%edx
8010063e:	89 d0                	mov    %edx,%eax
80100640:	c1 e0 02             	shl    $0x2,%eax
80100643:	01 d0                	add    %edx,%eax
80100645:	c1 e0 04             	shl    $0x4,%eax
80100648:	89 ca                	mov    %ecx,%edx
8010064a:	29 c2                	sub    %eax,%edx
8010064c:	b8 50 00 00 00       	mov    $0x50,%eax
80100651:	29 d0                	sub    %edx,%eax
80100653:	01 45 f4             	add    %eax,-0xc(%ebp)
80100656:	eb 32                	jmp    8010068a <cgaputc+0xbd>
  else if(c == BACKSPACE){
80100658:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010065f:	75 0c                	jne    8010066d <cgaputc+0xa0>
    if(pos > 0) --pos;
80100661:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100665:	7e 23                	jle    8010068a <cgaputc+0xbd>
80100667:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
8010066b:	eb 1d                	jmp    8010068a <cgaputc+0xbd>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010066d:	a1 00 90 10 80       	mov    0x80109000,%eax
80100672:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100675:	01 d2                	add    %edx,%edx
80100677:	01 c2                	add    %eax,%edx
80100679:	8b 45 08             	mov    0x8(%ebp),%eax
8010067c:	66 25 ff 00          	and    $0xff,%ax
80100680:	80 cc 07             	or     $0x7,%ah
80100683:	66 89 02             	mov    %ax,(%edx)
80100686:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  
  if((pos/80) >= 24){  // Scroll up.
8010068a:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
80100691:	7e 53                	jle    801006e6 <cgaputc+0x119>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100693:	a1 00 90 10 80       	mov    0x80109000,%eax
80100698:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
8010069e:	a1 00 90 10 80       	mov    0x80109000,%eax
801006a3:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
801006aa:	00 
801006ab:	89 54 24 04          	mov    %edx,0x4(%esp)
801006af:	89 04 24             	mov    %eax,(%esp)
801006b2:	e8 d6 49 00 00       	call   8010508d <memmove>
    pos -= 80;
801006b7:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006bb:	b8 80 07 00 00       	mov    $0x780,%eax
801006c0:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006c3:	01 c0                	add    %eax,%eax
801006c5:	8b 15 00 90 10 80    	mov    0x80109000,%edx
801006cb:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006ce:	01 c9                	add    %ecx,%ecx
801006d0:	01 ca                	add    %ecx,%edx
801006d2:	89 44 24 08          	mov    %eax,0x8(%esp)
801006d6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801006dd:	00 
801006de:	89 14 24             	mov    %edx,(%esp)
801006e1:	e8 d4 48 00 00       	call   80104fba <memset>
  }
  
  outb(CRTPORT, 14);
801006e6:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801006ed:	00 
801006ee:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801006f5:	e8 e0 fb ff ff       	call   801002da <outb>
  outb(CRTPORT+1, pos>>8);
801006fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006fd:	c1 f8 08             	sar    $0x8,%eax
80100700:	0f b6 c0             	movzbl %al,%eax
80100703:	89 44 24 04          	mov    %eax,0x4(%esp)
80100707:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
8010070e:	e8 c7 fb ff ff       	call   801002da <outb>
  outb(CRTPORT, 15);
80100713:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
8010071a:	00 
8010071b:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100722:	e8 b3 fb ff ff       	call   801002da <outb>
  outb(CRTPORT+1, pos);
80100727:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010072a:	0f b6 c0             	movzbl %al,%eax
8010072d:	89 44 24 04          	mov    %eax,0x4(%esp)
80100731:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100738:	e8 9d fb ff ff       	call   801002da <outb>
  crt[pos] = ' ' | 0x0700;
8010073d:	a1 00 90 10 80       	mov    0x80109000,%eax
80100742:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100745:	01 d2                	add    %edx,%edx
80100747:	01 d0                	add    %edx,%eax
80100749:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
8010074e:	c9                   	leave  
8010074f:	c3                   	ret    

80100750 <consputc>:

void
consputc(int c)
{
80100750:	55                   	push   %ebp
80100751:	89 e5                	mov    %esp,%ebp
80100753:	83 ec 18             	sub    $0x18,%esp
  if(panicked){
80100756:	a1 a0 b5 10 80       	mov    0x8010b5a0,%eax
8010075b:	85 c0                	test   %eax,%eax
8010075d:	74 07                	je     80100766 <consputc+0x16>
    cli();
8010075f:	e8 94 fb ff ff       	call   801002f8 <cli>
    for(;;)
      ;
80100764:	eb fe                	jmp    80100764 <consputc+0x14>
  }

  if(c == BACKSPACE){
80100766:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010076d:	75 26                	jne    80100795 <consputc+0x45>
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010076f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100776:	e8 8e 62 00 00       	call   80106a09 <uartputc>
8010077b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80100782:	e8 82 62 00 00       	call   80106a09 <uartputc>
80100787:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010078e:	e8 76 62 00 00       	call   80106a09 <uartputc>
80100793:	eb 0b                	jmp    801007a0 <consputc+0x50>
  } else
    uartputc(c);
80100795:	8b 45 08             	mov    0x8(%ebp),%eax
80100798:	89 04 24             	mov    %eax,(%esp)
8010079b:	e8 69 62 00 00       	call   80106a09 <uartputc>
  cgaputc(c);
801007a0:	8b 45 08             	mov    0x8(%ebp),%eax
801007a3:	89 04 24             	mov    %eax,(%esp)
801007a6:	e8 22 fe ff ff       	call   801005cd <cgaputc>
}
801007ab:	c9                   	leave  
801007ac:	c3                   	ret    

801007ad <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007ad:	55                   	push   %ebp
801007ae:	89 e5                	mov    %esp,%ebp
801007b0:	83 ec 28             	sub    $0x28,%esp
  int c;

  acquire(&input.lock);
801007b3:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
801007ba:	e8 ac 45 00 00       	call   80104d6b <acquire>
  while((c = getc()) >= 0){
801007bf:	e9 41 01 00 00       	jmp    80100905 <consoleintr+0x158>
    switch(c){
801007c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007c7:	83 f8 10             	cmp    $0x10,%eax
801007ca:	74 1e                	je     801007ea <consoleintr+0x3d>
801007cc:	83 f8 10             	cmp    $0x10,%eax
801007cf:	7f 0a                	jg     801007db <consoleintr+0x2e>
801007d1:	83 f8 08             	cmp    $0x8,%eax
801007d4:	74 68                	je     8010083e <consoleintr+0x91>
801007d6:	e9 94 00 00 00       	jmp    8010086f <consoleintr+0xc2>
801007db:	83 f8 15             	cmp    $0x15,%eax
801007de:	74 2f                	je     8010080f <consoleintr+0x62>
801007e0:	83 f8 7f             	cmp    $0x7f,%eax
801007e3:	74 59                	je     8010083e <consoleintr+0x91>
801007e5:	e9 85 00 00 00       	jmp    8010086f <consoleintr+0xc2>
    case C('P'):  // Process listing.
      procdump();
801007ea:	e8 18 44 00 00       	call   80104c07 <procdump>
      break;
801007ef:	e9 11 01 00 00       	jmp    80100905 <consoleintr+0x158>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
801007f4:	a1 5c de 10 80       	mov    0x8010de5c,%eax
801007f9:	83 e8 01             	sub    $0x1,%eax
801007fc:	a3 5c de 10 80       	mov    %eax,0x8010de5c
        consputc(BACKSPACE);
80100801:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100808:	e8 43 ff ff ff       	call   80100750 <consputc>
8010080d:	eb 01                	jmp    80100810 <consoleintr+0x63>
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010080f:	90                   	nop
80100810:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100816:	a1 58 de 10 80       	mov    0x8010de58,%eax
8010081b:	39 c2                	cmp    %eax,%edx
8010081d:	0f 84 db 00 00 00    	je     801008fe <consoleintr+0x151>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100823:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100828:	83 e8 01             	sub    $0x1,%eax
8010082b:	83 e0 7f             	and    $0x7f,%eax
8010082e:	0f b6 80 d4 dd 10 80 	movzbl -0x7fef222c(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100835:	3c 0a                	cmp    $0xa,%al
80100837:	75 bb                	jne    801007f4 <consoleintr+0x47>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100839:	e9 c0 00 00 00       	jmp    801008fe <consoleintr+0x151>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
8010083e:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100844:	a1 58 de 10 80       	mov    0x8010de58,%eax
80100849:	39 c2                	cmp    %eax,%edx
8010084b:	0f 84 b0 00 00 00    	je     80100901 <consoleintr+0x154>
        input.e--;
80100851:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100856:	83 e8 01             	sub    $0x1,%eax
80100859:	a3 5c de 10 80       	mov    %eax,0x8010de5c
        consputc(BACKSPACE);
8010085e:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100865:	e8 e6 fe ff ff       	call   80100750 <consputc>
      }
      break;
8010086a:	e9 92 00 00 00       	jmp    80100901 <consoleintr+0x154>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
8010086f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100873:	0f 84 8b 00 00 00    	je     80100904 <consoleintr+0x157>
80100879:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
8010087f:	a1 54 de 10 80       	mov    0x8010de54,%eax
80100884:	89 d1                	mov    %edx,%ecx
80100886:	29 c1                	sub    %eax,%ecx
80100888:	89 c8                	mov    %ecx,%eax
8010088a:	83 f8 7f             	cmp    $0x7f,%eax
8010088d:	77 75                	ja     80100904 <consoleintr+0x157>
        c = (c == '\r') ? '\n' : c;
8010088f:	83 7d f4 0d          	cmpl   $0xd,-0xc(%ebp)
80100893:	74 05                	je     8010089a <consoleintr+0xed>
80100895:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100898:	eb 05                	jmp    8010089f <consoleintr+0xf2>
8010089a:	b8 0a 00 00 00       	mov    $0xa,%eax
8010089f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008a2:	a1 5c de 10 80       	mov    0x8010de5c,%eax
801008a7:	89 c1                	mov    %eax,%ecx
801008a9:	83 e1 7f             	and    $0x7f,%ecx
801008ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
801008af:	88 91 d4 dd 10 80    	mov    %dl,-0x7fef222c(%ecx)
801008b5:	83 c0 01             	add    $0x1,%eax
801008b8:	a3 5c de 10 80       	mov    %eax,0x8010de5c
        consputc(c);
801008bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008c0:	89 04 24             	mov    %eax,(%esp)
801008c3:	e8 88 fe ff ff       	call   80100750 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801008c8:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
801008cc:	74 18                	je     801008e6 <consoleintr+0x139>
801008ce:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
801008d2:	74 12                	je     801008e6 <consoleintr+0x139>
801008d4:	a1 5c de 10 80       	mov    0x8010de5c,%eax
801008d9:	8b 15 54 de 10 80    	mov    0x8010de54,%edx
801008df:	83 ea 80             	sub    $0xffffff80,%edx
801008e2:	39 d0                	cmp    %edx,%eax
801008e4:	75 1e                	jne    80100904 <consoleintr+0x157>
          input.w = input.e;
801008e6:	a1 5c de 10 80       	mov    0x8010de5c,%eax
801008eb:	a3 58 de 10 80       	mov    %eax,0x8010de58
          wakeup(&input.r);
801008f0:	c7 04 24 54 de 10 80 	movl   $0x8010de54,(%esp)
801008f7:	e8 41 42 00 00       	call   80104b3d <wakeup>
        }
      }
      break;
801008fc:	eb 06                	jmp    80100904 <consoleintr+0x157>
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
801008fe:	90                   	nop
801008ff:	eb 04                	jmp    80100905 <consoleintr+0x158>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100901:	90                   	nop
80100902:	eb 01                	jmp    80100905 <consoleintr+0x158>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
          input.w = input.e;
          wakeup(&input.r);
        }
      }
      break;
80100904:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c;

  acquire(&input.lock);
  while((c = getc()) >= 0){
80100905:	8b 45 08             	mov    0x8(%ebp),%eax
80100908:	ff d0                	call   *%eax
8010090a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010090d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100911:	0f 89 ad fe ff ff    	jns    801007c4 <consoleintr+0x17>
        }
      }
      break;
    }
  }
  release(&input.lock);
80100917:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
8010091e:	e8 aa 44 00 00       	call   80104dcd <release>
}
80100923:	c9                   	leave  
80100924:	c3                   	ret    

80100925 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100925:	55                   	push   %ebp
80100926:	89 e5                	mov    %esp,%ebp
80100928:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
8010092b:	8b 45 08             	mov    0x8(%ebp),%eax
8010092e:	89 04 24             	mov    %eax,(%esp)
80100931:	e8 80 10 00 00       	call   801019b6 <iunlock>
  target = n;
80100936:	8b 45 10             	mov    0x10(%ebp),%eax
80100939:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
8010093c:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100943:	e8 23 44 00 00       	call   80104d6b <acquire>
  while(n > 0){
80100948:	e9 a8 00 00 00       	jmp    801009f5 <consoleread+0xd0>
    while(input.r == input.w){
      if(proc->killed){
8010094d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100953:	8b 40 24             	mov    0x24(%eax),%eax
80100956:	85 c0                	test   %eax,%eax
80100958:	74 21                	je     8010097b <consoleread+0x56>
        release(&input.lock);
8010095a:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100961:	e8 67 44 00 00       	call   80104dcd <release>
        ilock(ip);
80100966:	8b 45 08             	mov    0x8(%ebp),%eax
80100969:	89 04 24             	mov    %eax,(%esp)
8010096c:	e8 f7 0e 00 00       	call   80101868 <ilock>
        return -1;
80100971:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100976:	e9 a9 00 00 00       	jmp    80100a24 <consoleread+0xff>
      }
      sleep(&input.r, &input.lock);
8010097b:	c7 44 24 04 a0 dd 10 	movl   $0x8010dda0,0x4(%esp)
80100982:	80 
80100983:	c7 04 24 54 de 10 80 	movl   $0x8010de54,(%esp)
8010098a:	e8 c2 40 00 00       	call   80104a51 <sleep>
8010098f:	eb 01                	jmp    80100992 <consoleread+0x6d>

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
80100991:	90                   	nop
80100992:	8b 15 54 de 10 80    	mov    0x8010de54,%edx
80100998:	a1 58 de 10 80       	mov    0x8010de58,%eax
8010099d:	39 c2                	cmp    %eax,%edx
8010099f:	74 ac                	je     8010094d <consoleread+0x28>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009a1:	a1 54 de 10 80       	mov    0x8010de54,%eax
801009a6:	89 c2                	mov    %eax,%edx
801009a8:	83 e2 7f             	and    $0x7f,%edx
801009ab:	0f b6 92 d4 dd 10 80 	movzbl -0x7fef222c(%edx),%edx
801009b2:	0f be d2             	movsbl %dl,%edx
801009b5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801009b8:	83 c0 01             	add    $0x1,%eax
801009bb:	a3 54 de 10 80       	mov    %eax,0x8010de54
    if(c == C('D')){  // EOF
801009c0:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801009c4:	75 17                	jne    801009dd <consoleread+0xb8>
      if(n < target){
801009c6:	8b 45 10             	mov    0x10(%ebp),%eax
801009c9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801009cc:	73 2f                	jae    801009fd <consoleread+0xd8>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
801009ce:	a1 54 de 10 80       	mov    0x8010de54,%eax
801009d3:	83 e8 01             	sub    $0x1,%eax
801009d6:	a3 54 de 10 80       	mov    %eax,0x8010de54
      }
      break;
801009db:	eb 20                	jmp    801009fd <consoleread+0xd8>
    }
    *dst++ = c;
801009dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801009e0:	89 c2                	mov    %eax,%edx
801009e2:	8b 45 0c             	mov    0xc(%ebp),%eax
801009e5:	88 10                	mov    %dl,(%eax)
801009e7:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    --n;
801009eb:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
801009ef:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
801009f3:	74 0b                	je     80100a00 <consoleread+0xdb>
  int c;

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
801009f5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801009f9:	7f 96                	jg     80100991 <consoleread+0x6c>
801009fb:	eb 04                	jmp    80100a01 <consoleread+0xdc>
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
801009fd:	90                   	nop
801009fe:	eb 01                	jmp    80100a01 <consoleread+0xdc>
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
80100a00:	90                   	nop
  }
  release(&input.lock);
80100a01:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100a08:	e8 c0 43 00 00       	call   80104dcd <release>
  ilock(ip);
80100a0d:	8b 45 08             	mov    0x8(%ebp),%eax
80100a10:	89 04 24             	mov    %eax,(%esp)
80100a13:	e8 50 0e 00 00       	call   80101868 <ilock>

  return target - n;
80100a18:	8b 45 10             	mov    0x10(%ebp),%eax
80100a1b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a1e:	89 d1                	mov    %edx,%ecx
80100a20:	29 c1                	sub    %eax,%ecx
80100a22:	89 c8                	mov    %ecx,%eax
}
80100a24:	c9                   	leave  
80100a25:	c3                   	ret    

80100a26 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a26:	55                   	push   %ebp
80100a27:	89 e5                	mov    %esp,%ebp
80100a29:	83 ec 28             	sub    $0x28,%esp
  int i;

  iunlock(ip);
80100a2c:	8b 45 08             	mov    0x8(%ebp),%eax
80100a2f:	89 04 24             	mov    %eax,(%esp)
80100a32:	e8 7f 0f 00 00       	call   801019b6 <iunlock>
  acquire(&cons.lock);
80100a37:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100a3e:	e8 28 43 00 00       	call   80104d6b <acquire>
  for(i = 0; i < n; i++)
80100a43:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100a4a:	eb 1d                	jmp    80100a69 <consolewrite+0x43>
    consputc(buf[i] & 0xff);
80100a4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a4f:	03 45 0c             	add    0xc(%ebp),%eax
80100a52:	0f b6 00             	movzbl (%eax),%eax
80100a55:	0f be c0             	movsbl %al,%eax
80100a58:	25 ff 00 00 00       	and    $0xff,%eax
80100a5d:	89 04 24             	mov    %eax,(%esp)
80100a60:	e8 eb fc ff ff       	call   80100750 <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100a65:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100a69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a6c:	3b 45 10             	cmp    0x10(%ebp),%eax
80100a6f:	7c db                	jl     80100a4c <consolewrite+0x26>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100a71:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100a78:	e8 50 43 00 00       	call   80104dcd <release>
  ilock(ip);
80100a7d:	8b 45 08             	mov    0x8(%ebp),%eax
80100a80:	89 04 24             	mov    %eax,(%esp)
80100a83:	e8 e0 0d 00 00       	call   80101868 <ilock>

  return n;
80100a88:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100a8b:	c9                   	leave  
80100a8c:	c3                   	ret    

80100a8d <consoleinit>:

void
consoleinit(void)
{
80100a8d:	55                   	push   %ebp
80100a8e:	89 e5                	mov    %esp,%ebp
80100a90:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100a93:	c7 44 24 04 ef 83 10 	movl   $0x801083ef,0x4(%esp)
80100a9a:	80 
80100a9b:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100aa2:	e8 a3 42 00 00       	call   80104d4a <initlock>
  initlock(&input.lock, "input");
80100aa7:	c7 44 24 04 f7 83 10 	movl   $0x801083f7,0x4(%esp)
80100aae:	80 
80100aaf:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100ab6:	e8 8f 42 00 00       	call   80104d4a <initlock>

  devsw[CONSOLE].write = consolewrite;
80100abb:	c7 05 0c e8 10 80 26 	movl   $0x80100a26,0x8010e80c
80100ac2:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100ac5:	c7 05 08 e8 10 80 25 	movl   $0x80100925,0x8010e808
80100acc:	09 10 80 
  cons.locking = 1;
80100acf:	c7 05 f4 b5 10 80 01 	movl   $0x1,0x8010b5f4
80100ad6:	00 00 00 

  picenable(IRQ_KBD);
80100ad9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100ae0:	e8 dc 2f 00 00       	call   80103ac1 <picenable>
  ioapicenable(IRQ_KBD, 0);
80100ae5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100aec:	00 
80100aed:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100af4:	e8 7d 1e 00 00       	call   80102976 <ioapicenable>
}
80100af9:	c9                   	leave  
80100afa:	c3                   	ret    
	...

80100afc <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100afc:	55                   	push   %ebp
80100afd:	89 e5                	mov    %esp,%ebp
80100aff:	81 ec 38 01 00 00    	sub    $0x138,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  if((ip = namei(path)) == 0)
80100b05:	8b 45 08             	mov    0x8(%ebp),%eax
80100b08:	89 04 24             	mov    %eax,(%esp)
80100b0b:	e8 fa 18 00 00       	call   8010240a <namei>
80100b10:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b13:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b17:	75 0a                	jne    80100b23 <exec+0x27>
    return -1;
80100b19:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b1e:	e9 da 03 00 00       	jmp    80100efd <exec+0x401>
  ilock(ip);
80100b23:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b26:	89 04 24             	mov    %eax,(%esp)
80100b29:	e8 3a 0d 00 00       	call   80101868 <ilock>
  pgdir = 0;
80100b2e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100b35:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100b3c:	00 
80100b3d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100b44:	00 
80100b45:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100b4b:	89 44 24 04          	mov    %eax,0x4(%esp)
80100b4f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b52:	89 04 24             	mov    %eax,(%esp)
80100b55:	e8 04 12 00 00       	call   80101d5e <readi>
80100b5a:	83 f8 33             	cmp    $0x33,%eax
80100b5d:	0f 86 54 03 00 00    	jbe    80100eb7 <exec+0x3bb>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100b63:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100b69:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100b6e:	0f 85 46 03 00 00    	jne    80100eba <exec+0x3be>
    goto bad;

  if((pgdir = setupkvm(kalloc)) == 0)
80100b74:	c7 04 24 ff 2a 10 80 	movl   $0x80102aff,(%esp)
80100b7b:	e8 cd 6f 00 00       	call   80107b4d <setupkvm>
80100b80:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100b83:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100b87:	0f 84 30 03 00 00    	je     80100ebd <exec+0x3c1>
    goto bad;

  // Load program into memory.
  sz = 0;
80100b8d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100b94:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100b9b:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100ba1:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100ba4:	e9 c5 00 00 00       	jmp    80100c6e <exec+0x172>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100ba9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100bac:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100bb3:	00 
80100bb4:	89 44 24 08          	mov    %eax,0x8(%esp)
80100bb8:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100bbe:	89 44 24 04          	mov    %eax,0x4(%esp)
80100bc2:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100bc5:	89 04 24             	mov    %eax,(%esp)
80100bc8:	e8 91 11 00 00       	call   80101d5e <readi>
80100bcd:	83 f8 20             	cmp    $0x20,%eax
80100bd0:	0f 85 ea 02 00 00    	jne    80100ec0 <exec+0x3c4>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100bd6:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100bdc:	83 f8 01             	cmp    $0x1,%eax
80100bdf:	75 7f                	jne    80100c60 <exec+0x164>
      continue;
    if(ph.memsz < ph.filesz)
80100be1:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100be7:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100bed:	39 c2                	cmp    %eax,%edx
80100bef:	0f 82 ce 02 00 00    	jb     80100ec3 <exec+0x3c7>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100bf5:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100bfb:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c01:	01 d0                	add    %edx,%eax
80100c03:	89 44 24 08          	mov    %eax,0x8(%esp)
80100c07:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c0a:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c0e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c11:	89 04 24             	mov    %eax,(%esp)
80100c14:	e8 06 73 00 00       	call   80107f1f <allocuvm>
80100c19:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c1c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c20:	0f 84 a0 02 00 00    	je     80100ec6 <exec+0x3ca>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c26:	8b 8d fc fe ff ff    	mov    -0x104(%ebp),%ecx
80100c2c:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c32:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100c38:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100c3c:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100c40:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100c43:	89 54 24 08          	mov    %edx,0x8(%esp)
80100c47:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c4b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c4e:	89 04 24             	mov    %eax,(%esp)
80100c51:	e8 da 71 00 00       	call   80107e30 <loaduvm>
80100c56:	85 c0                	test   %eax,%eax
80100c58:	0f 88 6b 02 00 00    	js     80100ec9 <exec+0x3cd>
80100c5e:	eb 01                	jmp    80100c61 <exec+0x165>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100c60:	90                   	nop
  if((pgdir = setupkvm(kalloc)) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c61:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100c65:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c68:	83 c0 20             	add    $0x20,%eax
80100c6b:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c6e:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100c75:	0f b7 c0             	movzwl %ax,%eax
80100c78:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100c7b:	0f 8f 28 ff ff ff    	jg     80100ba9 <exec+0xad>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100c81:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100c84:	89 04 24             	mov    %eax,(%esp)
80100c87:	e8 60 0e 00 00       	call   80101aec <iunlockput>
  ip = 0;
80100c8c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100c93:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c96:	05 ff 0f 00 00       	add    $0xfff,%eax
80100c9b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100ca0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100ca3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100ca6:	05 00 20 00 00       	add    $0x2000,%eax
80100cab:	89 44 24 08          	mov    %eax,0x8(%esp)
80100caf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cb2:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cb6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100cb9:	89 04 24             	mov    %eax,(%esp)
80100cbc:	e8 5e 72 00 00       	call   80107f1f <allocuvm>
80100cc1:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cc4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cc8:	0f 84 fe 01 00 00    	je     80100ecc <exec+0x3d0>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100cce:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cd1:	2d 00 20 00 00       	sub    $0x2000,%eax
80100cd6:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cda:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100cdd:	89 04 24             	mov    %eax,(%esp)
80100ce0:	e8 5e 74 00 00       	call   80108143 <clearpteu>
  sp = sz;
80100ce5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100ce8:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100ceb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100cf2:	e9 81 00 00 00       	jmp    80100d78 <exec+0x27c>
    if(argc >= MAXARG)
80100cf7:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100cfb:	0f 87 ce 01 00 00    	ja     80100ecf <exec+0x3d3>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d01:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d04:	c1 e0 02             	shl    $0x2,%eax
80100d07:	03 45 0c             	add    0xc(%ebp),%eax
80100d0a:	8b 00                	mov    (%eax),%eax
80100d0c:	89 04 24             	mov    %eax,(%esp)
80100d0f:	e8 28 45 00 00       	call   8010523c <strlen>
80100d14:	f7 d0                	not    %eax
80100d16:	03 45 dc             	add    -0x24(%ebp),%eax
80100d19:	83 e0 fc             	and    $0xfffffffc,%eax
80100d1c:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d1f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d22:	c1 e0 02             	shl    $0x2,%eax
80100d25:	03 45 0c             	add    0xc(%ebp),%eax
80100d28:	8b 00                	mov    (%eax),%eax
80100d2a:	89 04 24             	mov    %eax,(%esp)
80100d2d:	e8 0a 45 00 00       	call   8010523c <strlen>
80100d32:	83 c0 01             	add    $0x1,%eax
80100d35:	89 c2                	mov    %eax,%edx
80100d37:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d3a:	c1 e0 02             	shl    $0x2,%eax
80100d3d:	03 45 0c             	add    0xc(%ebp),%eax
80100d40:	8b 00                	mov    (%eax),%eax
80100d42:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100d46:	89 44 24 08          	mov    %eax,0x8(%esp)
80100d4a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d4d:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d51:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100d54:	89 04 24             	mov    %eax,(%esp)
80100d57:	e8 9b 75 00 00       	call   801082f7 <copyout>
80100d5c:	85 c0                	test   %eax,%eax
80100d5e:	0f 88 6e 01 00 00    	js     80100ed2 <exec+0x3d6>
      goto bad;
    ustack[3+argc] = sp;
80100d64:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d67:	8d 50 03             	lea    0x3(%eax),%edx
80100d6a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d6d:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d74:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100d78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d7b:	c1 e0 02             	shl    $0x2,%eax
80100d7e:	03 45 0c             	add    0xc(%ebp),%eax
80100d81:	8b 00                	mov    (%eax),%eax
80100d83:	85 c0                	test   %eax,%eax
80100d85:	0f 85 6c ff ff ff    	jne    80100cf7 <exec+0x1fb>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100d8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d8e:	83 c0 03             	add    $0x3,%eax
80100d91:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100d98:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100d9c:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100da3:	ff ff ff 
  ustack[1] = argc;
80100da6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100da9:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100daf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100db2:	83 c0 01             	add    $0x1,%eax
80100db5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dbc:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dbf:	29 d0                	sub    %edx,%eax
80100dc1:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100dc7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dca:	83 c0 04             	add    $0x4,%eax
80100dcd:	c1 e0 02             	shl    $0x2,%eax
80100dd0:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100dd3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dd6:	83 c0 04             	add    $0x4,%eax
80100dd9:	c1 e0 02             	shl    $0x2,%eax
80100ddc:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100de0:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100de6:	89 44 24 08          	mov    %eax,0x8(%esp)
80100dea:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ded:	89 44 24 04          	mov    %eax,0x4(%esp)
80100df1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100df4:	89 04 24             	mov    %eax,(%esp)
80100df7:	e8 fb 74 00 00       	call   801082f7 <copyout>
80100dfc:	85 c0                	test   %eax,%eax
80100dfe:	0f 88 d1 00 00 00    	js     80100ed5 <exec+0x3d9>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e04:	8b 45 08             	mov    0x8(%ebp),%eax
80100e07:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100e0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e0d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100e10:	eb 17                	jmp    80100e29 <exec+0x32d>
    if(*s == '/')
80100e12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e15:	0f b6 00             	movzbl (%eax),%eax
80100e18:	3c 2f                	cmp    $0x2f,%al
80100e1a:	75 09                	jne    80100e25 <exec+0x329>
      last = s+1;
80100e1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e1f:	83 c0 01             	add    $0x1,%eax
80100e22:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e25:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100e29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e2c:	0f b6 00             	movzbl (%eax),%eax
80100e2f:	84 c0                	test   %al,%al
80100e31:	75 df                	jne    80100e12 <exec+0x316>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100e33:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e39:	8d 50 6c             	lea    0x6c(%eax),%edx
80100e3c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80100e43:	00 
80100e44:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100e47:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e4b:	89 14 24             	mov    %edx,(%esp)
80100e4e:	e8 9b 43 00 00       	call   801051ee <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100e53:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e59:	8b 40 04             	mov    0x4(%eax),%eax
80100e5c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100e5f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e65:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100e68:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100e6b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e71:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100e74:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100e76:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e7c:	8b 40 18             	mov    0x18(%eax),%eax
80100e7f:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100e85:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100e88:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e8e:	8b 40 18             	mov    0x18(%eax),%eax
80100e91:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100e94:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100e97:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e9d:	89 04 24             	mov    %eax,(%esp)
80100ea0:	e8 99 6d 00 00       	call   80107c3e <switchuvm>
  freevm(oldpgdir);
80100ea5:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100ea8:	89 04 24             	mov    %eax,(%esp)
80100eab:	e8 05 72 00 00       	call   801080b5 <freevm>
  return 0;
80100eb0:	b8 00 00 00 00       	mov    $0x0,%eax
80100eb5:	eb 46                	jmp    80100efd <exec+0x401>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
80100eb7:	90                   	nop
80100eb8:	eb 1c                	jmp    80100ed6 <exec+0x3da>
  if(elf.magic != ELF_MAGIC)
    goto bad;
80100eba:	90                   	nop
80100ebb:	eb 19                	jmp    80100ed6 <exec+0x3da>

  if((pgdir = setupkvm(kalloc)) == 0)
    goto bad;
80100ebd:	90                   	nop
80100ebe:	eb 16                	jmp    80100ed6 <exec+0x3da>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80100ec0:	90                   	nop
80100ec1:	eb 13                	jmp    80100ed6 <exec+0x3da>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80100ec3:	90                   	nop
80100ec4:	eb 10                	jmp    80100ed6 <exec+0x3da>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
80100ec6:	90                   	nop
80100ec7:	eb 0d                	jmp    80100ed6 <exec+0x3da>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80100ec9:	90                   	nop
80100eca:	eb 0a                	jmp    80100ed6 <exec+0x3da>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
80100ecc:	90                   	nop
80100ecd:	eb 07                	jmp    80100ed6 <exec+0x3da>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80100ecf:	90                   	nop
80100ed0:	eb 04                	jmp    80100ed6 <exec+0x3da>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80100ed2:	90                   	nop
80100ed3:	eb 01                	jmp    80100ed6 <exec+0x3da>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
80100ed5:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
80100ed6:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100eda:	74 0b                	je     80100ee7 <exec+0x3eb>
    freevm(pgdir);
80100edc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100edf:	89 04 24             	mov    %eax,(%esp)
80100ee2:	e8 ce 71 00 00       	call   801080b5 <freevm>
  if(ip)
80100ee7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100eeb:	74 0b                	je     80100ef8 <exec+0x3fc>
    iunlockput(ip);
80100eed:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100ef0:	89 04 24             	mov    %eax,(%esp)
80100ef3:	e8 f4 0b 00 00       	call   80101aec <iunlockput>
  return -1;
80100ef8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100efd:	c9                   	leave  
80100efe:	c3                   	ret    
	...

80100f00 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f00:	55                   	push   %ebp
80100f01:	89 e5                	mov    %esp,%ebp
80100f03:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
80100f06:	c7 44 24 04 fd 83 10 	movl   $0x801083fd,0x4(%esp)
80100f0d:	80 
80100f0e:	c7 04 24 60 de 10 80 	movl   $0x8010de60,(%esp)
80100f15:	e8 30 3e 00 00       	call   80104d4a <initlock>
}
80100f1a:	c9                   	leave  
80100f1b:	c3                   	ret    

80100f1c <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f1c:	55                   	push   %ebp
80100f1d:	89 e5                	mov    %esp,%ebp
80100f1f:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
80100f22:	c7 04 24 60 de 10 80 	movl   $0x8010de60,(%esp)
80100f29:	e8 3d 3e 00 00       	call   80104d6b <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f2e:	c7 45 f4 94 de 10 80 	movl   $0x8010de94,-0xc(%ebp)
80100f35:	eb 29                	jmp    80100f60 <filealloc+0x44>
    if(f->ref == 0){
80100f37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f3a:	8b 40 04             	mov    0x4(%eax),%eax
80100f3d:	85 c0                	test   %eax,%eax
80100f3f:	75 1b                	jne    80100f5c <filealloc+0x40>
      f->ref = 1;
80100f41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f44:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100f4b:	c7 04 24 60 de 10 80 	movl   $0x8010de60,(%esp)
80100f52:	e8 76 3e 00 00       	call   80104dcd <release>
      return f;
80100f57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f5a:	eb 1e                	jmp    80100f7a <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f5c:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100f60:	81 7d f4 f4 e7 10 80 	cmpl   $0x8010e7f4,-0xc(%ebp)
80100f67:	72 ce                	jb     80100f37 <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100f69:	c7 04 24 60 de 10 80 	movl   $0x8010de60,(%esp)
80100f70:	e8 58 3e 00 00       	call   80104dcd <release>
  return 0;
80100f75:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100f7a:	c9                   	leave  
80100f7b:	c3                   	ret    

80100f7c <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100f7c:	55                   	push   %ebp
80100f7d:	89 e5                	mov    %esp,%ebp
80100f7f:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
80100f82:	c7 04 24 60 de 10 80 	movl   $0x8010de60,(%esp)
80100f89:	e8 dd 3d 00 00       	call   80104d6b <acquire>
  if(f->ref < 1)
80100f8e:	8b 45 08             	mov    0x8(%ebp),%eax
80100f91:	8b 40 04             	mov    0x4(%eax),%eax
80100f94:	85 c0                	test   %eax,%eax
80100f96:	7f 0c                	jg     80100fa4 <filedup+0x28>
    panic("filedup");
80100f98:	c7 04 24 04 84 10 80 	movl   $0x80108404,(%esp)
80100f9f:	e8 99 f5 ff ff       	call   8010053d <panic>
  f->ref++;
80100fa4:	8b 45 08             	mov    0x8(%ebp),%eax
80100fa7:	8b 40 04             	mov    0x4(%eax),%eax
80100faa:	8d 50 01             	lea    0x1(%eax),%edx
80100fad:	8b 45 08             	mov    0x8(%ebp),%eax
80100fb0:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80100fb3:	c7 04 24 60 de 10 80 	movl   $0x8010de60,(%esp)
80100fba:	e8 0e 3e 00 00       	call   80104dcd <release>
  return f;
80100fbf:	8b 45 08             	mov    0x8(%ebp),%eax
}
80100fc2:	c9                   	leave  
80100fc3:	c3                   	ret    

80100fc4 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100fc4:	55                   	push   %ebp
80100fc5:	89 e5                	mov    %esp,%ebp
80100fc7:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
80100fca:	c7 04 24 60 de 10 80 	movl   $0x8010de60,(%esp)
80100fd1:	e8 95 3d 00 00       	call   80104d6b <acquire>
  if(f->ref < 1)
80100fd6:	8b 45 08             	mov    0x8(%ebp),%eax
80100fd9:	8b 40 04             	mov    0x4(%eax),%eax
80100fdc:	85 c0                	test   %eax,%eax
80100fde:	7f 0c                	jg     80100fec <fileclose+0x28>
    panic("fileclose");
80100fe0:	c7 04 24 0c 84 10 80 	movl   $0x8010840c,(%esp)
80100fe7:	e8 51 f5 ff ff       	call   8010053d <panic>
  if(--f->ref > 0){
80100fec:	8b 45 08             	mov    0x8(%ebp),%eax
80100fef:	8b 40 04             	mov    0x4(%eax),%eax
80100ff2:	8d 50 ff             	lea    -0x1(%eax),%edx
80100ff5:	8b 45 08             	mov    0x8(%ebp),%eax
80100ff8:	89 50 04             	mov    %edx,0x4(%eax)
80100ffb:	8b 45 08             	mov    0x8(%ebp),%eax
80100ffe:	8b 40 04             	mov    0x4(%eax),%eax
80101001:	85 c0                	test   %eax,%eax
80101003:	7e 11                	jle    80101016 <fileclose+0x52>
    release(&ftable.lock);
80101005:	c7 04 24 60 de 10 80 	movl   $0x8010de60,(%esp)
8010100c:	e8 bc 3d 00 00       	call   80104dcd <release>
    return;
80101011:	e9 82 00 00 00       	jmp    80101098 <fileclose+0xd4>
  }
  ff = *f;
80101016:	8b 45 08             	mov    0x8(%ebp),%eax
80101019:	8b 10                	mov    (%eax),%edx
8010101b:	89 55 e0             	mov    %edx,-0x20(%ebp)
8010101e:	8b 50 04             	mov    0x4(%eax),%edx
80101021:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101024:	8b 50 08             	mov    0x8(%eax),%edx
80101027:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010102a:	8b 50 0c             	mov    0xc(%eax),%edx
8010102d:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101030:	8b 50 10             	mov    0x10(%eax),%edx
80101033:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101036:	8b 40 14             	mov    0x14(%eax),%eax
80101039:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
8010103c:	8b 45 08             	mov    0x8(%ebp),%eax
8010103f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101046:	8b 45 08             	mov    0x8(%ebp),%eax
80101049:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
8010104f:	c7 04 24 60 de 10 80 	movl   $0x8010de60,(%esp)
80101056:	e8 72 3d 00 00       	call   80104dcd <release>
  
  if(ff.type == FD_PIPE)
8010105b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010105e:	83 f8 01             	cmp    $0x1,%eax
80101061:	75 18                	jne    8010107b <fileclose+0xb7>
    pipeclose(ff.pipe, ff.writable);
80101063:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101067:	0f be d0             	movsbl %al,%edx
8010106a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010106d:	89 54 24 04          	mov    %edx,0x4(%esp)
80101071:	89 04 24             	mov    %eax,(%esp)
80101074:	e8 02 2d 00 00       	call   80103d7b <pipeclose>
80101079:	eb 1d                	jmp    80101098 <fileclose+0xd4>
  else if(ff.type == FD_INODE){
8010107b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010107e:	83 f8 02             	cmp    $0x2,%eax
80101081:	75 15                	jne    80101098 <fileclose+0xd4>
    begin_trans();
80101083:	e8 95 21 00 00       	call   8010321d <begin_trans>
    iput(ff.ip);
80101088:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010108b:	89 04 24             	mov    %eax,(%esp)
8010108e:	e8 88 09 00 00       	call   80101a1b <iput>
    commit_trans();
80101093:	e8 ce 21 00 00       	call   80103266 <commit_trans>
  }
}
80101098:	c9                   	leave  
80101099:	c3                   	ret    

8010109a <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
8010109a:	55                   	push   %ebp
8010109b:	89 e5                	mov    %esp,%ebp
8010109d:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
801010a0:	8b 45 08             	mov    0x8(%ebp),%eax
801010a3:	8b 00                	mov    (%eax),%eax
801010a5:	83 f8 02             	cmp    $0x2,%eax
801010a8:	75 38                	jne    801010e2 <filestat+0x48>
    ilock(f->ip);
801010aa:	8b 45 08             	mov    0x8(%ebp),%eax
801010ad:	8b 40 10             	mov    0x10(%eax),%eax
801010b0:	89 04 24             	mov    %eax,(%esp)
801010b3:	e8 b0 07 00 00       	call   80101868 <ilock>
    stati(f->ip, st);
801010b8:	8b 45 08             	mov    0x8(%ebp),%eax
801010bb:	8b 40 10             	mov    0x10(%eax),%eax
801010be:	8b 55 0c             	mov    0xc(%ebp),%edx
801010c1:	89 54 24 04          	mov    %edx,0x4(%esp)
801010c5:	89 04 24             	mov    %eax,(%esp)
801010c8:	e8 4c 0c 00 00       	call   80101d19 <stati>
    iunlock(f->ip);
801010cd:	8b 45 08             	mov    0x8(%ebp),%eax
801010d0:	8b 40 10             	mov    0x10(%eax),%eax
801010d3:	89 04 24             	mov    %eax,(%esp)
801010d6:	e8 db 08 00 00       	call   801019b6 <iunlock>
    return 0;
801010db:	b8 00 00 00 00       	mov    $0x0,%eax
801010e0:	eb 05                	jmp    801010e7 <filestat+0x4d>
  }
  return -1;
801010e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801010e7:	c9                   	leave  
801010e8:	c3                   	ret    

801010e9 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801010e9:	55                   	push   %ebp
801010ea:	89 e5                	mov    %esp,%ebp
801010ec:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
801010ef:	8b 45 08             	mov    0x8(%ebp),%eax
801010f2:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801010f6:	84 c0                	test   %al,%al
801010f8:	75 0a                	jne    80101104 <fileread+0x1b>
    return -1;
801010fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801010ff:	e9 9f 00 00 00       	jmp    801011a3 <fileread+0xba>
  if(f->type == FD_PIPE)
80101104:	8b 45 08             	mov    0x8(%ebp),%eax
80101107:	8b 00                	mov    (%eax),%eax
80101109:	83 f8 01             	cmp    $0x1,%eax
8010110c:	75 1e                	jne    8010112c <fileread+0x43>
    return piperead(f->pipe, addr, n);
8010110e:	8b 45 08             	mov    0x8(%ebp),%eax
80101111:	8b 40 0c             	mov    0xc(%eax),%eax
80101114:	8b 55 10             	mov    0x10(%ebp),%edx
80101117:	89 54 24 08          	mov    %edx,0x8(%esp)
8010111b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010111e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101122:	89 04 24             	mov    %eax,(%esp)
80101125:	e8 d3 2d 00 00       	call   80103efd <piperead>
8010112a:	eb 77                	jmp    801011a3 <fileread+0xba>
  if(f->type == FD_INODE){
8010112c:	8b 45 08             	mov    0x8(%ebp),%eax
8010112f:	8b 00                	mov    (%eax),%eax
80101131:	83 f8 02             	cmp    $0x2,%eax
80101134:	75 61                	jne    80101197 <fileread+0xae>
    ilock(f->ip);
80101136:	8b 45 08             	mov    0x8(%ebp),%eax
80101139:	8b 40 10             	mov    0x10(%eax),%eax
8010113c:	89 04 24             	mov    %eax,(%esp)
8010113f:	e8 24 07 00 00       	call   80101868 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101144:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101147:	8b 45 08             	mov    0x8(%ebp),%eax
8010114a:	8b 50 14             	mov    0x14(%eax),%edx
8010114d:	8b 45 08             	mov    0x8(%ebp),%eax
80101150:	8b 40 10             	mov    0x10(%eax),%eax
80101153:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101157:	89 54 24 08          	mov    %edx,0x8(%esp)
8010115b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010115e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101162:	89 04 24             	mov    %eax,(%esp)
80101165:	e8 f4 0b 00 00       	call   80101d5e <readi>
8010116a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010116d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101171:	7e 11                	jle    80101184 <fileread+0x9b>
      f->off += r;
80101173:	8b 45 08             	mov    0x8(%ebp),%eax
80101176:	8b 50 14             	mov    0x14(%eax),%edx
80101179:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010117c:	01 c2                	add    %eax,%edx
8010117e:	8b 45 08             	mov    0x8(%ebp),%eax
80101181:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101184:	8b 45 08             	mov    0x8(%ebp),%eax
80101187:	8b 40 10             	mov    0x10(%eax),%eax
8010118a:	89 04 24             	mov    %eax,(%esp)
8010118d:	e8 24 08 00 00       	call   801019b6 <iunlock>
    return r;
80101192:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101195:	eb 0c                	jmp    801011a3 <fileread+0xba>
  }
  panic("fileread");
80101197:	c7 04 24 16 84 10 80 	movl   $0x80108416,(%esp)
8010119e:	e8 9a f3 ff ff       	call   8010053d <panic>
}
801011a3:	c9                   	leave  
801011a4:	c3                   	ret    

801011a5 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801011a5:	55                   	push   %ebp
801011a6:	89 e5                	mov    %esp,%ebp
801011a8:	53                   	push   %ebx
801011a9:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
801011ac:	8b 45 08             	mov    0x8(%ebp),%eax
801011af:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801011b3:	84 c0                	test   %al,%al
801011b5:	75 0a                	jne    801011c1 <filewrite+0x1c>
    return -1;
801011b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011bc:	e9 23 01 00 00       	jmp    801012e4 <filewrite+0x13f>
  if(f->type == FD_PIPE)
801011c1:	8b 45 08             	mov    0x8(%ebp),%eax
801011c4:	8b 00                	mov    (%eax),%eax
801011c6:	83 f8 01             	cmp    $0x1,%eax
801011c9:	75 21                	jne    801011ec <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
801011cb:	8b 45 08             	mov    0x8(%ebp),%eax
801011ce:	8b 40 0c             	mov    0xc(%eax),%eax
801011d1:	8b 55 10             	mov    0x10(%ebp),%edx
801011d4:	89 54 24 08          	mov    %edx,0x8(%esp)
801011d8:	8b 55 0c             	mov    0xc(%ebp),%edx
801011db:	89 54 24 04          	mov    %edx,0x4(%esp)
801011df:	89 04 24             	mov    %eax,(%esp)
801011e2:	e8 26 2c 00 00       	call   80103e0d <pipewrite>
801011e7:	e9 f8 00 00 00       	jmp    801012e4 <filewrite+0x13f>
  if(f->type == FD_INODE){
801011ec:	8b 45 08             	mov    0x8(%ebp),%eax
801011ef:	8b 00                	mov    (%eax),%eax
801011f1:	83 f8 02             	cmp    $0x2,%eax
801011f4:	0f 85 de 00 00 00    	jne    801012d8 <filewrite+0x133>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
801011fa:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
80101201:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101208:	e9 a8 00 00 00       	jmp    801012b5 <filewrite+0x110>
      int n1 = n - i;
8010120d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101210:	8b 55 10             	mov    0x10(%ebp),%edx
80101213:	89 d1                	mov    %edx,%ecx
80101215:	29 c1                	sub    %eax,%ecx
80101217:	89 c8                	mov    %ecx,%eax
80101219:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
8010121c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010121f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101222:	7e 06                	jle    8010122a <filewrite+0x85>
        n1 = max;
80101224:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101227:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_trans();
8010122a:	e8 ee 1f 00 00       	call   8010321d <begin_trans>
      ilock(f->ip);
8010122f:	8b 45 08             	mov    0x8(%ebp),%eax
80101232:	8b 40 10             	mov    0x10(%eax),%eax
80101235:	89 04 24             	mov    %eax,(%esp)
80101238:	e8 2b 06 00 00       	call   80101868 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010123d:	8b 5d f0             	mov    -0x10(%ebp),%ebx
80101240:	8b 45 08             	mov    0x8(%ebp),%eax
80101243:	8b 48 14             	mov    0x14(%eax),%ecx
80101246:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101249:	89 c2                	mov    %eax,%edx
8010124b:	03 55 0c             	add    0xc(%ebp),%edx
8010124e:	8b 45 08             	mov    0x8(%ebp),%eax
80101251:	8b 40 10             	mov    0x10(%eax),%eax
80101254:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80101258:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010125c:	89 54 24 04          	mov    %edx,0x4(%esp)
80101260:	89 04 24             	mov    %eax,(%esp)
80101263:	e8 61 0c 00 00       	call   80101ec9 <writei>
80101268:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010126b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010126f:	7e 11                	jle    80101282 <filewrite+0xdd>
        f->off += r;
80101271:	8b 45 08             	mov    0x8(%ebp),%eax
80101274:	8b 50 14             	mov    0x14(%eax),%edx
80101277:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010127a:	01 c2                	add    %eax,%edx
8010127c:	8b 45 08             	mov    0x8(%ebp),%eax
8010127f:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101282:	8b 45 08             	mov    0x8(%ebp),%eax
80101285:	8b 40 10             	mov    0x10(%eax),%eax
80101288:	89 04 24             	mov    %eax,(%esp)
8010128b:	e8 26 07 00 00       	call   801019b6 <iunlock>
      commit_trans();
80101290:	e8 d1 1f 00 00       	call   80103266 <commit_trans>

      if(r < 0)
80101295:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101299:	78 28                	js     801012c3 <filewrite+0x11e>
        break;
      if(r != n1)
8010129b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010129e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801012a1:	74 0c                	je     801012af <filewrite+0x10a>
        panic("short filewrite");
801012a3:	c7 04 24 1f 84 10 80 	movl   $0x8010841f,(%esp)
801012aa:	e8 8e f2 ff ff       	call   8010053d <panic>
      i += r;
801012af:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012b2:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801012b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012b8:	3b 45 10             	cmp    0x10(%ebp),%eax
801012bb:	0f 8c 4c ff ff ff    	jl     8010120d <filewrite+0x68>
801012c1:	eb 01                	jmp    801012c4 <filewrite+0x11f>
        f->off += r;
      iunlock(f->ip);
      commit_trans();

      if(r < 0)
        break;
801012c3:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
801012c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012c7:	3b 45 10             	cmp    0x10(%ebp),%eax
801012ca:	75 05                	jne    801012d1 <filewrite+0x12c>
801012cc:	8b 45 10             	mov    0x10(%ebp),%eax
801012cf:	eb 05                	jmp    801012d6 <filewrite+0x131>
801012d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012d6:	eb 0c                	jmp    801012e4 <filewrite+0x13f>
  }
  panic("filewrite");
801012d8:	c7 04 24 2f 84 10 80 	movl   $0x8010842f,(%esp)
801012df:	e8 59 f2 ff ff       	call   8010053d <panic>
}
801012e4:	83 c4 24             	add    $0x24,%esp
801012e7:	5b                   	pop    %ebx
801012e8:	5d                   	pop    %ebp
801012e9:	c3                   	ret    
	...

801012ec <readsb>:
static void itrunc(struct inode*);

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801012ec:	55                   	push   %ebp
801012ed:	89 e5                	mov    %esp,%ebp
801012ef:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
801012f2:	8b 45 08             	mov    0x8(%ebp),%eax
801012f5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801012fc:	00 
801012fd:	89 04 24             	mov    %eax,(%esp)
80101300:	e8 a1 ee ff ff       	call   801001a6 <bread>
80101305:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101308:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010130b:	83 c0 18             	add    $0x18,%eax
8010130e:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80101315:	00 
80101316:	89 44 24 04          	mov    %eax,0x4(%esp)
8010131a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010131d:	89 04 24             	mov    %eax,(%esp)
80101320:	e8 68 3d 00 00       	call   8010508d <memmove>
  brelse(bp);
80101325:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101328:	89 04 24             	mov    %eax,(%esp)
8010132b:	e8 e7 ee ff ff       	call   80100217 <brelse>
}
80101330:	c9                   	leave  
80101331:	c3                   	ret    

80101332 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101332:	55                   	push   %ebp
80101333:	89 e5                	mov    %esp,%ebp
80101335:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
80101338:	8b 55 0c             	mov    0xc(%ebp),%edx
8010133b:	8b 45 08             	mov    0x8(%ebp),%eax
8010133e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101342:	89 04 24             	mov    %eax,(%esp)
80101345:	e8 5c ee ff ff       	call   801001a6 <bread>
8010134a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010134d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101350:	83 c0 18             	add    $0x18,%eax
80101353:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010135a:	00 
8010135b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101362:	00 
80101363:	89 04 24             	mov    %eax,(%esp)
80101366:	e8 4f 3c 00 00       	call   80104fba <memset>
  log_write(bp);
8010136b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010136e:	89 04 24             	mov    %eax,(%esp)
80101371:	e8 48 1f 00 00       	call   801032be <log_write>
  brelse(bp);
80101376:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101379:	89 04 24             	mov    %eax,(%esp)
8010137c:	e8 96 ee ff ff       	call   80100217 <brelse>
}
80101381:	c9                   	leave  
80101382:	c3                   	ret    

80101383 <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101383:	55                   	push   %ebp
80101384:	89 e5                	mov    %esp,%ebp
80101386:	53                   	push   %ebx
80101387:	83 ec 34             	sub    $0x34,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
8010138a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  readsb(dev, &sb);
80101391:	8b 45 08             	mov    0x8(%ebp),%eax
80101394:	8d 55 d8             	lea    -0x28(%ebp),%edx
80101397:	89 54 24 04          	mov    %edx,0x4(%esp)
8010139b:	89 04 24             	mov    %eax,(%esp)
8010139e:	e8 49 ff ff ff       	call   801012ec <readsb>
  for(b = 0; b < sb.size; b += BPB){
801013a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801013aa:	e9 11 01 00 00       	jmp    801014c0 <balloc+0x13d>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
801013af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013b2:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801013b8:	85 c0                	test   %eax,%eax
801013ba:	0f 48 c2             	cmovs  %edx,%eax
801013bd:	c1 f8 0c             	sar    $0xc,%eax
801013c0:	8b 55 e0             	mov    -0x20(%ebp),%edx
801013c3:	c1 ea 03             	shr    $0x3,%edx
801013c6:	01 d0                	add    %edx,%eax
801013c8:	83 c0 03             	add    $0x3,%eax
801013cb:	89 44 24 04          	mov    %eax,0x4(%esp)
801013cf:	8b 45 08             	mov    0x8(%ebp),%eax
801013d2:	89 04 24             	mov    %eax,(%esp)
801013d5:	e8 cc ed ff ff       	call   801001a6 <bread>
801013da:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801013dd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801013e4:	e9 a7 00 00 00       	jmp    80101490 <balloc+0x10d>
      m = 1 << (bi % 8);
801013e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801013ec:	89 c2                	mov    %eax,%edx
801013ee:	c1 fa 1f             	sar    $0x1f,%edx
801013f1:	c1 ea 1d             	shr    $0x1d,%edx
801013f4:	01 d0                	add    %edx,%eax
801013f6:	83 e0 07             	and    $0x7,%eax
801013f9:	29 d0                	sub    %edx,%eax
801013fb:	ba 01 00 00 00       	mov    $0x1,%edx
80101400:	89 d3                	mov    %edx,%ebx
80101402:	89 c1                	mov    %eax,%ecx
80101404:	d3 e3                	shl    %cl,%ebx
80101406:	89 d8                	mov    %ebx,%eax
80101408:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010140b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010140e:	8d 50 07             	lea    0x7(%eax),%edx
80101411:	85 c0                	test   %eax,%eax
80101413:	0f 48 c2             	cmovs  %edx,%eax
80101416:	c1 f8 03             	sar    $0x3,%eax
80101419:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010141c:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101421:	0f b6 c0             	movzbl %al,%eax
80101424:	23 45 e8             	and    -0x18(%ebp),%eax
80101427:	85 c0                	test   %eax,%eax
80101429:	75 61                	jne    8010148c <balloc+0x109>
        bp->data[bi/8] |= m;  // Mark block in use.
8010142b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010142e:	8d 50 07             	lea    0x7(%eax),%edx
80101431:	85 c0                	test   %eax,%eax
80101433:	0f 48 c2             	cmovs  %edx,%eax
80101436:	c1 f8 03             	sar    $0x3,%eax
80101439:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010143c:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101441:	89 d1                	mov    %edx,%ecx
80101443:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101446:	09 ca                	or     %ecx,%edx
80101448:	89 d1                	mov    %edx,%ecx
8010144a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010144d:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
80101451:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101454:	89 04 24             	mov    %eax,(%esp)
80101457:	e8 62 1e 00 00       	call   801032be <log_write>
        brelse(bp);
8010145c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010145f:	89 04 24             	mov    %eax,(%esp)
80101462:	e8 b0 ed ff ff       	call   80100217 <brelse>
        bzero(dev, b + bi);
80101467:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010146a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010146d:	01 c2                	add    %eax,%edx
8010146f:	8b 45 08             	mov    0x8(%ebp),%eax
80101472:	89 54 24 04          	mov    %edx,0x4(%esp)
80101476:	89 04 24             	mov    %eax,(%esp)
80101479:	e8 b4 fe ff ff       	call   80101332 <bzero>
        return b + bi;
8010147e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101481:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101484:	01 d0                	add    %edx,%eax
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
}
80101486:	83 c4 34             	add    $0x34,%esp
80101489:	5b                   	pop    %ebx
8010148a:	5d                   	pop    %ebp
8010148b:	c3                   	ret    

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010148c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101490:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101497:	7f 15                	jg     801014ae <balloc+0x12b>
80101499:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010149c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010149f:	01 d0                	add    %edx,%eax
801014a1:	89 c2                	mov    %eax,%edx
801014a3:	8b 45 d8             	mov    -0x28(%ebp),%eax
801014a6:	39 c2                	cmp    %eax,%edx
801014a8:	0f 82 3b ff ff ff    	jb     801013e9 <balloc+0x66>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
801014ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014b1:	89 04 24             	mov    %eax,(%esp)
801014b4:	e8 5e ed ff ff       	call   80100217 <brelse>
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
801014b9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801014c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014c3:	8b 45 d8             	mov    -0x28(%ebp),%eax
801014c6:	39 c2                	cmp    %eax,%edx
801014c8:	0f 82 e1 fe ff ff    	jb     801013af <balloc+0x2c>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
801014ce:	c7 04 24 39 84 10 80 	movl   $0x80108439,(%esp)
801014d5:	e8 63 f0 ff ff       	call   8010053d <panic>

801014da <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
801014da:	55                   	push   %ebp
801014db:	89 e5                	mov    %esp,%ebp
801014dd:	53                   	push   %ebx
801014de:	83 ec 34             	sub    $0x34,%esp
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
801014e1:	8d 45 dc             	lea    -0x24(%ebp),%eax
801014e4:	89 44 24 04          	mov    %eax,0x4(%esp)
801014e8:	8b 45 08             	mov    0x8(%ebp),%eax
801014eb:	89 04 24             	mov    %eax,(%esp)
801014ee:	e8 f9 fd ff ff       	call   801012ec <readsb>
  bp = bread(dev, BBLOCK(b, sb.ninodes));
801014f3:	8b 45 0c             	mov    0xc(%ebp),%eax
801014f6:	89 c2                	mov    %eax,%edx
801014f8:	c1 ea 0c             	shr    $0xc,%edx
801014fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801014fe:	c1 e8 03             	shr    $0x3,%eax
80101501:	01 d0                	add    %edx,%eax
80101503:	8d 50 03             	lea    0x3(%eax),%edx
80101506:	8b 45 08             	mov    0x8(%ebp),%eax
80101509:	89 54 24 04          	mov    %edx,0x4(%esp)
8010150d:	89 04 24             	mov    %eax,(%esp)
80101510:	e8 91 ec ff ff       	call   801001a6 <bread>
80101515:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101518:	8b 45 0c             	mov    0xc(%ebp),%eax
8010151b:	25 ff 0f 00 00       	and    $0xfff,%eax
80101520:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101523:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101526:	89 c2                	mov    %eax,%edx
80101528:	c1 fa 1f             	sar    $0x1f,%edx
8010152b:	c1 ea 1d             	shr    $0x1d,%edx
8010152e:	01 d0                	add    %edx,%eax
80101530:	83 e0 07             	and    $0x7,%eax
80101533:	29 d0                	sub    %edx,%eax
80101535:	ba 01 00 00 00       	mov    $0x1,%edx
8010153a:	89 d3                	mov    %edx,%ebx
8010153c:	89 c1                	mov    %eax,%ecx
8010153e:	d3 e3                	shl    %cl,%ebx
80101540:	89 d8                	mov    %ebx,%eax
80101542:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101545:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101548:	8d 50 07             	lea    0x7(%eax),%edx
8010154b:	85 c0                	test   %eax,%eax
8010154d:	0f 48 c2             	cmovs  %edx,%eax
80101550:	c1 f8 03             	sar    $0x3,%eax
80101553:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101556:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
8010155b:	0f b6 c0             	movzbl %al,%eax
8010155e:	23 45 ec             	and    -0x14(%ebp),%eax
80101561:	85 c0                	test   %eax,%eax
80101563:	75 0c                	jne    80101571 <bfree+0x97>
    panic("freeing free block");
80101565:	c7 04 24 4f 84 10 80 	movl   $0x8010844f,(%esp)
8010156c:	e8 cc ef ff ff       	call   8010053d <panic>
  bp->data[bi/8] &= ~m;
80101571:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101574:	8d 50 07             	lea    0x7(%eax),%edx
80101577:	85 c0                	test   %eax,%eax
80101579:	0f 48 c2             	cmovs  %edx,%eax
8010157c:	c1 f8 03             	sar    $0x3,%eax
8010157f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101582:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101587:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010158a:	f7 d1                	not    %ecx
8010158c:	21 ca                	and    %ecx,%edx
8010158e:	89 d1                	mov    %edx,%ecx
80101590:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101593:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
80101597:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010159a:	89 04 24             	mov    %eax,(%esp)
8010159d:	e8 1c 1d 00 00       	call   801032be <log_write>
  brelse(bp);
801015a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015a5:	89 04 24             	mov    %eax,(%esp)
801015a8:	e8 6a ec ff ff       	call   80100217 <brelse>
}
801015ad:	83 c4 34             	add    $0x34,%esp
801015b0:	5b                   	pop    %ebx
801015b1:	5d                   	pop    %ebp
801015b2:	c3                   	ret    

801015b3 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
801015b3:	55                   	push   %ebp
801015b4:	89 e5                	mov    %esp,%ebp
801015b6:	83 ec 18             	sub    $0x18,%esp
  initlock(&icache.lock, "icache");
801015b9:	c7 44 24 04 62 84 10 	movl   $0x80108462,0x4(%esp)
801015c0:	80 
801015c1:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
801015c8:	e8 7d 37 00 00       	call   80104d4a <initlock>
}
801015cd:	c9                   	leave  
801015ce:	c3                   	ret    

801015cf <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
801015cf:	55                   	push   %ebp
801015d0:	89 e5                	mov    %esp,%ebp
801015d2:	83 ec 48             	sub    $0x48,%esp
801015d5:	8b 45 0c             	mov    0xc(%ebp),%eax
801015d8:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
801015dc:	8b 45 08             	mov    0x8(%ebp),%eax
801015df:	8d 55 dc             	lea    -0x24(%ebp),%edx
801015e2:	89 54 24 04          	mov    %edx,0x4(%esp)
801015e6:	89 04 24             	mov    %eax,(%esp)
801015e9:	e8 fe fc ff ff       	call   801012ec <readsb>

  for(inum = 1; inum < sb.ninodes; inum++){
801015ee:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801015f5:	e9 98 00 00 00       	jmp    80101692 <ialloc+0xc3>
    bp = bread(dev, IBLOCK(inum));
801015fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015fd:	c1 e8 03             	shr    $0x3,%eax
80101600:	83 c0 02             	add    $0x2,%eax
80101603:	89 44 24 04          	mov    %eax,0x4(%esp)
80101607:	8b 45 08             	mov    0x8(%ebp),%eax
8010160a:	89 04 24             	mov    %eax,(%esp)
8010160d:	e8 94 eb ff ff       	call   801001a6 <bread>
80101612:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101615:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101618:	8d 50 18             	lea    0x18(%eax),%edx
8010161b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010161e:	83 e0 07             	and    $0x7,%eax
80101621:	c1 e0 06             	shl    $0x6,%eax
80101624:	01 d0                	add    %edx,%eax
80101626:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101629:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010162c:	0f b7 00             	movzwl (%eax),%eax
8010162f:	66 85 c0             	test   %ax,%ax
80101632:	75 4f                	jne    80101683 <ialloc+0xb4>
      memset(dip, 0, sizeof(*dip));
80101634:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
8010163b:	00 
8010163c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101643:	00 
80101644:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101647:	89 04 24             	mov    %eax,(%esp)
8010164a:	e8 6b 39 00 00       	call   80104fba <memset>
      dip->type = type;
8010164f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101652:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
80101656:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101659:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010165c:	89 04 24             	mov    %eax,(%esp)
8010165f:	e8 5a 1c 00 00       	call   801032be <log_write>
      brelse(bp);
80101664:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101667:	89 04 24             	mov    %eax,(%esp)
8010166a:	e8 a8 eb ff ff       	call   80100217 <brelse>
      return iget(dev, inum);
8010166f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101672:	89 44 24 04          	mov    %eax,0x4(%esp)
80101676:	8b 45 08             	mov    0x8(%ebp),%eax
80101679:	89 04 24             	mov    %eax,(%esp)
8010167c:	e8 e3 00 00 00       	call   80101764 <iget>
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
}
80101681:	c9                   	leave  
80101682:	c3                   	ret    
      dip->type = type;
      log_write(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
80101683:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101686:	89 04 24             	mov    %eax,(%esp)
80101689:	e8 89 eb ff ff       	call   80100217 <brelse>
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);

  for(inum = 1; inum < sb.ninodes; inum++){
8010168e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101692:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101695:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101698:	39 c2                	cmp    %eax,%edx
8010169a:	0f 82 5a ff ff ff    	jb     801015fa <ialloc+0x2b>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
801016a0:	c7 04 24 69 84 10 80 	movl   $0x80108469,(%esp)
801016a7:	e8 91 ee ff ff       	call   8010053d <panic>

801016ac <iupdate>:
}

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
801016ac:	55                   	push   %ebp
801016ad:	89 e5                	mov    %esp,%ebp
801016af:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
801016b2:	8b 45 08             	mov    0x8(%ebp),%eax
801016b5:	8b 40 04             	mov    0x4(%eax),%eax
801016b8:	c1 e8 03             	shr    $0x3,%eax
801016bb:	8d 50 02             	lea    0x2(%eax),%edx
801016be:	8b 45 08             	mov    0x8(%ebp),%eax
801016c1:	8b 00                	mov    (%eax),%eax
801016c3:	89 54 24 04          	mov    %edx,0x4(%esp)
801016c7:	89 04 24             	mov    %eax,(%esp)
801016ca:	e8 d7 ea ff ff       	call   801001a6 <bread>
801016cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801016d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016d5:	8d 50 18             	lea    0x18(%eax),%edx
801016d8:	8b 45 08             	mov    0x8(%ebp),%eax
801016db:	8b 40 04             	mov    0x4(%eax),%eax
801016de:	83 e0 07             	and    $0x7,%eax
801016e1:	c1 e0 06             	shl    $0x6,%eax
801016e4:	01 d0                	add    %edx,%eax
801016e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801016e9:	8b 45 08             	mov    0x8(%ebp),%eax
801016ec:	0f b7 50 10          	movzwl 0x10(%eax),%edx
801016f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016f3:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801016f6:	8b 45 08             	mov    0x8(%ebp),%eax
801016f9:	0f b7 50 12          	movzwl 0x12(%eax),%edx
801016fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101700:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101704:	8b 45 08             	mov    0x8(%ebp),%eax
80101707:	0f b7 50 14          	movzwl 0x14(%eax),%edx
8010170b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010170e:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101712:	8b 45 08             	mov    0x8(%ebp),%eax
80101715:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101719:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010171c:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101720:	8b 45 08             	mov    0x8(%ebp),%eax
80101723:	8b 50 18             	mov    0x18(%eax),%edx
80101726:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101729:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010172c:	8b 45 08             	mov    0x8(%ebp),%eax
8010172f:	8d 50 1c             	lea    0x1c(%eax),%edx
80101732:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101735:	83 c0 0c             	add    $0xc,%eax
80101738:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
8010173f:	00 
80101740:	89 54 24 04          	mov    %edx,0x4(%esp)
80101744:	89 04 24             	mov    %eax,(%esp)
80101747:	e8 41 39 00 00       	call   8010508d <memmove>
  log_write(bp);
8010174c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010174f:	89 04 24             	mov    %eax,(%esp)
80101752:	e8 67 1b 00 00       	call   801032be <log_write>
  brelse(bp);
80101757:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010175a:	89 04 24             	mov    %eax,(%esp)
8010175d:	e8 b5 ea ff ff       	call   80100217 <brelse>
}
80101762:	c9                   	leave  
80101763:	c3                   	ret    

80101764 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101764:	55                   	push   %ebp
80101765:	89 e5                	mov    %esp,%ebp
80101767:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
8010176a:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
80101771:	e8 f5 35 00 00       	call   80104d6b <acquire>

  // Is the inode already cached?
  empty = 0;
80101776:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010177d:	c7 45 f4 94 e8 10 80 	movl   $0x8010e894,-0xc(%ebp)
80101784:	eb 59                	jmp    801017df <iget+0x7b>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101786:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101789:	8b 40 08             	mov    0x8(%eax),%eax
8010178c:	85 c0                	test   %eax,%eax
8010178e:	7e 35                	jle    801017c5 <iget+0x61>
80101790:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101793:	8b 00                	mov    (%eax),%eax
80101795:	3b 45 08             	cmp    0x8(%ebp),%eax
80101798:	75 2b                	jne    801017c5 <iget+0x61>
8010179a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010179d:	8b 40 04             	mov    0x4(%eax),%eax
801017a0:	3b 45 0c             	cmp    0xc(%ebp),%eax
801017a3:	75 20                	jne    801017c5 <iget+0x61>
      ip->ref++;
801017a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017a8:	8b 40 08             	mov    0x8(%eax),%eax
801017ab:	8d 50 01             	lea    0x1(%eax),%edx
801017ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017b1:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
801017b4:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
801017bb:	e8 0d 36 00 00       	call   80104dcd <release>
      return ip;
801017c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017c3:	eb 6f                	jmp    80101834 <iget+0xd0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801017c5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801017c9:	75 10                	jne    801017db <iget+0x77>
801017cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017ce:	8b 40 08             	mov    0x8(%eax),%eax
801017d1:	85 c0                	test   %eax,%eax
801017d3:	75 06                	jne    801017db <iget+0x77>
      empty = ip;
801017d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017d8:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801017db:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
801017df:	81 7d f4 34 f8 10 80 	cmpl   $0x8010f834,-0xc(%ebp)
801017e6:	72 9e                	jb     80101786 <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801017e8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801017ec:	75 0c                	jne    801017fa <iget+0x96>
    panic("iget: no inodes");
801017ee:	c7 04 24 7b 84 10 80 	movl   $0x8010847b,(%esp)
801017f5:	e8 43 ed ff ff       	call   8010053d <panic>

  ip = empty;
801017fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101800:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101803:	8b 55 08             	mov    0x8(%ebp),%edx
80101806:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101808:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010180b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010180e:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101811:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101814:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
8010181b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010181e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101825:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
8010182c:	e8 9c 35 00 00       	call   80104dcd <release>

  return ip;
80101831:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101834:	c9                   	leave  
80101835:	c3                   	ret    

80101836 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101836:	55                   	push   %ebp
80101837:	89 e5                	mov    %esp,%ebp
80101839:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
8010183c:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
80101843:	e8 23 35 00 00       	call   80104d6b <acquire>
  ip->ref++;
80101848:	8b 45 08             	mov    0x8(%ebp),%eax
8010184b:	8b 40 08             	mov    0x8(%eax),%eax
8010184e:	8d 50 01             	lea    0x1(%eax),%edx
80101851:	8b 45 08             	mov    0x8(%ebp),%eax
80101854:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101857:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
8010185e:	e8 6a 35 00 00       	call   80104dcd <release>
  return ip;
80101863:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101866:	c9                   	leave  
80101867:	c3                   	ret    

80101868 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101868:	55                   	push   %ebp
80101869:	89 e5                	mov    %esp,%ebp
8010186b:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
8010186e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101872:	74 0a                	je     8010187e <ilock+0x16>
80101874:	8b 45 08             	mov    0x8(%ebp),%eax
80101877:	8b 40 08             	mov    0x8(%eax),%eax
8010187a:	85 c0                	test   %eax,%eax
8010187c:	7f 0c                	jg     8010188a <ilock+0x22>
    panic("ilock");
8010187e:	c7 04 24 8b 84 10 80 	movl   $0x8010848b,(%esp)
80101885:	e8 b3 ec ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
8010188a:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
80101891:	e8 d5 34 00 00       	call   80104d6b <acquire>
  while(ip->flags & I_BUSY)
80101896:	eb 13                	jmp    801018ab <ilock+0x43>
    sleep(ip, &icache.lock);
80101898:	c7 44 24 04 60 e8 10 	movl   $0x8010e860,0x4(%esp)
8010189f:	80 
801018a0:	8b 45 08             	mov    0x8(%ebp),%eax
801018a3:	89 04 24             	mov    %eax,(%esp)
801018a6:	e8 a6 31 00 00       	call   80104a51 <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
801018ab:	8b 45 08             	mov    0x8(%ebp),%eax
801018ae:	8b 40 0c             	mov    0xc(%eax),%eax
801018b1:	83 e0 01             	and    $0x1,%eax
801018b4:	84 c0                	test   %al,%al
801018b6:	75 e0                	jne    80101898 <ilock+0x30>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
801018b8:	8b 45 08             	mov    0x8(%ebp),%eax
801018bb:	8b 40 0c             	mov    0xc(%eax),%eax
801018be:	89 c2                	mov    %eax,%edx
801018c0:	83 ca 01             	or     $0x1,%edx
801018c3:	8b 45 08             	mov    0x8(%ebp),%eax
801018c6:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
801018c9:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
801018d0:	e8 f8 34 00 00       	call   80104dcd <release>

  if(!(ip->flags & I_VALID)){
801018d5:	8b 45 08             	mov    0x8(%ebp),%eax
801018d8:	8b 40 0c             	mov    0xc(%eax),%eax
801018db:	83 e0 02             	and    $0x2,%eax
801018de:	85 c0                	test   %eax,%eax
801018e0:	0f 85 ce 00 00 00    	jne    801019b4 <ilock+0x14c>
    bp = bread(ip->dev, IBLOCK(ip->inum));
801018e6:	8b 45 08             	mov    0x8(%ebp),%eax
801018e9:	8b 40 04             	mov    0x4(%eax),%eax
801018ec:	c1 e8 03             	shr    $0x3,%eax
801018ef:	8d 50 02             	lea    0x2(%eax),%edx
801018f2:	8b 45 08             	mov    0x8(%ebp),%eax
801018f5:	8b 00                	mov    (%eax),%eax
801018f7:	89 54 24 04          	mov    %edx,0x4(%esp)
801018fb:	89 04 24             	mov    %eax,(%esp)
801018fe:	e8 a3 e8 ff ff       	call   801001a6 <bread>
80101903:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101906:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101909:	8d 50 18             	lea    0x18(%eax),%edx
8010190c:	8b 45 08             	mov    0x8(%ebp),%eax
8010190f:	8b 40 04             	mov    0x4(%eax),%eax
80101912:	83 e0 07             	and    $0x7,%eax
80101915:	c1 e0 06             	shl    $0x6,%eax
80101918:	01 d0                	add    %edx,%eax
8010191a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
8010191d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101920:	0f b7 10             	movzwl (%eax),%edx
80101923:	8b 45 08             	mov    0x8(%ebp),%eax
80101926:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
8010192a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010192d:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101931:	8b 45 08             	mov    0x8(%ebp),%eax
80101934:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101938:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010193b:	0f b7 50 04          	movzwl 0x4(%eax),%edx
8010193f:	8b 45 08             	mov    0x8(%ebp),%eax
80101942:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101946:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101949:	0f b7 50 06          	movzwl 0x6(%eax),%edx
8010194d:	8b 45 08             	mov    0x8(%ebp),%eax
80101950:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101954:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101957:	8b 50 08             	mov    0x8(%eax),%edx
8010195a:	8b 45 08             	mov    0x8(%ebp),%eax
8010195d:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101960:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101963:	8d 50 0c             	lea    0xc(%eax),%edx
80101966:	8b 45 08             	mov    0x8(%ebp),%eax
80101969:	83 c0 1c             	add    $0x1c,%eax
8010196c:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101973:	00 
80101974:	89 54 24 04          	mov    %edx,0x4(%esp)
80101978:	89 04 24             	mov    %eax,(%esp)
8010197b:	e8 0d 37 00 00       	call   8010508d <memmove>
    brelse(bp);
80101980:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101983:	89 04 24             	mov    %eax,(%esp)
80101986:	e8 8c e8 ff ff       	call   80100217 <brelse>
    ip->flags |= I_VALID;
8010198b:	8b 45 08             	mov    0x8(%ebp),%eax
8010198e:	8b 40 0c             	mov    0xc(%eax),%eax
80101991:	89 c2                	mov    %eax,%edx
80101993:	83 ca 02             	or     $0x2,%edx
80101996:	8b 45 08             	mov    0x8(%ebp),%eax
80101999:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
8010199c:	8b 45 08             	mov    0x8(%ebp),%eax
8010199f:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801019a3:	66 85 c0             	test   %ax,%ax
801019a6:	75 0c                	jne    801019b4 <ilock+0x14c>
      panic("ilock: no type");
801019a8:	c7 04 24 91 84 10 80 	movl   $0x80108491,(%esp)
801019af:	e8 89 eb ff ff       	call   8010053d <panic>
  }
}
801019b4:	c9                   	leave  
801019b5:	c3                   	ret    

801019b6 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
801019b6:	55                   	push   %ebp
801019b7:	89 e5                	mov    %esp,%ebp
801019b9:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
801019bc:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801019c0:	74 17                	je     801019d9 <iunlock+0x23>
801019c2:	8b 45 08             	mov    0x8(%ebp),%eax
801019c5:	8b 40 0c             	mov    0xc(%eax),%eax
801019c8:	83 e0 01             	and    $0x1,%eax
801019cb:	85 c0                	test   %eax,%eax
801019cd:	74 0a                	je     801019d9 <iunlock+0x23>
801019cf:	8b 45 08             	mov    0x8(%ebp),%eax
801019d2:	8b 40 08             	mov    0x8(%eax),%eax
801019d5:	85 c0                	test   %eax,%eax
801019d7:	7f 0c                	jg     801019e5 <iunlock+0x2f>
    panic("iunlock");
801019d9:	c7 04 24 a0 84 10 80 	movl   $0x801084a0,(%esp)
801019e0:	e8 58 eb ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
801019e5:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
801019ec:	e8 7a 33 00 00       	call   80104d6b <acquire>
  ip->flags &= ~I_BUSY;
801019f1:	8b 45 08             	mov    0x8(%ebp),%eax
801019f4:	8b 40 0c             	mov    0xc(%eax),%eax
801019f7:	89 c2                	mov    %eax,%edx
801019f9:	83 e2 fe             	and    $0xfffffffe,%edx
801019fc:	8b 45 08             	mov    0x8(%ebp),%eax
801019ff:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101a02:	8b 45 08             	mov    0x8(%ebp),%eax
80101a05:	89 04 24             	mov    %eax,(%esp)
80101a08:	e8 30 31 00 00       	call   80104b3d <wakeup>
  release(&icache.lock);
80101a0d:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
80101a14:	e8 b4 33 00 00       	call   80104dcd <release>
}
80101a19:	c9                   	leave  
80101a1a:	c3                   	ret    

80101a1b <iput>:
// be recycled.
// If that was the last reference and the inode has no links
// to it, free the inode (and its content) on disk.
void
iput(struct inode *ip)
{
80101a1b:	55                   	push   %ebp
80101a1c:	89 e5                	mov    %esp,%ebp
80101a1e:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101a21:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
80101a28:	e8 3e 33 00 00       	call   80104d6b <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101a2d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a30:	8b 40 08             	mov    0x8(%eax),%eax
80101a33:	83 f8 01             	cmp    $0x1,%eax
80101a36:	0f 85 93 00 00 00    	jne    80101acf <iput+0xb4>
80101a3c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a3f:	8b 40 0c             	mov    0xc(%eax),%eax
80101a42:	83 e0 02             	and    $0x2,%eax
80101a45:	85 c0                	test   %eax,%eax
80101a47:	0f 84 82 00 00 00    	je     80101acf <iput+0xb4>
80101a4d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a50:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101a54:	66 85 c0             	test   %ax,%ax
80101a57:	75 76                	jne    80101acf <iput+0xb4>
    // inode has no links: truncate and free inode.
    if(ip->flags & I_BUSY)
80101a59:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5c:	8b 40 0c             	mov    0xc(%eax),%eax
80101a5f:	83 e0 01             	and    $0x1,%eax
80101a62:	84 c0                	test   %al,%al
80101a64:	74 0c                	je     80101a72 <iput+0x57>
      panic("iput busy");
80101a66:	c7 04 24 a8 84 10 80 	movl   $0x801084a8,(%esp)
80101a6d:	e8 cb ea ff ff       	call   8010053d <panic>
    ip->flags |= I_BUSY;
80101a72:	8b 45 08             	mov    0x8(%ebp),%eax
80101a75:	8b 40 0c             	mov    0xc(%eax),%eax
80101a78:	89 c2                	mov    %eax,%edx
80101a7a:	83 ca 01             	or     $0x1,%edx
80101a7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a80:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101a83:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
80101a8a:	e8 3e 33 00 00       	call   80104dcd <release>
    itrunc(ip);
80101a8f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a92:	89 04 24             	mov    %eax,(%esp)
80101a95:	e8 72 01 00 00       	call   80101c0c <itrunc>
    ip->type = 0;
80101a9a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9d:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101aa3:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa6:	89 04 24             	mov    %eax,(%esp)
80101aa9:	e8 fe fb ff ff       	call   801016ac <iupdate>
    acquire(&icache.lock);
80101aae:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
80101ab5:	e8 b1 32 00 00       	call   80104d6b <acquire>
    ip->flags = 0;
80101aba:	8b 45 08             	mov    0x8(%ebp),%eax
80101abd:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101ac4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac7:	89 04 24             	mov    %eax,(%esp)
80101aca:	e8 6e 30 00 00       	call   80104b3d <wakeup>
  }
  ip->ref--;
80101acf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad2:	8b 40 08             	mov    0x8(%eax),%eax
80101ad5:	8d 50 ff             	lea    -0x1(%eax),%edx
80101ad8:	8b 45 08             	mov    0x8(%ebp),%eax
80101adb:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101ade:	c7 04 24 60 e8 10 80 	movl   $0x8010e860,(%esp)
80101ae5:	e8 e3 32 00 00       	call   80104dcd <release>
}
80101aea:	c9                   	leave  
80101aeb:	c3                   	ret    

80101aec <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101aec:	55                   	push   %ebp
80101aed:	89 e5                	mov    %esp,%ebp
80101aef:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101af2:	8b 45 08             	mov    0x8(%ebp),%eax
80101af5:	89 04 24             	mov    %eax,(%esp)
80101af8:	e8 b9 fe ff ff       	call   801019b6 <iunlock>
  iput(ip);
80101afd:	8b 45 08             	mov    0x8(%ebp),%eax
80101b00:	89 04 24             	mov    %eax,(%esp)
80101b03:	e8 13 ff ff ff       	call   80101a1b <iput>
}
80101b08:	c9                   	leave  
80101b09:	c3                   	ret    

80101b0a <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101b0a:	55                   	push   %ebp
80101b0b:	89 e5                	mov    %esp,%ebp
80101b0d:	53                   	push   %ebx
80101b0e:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101b11:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101b15:	77 3e                	ja     80101b55 <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101b17:	8b 45 08             	mov    0x8(%ebp),%eax
80101b1a:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b1d:	83 c2 04             	add    $0x4,%edx
80101b20:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101b24:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b27:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b2b:	75 20                	jne    80101b4d <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101b2d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b30:	8b 00                	mov    (%eax),%eax
80101b32:	89 04 24             	mov    %eax,(%esp)
80101b35:	e8 49 f8 ff ff       	call   80101383 <balloc>
80101b3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b3d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b40:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b43:	8d 4a 04             	lea    0x4(%edx),%ecx
80101b46:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b49:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b50:	e9 b1 00 00 00       	jmp    80101c06 <bmap+0xfc>
  }
  bn -= NDIRECT;
80101b55:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101b59:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101b5d:	0f 87 97 00 00 00    	ja     80101bfa <bmap+0xf0>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101b63:	8b 45 08             	mov    0x8(%ebp),%eax
80101b66:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b69:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b6c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b70:	75 19                	jne    80101b8b <bmap+0x81>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101b72:	8b 45 08             	mov    0x8(%ebp),%eax
80101b75:	8b 00                	mov    (%eax),%eax
80101b77:	89 04 24             	mov    %eax,(%esp)
80101b7a:	e8 04 f8 ff ff       	call   80101383 <balloc>
80101b7f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b82:	8b 45 08             	mov    0x8(%ebp),%eax
80101b85:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b88:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101b8b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8e:	8b 00                	mov    (%eax),%eax
80101b90:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b93:	89 54 24 04          	mov    %edx,0x4(%esp)
80101b97:	89 04 24             	mov    %eax,(%esp)
80101b9a:	e8 07 e6 ff ff       	call   801001a6 <bread>
80101b9f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101ba2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ba5:	83 c0 18             	add    $0x18,%eax
80101ba8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101bab:	8b 45 0c             	mov    0xc(%ebp),%eax
80101bae:	c1 e0 02             	shl    $0x2,%eax
80101bb1:	03 45 ec             	add    -0x14(%ebp),%eax
80101bb4:	8b 00                	mov    (%eax),%eax
80101bb6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bb9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101bbd:	75 2b                	jne    80101bea <bmap+0xe0>
      a[bn] = addr = balloc(ip->dev);
80101bbf:	8b 45 0c             	mov    0xc(%ebp),%eax
80101bc2:	c1 e0 02             	shl    $0x2,%eax
80101bc5:	89 c3                	mov    %eax,%ebx
80101bc7:	03 5d ec             	add    -0x14(%ebp),%ebx
80101bca:	8b 45 08             	mov    0x8(%ebp),%eax
80101bcd:	8b 00                	mov    (%eax),%eax
80101bcf:	89 04 24             	mov    %eax,(%esp)
80101bd2:	e8 ac f7 ff ff       	call   80101383 <balloc>
80101bd7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bdd:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101bdf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101be2:	89 04 24             	mov    %eax,(%esp)
80101be5:	e8 d4 16 00 00       	call   801032be <log_write>
    }
    brelse(bp);
80101bea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bed:	89 04 24             	mov    %eax,(%esp)
80101bf0:	e8 22 e6 ff ff       	call   80100217 <brelse>
    return addr;
80101bf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bf8:	eb 0c                	jmp    80101c06 <bmap+0xfc>
  }

  panic("bmap: out of range");
80101bfa:	c7 04 24 b2 84 10 80 	movl   $0x801084b2,(%esp)
80101c01:	e8 37 e9 ff ff       	call   8010053d <panic>
}
80101c06:	83 c4 24             	add    $0x24,%esp
80101c09:	5b                   	pop    %ebx
80101c0a:	5d                   	pop    %ebp
80101c0b:	c3                   	ret    

80101c0c <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101c0c:	55                   	push   %ebp
80101c0d:	89 e5                	mov    %esp,%ebp
80101c0f:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101c12:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101c19:	eb 44                	jmp    80101c5f <itrunc+0x53>
    if(ip->addrs[i]){
80101c1b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c1e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c21:	83 c2 04             	add    $0x4,%edx
80101c24:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c28:	85 c0                	test   %eax,%eax
80101c2a:	74 2f                	je     80101c5b <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101c2c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c32:	83 c2 04             	add    $0x4,%edx
80101c35:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101c39:	8b 45 08             	mov    0x8(%ebp),%eax
80101c3c:	8b 00                	mov    (%eax),%eax
80101c3e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c42:	89 04 24             	mov    %eax,(%esp)
80101c45:	e8 90 f8 ff ff       	call   801014da <bfree>
      ip->addrs[i] = 0;
80101c4a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c50:	83 c2 04             	add    $0x4,%edx
80101c53:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101c5a:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101c5b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101c5f:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101c63:	7e b6                	jle    80101c1b <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101c65:	8b 45 08             	mov    0x8(%ebp),%eax
80101c68:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c6b:	85 c0                	test   %eax,%eax
80101c6d:	0f 84 8f 00 00 00    	je     80101d02 <itrunc+0xf6>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101c73:	8b 45 08             	mov    0x8(%ebp),%eax
80101c76:	8b 50 4c             	mov    0x4c(%eax),%edx
80101c79:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7c:	8b 00                	mov    (%eax),%eax
80101c7e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c82:	89 04 24             	mov    %eax,(%esp)
80101c85:	e8 1c e5 ff ff       	call   801001a6 <bread>
80101c8a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101c8d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c90:	83 c0 18             	add    $0x18,%eax
80101c93:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101c96:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101c9d:	eb 2f                	jmp    80101cce <itrunc+0xc2>
      if(a[j])
80101c9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ca2:	c1 e0 02             	shl    $0x2,%eax
80101ca5:	03 45 e8             	add    -0x18(%ebp),%eax
80101ca8:	8b 00                	mov    (%eax),%eax
80101caa:	85 c0                	test   %eax,%eax
80101cac:	74 1c                	je     80101cca <itrunc+0xbe>
        bfree(ip->dev, a[j]);
80101cae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cb1:	c1 e0 02             	shl    $0x2,%eax
80101cb4:	03 45 e8             	add    -0x18(%ebp),%eax
80101cb7:	8b 10                	mov    (%eax),%edx
80101cb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101cbc:	8b 00                	mov    (%eax),%eax
80101cbe:	89 54 24 04          	mov    %edx,0x4(%esp)
80101cc2:	89 04 24             	mov    %eax,(%esp)
80101cc5:	e8 10 f8 ff ff       	call   801014da <bfree>
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101cca:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101cce:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cd1:	83 f8 7f             	cmp    $0x7f,%eax
80101cd4:	76 c9                	jbe    80101c9f <itrunc+0x93>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101cd6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cd9:	89 04 24             	mov    %eax,(%esp)
80101cdc:	e8 36 e5 ff ff       	call   80100217 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101ce1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce4:	8b 50 4c             	mov    0x4c(%eax),%edx
80101ce7:	8b 45 08             	mov    0x8(%ebp),%eax
80101cea:	8b 00                	mov    (%eax),%eax
80101cec:	89 54 24 04          	mov    %edx,0x4(%esp)
80101cf0:	89 04 24             	mov    %eax,(%esp)
80101cf3:	e8 e2 f7 ff ff       	call   801014da <bfree>
    ip->addrs[NDIRECT] = 0;
80101cf8:	8b 45 08             	mov    0x8(%ebp),%eax
80101cfb:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101d02:	8b 45 08             	mov    0x8(%ebp),%eax
80101d05:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101d0c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0f:	89 04 24             	mov    %eax,(%esp)
80101d12:	e8 95 f9 ff ff       	call   801016ac <iupdate>
}
80101d17:	c9                   	leave  
80101d18:	c3                   	ret    

80101d19 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101d19:	55                   	push   %ebp
80101d1a:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101d1c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d1f:	8b 00                	mov    (%eax),%eax
80101d21:	89 c2                	mov    %eax,%edx
80101d23:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d26:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101d29:	8b 45 08             	mov    0x8(%ebp),%eax
80101d2c:	8b 50 04             	mov    0x4(%eax),%edx
80101d2f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d32:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101d35:	8b 45 08             	mov    0x8(%ebp),%eax
80101d38:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101d3c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d3f:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101d42:	8b 45 08             	mov    0x8(%ebp),%eax
80101d45:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101d49:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d4c:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101d50:	8b 45 08             	mov    0x8(%ebp),%eax
80101d53:	8b 50 18             	mov    0x18(%eax),%edx
80101d56:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d59:	89 50 10             	mov    %edx,0x10(%eax)
}
80101d5c:	5d                   	pop    %ebp
80101d5d:	c3                   	ret    

80101d5e <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101d5e:	55                   	push   %ebp
80101d5f:	89 e5                	mov    %esp,%ebp
80101d61:	53                   	push   %ebx
80101d62:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101d65:	8b 45 08             	mov    0x8(%ebp),%eax
80101d68:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101d6c:	66 83 f8 03          	cmp    $0x3,%ax
80101d70:	75 60                	jne    80101dd2 <readi+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101d72:	8b 45 08             	mov    0x8(%ebp),%eax
80101d75:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101d79:	66 85 c0             	test   %ax,%ax
80101d7c:	78 20                	js     80101d9e <readi+0x40>
80101d7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101d81:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101d85:	66 83 f8 09          	cmp    $0x9,%ax
80101d89:	7f 13                	jg     80101d9e <readi+0x40>
80101d8b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d8e:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101d92:	98                   	cwtl   
80101d93:	8b 04 c5 00 e8 10 80 	mov    -0x7fef1800(,%eax,8),%eax
80101d9a:	85 c0                	test   %eax,%eax
80101d9c:	75 0a                	jne    80101da8 <readi+0x4a>
      return -1;
80101d9e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101da3:	e9 1b 01 00 00       	jmp    80101ec3 <readi+0x165>
    return devsw[ip->major].read(ip, dst, n);
80101da8:	8b 45 08             	mov    0x8(%ebp),%eax
80101dab:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101daf:	98                   	cwtl   
80101db0:	8b 14 c5 00 e8 10 80 	mov    -0x7fef1800(,%eax,8),%edx
80101db7:	8b 45 14             	mov    0x14(%ebp),%eax
80101dba:	89 44 24 08          	mov    %eax,0x8(%esp)
80101dbe:	8b 45 0c             	mov    0xc(%ebp),%eax
80101dc1:	89 44 24 04          	mov    %eax,0x4(%esp)
80101dc5:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc8:	89 04 24             	mov    %eax,(%esp)
80101dcb:	ff d2                	call   *%edx
80101dcd:	e9 f1 00 00 00       	jmp    80101ec3 <readi+0x165>
  }

  if(off > ip->size || off + n < off)
80101dd2:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd5:	8b 40 18             	mov    0x18(%eax),%eax
80101dd8:	3b 45 10             	cmp    0x10(%ebp),%eax
80101ddb:	72 0d                	jb     80101dea <readi+0x8c>
80101ddd:	8b 45 14             	mov    0x14(%ebp),%eax
80101de0:	8b 55 10             	mov    0x10(%ebp),%edx
80101de3:	01 d0                	add    %edx,%eax
80101de5:	3b 45 10             	cmp    0x10(%ebp),%eax
80101de8:	73 0a                	jae    80101df4 <readi+0x96>
    return -1;
80101dea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101def:	e9 cf 00 00 00       	jmp    80101ec3 <readi+0x165>
  if(off + n > ip->size)
80101df4:	8b 45 14             	mov    0x14(%ebp),%eax
80101df7:	8b 55 10             	mov    0x10(%ebp),%edx
80101dfa:	01 c2                	add    %eax,%edx
80101dfc:	8b 45 08             	mov    0x8(%ebp),%eax
80101dff:	8b 40 18             	mov    0x18(%eax),%eax
80101e02:	39 c2                	cmp    %eax,%edx
80101e04:	76 0c                	jbe    80101e12 <readi+0xb4>
    n = ip->size - off;
80101e06:	8b 45 08             	mov    0x8(%ebp),%eax
80101e09:	8b 40 18             	mov    0x18(%eax),%eax
80101e0c:	2b 45 10             	sub    0x10(%ebp),%eax
80101e0f:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101e12:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e19:	e9 96 00 00 00       	jmp    80101eb4 <readi+0x156>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101e1e:	8b 45 10             	mov    0x10(%ebp),%eax
80101e21:	c1 e8 09             	shr    $0x9,%eax
80101e24:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e28:	8b 45 08             	mov    0x8(%ebp),%eax
80101e2b:	89 04 24             	mov    %eax,(%esp)
80101e2e:	e8 d7 fc ff ff       	call   80101b0a <bmap>
80101e33:	8b 55 08             	mov    0x8(%ebp),%edx
80101e36:	8b 12                	mov    (%edx),%edx
80101e38:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e3c:	89 14 24             	mov    %edx,(%esp)
80101e3f:	e8 62 e3 ff ff       	call   801001a6 <bread>
80101e44:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101e47:	8b 45 10             	mov    0x10(%ebp),%eax
80101e4a:	89 c2                	mov    %eax,%edx
80101e4c:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80101e52:	b8 00 02 00 00       	mov    $0x200,%eax
80101e57:	89 c1                	mov    %eax,%ecx
80101e59:	29 d1                	sub    %edx,%ecx
80101e5b:	89 ca                	mov    %ecx,%edx
80101e5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e60:	8b 4d 14             	mov    0x14(%ebp),%ecx
80101e63:	89 cb                	mov    %ecx,%ebx
80101e65:	29 c3                	sub    %eax,%ebx
80101e67:	89 d8                	mov    %ebx,%eax
80101e69:	39 c2                	cmp    %eax,%edx
80101e6b:	0f 46 c2             	cmovbe %edx,%eax
80101e6e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101e71:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e74:	8d 50 18             	lea    0x18(%eax),%edx
80101e77:	8b 45 10             	mov    0x10(%ebp),%eax
80101e7a:	25 ff 01 00 00       	and    $0x1ff,%eax
80101e7f:	01 c2                	add    %eax,%edx
80101e81:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e84:	89 44 24 08          	mov    %eax,0x8(%esp)
80101e88:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e8c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e8f:	89 04 24             	mov    %eax,(%esp)
80101e92:	e8 f6 31 00 00       	call   8010508d <memmove>
    brelse(bp);
80101e97:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e9a:	89 04 24             	mov    %eax,(%esp)
80101e9d:	e8 75 e3 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101ea2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ea5:	01 45 f4             	add    %eax,-0xc(%ebp)
80101ea8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101eab:	01 45 10             	add    %eax,0x10(%ebp)
80101eae:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101eb1:	01 45 0c             	add    %eax,0xc(%ebp)
80101eb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101eb7:	3b 45 14             	cmp    0x14(%ebp),%eax
80101eba:	0f 82 5e ff ff ff    	jb     80101e1e <readi+0xc0>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80101ec0:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101ec3:	83 c4 24             	add    $0x24,%esp
80101ec6:	5b                   	pop    %ebx
80101ec7:	5d                   	pop    %ebp
80101ec8:	c3                   	ret    

80101ec9 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101ec9:	55                   	push   %ebp
80101eca:	89 e5                	mov    %esp,%ebp
80101ecc:	53                   	push   %ebx
80101ecd:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ed0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed3:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101ed7:	66 83 f8 03          	cmp    $0x3,%ax
80101edb:	75 60                	jne    80101f3d <writei+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101edd:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee0:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ee4:	66 85 c0             	test   %ax,%ax
80101ee7:	78 20                	js     80101f09 <writei+0x40>
80101ee9:	8b 45 08             	mov    0x8(%ebp),%eax
80101eec:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ef0:	66 83 f8 09          	cmp    $0x9,%ax
80101ef4:	7f 13                	jg     80101f09 <writei+0x40>
80101ef6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef9:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101efd:	98                   	cwtl   
80101efe:	8b 04 c5 04 e8 10 80 	mov    -0x7fef17fc(,%eax,8),%eax
80101f05:	85 c0                	test   %eax,%eax
80101f07:	75 0a                	jne    80101f13 <writei+0x4a>
      return -1;
80101f09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f0e:	e9 46 01 00 00       	jmp    80102059 <writei+0x190>
    return devsw[ip->major].write(ip, src, n);
80101f13:	8b 45 08             	mov    0x8(%ebp),%eax
80101f16:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f1a:	98                   	cwtl   
80101f1b:	8b 14 c5 04 e8 10 80 	mov    -0x7fef17fc(,%eax,8),%edx
80101f22:	8b 45 14             	mov    0x14(%ebp),%eax
80101f25:	89 44 24 08          	mov    %eax,0x8(%esp)
80101f29:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f2c:	89 44 24 04          	mov    %eax,0x4(%esp)
80101f30:	8b 45 08             	mov    0x8(%ebp),%eax
80101f33:	89 04 24             	mov    %eax,(%esp)
80101f36:	ff d2                	call   *%edx
80101f38:	e9 1c 01 00 00       	jmp    80102059 <writei+0x190>
  }

  if(off > ip->size || off + n < off)
80101f3d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f40:	8b 40 18             	mov    0x18(%eax),%eax
80101f43:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f46:	72 0d                	jb     80101f55 <writei+0x8c>
80101f48:	8b 45 14             	mov    0x14(%ebp),%eax
80101f4b:	8b 55 10             	mov    0x10(%ebp),%edx
80101f4e:	01 d0                	add    %edx,%eax
80101f50:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f53:	73 0a                	jae    80101f5f <writei+0x96>
    return -1;
80101f55:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f5a:	e9 fa 00 00 00       	jmp    80102059 <writei+0x190>
  if(off + n > MAXFILE*BSIZE)
80101f5f:	8b 45 14             	mov    0x14(%ebp),%eax
80101f62:	8b 55 10             	mov    0x10(%ebp),%edx
80101f65:	01 d0                	add    %edx,%eax
80101f67:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101f6c:	76 0a                	jbe    80101f78 <writei+0xaf>
    return -1;
80101f6e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f73:	e9 e1 00 00 00       	jmp    80102059 <writei+0x190>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101f78:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f7f:	e9 a1 00 00 00       	jmp    80102025 <writei+0x15c>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f84:	8b 45 10             	mov    0x10(%ebp),%eax
80101f87:	c1 e8 09             	shr    $0x9,%eax
80101f8a:	89 44 24 04          	mov    %eax,0x4(%esp)
80101f8e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f91:	89 04 24             	mov    %eax,(%esp)
80101f94:	e8 71 fb ff ff       	call   80101b0a <bmap>
80101f99:	8b 55 08             	mov    0x8(%ebp),%edx
80101f9c:	8b 12                	mov    (%edx),%edx
80101f9e:	89 44 24 04          	mov    %eax,0x4(%esp)
80101fa2:	89 14 24             	mov    %edx,(%esp)
80101fa5:	e8 fc e1 ff ff       	call   801001a6 <bread>
80101faa:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fad:	8b 45 10             	mov    0x10(%ebp),%eax
80101fb0:	89 c2                	mov    %eax,%edx
80101fb2:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80101fb8:	b8 00 02 00 00       	mov    $0x200,%eax
80101fbd:	89 c1                	mov    %eax,%ecx
80101fbf:	29 d1                	sub    %edx,%ecx
80101fc1:	89 ca                	mov    %ecx,%edx
80101fc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101fc6:	8b 4d 14             	mov    0x14(%ebp),%ecx
80101fc9:	89 cb                	mov    %ecx,%ebx
80101fcb:	29 c3                	sub    %eax,%ebx
80101fcd:	89 d8                	mov    %ebx,%eax
80101fcf:	39 c2                	cmp    %eax,%edx
80101fd1:	0f 46 c2             	cmovbe %edx,%eax
80101fd4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80101fd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fda:	8d 50 18             	lea    0x18(%eax),%edx
80101fdd:	8b 45 10             	mov    0x10(%ebp),%eax
80101fe0:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fe5:	01 c2                	add    %eax,%edx
80101fe7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fea:	89 44 24 08          	mov    %eax,0x8(%esp)
80101fee:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ff1:	89 44 24 04          	mov    %eax,0x4(%esp)
80101ff5:	89 14 24             	mov    %edx,(%esp)
80101ff8:	e8 90 30 00 00       	call   8010508d <memmove>
    log_write(bp);
80101ffd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102000:	89 04 24             	mov    %eax,(%esp)
80102003:	e8 b6 12 00 00       	call   801032be <log_write>
    brelse(bp);
80102008:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010200b:	89 04 24             	mov    %eax,(%esp)
8010200e:	e8 04 e2 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102013:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102016:	01 45 f4             	add    %eax,-0xc(%ebp)
80102019:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010201c:	01 45 10             	add    %eax,0x10(%ebp)
8010201f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102022:	01 45 0c             	add    %eax,0xc(%ebp)
80102025:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102028:	3b 45 14             	cmp    0x14(%ebp),%eax
8010202b:	0f 82 53 ff ff ff    	jb     80101f84 <writei+0xbb>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80102031:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102035:	74 1f                	je     80102056 <writei+0x18d>
80102037:	8b 45 08             	mov    0x8(%ebp),%eax
8010203a:	8b 40 18             	mov    0x18(%eax),%eax
8010203d:	3b 45 10             	cmp    0x10(%ebp),%eax
80102040:	73 14                	jae    80102056 <writei+0x18d>
    ip->size = off;
80102042:	8b 45 08             	mov    0x8(%ebp),%eax
80102045:	8b 55 10             	mov    0x10(%ebp),%edx
80102048:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
8010204b:	8b 45 08             	mov    0x8(%ebp),%eax
8010204e:	89 04 24             	mov    %eax,(%esp)
80102051:	e8 56 f6 ff ff       	call   801016ac <iupdate>
  }
  return n;
80102056:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102059:	83 c4 24             	add    $0x24,%esp
8010205c:	5b                   	pop    %ebx
8010205d:	5d                   	pop    %ebp
8010205e:	c3                   	ret    

8010205f <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
8010205f:	55                   	push   %ebp
80102060:	89 e5                	mov    %esp,%ebp
80102062:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
80102065:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
8010206c:	00 
8010206d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102070:	89 44 24 04          	mov    %eax,0x4(%esp)
80102074:	8b 45 08             	mov    0x8(%ebp),%eax
80102077:	89 04 24             	mov    %eax,(%esp)
8010207a:	e8 b6 30 00 00       	call   80105135 <strncmp>
}
8010207f:	c9                   	leave  
80102080:	c3                   	ret    

80102081 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80102081:	55                   	push   %ebp
80102082:	89 e5                	mov    %esp,%ebp
80102084:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102087:	8b 45 08             	mov    0x8(%ebp),%eax
8010208a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010208e:	66 83 f8 01          	cmp    $0x1,%ax
80102092:	74 0c                	je     801020a0 <dirlookup+0x1f>
    panic("dirlookup not DIR");
80102094:	c7 04 24 c5 84 10 80 	movl   $0x801084c5,(%esp)
8010209b:	e8 9d e4 ff ff       	call   8010053d <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801020a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020a7:	e9 87 00 00 00       	jmp    80102133 <dirlookup+0xb2>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801020ac:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801020b3:	00 
801020b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020b7:	89 44 24 08          	mov    %eax,0x8(%esp)
801020bb:	8d 45 e0             	lea    -0x20(%ebp),%eax
801020be:	89 44 24 04          	mov    %eax,0x4(%esp)
801020c2:	8b 45 08             	mov    0x8(%ebp),%eax
801020c5:	89 04 24             	mov    %eax,(%esp)
801020c8:	e8 91 fc ff ff       	call   80101d5e <readi>
801020cd:	83 f8 10             	cmp    $0x10,%eax
801020d0:	74 0c                	je     801020de <dirlookup+0x5d>
      panic("dirlink read");
801020d2:	c7 04 24 d7 84 10 80 	movl   $0x801084d7,(%esp)
801020d9:	e8 5f e4 ff ff       	call   8010053d <panic>
    if(de.inum == 0)
801020de:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801020e2:	66 85 c0             	test   %ax,%ax
801020e5:	74 47                	je     8010212e <dirlookup+0xad>
      continue;
    if(namecmp(name, de.name) == 0){
801020e7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801020ea:	83 c0 02             	add    $0x2,%eax
801020ed:	89 44 24 04          	mov    %eax,0x4(%esp)
801020f1:	8b 45 0c             	mov    0xc(%ebp),%eax
801020f4:	89 04 24             	mov    %eax,(%esp)
801020f7:	e8 63 ff ff ff       	call   8010205f <namecmp>
801020fc:	85 c0                	test   %eax,%eax
801020fe:	75 2f                	jne    8010212f <dirlookup+0xae>
      // entry matches path element
      if(poff)
80102100:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102104:	74 08                	je     8010210e <dirlookup+0x8d>
        *poff = off;
80102106:	8b 45 10             	mov    0x10(%ebp),%eax
80102109:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010210c:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010210e:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102112:	0f b7 c0             	movzwl %ax,%eax
80102115:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102118:	8b 45 08             	mov    0x8(%ebp),%eax
8010211b:	8b 00                	mov    (%eax),%eax
8010211d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102120:	89 54 24 04          	mov    %edx,0x4(%esp)
80102124:	89 04 24             	mov    %eax,(%esp)
80102127:	e8 38 f6 ff ff       	call   80101764 <iget>
8010212c:	eb 19                	jmp    80102147 <dirlookup+0xc6>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
8010212e:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
8010212f:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102133:	8b 45 08             	mov    0x8(%ebp),%eax
80102136:	8b 40 18             	mov    0x18(%eax),%eax
80102139:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010213c:	0f 87 6a ff ff ff    	ja     801020ac <dirlookup+0x2b>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80102142:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102147:	c9                   	leave  
80102148:	c3                   	ret    

80102149 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102149:	55                   	push   %ebp
8010214a:	89 e5                	mov    %esp,%ebp
8010214c:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010214f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80102156:	00 
80102157:	8b 45 0c             	mov    0xc(%ebp),%eax
8010215a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010215e:	8b 45 08             	mov    0x8(%ebp),%eax
80102161:	89 04 24             	mov    %eax,(%esp)
80102164:	e8 18 ff ff ff       	call   80102081 <dirlookup>
80102169:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010216c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102170:	74 15                	je     80102187 <dirlink+0x3e>
    iput(ip);
80102172:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102175:	89 04 24             	mov    %eax,(%esp)
80102178:	e8 9e f8 ff ff       	call   80101a1b <iput>
    return -1;
8010217d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102182:	e9 b8 00 00 00       	jmp    8010223f <dirlink+0xf6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102187:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010218e:	eb 44                	jmp    801021d4 <dirlink+0x8b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102193:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010219a:	00 
8010219b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010219f:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021a2:	89 44 24 04          	mov    %eax,0x4(%esp)
801021a6:	8b 45 08             	mov    0x8(%ebp),%eax
801021a9:	89 04 24             	mov    %eax,(%esp)
801021ac:	e8 ad fb ff ff       	call   80101d5e <readi>
801021b1:	83 f8 10             	cmp    $0x10,%eax
801021b4:	74 0c                	je     801021c2 <dirlink+0x79>
      panic("dirlink read");
801021b6:	c7 04 24 d7 84 10 80 	movl   $0x801084d7,(%esp)
801021bd:	e8 7b e3 ff ff       	call   8010053d <panic>
    if(de.inum == 0)
801021c2:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801021c6:	66 85 c0             	test   %ax,%ax
801021c9:	74 18                	je     801021e3 <dirlink+0x9a>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801021cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021ce:	83 c0 10             	add    $0x10,%eax
801021d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801021d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801021d7:	8b 45 08             	mov    0x8(%ebp),%eax
801021da:	8b 40 18             	mov    0x18(%eax),%eax
801021dd:	39 c2                	cmp    %eax,%edx
801021df:	72 af                	jb     80102190 <dirlink+0x47>
801021e1:	eb 01                	jmp    801021e4 <dirlink+0x9b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
801021e3:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801021e4:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801021eb:	00 
801021ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801021ef:	89 44 24 04          	mov    %eax,0x4(%esp)
801021f3:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021f6:	83 c0 02             	add    $0x2,%eax
801021f9:	89 04 24             	mov    %eax,(%esp)
801021fc:	e8 8c 2f 00 00       	call   8010518d <strncpy>
  de.inum = inum;
80102201:	8b 45 10             	mov    0x10(%ebp),%eax
80102204:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102208:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010220b:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102212:	00 
80102213:	89 44 24 08          	mov    %eax,0x8(%esp)
80102217:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010221a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010221e:	8b 45 08             	mov    0x8(%ebp),%eax
80102221:	89 04 24             	mov    %eax,(%esp)
80102224:	e8 a0 fc ff ff       	call   80101ec9 <writei>
80102229:	83 f8 10             	cmp    $0x10,%eax
8010222c:	74 0c                	je     8010223a <dirlink+0xf1>
    panic("dirlink");
8010222e:	c7 04 24 e4 84 10 80 	movl   $0x801084e4,(%esp)
80102235:	e8 03 e3 ff ff       	call   8010053d <panic>
  
  return 0;
8010223a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010223f:	c9                   	leave  
80102240:	c3                   	ret    

80102241 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102241:	55                   	push   %ebp
80102242:	89 e5                	mov    %esp,%ebp
80102244:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
80102247:	eb 04                	jmp    8010224d <skipelem+0xc>
    path++;
80102249:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
8010224d:	8b 45 08             	mov    0x8(%ebp),%eax
80102250:	0f b6 00             	movzbl (%eax),%eax
80102253:	3c 2f                	cmp    $0x2f,%al
80102255:	74 f2                	je     80102249 <skipelem+0x8>
    path++;
  if(*path == 0)
80102257:	8b 45 08             	mov    0x8(%ebp),%eax
8010225a:	0f b6 00             	movzbl (%eax),%eax
8010225d:	84 c0                	test   %al,%al
8010225f:	75 0a                	jne    8010226b <skipelem+0x2a>
    return 0;
80102261:	b8 00 00 00 00       	mov    $0x0,%eax
80102266:	e9 86 00 00 00       	jmp    801022f1 <skipelem+0xb0>
  s = path;
8010226b:	8b 45 08             	mov    0x8(%ebp),%eax
8010226e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102271:	eb 04                	jmp    80102277 <skipelem+0x36>
    path++;
80102273:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80102277:	8b 45 08             	mov    0x8(%ebp),%eax
8010227a:	0f b6 00             	movzbl (%eax),%eax
8010227d:	3c 2f                	cmp    $0x2f,%al
8010227f:	74 0a                	je     8010228b <skipelem+0x4a>
80102281:	8b 45 08             	mov    0x8(%ebp),%eax
80102284:	0f b6 00             	movzbl (%eax),%eax
80102287:	84 c0                	test   %al,%al
80102289:	75 e8                	jne    80102273 <skipelem+0x32>
    path++;
  len = path - s;
8010228b:	8b 55 08             	mov    0x8(%ebp),%edx
8010228e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102291:	89 d1                	mov    %edx,%ecx
80102293:	29 c1                	sub    %eax,%ecx
80102295:	89 c8                	mov    %ecx,%eax
80102297:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
8010229a:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
8010229e:	7e 1c                	jle    801022bc <skipelem+0x7b>
    memmove(name, s, DIRSIZ);
801022a0:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801022a7:	00 
801022a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022ab:	89 44 24 04          	mov    %eax,0x4(%esp)
801022af:	8b 45 0c             	mov    0xc(%ebp),%eax
801022b2:	89 04 24             	mov    %eax,(%esp)
801022b5:	e8 d3 2d 00 00       	call   8010508d <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801022ba:	eb 28                	jmp    801022e4 <skipelem+0xa3>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
801022bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022bf:	89 44 24 08          	mov    %eax,0x8(%esp)
801022c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022c6:	89 44 24 04          	mov    %eax,0x4(%esp)
801022ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801022cd:	89 04 24             	mov    %eax,(%esp)
801022d0:	e8 b8 2d 00 00       	call   8010508d <memmove>
    name[len] = 0;
801022d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022d8:	03 45 0c             	add    0xc(%ebp),%eax
801022db:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801022de:	eb 04                	jmp    801022e4 <skipelem+0xa3>
    path++;
801022e0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801022e4:	8b 45 08             	mov    0x8(%ebp),%eax
801022e7:	0f b6 00             	movzbl (%eax),%eax
801022ea:	3c 2f                	cmp    $0x2f,%al
801022ec:	74 f2                	je     801022e0 <skipelem+0x9f>
    path++;
  return path;
801022ee:	8b 45 08             	mov    0x8(%ebp),%eax
}
801022f1:	c9                   	leave  
801022f2:	c3                   	ret    

801022f3 <namex>:
// Look up and return the inode for a path name.
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801022f3:	55                   	push   %ebp
801022f4:	89 e5                	mov    %esp,%ebp
801022f6:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
801022f9:	8b 45 08             	mov    0x8(%ebp),%eax
801022fc:	0f b6 00             	movzbl (%eax),%eax
801022ff:	3c 2f                	cmp    $0x2f,%al
80102301:	75 1c                	jne    8010231f <namex+0x2c>
    ip = iget(ROOTDEV, ROOTINO);
80102303:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010230a:	00 
8010230b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102312:	e8 4d f4 ff ff       	call   80101764 <iget>
80102317:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
8010231a:	e9 af 00 00 00       	jmp    801023ce <namex+0xdb>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
8010231f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102325:	8b 40 68             	mov    0x68(%eax),%eax
80102328:	89 04 24             	mov    %eax,(%esp)
8010232b:	e8 06 f5 ff ff       	call   80101836 <idup>
80102330:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102333:	e9 96 00 00 00       	jmp    801023ce <namex+0xdb>
    ilock(ip);
80102338:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010233b:	89 04 24             	mov    %eax,(%esp)
8010233e:	e8 25 f5 ff ff       	call   80101868 <ilock>
    if(ip->type != T_DIR){
80102343:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102346:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010234a:	66 83 f8 01          	cmp    $0x1,%ax
8010234e:	74 15                	je     80102365 <namex+0x72>
      iunlockput(ip);
80102350:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102353:	89 04 24             	mov    %eax,(%esp)
80102356:	e8 91 f7 ff ff       	call   80101aec <iunlockput>
      return 0;
8010235b:	b8 00 00 00 00       	mov    $0x0,%eax
80102360:	e9 a3 00 00 00       	jmp    80102408 <namex+0x115>
    }
    if(nameiparent && *path == '\0'){
80102365:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102369:	74 1d                	je     80102388 <namex+0x95>
8010236b:	8b 45 08             	mov    0x8(%ebp),%eax
8010236e:	0f b6 00             	movzbl (%eax),%eax
80102371:	84 c0                	test   %al,%al
80102373:	75 13                	jne    80102388 <namex+0x95>
      // Stop one level early.
      iunlock(ip);
80102375:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102378:	89 04 24             	mov    %eax,(%esp)
8010237b:	e8 36 f6 ff ff       	call   801019b6 <iunlock>
      return ip;
80102380:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102383:	e9 80 00 00 00       	jmp    80102408 <namex+0x115>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102388:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010238f:	00 
80102390:	8b 45 10             	mov    0x10(%ebp),%eax
80102393:	89 44 24 04          	mov    %eax,0x4(%esp)
80102397:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010239a:	89 04 24             	mov    %eax,(%esp)
8010239d:	e8 df fc ff ff       	call   80102081 <dirlookup>
801023a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
801023a5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801023a9:	75 12                	jne    801023bd <namex+0xca>
      iunlockput(ip);
801023ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023ae:	89 04 24             	mov    %eax,(%esp)
801023b1:	e8 36 f7 ff ff       	call   80101aec <iunlockput>
      return 0;
801023b6:	b8 00 00 00 00       	mov    $0x0,%eax
801023bb:	eb 4b                	jmp    80102408 <namex+0x115>
    }
    iunlockput(ip);
801023bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023c0:	89 04 24             	mov    %eax,(%esp)
801023c3:	e8 24 f7 ff ff       	call   80101aec <iunlockput>
    ip = next;
801023c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
801023ce:	8b 45 10             	mov    0x10(%ebp),%eax
801023d1:	89 44 24 04          	mov    %eax,0x4(%esp)
801023d5:	8b 45 08             	mov    0x8(%ebp),%eax
801023d8:	89 04 24             	mov    %eax,(%esp)
801023db:	e8 61 fe ff ff       	call   80102241 <skipelem>
801023e0:	89 45 08             	mov    %eax,0x8(%ebp)
801023e3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801023e7:	0f 85 4b ff ff ff    	jne    80102338 <namex+0x45>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
801023ed:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801023f1:	74 12                	je     80102405 <namex+0x112>
    iput(ip);
801023f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023f6:	89 04 24             	mov    %eax,(%esp)
801023f9:	e8 1d f6 ff ff       	call   80101a1b <iput>
    return 0;
801023fe:	b8 00 00 00 00       	mov    $0x0,%eax
80102403:	eb 03                	jmp    80102408 <namex+0x115>
  }
  return ip;
80102405:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102408:	c9                   	leave  
80102409:	c3                   	ret    

8010240a <namei>:

struct inode*
namei(char *path)
{
8010240a:	55                   	push   %ebp
8010240b:	89 e5                	mov    %esp,%ebp
8010240d:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102410:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102413:	89 44 24 08          	mov    %eax,0x8(%esp)
80102417:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010241e:	00 
8010241f:	8b 45 08             	mov    0x8(%ebp),%eax
80102422:	89 04 24             	mov    %eax,(%esp)
80102425:	e8 c9 fe ff ff       	call   801022f3 <namex>
}
8010242a:	c9                   	leave  
8010242b:	c3                   	ret    

8010242c <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
8010242c:	55                   	push   %ebp
8010242d:	89 e5                	mov    %esp,%ebp
8010242f:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
80102432:	8b 45 0c             	mov    0xc(%ebp),%eax
80102435:	89 44 24 08          	mov    %eax,0x8(%esp)
80102439:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102440:	00 
80102441:	8b 45 08             	mov    0x8(%ebp),%eax
80102444:	89 04 24             	mov    %eax,(%esp)
80102447:	e8 a7 fe ff ff       	call   801022f3 <namex>
}
8010244c:	c9                   	leave  
8010244d:	c3                   	ret    
	...

80102450 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102450:	55                   	push   %ebp
80102451:	89 e5                	mov    %esp,%ebp
80102453:	53                   	push   %ebx
80102454:	83 ec 14             	sub    $0x14,%esp
80102457:	8b 45 08             	mov    0x8(%ebp),%eax
8010245a:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010245e:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80102462:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80102466:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
8010246a:	ec                   	in     (%dx),%al
8010246b:	89 c3                	mov    %eax,%ebx
8010246d:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80102470:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80102474:	83 c4 14             	add    $0x14,%esp
80102477:	5b                   	pop    %ebx
80102478:	5d                   	pop    %ebp
80102479:	c3                   	ret    

8010247a <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
8010247a:	55                   	push   %ebp
8010247b:	89 e5                	mov    %esp,%ebp
8010247d:	57                   	push   %edi
8010247e:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
8010247f:	8b 55 08             	mov    0x8(%ebp),%edx
80102482:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102485:	8b 45 10             	mov    0x10(%ebp),%eax
80102488:	89 cb                	mov    %ecx,%ebx
8010248a:	89 df                	mov    %ebx,%edi
8010248c:	89 c1                	mov    %eax,%ecx
8010248e:	fc                   	cld    
8010248f:	f3 6d                	rep insl (%dx),%es:(%edi)
80102491:	89 c8                	mov    %ecx,%eax
80102493:	89 fb                	mov    %edi,%ebx
80102495:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102498:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
8010249b:	5b                   	pop    %ebx
8010249c:	5f                   	pop    %edi
8010249d:	5d                   	pop    %ebp
8010249e:	c3                   	ret    

8010249f <outb>:

static inline void
outb(ushort port, uchar data)
{
8010249f:	55                   	push   %ebp
801024a0:	89 e5                	mov    %esp,%ebp
801024a2:	83 ec 08             	sub    $0x8,%esp
801024a5:	8b 55 08             	mov    0x8(%ebp),%edx
801024a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801024ab:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801024af:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801024b2:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801024b6:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801024ba:	ee                   	out    %al,(%dx)
}
801024bb:	c9                   	leave  
801024bc:	c3                   	ret    

801024bd <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
801024bd:	55                   	push   %ebp
801024be:	89 e5                	mov    %esp,%ebp
801024c0:	56                   	push   %esi
801024c1:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801024c2:	8b 55 08             	mov    0x8(%ebp),%edx
801024c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801024c8:	8b 45 10             	mov    0x10(%ebp),%eax
801024cb:	89 cb                	mov    %ecx,%ebx
801024cd:	89 de                	mov    %ebx,%esi
801024cf:	89 c1                	mov    %eax,%ecx
801024d1:	fc                   	cld    
801024d2:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801024d4:	89 c8                	mov    %ecx,%eax
801024d6:	89 f3                	mov    %esi,%ebx
801024d8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801024db:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
801024de:	5b                   	pop    %ebx
801024df:	5e                   	pop    %esi
801024e0:	5d                   	pop    %ebp
801024e1:	c3                   	ret    

801024e2 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801024e2:	55                   	push   %ebp
801024e3:	89 e5                	mov    %esp,%ebp
801024e5:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
801024e8:	90                   	nop
801024e9:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801024f0:	e8 5b ff ff ff       	call   80102450 <inb>
801024f5:	0f b6 c0             	movzbl %al,%eax
801024f8:	89 45 fc             	mov    %eax,-0x4(%ebp)
801024fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801024fe:	25 c0 00 00 00       	and    $0xc0,%eax
80102503:	83 f8 40             	cmp    $0x40,%eax
80102506:	75 e1                	jne    801024e9 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102508:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010250c:	74 11                	je     8010251f <idewait+0x3d>
8010250e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102511:	83 e0 21             	and    $0x21,%eax
80102514:	85 c0                	test   %eax,%eax
80102516:	74 07                	je     8010251f <idewait+0x3d>
    return -1;
80102518:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010251d:	eb 05                	jmp    80102524 <idewait+0x42>
  return 0;
8010251f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102524:	c9                   	leave  
80102525:	c3                   	ret    

80102526 <ideinit>:

void
ideinit(void)
{
80102526:	55                   	push   %ebp
80102527:	89 e5                	mov    %esp,%ebp
80102529:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
8010252c:	c7 44 24 04 ec 84 10 	movl   $0x801084ec,0x4(%esp)
80102533:	80 
80102534:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
8010253b:	e8 0a 28 00 00       	call   80104d4a <initlock>
  picenable(IRQ_IDE);
80102540:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102547:	e8 75 15 00 00       	call   80103ac1 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
8010254c:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
80102551:	83 e8 01             	sub    $0x1,%eax
80102554:	89 44 24 04          	mov    %eax,0x4(%esp)
80102558:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
8010255f:	e8 12 04 00 00       	call   80102976 <ioapicenable>
  idewait(0);
80102564:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010256b:	e8 72 ff ff ff       	call   801024e2 <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102570:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
80102577:	00 
80102578:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
8010257f:	e8 1b ff ff ff       	call   8010249f <outb>
  for(i=0; i<1000; i++){
80102584:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010258b:	eb 20                	jmp    801025ad <ideinit+0x87>
    if(inb(0x1f7) != 0){
8010258d:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102594:	e8 b7 fe ff ff       	call   80102450 <inb>
80102599:	84 c0                	test   %al,%al
8010259b:	74 0c                	je     801025a9 <ideinit+0x83>
      havedisk1 = 1;
8010259d:	c7 05 38 b6 10 80 01 	movl   $0x1,0x8010b638
801025a4:	00 00 00 
      break;
801025a7:	eb 0d                	jmp    801025b6 <ideinit+0x90>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
801025a9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801025ad:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801025b4:	7e d7                	jle    8010258d <ideinit+0x67>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801025b6:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
801025bd:	00 
801025be:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801025c5:	e8 d5 fe ff ff       	call   8010249f <outb>
}
801025ca:	c9                   	leave  
801025cb:	c3                   	ret    

801025cc <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801025cc:	55                   	push   %ebp
801025cd:	89 e5                	mov    %esp,%ebp
801025cf:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801025d2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025d6:	75 0c                	jne    801025e4 <idestart+0x18>
    panic("idestart");
801025d8:	c7 04 24 f0 84 10 80 	movl   $0x801084f0,(%esp)
801025df:	e8 59 df ff ff       	call   8010053d <panic>

  idewait(0);
801025e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801025eb:	e8 f2 fe ff ff       	call   801024e2 <idewait>
  outb(0x3f6, 0);  // generate interrupt
801025f0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801025f7:	00 
801025f8:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
801025ff:	e8 9b fe ff ff       	call   8010249f <outb>
  outb(0x1f2, 1);  // number of sectors
80102604:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010260b:	00 
8010260c:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
80102613:	e8 87 fe ff ff       	call   8010249f <outb>
  outb(0x1f3, b->sector & 0xff);
80102618:	8b 45 08             	mov    0x8(%ebp),%eax
8010261b:	8b 40 08             	mov    0x8(%eax),%eax
8010261e:	0f b6 c0             	movzbl %al,%eax
80102621:	89 44 24 04          	mov    %eax,0x4(%esp)
80102625:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
8010262c:	e8 6e fe ff ff       	call   8010249f <outb>
  outb(0x1f4, (b->sector >> 8) & 0xff);
80102631:	8b 45 08             	mov    0x8(%ebp),%eax
80102634:	8b 40 08             	mov    0x8(%eax),%eax
80102637:	c1 e8 08             	shr    $0x8,%eax
8010263a:	0f b6 c0             	movzbl %al,%eax
8010263d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102641:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
80102648:	e8 52 fe ff ff       	call   8010249f <outb>
  outb(0x1f5, (b->sector >> 16) & 0xff);
8010264d:	8b 45 08             	mov    0x8(%ebp),%eax
80102650:	8b 40 08             	mov    0x8(%eax),%eax
80102653:	c1 e8 10             	shr    $0x10,%eax
80102656:	0f b6 c0             	movzbl %al,%eax
80102659:	89 44 24 04          	mov    %eax,0x4(%esp)
8010265d:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
80102664:	e8 36 fe ff ff       	call   8010249f <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
80102669:	8b 45 08             	mov    0x8(%ebp),%eax
8010266c:	8b 40 04             	mov    0x4(%eax),%eax
8010266f:	83 e0 01             	and    $0x1,%eax
80102672:	89 c2                	mov    %eax,%edx
80102674:	c1 e2 04             	shl    $0x4,%edx
80102677:	8b 45 08             	mov    0x8(%ebp),%eax
8010267a:	8b 40 08             	mov    0x8(%eax),%eax
8010267d:	c1 e8 18             	shr    $0x18,%eax
80102680:	83 e0 0f             	and    $0xf,%eax
80102683:	09 d0                	or     %edx,%eax
80102685:	83 c8 e0             	or     $0xffffffe0,%eax
80102688:	0f b6 c0             	movzbl %al,%eax
8010268b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010268f:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102696:	e8 04 fe ff ff       	call   8010249f <outb>
  if(b->flags & B_DIRTY){
8010269b:	8b 45 08             	mov    0x8(%ebp),%eax
8010269e:	8b 00                	mov    (%eax),%eax
801026a0:	83 e0 04             	and    $0x4,%eax
801026a3:	85 c0                	test   %eax,%eax
801026a5:	74 34                	je     801026db <idestart+0x10f>
    outb(0x1f7, IDE_CMD_WRITE);
801026a7:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
801026ae:	00 
801026af:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801026b6:	e8 e4 fd ff ff       	call   8010249f <outb>
    outsl(0x1f0, b->data, 512/4);
801026bb:	8b 45 08             	mov    0x8(%ebp),%eax
801026be:	83 c0 18             	add    $0x18,%eax
801026c1:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801026c8:	00 
801026c9:	89 44 24 04          	mov    %eax,0x4(%esp)
801026cd:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
801026d4:	e8 e4 fd ff ff       	call   801024bd <outsl>
801026d9:	eb 14                	jmp    801026ef <idestart+0x123>
  } else {
    outb(0x1f7, IDE_CMD_READ);
801026db:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
801026e2:	00 
801026e3:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801026ea:	e8 b0 fd ff ff       	call   8010249f <outb>
  }
}
801026ef:	c9                   	leave  
801026f0:	c3                   	ret    

801026f1 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
801026f1:	55                   	push   %ebp
801026f2:	89 e5                	mov    %esp,%ebp
801026f4:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
801026f7:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
801026fe:	e8 68 26 00 00       	call   80104d6b <acquire>
  if((b = idequeue) == 0){
80102703:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102708:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010270b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010270f:	75 11                	jne    80102722 <ideintr+0x31>
    release(&idelock);
80102711:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102718:	e8 b0 26 00 00       	call   80104dcd <release>
    // cprintf("spurious IDE interrupt\n");
    return;
8010271d:	e9 90 00 00 00       	jmp    801027b2 <ideintr+0xc1>
  }
  idequeue = b->qnext;
80102722:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102725:	8b 40 14             	mov    0x14(%eax),%eax
80102728:	a3 34 b6 10 80       	mov    %eax,0x8010b634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
8010272d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102730:	8b 00                	mov    (%eax),%eax
80102732:	83 e0 04             	and    $0x4,%eax
80102735:	85 c0                	test   %eax,%eax
80102737:	75 2e                	jne    80102767 <ideintr+0x76>
80102739:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102740:	e8 9d fd ff ff       	call   801024e2 <idewait>
80102745:	85 c0                	test   %eax,%eax
80102747:	78 1e                	js     80102767 <ideintr+0x76>
    insl(0x1f0, b->data, 512/4);
80102749:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010274c:	83 c0 18             	add    $0x18,%eax
8010274f:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102756:	00 
80102757:	89 44 24 04          	mov    %eax,0x4(%esp)
8010275b:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102762:	e8 13 fd ff ff       	call   8010247a <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102767:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010276a:	8b 00                	mov    (%eax),%eax
8010276c:	89 c2                	mov    %eax,%edx
8010276e:	83 ca 02             	or     $0x2,%edx
80102771:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102774:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102776:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102779:	8b 00                	mov    (%eax),%eax
8010277b:	89 c2                	mov    %eax,%edx
8010277d:	83 e2 fb             	and    $0xfffffffb,%edx
80102780:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102783:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102785:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102788:	89 04 24             	mov    %eax,(%esp)
8010278b:	e8 ad 23 00 00       	call   80104b3d <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
80102790:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102795:	85 c0                	test   %eax,%eax
80102797:	74 0d                	je     801027a6 <ideintr+0xb5>
    idestart(idequeue);
80102799:	a1 34 b6 10 80       	mov    0x8010b634,%eax
8010279e:	89 04 24             	mov    %eax,(%esp)
801027a1:	e8 26 fe ff ff       	call   801025cc <idestart>

  release(&idelock);
801027a6:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
801027ad:	e8 1b 26 00 00       	call   80104dcd <release>
}
801027b2:	c9                   	leave  
801027b3:	c3                   	ret    

801027b4 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
801027b4:	55                   	push   %ebp
801027b5:	89 e5                	mov    %esp,%ebp
801027b7:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
801027ba:	8b 45 08             	mov    0x8(%ebp),%eax
801027bd:	8b 00                	mov    (%eax),%eax
801027bf:	83 e0 01             	and    $0x1,%eax
801027c2:	85 c0                	test   %eax,%eax
801027c4:	75 0c                	jne    801027d2 <iderw+0x1e>
    panic("iderw: buf not busy");
801027c6:	c7 04 24 f9 84 10 80 	movl   $0x801084f9,(%esp)
801027cd:	e8 6b dd ff ff       	call   8010053d <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801027d2:	8b 45 08             	mov    0x8(%ebp),%eax
801027d5:	8b 00                	mov    (%eax),%eax
801027d7:	83 e0 06             	and    $0x6,%eax
801027da:	83 f8 02             	cmp    $0x2,%eax
801027dd:	75 0c                	jne    801027eb <iderw+0x37>
    panic("iderw: nothing to do");
801027df:	c7 04 24 0d 85 10 80 	movl   $0x8010850d,(%esp)
801027e6:	e8 52 dd ff ff       	call   8010053d <panic>
  if(b->dev != 0 && !havedisk1)
801027eb:	8b 45 08             	mov    0x8(%ebp),%eax
801027ee:	8b 40 04             	mov    0x4(%eax),%eax
801027f1:	85 c0                	test   %eax,%eax
801027f3:	74 15                	je     8010280a <iderw+0x56>
801027f5:	a1 38 b6 10 80       	mov    0x8010b638,%eax
801027fa:	85 c0                	test   %eax,%eax
801027fc:	75 0c                	jne    8010280a <iderw+0x56>
    panic("iderw: ide disk 1 not present");
801027fe:	c7 04 24 22 85 10 80 	movl   $0x80108522,(%esp)
80102805:	e8 33 dd ff ff       	call   8010053d <panic>

  acquire(&idelock);  //DOC: acquire-lock
8010280a:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102811:	e8 55 25 00 00       	call   80104d6b <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102816:	8b 45 08             	mov    0x8(%ebp),%eax
80102819:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC: insert-queue
80102820:	c7 45 f4 34 b6 10 80 	movl   $0x8010b634,-0xc(%ebp)
80102827:	eb 0b                	jmp    80102834 <iderw+0x80>
80102829:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010282c:	8b 00                	mov    (%eax),%eax
8010282e:	83 c0 14             	add    $0x14,%eax
80102831:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102834:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102837:	8b 00                	mov    (%eax),%eax
80102839:	85 c0                	test   %eax,%eax
8010283b:	75 ec                	jne    80102829 <iderw+0x75>
    ;
  *pp = b;
8010283d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102840:	8b 55 08             	mov    0x8(%ebp),%edx
80102843:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102845:	a1 34 b6 10 80       	mov    0x8010b634,%eax
8010284a:	3b 45 08             	cmp    0x8(%ebp),%eax
8010284d:	75 22                	jne    80102871 <iderw+0xbd>
    idestart(b);
8010284f:	8b 45 08             	mov    0x8(%ebp),%eax
80102852:	89 04 24             	mov    %eax,(%esp)
80102855:	e8 72 fd ff ff       	call   801025cc <idestart>
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010285a:	eb 15                	jmp    80102871 <iderw+0xbd>
    sleep(b, &idelock);
8010285c:	c7 44 24 04 00 b6 10 	movl   $0x8010b600,0x4(%esp)
80102863:	80 
80102864:	8b 45 08             	mov    0x8(%ebp),%eax
80102867:	89 04 24             	mov    %eax,(%esp)
8010286a:	e8 e2 21 00 00       	call   80104a51 <sleep>
8010286f:	eb 01                	jmp    80102872 <iderw+0xbe>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102871:	90                   	nop
80102872:	8b 45 08             	mov    0x8(%ebp),%eax
80102875:	8b 00                	mov    (%eax),%eax
80102877:	83 e0 06             	and    $0x6,%eax
8010287a:	83 f8 02             	cmp    $0x2,%eax
8010287d:	75 dd                	jne    8010285c <iderw+0xa8>
    sleep(b, &idelock);
  }

  release(&idelock);
8010287f:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102886:	e8 42 25 00 00       	call   80104dcd <release>
}
8010288b:	c9                   	leave  
8010288c:	c3                   	ret    
8010288d:	00 00                	add    %al,(%eax)
	...

80102890 <ioapicread>:
80102890:	55                   	push   %ebp
80102891:	89 e5                	mov    %esp,%ebp
80102893:	a1 34 f8 10 80       	mov    0x8010f834,%eax
80102898:	8b 55 08             	mov    0x8(%ebp),%edx
8010289b:	89 10                	mov    %edx,(%eax)
8010289d:	a1 34 f8 10 80       	mov    0x8010f834,%eax
801028a2:	8b 40 10             	mov    0x10(%eax),%eax
801028a5:	5d                   	pop    %ebp
801028a6:	c3                   	ret    

801028a7 <ioapicwrite>:
801028a7:	55                   	push   %ebp
801028a8:	89 e5                	mov    %esp,%ebp
801028aa:	a1 34 f8 10 80       	mov    0x8010f834,%eax
801028af:	8b 55 08             	mov    0x8(%ebp),%edx
801028b2:	89 10                	mov    %edx,(%eax)
801028b4:	a1 34 f8 10 80       	mov    0x8010f834,%eax
801028b9:	8b 55 0c             	mov    0xc(%ebp),%edx
801028bc:	89 50 10             	mov    %edx,0x10(%eax)
801028bf:	5d                   	pop    %ebp
801028c0:	c3                   	ret    

801028c1 <ioapicinit>:
801028c1:	55                   	push   %ebp
801028c2:	89 e5                	mov    %esp,%ebp
801028c4:	83 ec 28             	sub    $0x28,%esp
801028c7:	a1 04 f9 10 80       	mov    0x8010f904,%eax
801028cc:	85 c0                	test   %eax,%eax
801028ce:	0f 84 9f 00 00 00    	je     80102973 <ioapicinit+0xb2>
801028d4:	c7 05 34 f8 10 80 00 	movl   $0xfec00000,0x8010f834
801028db:	00 c0 fe 
801028de:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801028e5:	e8 a6 ff ff ff       	call   80102890 <ioapicread>
801028ea:	c1 e8 10             	shr    $0x10,%eax
801028ed:	25 ff 00 00 00       	and    $0xff,%eax
801028f2:	89 45 f0             	mov    %eax,-0x10(%ebp)
801028f5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801028fc:	e8 8f ff ff ff       	call   80102890 <ioapicread>
80102901:	c1 e8 18             	shr    $0x18,%eax
80102904:	89 45 ec             	mov    %eax,-0x14(%ebp)
80102907:	0f b6 05 00 f9 10 80 	movzbl 0x8010f900,%eax
8010290e:	0f b6 c0             	movzbl %al,%eax
80102911:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102914:	74 0c                	je     80102922 <ioapicinit+0x61>
80102916:	c7 04 24 40 85 10 80 	movl   $0x80108540,(%esp)
8010291d:	e8 7f da ff ff       	call   801003a1 <cprintf>
80102922:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102929:	eb 3e                	jmp    80102969 <ioapicinit+0xa8>
8010292b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010292e:	83 c0 20             	add    $0x20,%eax
80102931:	0d 00 00 01 00       	or     $0x10000,%eax
80102936:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102939:	83 c2 08             	add    $0x8,%edx
8010293c:	01 d2                	add    %edx,%edx
8010293e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102942:	89 14 24             	mov    %edx,(%esp)
80102945:	e8 5d ff ff ff       	call   801028a7 <ioapicwrite>
8010294a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010294d:	83 c0 08             	add    $0x8,%eax
80102950:	01 c0                	add    %eax,%eax
80102952:	83 c0 01             	add    $0x1,%eax
80102955:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010295c:	00 
8010295d:	89 04 24             	mov    %eax,(%esp)
80102960:	e8 42 ff ff ff       	call   801028a7 <ioapicwrite>
80102965:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102969:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010296c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010296f:	7e ba                	jle    8010292b <ioapicinit+0x6a>
80102971:	eb 01                	jmp    80102974 <ioapicinit+0xb3>
80102973:	90                   	nop
80102974:	c9                   	leave  
80102975:	c3                   	ret    

80102976 <ioapicenable>:
80102976:	55                   	push   %ebp
80102977:	89 e5                	mov    %esp,%ebp
80102979:	83 ec 08             	sub    $0x8,%esp
8010297c:	a1 04 f9 10 80       	mov    0x8010f904,%eax
80102981:	85 c0                	test   %eax,%eax
80102983:	74 39                	je     801029be <ioapicenable+0x48>
80102985:	8b 45 08             	mov    0x8(%ebp),%eax
80102988:	83 c0 20             	add    $0x20,%eax
8010298b:	8b 55 08             	mov    0x8(%ebp),%edx
8010298e:	83 c2 08             	add    $0x8,%edx
80102991:	01 d2                	add    %edx,%edx
80102993:	89 44 24 04          	mov    %eax,0x4(%esp)
80102997:	89 14 24             	mov    %edx,(%esp)
8010299a:	e8 08 ff ff ff       	call   801028a7 <ioapicwrite>
8010299f:	8b 45 0c             	mov    0xc(%ebp),%eax
801029a2:	c1 e0 18             	shl    $0x18,%eax
801029a5:	8b 55 08             	mov    0x8(%ebp),%edx
801029a8:	83 c2 08             	add    $0x8,%edx
801029ab:	01 d2                	add    %edx,%edx
801029ad:	83 c2 01             	add    $0x1,%edx
801029b0:	89 44 24 04          	mov    %eax,0x4(%esp)
801029b4:	89 14 24             	mov    %edx,(%esp)
801029b7:	e8 eb fe ff ff       	call   801028a7 <ioapicwrite>
801029bc:	eb 01                	jmp    801029bf <ioapicenable+0x49>
801029be:	90                   	nop
801029bf:	c9                   	leave  
801029c0:	c3                   	ret    
801029c1:	00 00                	add    %al,(%eax)
	...

801029c4 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801029c4:	55                   	push   %ebp
801029c5:	89 e5                	mov    %esp,%ebp
801029c7:	8b 45 08             	mov    0x8(%ebp),%eax
801029ca:	05 00 00 00 80       	add    $0x80000000,%eax
801029cf:	5d                   	pop    %ebp
801029d0:	c3                   	ret    

801029d1 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
801029d1:	55                   	push   %ebp
801029d2:	89 e5                	mov    %esp,%ebp
801029d4:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
801029d7:	c7 44 24 04 72 85 10 	movl   $0x80108572,0x4(%esp)
801029de:	80 
801029df:	c7 04 24 40 f8 10 80 	movl   $0x8010f840,(%esp)
801029e6:	e8 5f 23 00 00       	call   80104d4a <initlock>
  kmem.use_lock = 0;
801029eb:	c7 05 74 f8 10 80 00 	movl   $0x0,0x8010f874
801029f2:	00 00 00 
  freerange(vstart, vend);
801029f5:	8b 45 0c             	mov    0xc(%ebp),%eax
801029f8:	89 44 24 04          	mov    %eax,0x4(%esp)
801029fc:	8b 45 08             	mov    0x8(%ebp),%eax
801029ff:	89 04 24             	mov    %eax,(%esp)
80102a02:	e8 26 00 00 00       	call   80102a2d <freerange>
}
80102a07:	c9                   	leave  
80102a08:	c3                   	ret    

80102a09 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102a09:	55                   	push   %ebp
80102a0a:	89 e5                	mov    %esp,%ebp
80102a0c:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102a0f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a12:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a16:	8b 45 08             	mov    0x8(%ebp),%eax
80102a19:	89 04 24             	mov    %eax,(%esp)
80102a1c:	e8 0c 00 00 00       	call   80102a2d <freerange>
  kmem.use_lock = 1;
80102a21:	c7 05 74 f8 10 80 01 	movl   $0x1,0x8010f874
80102a28:	00 00 00 
}
80102a2b:	c9                   	leave  
80102a2c:	c3                   	ret    

80102a2d <freerange>:

void
freerange(void *vstart, void *vend)
{
80102a2d:	55                   	push   %ebp
80102a2e:	89 e5                	mov    %esp,%ebp
80102a30:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102a33:	8b 45 08             	mov    0x8(%ebp),%eax
80102a36:	05 ff 0f 00 00       	add    $0xfff,%eax
80102a3b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102a40:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102a43:	eb 12                	jmp    80102a57 <freerange+0x2a>
    kfree(p);
80102a45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a48:	89 04 24             	mov    %eax,(%esp)
80102a4b:	e8 16 00 00 00       	call   80102a66 <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102a50:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102a57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a5a:	05 00 10 00 00       	add    $0x1000,%eax
80102a5f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102a62:	76 e1                	jbe    80102a45 <freerange+0x18>
    kfree(p);
}
80102a64:	c9                   	leave  
80102a65:	c3                   	ret    

80102a66 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102a66:	55                   	push   %ebp
80102a67:	89 e5                	mov    %esp,%ebp
80102a69:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102a6c:	8b 45 08             	mov    0x8(%ebp),%eax
80102a6f:	25 ff 0f 00 00       	and    $0xfff,%eax
80102a74:	85 c0                	test   %eax,%eax
80102a76:	75 1b                	jne    80102a93 <kfree+0x2d>
80102a78:	81 7d 08 1c 2a 11 80 	cmpl   $0x80112a1c,0x8(%ebp)
80102a7f:	72 12                	jb     80102a93 <kfree+0x2d>
80102a81:	8b 45 08             	mov    0x8(%ebp),%eax
80102a84:	89 04 24             	mov    %eax,(%esp)
80102a87:	e8 38 ff ff ff       	call   801029c4 <v2p>
80102a8c:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102a91:	76 0c                	jbe    80102a9f <kfree+0x39>
    panic("kfree");
80102a93:	c7 04 24 77 85 10 80 	movl   $0x80108577,(%esp)
80102a9a:	e8 9e da ff ff       	call   8010053d <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102a9f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102aa6:	00 
80102aa7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102aae:	00 
80102aaf:	8b 45 08             	mov    0x8(%ebp),%eax
80102ab2:	89 04 24             	mov    %eax,(%esp)
80102ab5:	e8 00 25 00 00       	call   80104fba <memset>

  if(kmem.use_lock)
80102aba:	a1 74 f8 10 80       	mov    0x8010f874,%eax
80102abf:	85 c0                	test   %eax,%eax
80102ac1:	74 0c                	je     80102acf <kfree+0x69>
    acquire(&kmem.lock);
80102ac3:	c7 04 24 40 f8 10 80 	movl   $0x8010f840,(%esp)
80102aca:	e8 9c 22 00 00       	call   80104d6b <acquire>
  r = (struct run*)v;
80102acf:	8b 45 08             	mov    0x8(%ebp),%eax
80102ad2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102ad5:	8b 15 78 f8 10 80    	mov    0x8010f878,%edx
80102adb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ade:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102ae0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ae3:	a3 78 f8 10 80       	mov    %eax,0x8010f878
  if(kmem.use_lock)
80102ae8:	a1 74 f8 10 80       	mov    0x8010f874,%eax
80102aed:	85 c0                	test   %eax,%eax
80102aef:	74 0c                	je     80102afd <kfree+0x97>
    release(&kmem.lock);
80102af1:	c7 04 24 40 f8 10 80 	movl   $0x8010f840,(%esp)
80102af8:	e8 d0 22 00 00       	call   80104dcd <release>
}
80102afd:	c9                   	leave  
80102afe:	c3                   	ret    

80102aff <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102aff:	55                   	push   %ebp
80102b00:	89 e5                	mov    %esp,%ebp
80102b02:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102b05:	a1 74 f8 10 80       	mov    0x8010f874,%eax
80102b0a:	85 c0                	test   %eax,%eax
80102b0c:	74 0c                	je     80102b1a <kalloc+0x1b>
    acquire(&kmem.lock);
80102b0e:	c7 04 24 40 f8 10 80 	movl   $0x8010f840,(%esp)
80102b15:	e8 51 22 00 00       	call   80104d6b <acquire>
  r = kmem.freelist;
80102b1a:	a1 78 f8 10 80       	mov    0x8010f878,%eax
80102b1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102b22:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102b26:	74 0a                	je     80102b32 <kalloc+0x33>
    kmem.freelist = r->next;
80102b28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b2b:	8b 00                	mov    (%eax),%eax
80102b2d:	a3 78 f8 10 80       	mov    %eax,0x8010f878
  if(kmem.use_lock)
80102b32:	a1 74 f8 10 80       	mov    0x8010f874,%eax
80102b37:	85 c0                	test   %eax,%eax
80102b39:	74 0c                	je     80102b47 <kalloc+0x48>
    release(&kmem.lock);
80102b3b:	c7 04 24 40 f8 10 80 	movl   $0x8010f840,(%esp)
80102b42:	e8 86 22 00 00       	call   80104dcd <release>
  return (char*)r;
80102b47:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102b4a:	c9                   	leave  
80102b4b:	c3                   	ret    

80102b4c <inb>:
80102b4c:	55                   	push   %ebp
80102b4d:	89 e5                	mov    %esp,%ebp
80102b4f:	53                   	push   %ebx
80102b50:	83 ec 18             	sub    $0x18,%esp
80102b53:	8b 45 08             	mov    0x8(%ebp),%eax
80102b56:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
80102b5a:	0f b7 45 e8          	movzwl -0x18(%ebp),%eax
80102b5e:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
80102b62:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
80102b66:	ec                   	in     (%dx),%al
80102b67:	89 c3                	mov    %eax,%ebx
80102b69:	88 5d fb             	mov    %bl,-0x5(%ebp)
80102b6c:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
80102b70:	83 c4 18             	add    $0x18,%esp
80102b73:	5b                   	pop    %ebx
80102b74:	5d                   	pop    %ebp
80102b75:	c3                   	ret    

80102b76 <kbdgetc>:
80102b76:	55                   	push   %ebp
80102b77:	89 e5                	mov    %esp,%ebp
80102b79:	83 ec 14             	sub    $0x14,%esp
80102b7c:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102b83:	e8 c4 ff ff ff       	call   80102b4c <inb>
80102b88:	0f b6 c0             	movzbl %al,%eax
80102b8b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102b8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b91:	83 e0 01             	and    $0x1,%eax
80102b94:	85 c0                	test   %eax,%eax
80102b96:	75 0a                	jne    80102ba2 <kbdgetc+0x2c>
80102b98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102b9d:	e9 23 01 00 00       	jmp    80102cc5 <kbdgetc+0x14f>
80102ba2:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102ba9:	e8 9e ff ff ff       	call   80102b4c <inb>
80102bae:	0f b6 c0             	movzbl %al,%eax
80102bb1:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102bb4:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102bbb:	75 17                	jne    80102bd4 <kbdgetc+0x5e>
80102bbd:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102bc2:	83 c8 40             	or     $0x40,%eax
80102bc5:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
80102bca:	b8 00 00 00 00       	mov    $0x0,%eax
80102bcf:	e9 f1 00 00 00       	jmp    80102cc5 <kbdgetc+0x14f>
80102bd4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102bd7:	25 80 00 00 00       	and    $0x80,%eax
80102bdc:	85 c0                	test   %eax,%eax
80102bde:	74 45                	je     80102c25 <kbdgetc+0xaf>
80102be0:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102be5:	83 e0 40             	and    $0x40,%eax
80102be8:	85 c0                	test   %eax,%eax
80102bea:	75 08                	jne    80102bf4 <kbdgetc+0x7e>
80102bec:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102bef:	83 e0 7f             	and    $0x7f,%eax
80102bf2:	eb 03                	jmp    80102bf7 <kbdgetc+0x81>
80102bf4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102bf7:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102bfa:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102bfd:	05 20 90 10 80       	add    $0x80109020,%eax
80102c02:	0f b6 00             	movzbl (%eax),%eax
80102c05:	83 c8 40             	or     $0x40,%eax
80102c08:	0f b6 c0             	movzbl %al,%eax
80102c0b:	f7 d0                	not    %eax
80102c0d:	89 c2                	mov    %eax,%edx
80102c0f:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c14:	21 d0                	and    %edx,%eax
80102c16:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
80102c1b:	b8 00 00 00 00       	mov    $0x0,%eax
80102c20:	e9 a0 00 00 00       	jmp    80102cc5 <kbdgetc+0x14f>
80102c25:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c2a:	83 e0 40             	and    $0x40,%eax
80102c2d:	85 c0                	test   %eax,%eax
80102c2f:	74 14                	je     80102c45 <kbdgetc+0xcf>
80102c31:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
80102c38:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c3d:	83 e0 bf             	and    $0xffffffbf,%eax
80102c40:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
80102c45:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c48:	05 20 90 10 80       	add    $0x80109020,%eax
80102c4d:	0f b6 00             	movzbl (%eax),%eax
80102c50:	0f b6 d0             	movzbl %al,%edx
80102c53:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c58:	09 d0                	or     %edx,%eax
80102c5a:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
80102c5f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c62:	05 20 91 10 80       	add    $0x80109120,%eax
80102c67:	0f b6 00             	movzbl (%eax),%eax
80102c6a:	0f b6 d0             	movzbl %al,%edx
80102c6d:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c72:	31 d0                	xor    %edx,%eax
80102c74:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
80102c79:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c7e:	83 e0 03             	and    $0x3,%eax
80102c81:	8b 04 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%eax
80102c88:	03 45 fc             	add    -0x4(%ebp),%eax
80102c8b:	0f b6 00             	movzbl (%eax),%eax
80102c8e:	0f b6 c0             	movzbl %al,%eax
80102c91:	89 45 f8             	mov    %eax,-0x8(%ebp)
80102c94:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c99:	83 e0 08             	and    $0x8,%eax
80102c9c:	85 c0                	test   %eax,%eax
80102c9e:	74 22                	je     80102cc2 <kbdgetc+0x14c>
80102ca0:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102ca4:	76 0c                	jbe    80102cb2 <kbdgetc+0x13c>
80102ca6:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102caa:	77 06                	ja     80102cb2 <kbdgetc+0x13c>
80102cac:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102cb0:	eb 10                	jmp    80102cc2 <kbdgetc+0x14c>
80102cb2:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102cb6:	76 0a                	jbe    80102cc2 <kbdgetc+0x14c>
80102cb8:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102cbc:	77 04                	ja     80102cc2 <kbdgetc+0x14c>
80102cbe:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
80102cc2:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102cc5:	c9                   	leave  
80102cc6:	c3                   	ret    

80102cc7 <kbdintr>:
80102cc7:	55                   	push   %ebp
80102cc8:	89 e5                	mov    %esp,%ebp
80102cca:	83 ec 18             	sub    $0x18,%esp
80102ccd:	c7 04 24 76 2b 10 80 	movl   $0x80102b76,(%esp)
80102cd4:	e8 d4 da ff ff       	call   801007ad <consoleintr>
80102cd9:	c9                   	leave  
80102cda:	c3                   	ret    
	...

80102cdc <outb>:
80102cdc:	55                   	push   %ebp
80102cdd:	89 e5                	mov    %esp,%ebp
80102cdf:	83 ec 08             	sub    $0x8,%esp
80102ce2:	8b 55 08             	mov    0x8(%ebp),%edx
80102ce5:	8b 45 0c             	mov    0xc(%ebp),%eax
80102ce8:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102cec:	88 45 f8             	mov    %al,-0x8(%ebp)
80102cef:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102cf3:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102cf7:	ee                   	out    %al,(%dx)
80102cf8:	c9                   	leave  
80102cf9:	c3                   	ret    

80102cfa <readeflags>:
80102cfa:	55                   	push   %ebp
80102cfb:	89 e5                	mov    %esp,%ebp
80102cfd:	53                   	push   %ebx
80102cfe:	83 ec 10             	sub    $0x10,%esp
80102d01:	9c                   	pushf  
80102d02:	5b                   	pop    %ebx
80102d03:	89 5d f8             	mov    %ebx,-0x8(%ebp)
80102d06:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102d09:	83 c4 10             	add    $0x10,%esp
80102d0c:	5b                   	pop    %ebx
80102d0d:	5d                   	pop    %ebp
80102d0e:	c3                   	ret    

80102d0f <lapicw>:
80102d0f:	55                   	push   %ebp
80102d10:	89 e5                	mov    %esp,%ebp
80102d12:	a1 7c f8 10 80       	mov    0x8010f87c,%eax
80102d17:	8b 55 08             	mov    0x8(%ebp),%edx
80102d1a:	c1 e2 02             	shl    $0x2,%edx
80102d1d:	8d 14 10             	lea    (%eax,%edx,1),%edx
80102d20:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d23:	89 02                	mov    %eax,(%edx)
80102d25:	a1 7c f8 10 80       	mov    0x8010f87c,%eax
80102d2a:	83 c0 20             	add    $0x20,%eax
80102d2d:	8b 00                	mov    (%eax),%eax
80102d2f:	5d                   	pop    %ebp
80102d30:	c3                   	ret    

80102d31 <lapicinit>:
80102d31:	55                   	push   %ebp
80102d32:	89 e5                	mov    %esp,%ebp
80102d34:	83 ec 08             	sub    $0x8,%esp
80102d37:	a1 7c f8 10 80       	mov    0x8010f87c,%eax
80102d3c:	85 c0                	test   %eax,%eax
80102d3e:	0f 84 47 01 00 00    	je     80102e8b <lapicinit+0x15a>
80102d44:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80102d4b:	00 
80102d4c:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80102d53:	e8 b7 ff ff ff       	call   80102d0f <lapicw>
80102d58:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80102d5f:	00 
80102d60:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80102d67:	e8 a3 ff ff ff       	call   80102d0f <lapicw>
80102d6c:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80102d73:	00 
80102d74:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102d7b:	e8 8f ff ff ff       	call   80102d0f <lapicw>
80102d80:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80102d87:	00 
80102d88:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
80102d8f:	e8 7b ff ff ff       	call   80102d0f <lapicw>
80102d94:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102d9b:	00 
80102d9c:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80102da3:	e8 67 ff ff ff       	call   80102d0f <lapicw>
80102da8:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102daf:	00 
80102db0:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80102db7:	e8 53 ff ff ff       	call   80102d0f <lapicw>
80102dbc:	a1 7c f8 10 80       	mov    0x8010f87c,%eax
80102dc1:	83 c0 30             	add    $0x30,%eax
80102dc4:	8b 00                	mov    (%eax),%eax
80102dc6:	c1 e8 10             	shr    $0x10,%eax
80102dc9:	25 ff 00 00 00       	and    $0xff,%eax
80102dce:	83 f8 03             	cmp    $0x3,%eax
80102dd1:	76 14                	jbe    80102de7 <lapicinit+0xb6>
80102dd3:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102dda:	00 
80102ddb:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80102de2:	e8 28 ff ff ff       	call   80102d0f <lapicw>
80102de7:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80102dee:	00 
80102def:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80102df6:	e8 14 ff ff ff       	call   80102d0f <lapicw>
80102dfb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e02:	00 
80102e03:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102e0a:	e8 00 ff ff ff       	call   80102d0f <lapicw>
80102e0f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e16:	00 
80102e17:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102e1e:	e8 ec fe ff ff       	call   80102d0f <lapicw>
80102e23:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e2a:	00 
80102e2b:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102e32:	e8 d8 fe ff ff       	call   80102d0f <lapicw>
80102e37:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e3e:	00 
80102e3f:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102e46:	e8 c4 fe ff ff       	call   80102d0f <lapicw>
80102e4b:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80102e52:	00 
80102e53:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102e5a:	e8 b0 fe ff ff       	call   80102d0f <lapicw>
80102e5f:	90                   	nop
80102e60:	a1 7c f8 10 80       	mov    0x8010f87c,%eax
80102e65:	05 00 03 00 00       	add    $0x300,%eax
80102e6a:	8b 00                	mov    (%eax),%eax
80102e6c:	25 00 10 00 00       	and    $0x1000,%eax
80102e71:	85 c0                	test   %eax,%eax
80102e73:	75 eb                	jne    80102e60 <lapicinit+0x12f>
80102e75:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e7c:	00 
80102e7d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80102e84:	e8 86 fe ff ff       	call   80102d0f <lapicw>
80102e89:	eb 01                	jmp    80102e8c <lapicinit+0x15b>
80102e8b:	90                   	nop
80102e8c:	c9                   	leave  
80102e8d:	c3                   	ret    

80102e8e <cpunum>:
80102e8e:	55                   	push   %ebp
80102e8f:	89 e5                	mov    %esp,%ebp
80102e91:	83 ec 18             	sub    $0x18,%esp
80102e94:	e8 61 fe ff ff       	call   80102cfa <readeflags>
80102e99:	25 00 02 00 00       	and    $0x200,%eax
80102e9e:	85 c0                	test   %eax,%eax
80102ea0:	74 29                	je     80102ecb <cpunum+0x3d>
80102ea2:	a1 40 b6 10 80       	mov    0x8010b640,%eax
80102ea7:	85 c0                	test   %eax,%eax
80102ea9:	0f 94 c2             	sete   %dl
80102eac:	83 c0 01             	add    $0x1,%eax
80102eaf:	a3 40 b6 10 80       	mov    %eax,0x8010b640
80102eb4:	84 d2                	test   %dl,%dl
80102eb6:	74 13                	je     80102ecb <cpunum+0x3d>
80102eb8:	8b 45 04             	mov    0x4(%ebp),%eax
80102ebb:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ebf:	c7 04 24 80 85 10 80 	movl   $0x80108580,(%esp)
80102ec6:	e8 d6 d4 ff ff       	call   801003a1 <cprintf>
80102ecb:	a1 7c f8 10 80       	mov    0x8010f87c,%eax
80102ed0:	85 c0                	test   %eax,%eax
80102ed2:	74 0f                	je     80102ee3 <cpunum+0x55>
80102ed4:	a1 7c f8 10 80       	mov    0x8010f87c,%eax
80102ed9:	83 c0 20             	add    $0x20,%eax
80102edc:	8b 00                	mov    (%eax),%eax
80102ede:	c1 e8 18             	shr    $0x18,%eax
80102ee1:	eb 05                	jmp    80102ee8 <cpunum+0x5a>
80102ee3:	b8 00 00 00 00       	mov    $0x0,%eax
80102ee8:	c9                   	leave  
80102ee9:	c3                   	ret    

80102eea <lapiceoi>:
80102eea:	55                   	push   %ebp
80102eeb:	89 e5                	mov    %esp,%ebp
80102eed:	83 ec 08             	sub    $0x8,%esp
80102ef0:	a1 7c f8 10 80       	mov    0x8010f87c,%eax
80102ef5:	85 c0                	test   %eax,%eax
80102ef7:	74 14                	je     80102f0d <lapiceoi+0x23>
80102ef9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102f00:	00 
80102f01:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102f08:	e8 02 fe ff ff       	call   80102d0f <lapicw>
80102f0d:	c9                   	leave  
80102f0e:	c3                   	ret    

80102f0f <microdelay>:
80102f0f:	55                   	push   %ebp
80102f10:	89 e5                	mov    %esp,%ebp
80102f12:	5d                   	pop    %ebp
80102f13:	c3                   	ret    

80102f14 <lapicstartap>:
80102f14:	55                   	push   %ebp
80102f15:	89 e5                	mov    %esp,%ebp
80102f17:	83 ec 1c             	sub    $0x1c,%esp
80102f1a:	8b 45 08             	mov    0x8(%ebp),%eax
80102f1d:	88 45 ec             	mov    %al,-0x14(%ebp)
80102f20:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80102f27:	00 
80102f28:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80102f2f:	e8 a8 fd ff ff       	call   80102cdc <outb>
80102f34:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80102f3b:	00 
80102f3c:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80102f43:	e8 94 fd ff ff       	call   80102cdc <outb>
80102f48:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
80102f4f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102f52:	66 c7 00 00 00       	movw   $0x0,(%eax)
80102f57:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102f5a:	8d 50 02             	lea    0x2(%eax),%edx
80102f5d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f60:	c1 e8 04             	shr    $0x4,%eax
80102f63:	66 89 02             	mov    %ax,(%edx)
80102f66:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102f6a:	c1 e0 18             	shl    $0x18,%eax
80102f6d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102f71:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102f78:	e8 92 fd ff ff       	call   80102d0f <lapicw>
80102f7d:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
80102f84:	00 
80102f85:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102f8c:	e8 7e fd ff ff       	call   80102d0f <lapicw>
80102f91:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102f98:	e8 72 ff ff ff       	call   80102f0f <microdelay>
80102f9d:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
80102fa4:	00 
80102fa5:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102fac:	e8 5e fd ff ff       	call   80102d0f <lapicw>
80102fb1:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102fb8:	e8 52 ff ff ff       	call   80102f0f <microdelay>
80102fbd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102fc4:	eb 40                	jmp    80103006 <lapicstartap+0xf2>
80102fc6:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102fca:	c1 e0 18             	shl    $0x18,%eax
80102fcd:	89 44 24 04          	mov    %eax,0x4(%esp)
80102fd1:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102fd8:	e8 32 fd ff ff       	call   80102d0f <lapicw>
80102fdd:	8b 45 0c             	mov    0xc(%ebp),%eax
80102fe0:	c1 e8 0c             	shr    $0xc,%eax
80102fe3:	80 cc 06             	or     $0x6,%ah
80102fe6:	89 44 24 04          	mov    %eax,0x4(%esp)
80102fea:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102ff1:	e8 19 fd ff ff       	call   80102d0f <lapicw>
80102ff6:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102ffd:	e8 0d ff ff ff       	call   80102f0f <microdelay>
80103002:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103006:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
8010300a:	7e ba                	jle    80102fc6 <lapicstartap+0xb2>
8010300c:	c9                   	leave  
8010300d:	c3                   	ret    
	...

80103010 <initlog>:

static void recover_from_log(void);

void
initlog(void)
{
80103010:	55                   	push   %ebp
80103011:	89 e5                	mov    %esp,%ebp
80103013:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103016:	c7 44 24 04 ac 85 10 	movl   $0x801085ac,0x4(%esp)
8010301d:	80 
8010301e:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
80103025:	e8 20 1d 00 00       	call   80104d4a <initlock>
  readsb(ROOTDEV, &sb);
8010302a:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010302d:	89 44 24 04          	mov    %eax,0x4(%esp)
80103031:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80103038:	e8 af e2 ff ff       	call   801012ec <readsb>
  log.start = sb.size - sb.nlog;
8010303d:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103040:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103043:	89 d1                	mov    %edx,%ecx
80103045:	29 c1                	sub    %eax,%ecx
80103047:	89 c8                	mov    %ecx,%eax
80103049:	a3 b4 f8 10 80       	mov    %eax,0x8010f8b4
  log.size = sb.nlog;
8010304e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103051:	a3 b8 f8 10 80       	mov    %eax,0x8010f8b8
  log.dev = ROOTDEV;
80103056:	c7 05 c0 f8 10 80 01 	movl   $0x1,0x8010f8c0
8010305d:	00 00 00 
  recover_from_log();
80103060:	e8 97 01 00 00       	call   801031fc <recover_from_log>
}
80103065:	c9                   	leave  
80103066:	c3                   	ret    

80103067 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
80103067:	55                   	push   %ebp
80103068:	89 e5                	mov    %esp,%ebp
8010306a:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010306d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103074:	e9 89 00 00 00       	jmp    80103102 <install_trans+0x9b>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103079:	a1 b4 f8 10 80       	mov    0x8010f8b4,%eax
8010307e:	03 45 f4             	add    -0xc(%ebp),%eax
80103081:	83 c0 01             	add    $0x1,%eax
80103084:	89 c2                	mov    %eax,%edx
80103086:	a1 c0 f8 10 80       	mov    0x8010f8c0,%eax
8010308b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010308f:	89 04 24             	mov    %eax,(%esp)
80103092:	e8 0f d1 ff ff       	call   801001a6 <bread>
80103097:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
8010309a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010309d:	83 c0 10             	add    $0x10,%eax
801030a0:	8b 04 85 88 f8 10 80 	mov    -0x7fef0778(,%eax,4),%eax
801030a7:	89 c2                	mov    %eax,%edx
801030a9:	a1 c0 f8 10 80       	mov    0x8010f8c0,%eax
801030ae:	89 54 24 04          	mov    %edx,0x4(%esp)
801030b2:	89 04 24             	mov    %eax,(%esp)
801030b5:	e8 ec d0 ff ff       	call   801001a6 <bread>
801030ba:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801030bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801030c0:	8d 50 18             	lea    0x18(%eax),%edx
801030c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801030c6:	83 c0 18             	add    $0x18,%eax
801030c9:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801030d0:	00 
801030d1:	89 54 24 04          	mov    %edx,0x4(%esp)
801030d5:	89 04 24             	mov    %eax,(%esp)
801030d8:	e8 b0 1f 00 00       	call   8010508d <memmove>
    bwrite(dbuf);  // write dst to disk
801030dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801030e0:	89 04 24             	mov    %eax,(%esp)
801030e3:	e8 f5 d0 ff ff       	call   801001dd <bwrite>
    brelse(lbuf); 
801030e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801030eb:	89 04 24             	mov    %eax,(%esp)
801030ee:	e8 24 d1 ff ff       	call   80100217 <brelse>
    brelse(dbuf);
801030f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801030f6:	89 04 24             	mov    %eax,(%esp)
801030f9:	e8 19 d1 ff ff       	call   80100217 <brelse>
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801030fe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103102:	a1 c4 f8 10 80       	mov    0x8010f8c4,%eax
80103107:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010310a:	0f 8f 69 ff ff ff    	jg     80103079 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103110:	c9                   	leave  
80103111:	c3                   	ret    

80103112 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103112:	55                   	push   %ebp
80103113:	89 e5                	mov    %esp,%ebp
80103115:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103118:	a1 b4 f8 10 80       	mov    0x8010f8b4,%eax
8010311d:	89 c2                	mov    %eax,%edx
8010311f:	a1 c0 f8 10 80       	mov    0x8010f8c0,%eax
80103124:	89 54 24 04          	mov    %edx,0x4(%esp)
80103128:	89 04 24             	mov    %eax,(%esp)
8010312b:	e8 76 d0 ff ff       	call   801001a6 <bread>
80103130:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103133:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103136:	83 c0 18             	add    $0x18,%eax
80103139:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
8010313c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010313f:	8b 00                	mov    (%eax),%eax
80103141:	a3 c4 f8 10 80       	mov    %eax,0x8010f8c4
  for (i = 0; i < log.lh.n; i++) {
80103146:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010314d:	eb 1b                	jmp    8010316a <read_head+0x58>
    log.lh.sector[i] = lh->sector[i];
8010314f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103152:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103155:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103159:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010315c:	83 c2 10             	add    $0x10,%edx
8010315f:	89 04 95 88 f8 10 80 	mov    %eax,-0x7fef0778(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103166:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010316a:	a1 c4 f8 10 80       	mov    0x8010f8c4,%eax
8010316f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103172:	7f db                	jg     8010314f <read_head+0x3d>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
80103174:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103177:	89 04 24             	mov    %eax,(%esp)
8010317a:	e8 98 d0 ff ff       	call   80100217 <brelse>
}
8010317f:	c9                   	leave  
80103180:	c3                   	ret    

80103181 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103181:	55                   	push   %ebp
80103182:	89 e5                	mov    %esp,%ebp
80103184:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103187:	a1 b4 f8 10 80       	mov    0x8010f8b4,%eax
8010318c:	89 c2                	mov    %eax,%edx
8010318e:	a1 c0 f8 10 80       	mov    0x8010f8c0,%eax
80103193:	89 54 24 04          	mov    %edx,0x4(%esp)
80103197:	89 04 24             	mov    %eax,(%esp)
8010319a:	e8 07 d0 ff ff       	call   801001a6 <bread>
8010319f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801031a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801031a5:	83 c0 18             	add    $0x18,%eax
801031a8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801031ab:	8b 15 c4 f8 10 80    	mov    0x8010f8c4,%edx
801031b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031b4:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801031b6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801031bd:	eb 1b                	jmp    801031da <write_head+0x59>
    hb->sector[i] = log.lh.sector[i];
801031bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031c2:	83 c0 10             	add    $0x10,%eax
801031c5:	8b 0c 85 88 f8 10 80 	mov    -0x7fef0778(,%eax,4),%ecx
801031cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
801031d2:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
801031d6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801031da:	a1 c4 f8 10 80       	mov    0x8010f8c4,%eax
801031df:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801031e2:	7f db                	jg     801031bf <write_head+0x3e>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
801031e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801031e7:	89 04 24             	mov    %eax,(%esp)
801031ea:	e8 ee cf ff ff       	call   801001dd <bwrite>
  brelse(buf);
801031ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801031f2:	89 04 24             	mov    %eax,(%esp)
801031f5:	e8 1d d0 ff ff       	call   80100217 <brelse>
}
801031fa:	c9                   	leave  
801031fb:	c3                   	ret    

801031fc <recover_from_log>:

static void
recover_from_log(void)
{
801031fc:	55                   	push   %ebp
801031fd:	89 e5                	mov    %esp,%ebp
801031ff:	83 ec 08             	sub    $0x8,%esp
  read_head();      
80103202:	e8 0b ff ff ff       	call   80103112 <read_head>
  install_trans(); // if committed, copy from log to disk
80103207:	e8 5b fe ff ff       	call   80103067 <install_trans>
  log.lh.n = 0;
8010320c:	c7 05 c4 f8 10 80 00 	movl   $0x0,0x8010f8c4
80103213:	00 00 00 
  write_head(); // clear the log
80103216:	e8 66 ff ff ff       	call   80103181 <write_head>
}
8010321b:	c9                   	leave  
8010321c:	c3                   	ret    

8010321d <begin_trans>:

void
begin_trans(void)
{
8010321d:	55                   	push   %ebp
8010321e:	89 e5                	mov    %esp,%ebp
80103220:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
80103223:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
8010322a:	e8 3c 1b 00 00       	call   80104d6b <acquire>
  while (log.busy) {
8010322f:	eb 14                	jmp    80103245 <begin_trans+0x28>
    sleep(&log, &log.lock);
80103231:	c7 44 24 04 80 f8 10 	movl   $0x8010f880,0x4(%esp)
80103238:	80 
80103239:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
80103240:	e8 0c 18 00 00       	call   80104a51 <sleep>

void
begin_trans(void)
{
  acquire(&log.lock);
  while (log.busy) {
80103245:	a1 bc f8 10 80       	mov    0x8010f8bc,%eax
8010324a:	85 c0                	test   %eax,%eax
8010324c:	75 e3                	jne    80103231 <begin_trans+0x14>
    sleep(&log, &log.lock);
  }
  log.busy = 1;
8010324e:	c7 05 bc f8 10 80 01 	movl   $0x1,0x8010f8bc
80103255:	00 00 00 
  release(&log.lock);
80103258:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
8010325f:	e8 69 1b 00 00       	call   80104dcd <release>
}
80103264:	c9                   	leave  
80103265:	c3                   	ret    

80103266 <commit_trans>:

void
commit_trans(void)
{
80103266:	55                   	push   %ebp
80103267:	89 e5                	mov    %esp,%ebp
80103269:	83 ec 18             	sub    $0x18,%esp
  if (log.lh.n > 0) {
8010326c:	a1 c4 f8 10 80       	mov    0x8010f8c4,%eax
80103271:	85 c0                	test   %eax,%eax
80103273:	7e 19                	jle    8010328e <commit_trans+0x28>
    write_head();    // Write header to disk -- the real commit
80103275:	e8 07 ff ff ff       	call   80103181 <write_head>
    install_trans(); // Now install writes to home locations
8010327a:	e8 e8 fd ff ff       	call   80103067 <install_trans>
    log.lh.n = 0; 
8010327f:	c7 05 c4 f8 10 80 00 	movl   $0x0,0x8010f8c4
80103286:	00 00 00 
    write_head();    // Erase the transaction from the log
80103289:	e8 f3 fe ff ff       	call   80103181 <write_head>
  }
  
  acquire(&log.lock);
8010328e:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
80103295:	e8 d1 1a 00 00       	call   80104d6b <acquire>
  log.busy = 0;
8010329a:	c7 05 bc f8 10 80 00 	movl   $0x0,0x8010f8bc
801032a1:	00 00 00 
  wakeup(&log);
801032a4:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
801032ab:	e8 8d 18 00 00       	call   80104b3d <wakeup>
  release(&log.lock);
801032b0:	c7 04 24 80 f8 10 80 	movl   $0x8010f880,(%esp)
801032b7:	e8 11 1b 00 00       	call   80104dcd <release>
}
801032bc:	c9                   	leave  
801032bd:	c3                   	ret    

801032be <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801032be:	55                   	push   %ebp
801032bf:	89 e5                	mov    %esp,%ebp
801032c1:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801032c4:	a1 c4 f8 10 80       	mov    0x8010f8c4,%eax
801032c9:	83 f8 09             	cmp    $0x9,%eax
801032cc:	7f 12                	jg     801032e0 <log_write+0x22>
801032ce:	a1 c4 f8 10 80       	mov    0x8010f8c4,%eax
801032d3:	8b 15 b8 f8 10 80    	mov    0x8010f8b8,%edx
801032d9:	83 ea 01             	sub    $0x1,%edx
801032dc:	39 d0                	cmp    %edx,%eax
801032de:	7c 0c                	jl     801032ec <log_write+0x2e>
    panic("too big a transaction");
801032e0:	c7 04 24 b0 85 10 80 	movl   $0x801085b0,(%esp)
801032e7:	e8 51 d2 ff ff       	call   8010053d <panic>
  if (!log.busy)
801032ec:	a1 bc f8 10 80       	mov    0x8010f8bc,%eax
801032f1:	85 c0                	test   %eax,%eax
801032f3:	75 0c                	jne    80103301 <log_write+0x43>
    panic("write outside of trans");
801032f5:	c7 04 24 c6 85 10 80 	movl   $0x801085c6,(%esp)
801032fc:	e8 3c d2 ff ff       	call   8010053d <panic>

  for (i = 0; i < log.lh.n; i++) {
80103301:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103308:	eb 1d                	jmp    80103327 <log_write+0x69>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
8010330a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010330d:	83 c0 10             	add    $0x10,%eax
80103310:	8b 04 85 88 f8 10 80 	mov    -0x7fef0778(,%eax,4),%eax
80103317:	89 c2                	mov    %eax,%edx
80103319:	8b 45 08             	mov    0x8(%ebp),%eax
8010331c:	8b 40 08             	mov    0x8(%eax),%eax
8010331f:	39 c2                	cmp    %eax,%edx
80103321:	74 10                	je     80103333 <log_write+0x75>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    panic("too big a transaction");
  if (!log.busy)
    panic("write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
80103323:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103327:	a1 c4 f8 10 80       	mov    0x8010f8c4,%eax
8010332c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010332f:	7f d9                	jg     8010330a <log_write+0x4c>
80103331:	eb 01                	jmp    80103334 <log_write+0x76>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
      break;
80103333:	90                   	nop
  }
  log.lh.sector[i] = b->sector;
80103334:	8b 45 08             	mov    0x8(%ebp),%eax
80103337:	8b 40 08             	mov    0x8(%eax),%eax
8010333a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010333d:	83 c2 10             	add    $0x10,%edx
80103340:	89 04 95 88 f8 10 80 	mov    %eax,-0x7fef0778(,%edx,4)
  struct buf *lbuf = bread(b->dev, log.start+i+1);
80103347:	a1 b4 f8 10 80       	mov    0x8010f8b4,%eax
8010334c:	03 45 f4             	add    -0xc(%ebp),%eax
8010334f:	83 c0 01             	add    $0x1,%eax
80103352:	89 c2                	mov    %eax,%edx
80103354:	8b 45 08             	mov    0x8(%ebp),%eax
80103357:	8b 40 04             	mov    0x4(%eax),%eax
8010335a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010335e:	89 04 24             	mov    %eax,(%esp)
80103361:	e8 40 ce ff ff       	call   801001a6 <bread>
80103366:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(lbuf->data, b->data, BSIZE);
80103369:	8b 45 08             	mov    0x8(%ebp),%eax
8010336c:	8d 50 18             	lea    0x18(%eax),%edx
8010336f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103372:	83 c0 18             	add    $0x18,%eax
80103375:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010337c:	00 
8010337d:	89 54 24 04          	mov    %edx,0x4(%esp)
80103381:	89 04 24             	mov    %eax,(%esp)
80103384:	e8 04 1d 00 00       	call   8010508d <memmove>
  bwrite(lbuf);
80103389:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010338c:	89 04 24             	mov    %eax,(%esp)
8010338f:	e8 49 ce ff ff       	call   801001dd <bwrite>
  brelse(lbuf);
80103394:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103397:	89 04 24             	mov    %eax,(%esp)
8010339a:	e8 78 ce ff ff       	call   80100217 <brelse>
  if (i == log.lh.n)
8010339f:	a1 c4 f8 10 80       	mov    0x8010f8c4,%eax
801033a4:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801033a7:	75 0d                	jne    801033b6 <log_write+0xf8>
    log.lh.n++;
801033a9:	a1 c4 f8 10 80       	mov    0x8010f8c4,%eax
801033ae:	83 c0 01             	add    $0x1,%eax
801033b1:	a3 c4 f8 10 80       	mov    %eax,0x8010f8c4
  b->flags |= B_DIRTY; // XXX prevent eviction
801033b6:	8b 45 08             	mov    0x8(%ebp),%eax
801033b9:	8b 00                	mov    (%eax),%eax
801033bb:	89 c2                	mov    %eax,%edx
801033bd:	83 ca 04             	or     $0x4,%edx
801033c0:	8b 45 08             	mov    0x8(%ebp),%eax
801033c3:	89 10                	mov    %edx,(%eax)
}
801033c5:	c9                   	leave  
801033c6:	c3                   	ret    
	...

801033c8 <v2p>:
801033c8:	55                   	push   %ebp
801033c9:	89 e5                	mov    %esp,%ebp
801033cb:	8b 45 08             	mov    0x8(%ebp),%eax
801033ce:	05 00 00 00 80       	add    $0x80000000,%eax
801033d3:	5d                   	pop    %ebp
801033d4:	c3                   	ret    

801033d5 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801033d5:	55                   	push   %ebp
801033d6:	89 e5                	mov    %esp,%ebp
801033d8:	8b 45 08             	mov    0x8(%ebp),%eax
801033db:	05 00 00 00 80       	add    $0x80000000,%eax
801033e0:	5d                   	pop    %ebp
801033e1:	c3                   	ret    

801033e2 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
801033e2:	55                   	push   %ebp
801033e3:	89 e5                	mov    %esp,%ebp
801033e5:	53                   	push   %ebx
801033e6:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
801033e9:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801033ec:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
801033ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801033f2:	89 c3                	mov    %eax,%ebx
801033f4:	89 d8                	mov    %ebx,%eax
801033f6:	f0 87 02             	lock xchg %eax,(%edx)
801033f9:	89 c3                	mov    %eax,%ebx
801033fb:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801033fe:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103401:	83 c4 10             	add    $0x10,%esp
80103404:	5b                   	pop    %ebx
80103405:	5d                   	pop    %ebp
80103406:	c3                   	ret    

80103407 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103407:	55                   	push   %ebp
80103408:	89 e5                	mov    %esp,%ebp
8010340a:	83 e4 f0             	and    $0xfffffff0,%esp
8010340d:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103410:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
80103417:	80 
80103418:	c7 04 24 1c 2a 11 80 	movl   $0x80112a1c,(%esp)
8010341f:	e8 ad f5 ff ff       	call   801029d1 <kinit1>
  kvmalloc();      // kernel page table
80103424:	e8 e1 47 00 00       	call   80107c0a <kvmalloc>
  mpinit();        // collect info about this machine
80103429:	e8 63 04 00 00       	call   80103891 <mpinit>
  lapicinit(mpbcpu());
8010342e:	e8 2e 02 00 00       	call   80103661 <mpbcpu>
80103433:	89 04 24             	mov    %eax,(%esp)
80103436:	e8 f6 f8 ff ff       	call   80102d31 <lapicinit>
  seginit();       // set up segments
8010343b:	e8 6d 41 00 00       	call   801075ad <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103440:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103446:	0f b6 00             	movzbl (%eax),%eax
80103449:	0f b6 c0             	movzbl %al,%eax
8010344c:	89 44 24 04          	mov    %eax,0x4(%esp)
80103450:	c7 04 24 dd 85 10 80 	movl   $0x801085dd,(%esp)
80103457:	e8 45 cf ff ff       	call   801003a1 <cprintf>
  picinit();       // interrupt controller
8010345c:	e8 95 06 00 00       	call   80103af6 <picinit>
  ioapicinit();    // another interrupt controller
80103461:	e8 5b f4 ff ff       	call   801028c1 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
80103466:	e8 22 d6 ff ff       	call   80100a8d <consoleinit>
  uartinit();      // serial port
8010346b:	e8 88 34 00 00       	call   801068f8 <uartinit>
  pinit();         // process table
80103470:	e8 85 0d 00 00       	call   801041fa <pinit>
  tvinit();        // trap vectors
80103475:	e8 d5 2f 00 00       	call   8010644f <tvinit>
  binit();         // buffer cache
8010347a:	e8 b5 cb ff ff       	call   80100034 <binit>
  fileinit();      // file table
8010347f:	e8 7c da ff ff       	call   80100f00 <fileinit>
  iinit();         // inode cache
80103484:	e8 2a e1 ff ff       	call   801015b3 <iinit>
  ideinit();       // disk
80103489:	e8 98 f0 ff ff       	call   80102526 <ideinit>
  if(!ismp)
8010348e:	a1 04 f9 10 80       	mov    0x8010f904,%eax
80103493:	85 c0                	test   %eax,%eax
80103495:	75 05                	jne    8010349c <main+0x95>
    timerinit();   // uniprocessor timer
80103497:	e8 f6 2e 00 00       	call   80106392 <timerinit>
  startothers();   // start other processors
8010349c:	e8 87 00 00 00       	call   80103528 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801034a1:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
801034a8:	8e 
801034a9:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
801034b0:	e8 54 f5 ff ff       	call   80102a09 <kinit2>
  userinit();      // first user process
801034b5:	e8 5e 0e 00 00       	call   80104318 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
801034ba:	e8 22 00 00 00       	call   801034e1 <mpmain>

801034bf <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801034bf:	55                   	push   %ebp
801034c0:	89 e5                	mov    %esp,%ebp
801034c2:	83 ec 18             	sub    $0x18,%esp
  switchkvm(); 
801034c5:	e8 57 47 00 00       	call   80107c21 <switchkvm>
  seginit();
801034ca:	e8 de 40 00 00       	call   801075ad <seginit>
  lapicinit(cpunum());
801034cf:	e8 ba f9 ff ff       	call   80102e8e <cpunum>
801034d4:	89 04 24             	mov    %eax,(%esp)
801034d7:	e8 55 f8 ff ff       	call   80102d31 <lapicinit>
  mpmain();
801034dc:	e8 00 00 00 00       	call   801034e1 <mpmain>

801034e1 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801034e1:	55                   	push   %ebp
801034e2:	89 e5                	mov    %esp,%ebp
801034e4:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
801034e7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801034ed:	0f b6 00             	movzbl (%eax),%eax
801034f0:	0f b6 c0             	movzbl %al,%eax
801034f3:	89 44 24 04          	mov    %eax,0x4(%esp)
801034f7:	c7 04 24 f4 85 10 80 	movl   $0x801085f4,(%esp)
801034fe:	e8 9e ce ff ff       	call   801003a1 <cprintf>
  idtinit();       // load idt register
80103503:	e8 bb 30 00 00       	call   801065c3 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103508:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010350e:	05 a8 00 00 00       	add    $0xa8,%eax
80103513:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010351a:	00 
8010351b:	89 04 24             	mov    %eax,(%esp)
8010351e:	e8 bf fe ff ff       	call   801033e2 <xchg>
  scheduler();     // start running processes
80103523:	e8 5e 13 00 00       	call   80104886 <scheduler>

80103528 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103528:	55                   	push   %ebp
80103529:	89 e5                	mov    %esp,%ebp
8010352b:	53                   	push   %ebx
8010352c:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
8010352f:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
80103536:	e8 9a fe ff ff       	call   801033d5 <p2v>
8010353b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
8010353e:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103543:	89 44 24 08          	mov    %eax,0x8(%esp)
80103547:	c7 44 24 04 0c b5 10 	movl   $0x8010b50c,0x4(%esp)
8010354e:	80 
8010354f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103552:	89 04 24             	mov    %eax,(%esp)
80103555:	e8 33 1b 00 00       	call   8010508d <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
8010355a:	c7 45 f4 20 f9 10 80 	movl   $0x8010f920,-0xc(%ebp)
80103561:	e9 86 00 00 00       	jmp    801035ec <startothers+0xc4>
    if(c == cpus+cpunum())  // We've started already.
80103566:	e8 23 f9 ff ff       	call   80102e8e <cpunum>
8010356b:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103571:	05 20 f9 10 80       	add    $0x8010f920,%eax
80103576:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103579:	74 69                	je     801035e4 <startothers+0xbc>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
8010357b:	e8 7f f5 ff ff       	call   80102aff <kalloc>
80103580:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103583:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103586:	83 e8 04             	sub    $0x4,%eax
80103589:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010358c:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103592:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103594:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103597:	83 e8 08             	sub    $0x8,%eax
8010359a:	c7 00 bf 34 10 80    	movl   $0x801034bf,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
801035a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035a3:	8d 58 f4             	lea    -0xc(%eax),%ebx
801035a6:	c7 04 24 00 a0 10 80 	movl   $0x8010a000,(%esp)
801035ad:	e8 16 fe ff ff       	call   801033c8 <v2p>
801035b2:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
801035b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035b7:	89 04 24             	mov    %eax,(%esp)
801035ba:	e8 09 fe ff ff       	call   801033c8 <v2p>
801035bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
801035c2:	0f b6 12             	movzbl (%edx),%edx
801035c5:	0f b6 d2             	movzbl %dl,%edx
801035c8:	89 44 24 04          	mov    %eax,0x4(%esp)
801035cc:	89 14 24             	mov    %edx,(%esp)
801035cf:	e8 40 f9 ff ff       	call   80102f14 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801035d4:	90                   	nop
801035d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035d8:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801035de:	85 c0                	test   %eax,%eax
801035e0:	74 f3                	je     801035d5 <startothers+0xad>
801035e2:	eb 01                	jmp    801035e5 <startothers+0xbd>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
801035e4:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
801035e5:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
801035ec:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
801035f1:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801035f7:	05 20 f9 10 80       	add    $0x8010f920,%eax
801035fc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801035ff:	0f 87 61 ff ff ff    	ja     80103566 <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103605:	83 c4 24             	add    $0x24,%esp
80103608:	5b                   	pop    %ebx
80103609:	5d                   	pop    %ebp
8010360a:	c3                   	ret    
	...

8010360c <p2v>:
8010360c:	55                   	push   %ebp
8010360d:	89 e5                	mov    %esp,%ebp
8010360f:	8b 45 08             	mov    0x8(%ebp),%eax
80103612:	05 00 00 00 80       	add    $0x80000000,%eax
80103617:	5d                   	pop    %ebp
80103618:	c3                   	ret    

80103619 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103619:	55                   	push   %ebp
8010361a:	89 e5                	mov    %esp,%ebp
8010361c:	53                   	push   %ebx
8010361d:	83 ec 14             	sub    $0x14,%esp
80103620:	8b 45 08             	mov    0x8(%ebp),%eax
80103623:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103627:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
8010362b:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
8010362f:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80103633:	ec                   	in     (%dx),%al
80103634:	89 c3                	mov    %eax,%ebx
80103636:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80103639:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
8010363d:	83 c4 14             	add    $0x14,%esp
80103640:	5b                   	pop    %ebx
80103641:	5d                   	pop    %ebp
80103642:	c3                   	ret    

80103643 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103643:	55                   	push   %ebp
80103644:	89 e5                	mov    %esp,%ebp
80103646:	83 ec 08             	sub    $0x8,%esp
80103649:	8b 55 08             	mov    0x8(%ebp),%edx
8010364c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010364f:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103653:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103656:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010365a:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010365e:	ee                   	out    %al,(%dx)
}
8010365f:	c9                   	leave  
80103660:	c3                   	ret    

80103661 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103661:	55                   	push   %ebp
80103662:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103664:	a1 44 b6 10 80       	mov    0x8010b644,%eax
80103669:	89 c2                	mov    %eax,%edx
8010366b:	b8 20 f9 10 80       	mov    $0x8010f920,%eax
80103670:	89 d1                	mov    %edx,%ecx
80103672:	29 c1                	sub    %eax,%ecx
80103674:	89 c8                	mov    %ecx,%eax
80103676:	c1 f8 02             	sar    $0x2,%eax
80103679:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
8010367f:	5d                   	pop    %ebp
80103680:	c3                   	ret    

80103681 <sum>:

static uchar
sum(uchar *addr, int len)
{
80103681:	55                   	push   %ebp
80103682:	89 e5                	mov    %esp,%ebp
80103684:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103687:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
8010368e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103695:	eb 13                	jmp    801036aa <sum+0x29>
    sum += addr[i];
80103697:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010369a:	03 45 08             	add    0x8(%ebp),%eax
8010369d:	0f b6 00             	movzbl (%eax),%eax
801036a0:	0f b6 c0             	movzbl %al,%eax
801036a3:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
801036a6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801036aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
801036ad:	3b 45 0c             	cmp    0xc(%ebp),%eax
801036b0:	7c e5                	jl     80103697 <sum+0x16>
    sum += addr[i];
  return sum;
801036b2:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801036b5:	c9                   	leave  
801036b6:	c3                   	ret    

801036b7 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
801036b7:	55                   	push   %ebp
801036b8:	89 e5                	mov    %esp,%ebp
801036ba:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
801036bd:	8b 45 08             	mov    0x8(%ebp),%eax
801036c0:	89 04 24             	mov    %eax,(%esp)
801036c3:	e8 44 ff ff ff       	call   8010360c <p2v>
801036c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
801036cb:	8b 45 0c             	mov    0xc(%ebp),%eax
801036ce:	03 45 f0             	add    -0x10(%ebp),%eax
801036d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
801036d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801036da:	eb 3f                	jmp    8010371b <mpsearch1+0x64>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801036dc:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801036e3:	00 
801036e4:	c7 44 24 04 08 86 10 	movl   $0x80108608,0x4(%esp)
801036eb:	80 
801036ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036ef:	89 04 24             	mov    %eax,(%esp)
801036f2:	e8 3a 19 00 00       	call   80105031 <memcmp>
801036f7:	85 c0                	test   %eax,%eax
801036f9:	75 1c                	jne    80103717 <mpsearch1+0x60>
801036fb:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103702:	00 
80103703:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103706:	89 04 24             	mov    %eax,(%esp)
80103709:	e8 73 ff ff ff       	call   80103681 <sum>
8010370e:	84 c0                	test   %al,%al
80103710:	75 05                	jne    80103717 <mpsearch1+0x60>
      return (struct mp*)p;
80103712:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103715:	eb 11                	jmp    80103728 <mpsearch1+0x71>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103717:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010371b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010371e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103721:	72 b9                	jb     801036dc <mpsearch1+0x25>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103723:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103728:	c9                   	leave  
80103729:	c3                   	ret    

8010372a <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
8010372a:	55                   	push   %ebp
8010372b:	89 e5                	mov    %esp,%ebp
8010372d:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103730:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103737:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010373a:	83 c0 0f             	add    $0xf,%eax
8010373d:	0f b6 00             	movzbl (%eax),%eax
80103740:	0f b6 c0             	movzbl %al,%eax
80103743:	89 c2                	mov    %eax,%edx
80103745:	c1 e2 08             	shl    $0x8,%edx
80103748:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010374b:	83 c0 0e             	add    $0xe,%eax
8010374e:	0f b6 00             	movzbl (%eax),%eax
80103751:	0f b6 c0             	movzbl %al,%eax
80103754:	09 d0                	or     %edx,%eax
80103756:	c1 e0 04             	shl    $0x4,%eax
80103759:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010375c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103760:	74 21                	je     80103783 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103762:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103769:	00 
8010376a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010376d:	89 04 24             	mov    %eax,(%esp)
80103770:	e8 42 ff ff ff       	call   801036b7 <mpsearch1>
80103775:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103778:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010377c:	74 50                	je     801037ce <mpsearch+0xa4>
      return mp;
8010377e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103781:	eb 5f                	jmp    801037e2 <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103783:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103786:	83 c0 14             	add    $0x14,%eax
80103789:	0f b6 00             	movzbl (%eax),%eax
8010378c:	0f b6 c0             	movzbl %al,%eax
8010378f:	89 c2                	mov    %eax,%edx
80103791:	c1 e2 08             	shl    $0x8,%edx
80103794:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103797:	83 c0 13             	add    $0x13,%eax
8010379a:	0f b6 00             	movzbl (%eax),%eax
8010379d:	0f b6 c0             	movzbl %al,%eax
801037a0:	09 d0                	or     %edx,%eax
801037a2:	c1 e0 0a             	shl    $0xa,%eax
801037a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
801037a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801037ab:	2d 00 04 00 00       	sub    $0x400,%eax
801037b0:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
801037b7:	00 
801037b8:	89 04 24             	mov    %eax,(%esp)
801037bb:	e8 f7 fe ff ff       	call   801036b7 <mpsearch1>
801037c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
801037c3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801037c7:	74 05                	je     801037ce <mpsearch+0xa4>
      return mp;
801037c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801037cc:	eb 14                	jmp    801037e2 <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
801037ce:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801037d5:	00 
801037d6:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
801037dd:	e8 d5 fe ff ff       	call   801036b7 <mpsearch1>
}
801037e2:	c9                   	leave  
801037e3:	c3                   	ret    

801037e4 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
801037e4:	55                   	push   %ebp
801037e5:	89 e5                	mov    %esp,%ebp
801037e7:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
801037ea:	e8 3b ff ff ff       	call   8010372a <mpsearch>
801037ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
801037f2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801037f6:	74 0a                	je     80103802 <mpconfig+0x1e>
801037f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037fb:	8b 40 04             	mov    0x4(%eax),%eax
801037fe:	85 c0                	test   %eax,%eax
80103800:	75 0a                	jne    8010380c <mpconfig+0x28>
    return 0;
80103802:	b8 00 00 00 00       	mov    $0x0,%eax
80103807:	e9 83 00 00 00       	jmp    8010388f <mpconfig+0xab>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
8010380c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010380f:	8b 40 04             	mov    0x4(%eax),%eax
80103812:	89 04 24             	mov    %eax,(%esp)
80103815:	e8 f2 fd ff ff       	call   8010360c <p2v>
8010381a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
8010381d:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103824:	00 
80103825:	c7 44 24 04 0d 86 10 	movl   $0x8010860d,0x4(%esp)
8010382c:	80 
8010382d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103830:	89 04 24             	mov    %eax,(%esp)
80103833:	e8 f9 17 00 00       	call   80105031 <memcmp>
80103838:	85 c0                	test   %eax,%eax
8010383a:	74 07                	je     80103843 <mpconfig+0x5f>
    return 0;
8010383c:	b8 00 00 00 00       	mov    $0x0,%eax
80103841:	eb 4c                	jmp    8010388f <mpconfig+0xab>
  if(conf->version != 1 && conf->version != 4)
80103843:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103846:	0f b6 40 06          	movzbl 0x6(%eax),%eax
8010384a:	3c 01                	cmp    $0x1,%al
8010384c:	74 12                	je     80103860 <mpconfig+0x7c>
8010384e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103851:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103855:	3c 04                	cmp    $0x4,%al
80103857:	74 07                	je     80103860 <mpconfig+0x7c>
    return 0;
80103859:	b8 00 00 00 00       	mov    $0x0,%eax
8010385e:	eb 2f                	jmp    8010388f <mpconfig+0xab>
  if(sum((uchar*)conf, conf->length) != 0)
80103860:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103863:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103867:	0f b7 c0             	movzwl %ax,%eax
8010386a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010386e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103871:	89 04 24             	mov    %eax,(%esp)
80103874:	e8 08 fe ff ff       	call   80103681 <sum>
80103879:	84 c0                	test   %al,%al
8010387b:	74 07                	je     80103884 <mpconfig+0xa0>
    return 0;
8010387d:	b8 00 00 00 00       	mov    $0x0,%eax
80103882:	eb 0b                	jmp    8010388f <mpconfig+0xab>
  *pmp = mp;
80103884:	8b 45 08             	mov    0x8(%ebp),%eax
80103887:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010388a:	89 10                	mov    %edx,(%eax)
  return conf;
8010388c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010388f:	c9                   	leave  
80103890:	c3                   	ret    

80103891 <mpinit>:

void
mpinit(void)
{
80103891:	55                   	push   %ebp
80103892:	89 e5                	mov    %esp,%ebp
80103894:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103897:	c7 05 44 b6 10 80 20 	movl   $0x8010f920,0x8010b644
8010389e:	f9 10 80 
  if((conf = mpconfig(&mp)) == 0)
801038a1:	8d 45 e0             	lea    -0x20(%ebp),%eax
801038a4:	89 04 24             	mov    %eax,(%esp)
801038a7:	e8 38 ff ff ff       	call   801037e4 <mpconfig>
801038ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
801038af:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801038b3:	0f 84 9c 01 00 00    	je     80103a55 <mpinit+0x1c4>
    return;
  ismp = 1;
801038b9:	c7 05 04 f9 10 80 01 	movl   $0x1,0x8010f904
801038c0:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
801038c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038c6:	8b 40 24             	mov    0x24(%eax),%eax
801038c9:	a3 7c f8 10 80       	mov    %eax,0x8010f87c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801038ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038d1:	83 c0 2c             	add    $0x2c,%eax
801038d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801038d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038da:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801038de:	0f b7 c0             	movzwl %ax,%eax
801038e1:	03 45 f0             	add    -0x10(%ebp),%eax
801038e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801038e7:	e9 f4 00 00 00       	jmp    801039e0 <mpinit+0x14f>
    switch(*p){
801038ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038ef:	0f b6 00             	movzbl (%eax),%eax
801038f2:	0f b6 c0             	movzbl %al,%eax
801038f5:	83 f8 04             	cmp    $0x4,%eax
801038f8:	0f 87 bf 00 00 00    	ja     801039bd <mpinit+0x12c>
801038fe:	8b 04 85 50 86 10 80 	mov    -0x7fef79b0(,%eax,4),%eax
80103905:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103907:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010390a:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
8010390d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103910:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103914:	0f b6 d0             	movzbl %al,%edx
80103917:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
8010391c:	39 c2                	cmp    %eax,%edx
8010391e:	74 2d                	je     8010394d <mpinit+0xbc>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103920:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103923:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103927:	0f b6 d0             	movzbl %al,%edx
8010392a:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
8010392f:	89 54 24 08          	mov    %edx,0x8(%esp)
80103933:	89 44 24 04          	mov    %eax,0x4(%esp)
80103937:	c7 04 24 12 86 10 80 	movl   $0x80108612,(%esp)
8010393e:	e8 5e ca ff ff       	call   801003a1 <cprintf>
        ismp = 0;
80103943:	c7 05 04 f9 10 80 00 	movl   $0x0,0x8010f904
8010394a:	00 00 00 
      }
      if(proc->flags & MPBOOT)
8010394d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103950:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103954:	0f b6 c0             	movzbl %al,%eax
80103957:	83 e0 02             	and    $0x2,%eax
8010395a:	85 c0                	test   %eax,%eax
8010395c:	74 15                	je     80103973 <mpinit+0xe2>
        bcpu = &cpus[ncpu];
8010395e:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
80103963:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103969:	05 20 f9 10 80       	add    $0x8010f920,%eax
8010396e:	a3 44 b6 10 80       	mov    %eax,0x8010b644
      cpus[ncpu].id = ncpu;
80103973:	8b 15 00 ff 10 80    	mov    0x8010ff00,%edx
80103979:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
8010397e:	69 d2 bc 00 00 00    	imul   $0xbc,%edx,%edx
80103984:	81 c2 20 f9 10 80    	add    $0x8010f920,%edx
8010398a:	88 02                	mov    %al,(%edx)
      ncpu++;
8010398c:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
80103991:	83 c0 01             	add    $0x1,%eax
80103994:	a3 00 ff 10 80       	mov    %eax,0x8010ff00
      p += sizeof(struct mpproc);
80103999:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
8010399d:	eb 41                	jmp    801039e0 <mpinit+0x14f>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
8010399f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
801039a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801039a8:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801039ac:	a2 00 f9 10 80       	mov    %al,0x8010f900
      p += sizeof(struct mpioapic);
801039b1:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
801039b5:	eb 29                	jmp    801039e0 <mpinit+0x14f>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
801039b7:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
801039bb:	eb 23                	jmp    801039e0 <mpinit+0x14f>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
801039bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039c0:	0f b6 00             	movzbl (%eax),%eax
801039c3:	0f b6 c0             	movzbl %al,%eax
801039c6:	89 44 24 04          	mov    %eax,0x4(%esp)
801039ca:	c7 04 24 30 86 10 80 	movl   $0x80108630,(%esp)
801039d1:	e8 cb c9 ff ff       	call   801003a1 <cprintf>
      ismp = 0;
801039d6:	c7 05 04 f9 10 80 00 	movl   $0x0,0x8010f904
801039dd:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801039e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039e3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801039e6:	0f 82 00 ff ff ff    	jb     801038ec <mpinit+0x5b>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
801039ec:	a1 04 f9 10 80       	mov    0x8010f904,%eax
801039f1:	85 c0                	test   %eax,%eax
801039f3:	75 1d                	jne    80103a12 <mpinit+0x181>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
801039f5:	c7 05 00 ff 10 80 01 	movl   $0x1,0x8010ff00
801039fc:	00 00 00 
    lapic = 0;
801039ff:	c7 05 7c f8 10 80 00 	movl   $0x0,0x8010f87c
80103a06:	00 00 00 
    ioapicid = 0;
80103a09:	c6 05 00 f9 10 80 00 	movb   $0x0,0x8010f900
    return;
80103a10:	eb 44                	jmp    80103a56 <mpinit+0x1c5>
  }

  if(mp->imcrp){
80103a12:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103a15:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103a19:	84 c0                	test   %al,%al
80103a1b:	74 39                	je     80103a56 <mpinit+0x1c5>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103a1d:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103a24:	00 
80103a25:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103a2c:	e8 12 fc ff ff       	call   80103643 <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103a31:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103a38:	e8 dc fb ff ff       	call   80103619 <inb>
80103a3d:	83 c8 01             	or     $0x1,%eax
80103a40:	0f b6 c0             	movzbl %al,%eax
80103a43:	89 44 24 04          	mov    %eax,0x4(%esp)
80103a47:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103a4e:	e8 f0 fb ff ff       	call   80103643 <outb>
80103a53:	eb 01                	jmp    80103a56 <mpinit+0x1c5>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80103a55:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80103a56:	c9                   	leave  
80103a57:	c3                   	ret    

80103a58 <outb>:
80103a58:	55                   	push   %ebp
80103a59:	89 e5                	mov    %esp,%ebp
80103a5b:	83 ec 08             	sub    $0x8,%esp
80103a5e:	8b 55 08             	mov    0x8(%ebp),%edx
80103a61:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a64:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103a68:	88 45 f8             	mov    %al,-0x8(%ebp)
80103a6b:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103a6f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103a73:	ee                   	out    %al,(%dx)
80103a74:	c9                   	leave  
80103a75:	c3                   	ret    

80103a76 <picsetmask>:
80103a76:	55                   	push   %ebp
80103a77:	89 e5                	mov    %esp,%ebp
80103a79:	83 ec 0c             	sub    $0xc,%esp
80103a7c:	8b 45 08             	mov    0x8(%ebp),%eax
80103a7f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103a83:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103a87:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
80103a8d:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103a91:	0f b6 c0             	movzbl %al,%eax
80103a94:	89 44 24 04          	mov    %eax,0x4(%esp)
80103a98:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103a9f:	e8 b4 ff ff ff       	call   80103a58 <outb>
80103aa4:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103aa8:	66 c1 e8 08          	shr    $0x8,%ax
80103aac:	0f b6 c0             	movzbl %al,%eax
80103aaf:	89 44 24 04          	mov    %eax,0x4(%esp)
80103ab3:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103aba:	e8 99 ff ff ff       	call   80103a58 <outb>
80103abf:	c9                   	leave  
80103ac0:	c3                   	ret    

80103ac1 <picenable>:
80103ac1:	55                   	push   %ebp
80103ac2:	89 e5                	mov    %esp,%ebp
80103ac4:	53                   	push   %ebx
80103ac5:	83 ec 04             	sub    $0x4,%esp
80103ac8:	8b 45 08             	mov    0x8(%ebp),%eax
80103acb:	ba 01 00 00 00       	mov    $0x1,%edx
80103ad0:	89 d3                	mov    %edx,%ebx
80103ad2:	89 c1                	mov    %eax,%ecx
80103ad4:	d3 e3                	shl    %cl,%ebx
80103ad6:	89 d8                	mov    %ebx,%eax
80103ad8:	89 c2                	mov    %eax,%edx
80103ada:	f7 d2                	not    %edx
80103adc:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103ae3:	21 d0                	and    %edx,%eax
80103ae5:	0f b7 c0             	movzwl %ax,%eax
80103ae8:	89 04 24             	mov    %eax,(%esp)
80103aeb:	e8 86 ff ff ff       	call   80103a76 <picsetmask>
80103af0:	83 c4 04             	add    $0x4,%esp
80103af3:	5b                   	pop    %ebx
80103af4:	5d                   	pop    %ebp
80103af5:	c3                   	ret    

80103af6 <picinit>:
80103af6:	55                   	push   %ebp
80103af7:	89 e5                	mov    %esp,%ebp
80103af9:	83 ec 08             	sub    $0x8,%esp
80103afc:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103b03:	00 
80103b04:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103b0b:	e8 48 ff ff ff       	call   80103a58 <outb>
80103b10:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103b17:	00 
80103b18:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103b1f:	e8 34 ff ff ff       	call   80103a58 <outb>
80103b24:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103b2b:	00 
80103b2c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103b33:	e8 20 ff ff ff       	call   80103a58 <outb>
80103b38:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80103b3f:	00 
80103b40:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103b47:	e8 0c ff ff ff       	call   80103a58 <outb>
80103b4c:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80103b53:	00 
80103b54:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103b5b:	e8 f8 fe ff ff       	call   80103a58 <outb>
80103b60:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103b67:	00 
80103b68:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103b6f:	e8 e4 fe ff ff       	call   80103a58 <outb>
80103b74:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103b7b:	00 
80103b7c:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103b83:	e8 d0 fe ff ff       	call   80103a58 <outb>
80103b88:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
80103b8f:	00 
80103b90:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103b97:	e8 bc fe ff ff       	call   80103a58 <outb>
80103b9c:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80103ba3:	00 
80103ba4:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103bab:	e8 a8 fe ff ff       	call   80103a58 <outb>
80103bb0:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103bb7:	00 
80103bb8:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103bbf:	e8 94 fe ff ff       	call   80103a58 <outb>
80103bc4:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103bcb:	00 
80103bcc:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103bd3:	e8 80 fe ff ff       	call   80103a58 <outb>
80103bd8:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103bdf:	00 
80103be0:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103be7:	e8 6c fe ff ff       	call   80103a58 <outb>
80103bec:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103bf3:	00 
80103bf4:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103bfb:	e8 58 fe ff ff       	call   80103a58 <outb>
80103c00:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103c07:	00 
80103c08:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103c0f:	e8 44 fe ff ff       	call   80103a58 <outb>
80103c14:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103c1b:	66 83 f8 ff          	cmp    $0xffff,%ax
80103c1f:	74 12                	je     80103c33 <picinit+0x13d>
80103c21:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103c28:	0f b7 c0             	movzwl %ax,%eax
80103c2b:	89 04 24             	mov    %eax,(%esp)
80103c2e:	e8 43 fe ff ff       	call   80103a76 <picsetmask>
80103c33:	c9                   	leave  
80103c34:	c3                   	ret    
80103c35:	00 00                	add    %al,(%eax)
	...

80103c38 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103c38:	55                   	push   %ebp
80103c39:	89 e5                	mov    %esp,%ebp
80103c3b:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103c3e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103c45:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c48:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103c4e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c51:	8b 10                	mov    (%eax),%edx
80103c53:	8b 45 08             	mov    0x8(%ebp),%eax
80103c56:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103c58:	e8 bf d2 ff ff       	call   80100f1c <filealloc>
80103c5d:	8b 55 08             	mov    0x8(%ebp),%edx
80103c60:	89 02                	mov    %eax,(%edx)
80103c62:	8b 45 08             	mov    0x8(%ebp),%eax
80103c65:	8b 00                	mov    (%eax),%eax
80103c67:	85 c0                	test   %eax,%eax
80103c69:	0f 84 c8 00 00 00    	je     80103d37 <pipealloc+0xff>
80103c6f:	e8 a8 d2 ff ff       	call   80100f1c <filealloc>
80103c74:	8b 55 0c             	mov    0xc(%ebp),%edx
80103c77:	89 02                	mov    %eax,(%edx)
80103c79:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c7c:	8b 00                	mov    (%eax),%eax
80103c7e:	85 c0                	test   %eax,%eax
80103c80:	0f 84 b1 00 00 00    	je     80103d37 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103c86:	e8 74 ee ff ff       	call   80102aff <kalloc>
80103c8b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c8e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103c92:	0f 84 9e 00 00 00    	je     80103d36 <pipealloc+0xfe>
    goto bad;
  p->readopen = 1;
80103c98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c9b:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103ca2:	00 00 00 
  p->writeopen = 1;
80103ca5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ca8:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103caf:	00 00 00 
  p->nwrite = 0;
80103cb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cb5:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103cbc:	00 00 00 
  p->nread = 0;
80103cbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cc2:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103cc9:	00 00 00 
  initlock(&p->lock, "pipe");
80103ccc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ccf:	c7 44 24 04 64 86 10 	movl   $0x80108664,0x4(%esp)
80103cd6:	80 
80103cd7:	89 04 24             	mov    %eax,(%esp)
80103cda:	e8 6b 10 00 00       	call   80104d4a <initlock>
  (*f0)->type = FD_PIPE;
80103cdf:	8b 45 08             	mov    0x8(%ebp),%eax
80103ce2:	8b 00                	mov    (%eax),%eax
80103ce4:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103cea:	8b 45 08             	mov    0x8(%ebp),%eax
80103ced:	8b 00                	mov    (%eax),%eax
80103cef:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103cf3:	8b 45 08             	mov    0x8(%ebp),%eax
80103cf6:	8b 00                	mov    (%eax),%eax
80103cf8:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103cfc:	8b 45 08             	mov    0x8(%ebp),%eax
80103cff:	8b 00                	mov    (%eax),%eax
80103d01:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d04:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103d07:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d0a:	8b 00                	mov    (%eax),%eax
80103d0c:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103d12:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d15:	8b 00                	mov    (%eax),%eax
80103d17:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103d1b:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d1e:	8b 00                	mov    (%eax),%eax
80103d20:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103d24:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d27:	8b 00                	mov    (%eax),%eax
80103d29:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d2c:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103d2f:	b8 00 00 00 00       	mov    $0x0,%eax
80103d34:	eb 43                	jmp    80103d79 <pipealloc+0x141>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
80103d36:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
80103d37:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d3b:	74 0b                	je     80103d48 <pipealloc+0x110>
    kfree((char*)p);
80103d3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d40:	89 04 24             	mov    %eax,(%esp)
80103d43:	e8 1e ed ff ff       	call   80102a66 <kfree>
  if(*f0)
80103d48:	8b 45 08             	mov    0x8(%ebp),%eax
80103d4b:	8b 00                	mov    (%eax),%eax
80103d4d:	85 c0                	test   %eax,%eax
80103d4f:	74 0d                	je     80103d5e <pipealloc+0x126>
    fileclose(*f0);
80103d51:	8b 45 08             	mov    0x8(%ebp),%eax
80103d54:	8b 00                	mov    (%eax),%eax
80103d56:	89 04 24             	mov    %eax,(%esp)
80103d59:	e8 66 d2 ff ff       	call   80100fc4 <fileclose>
  if(*f1)
80103d5e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d61:	8b 00                	mov    (%eax),%eax
80103d63:	85 c0                	test   %eax,%eax
80103d65:	74 0d                	je     80103d74 <pipealloc+0x13c>
    fileclose(*f1);
80103d67:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d6a:	8b 00                	mov    (%eax),%eax
80103d6c:	89 04 24             	mov    %eax,(%esp)
80103d6f:	e8 50 d2 ff ff       	call   80100fc4 <fileclose>
  return -1;
80103d74:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103d79:	c9                   	leave  
80103d7a:	c3                   	ret    

80103d7b <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103d7b:	55                   	push   %ebp
80103d7c:	89 e5                	mov    %esp,%ebp
80103d7e:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80103d81:	8b 45 08             	mov    0x8(%ebp),%eax
80103d84:	89 04 24             	mov    %eax,(%esp)
80103d87:	e8 df 0f 00 00       	call   80104d6b <acquire>
  if(writable){
80103d8c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103d90:	74 1f                	je     80103db1 <pipeclose+0x36>
    p->writeopen = 0;
80103d92:	8b 45 08             	mov    0x8(%ebp),%eax
80103d95:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103d9c:	00 00 00 
    wakeup(&p->nread);
80103d9f:	8b 45 08             	mov    0x8(%ebp),%eax
80103da2:	05 34 02 00 00       	add    $0x234,%eax
80103da7:	89 04 24             	mov    %eax,(%esp)
80103daa:	e8 8e 0d 00 00       	call   80104b3d <wakeup>
80103daf:	eb 1d                	jmp    80103dce <pipeclose+0x53>
  } else {
    p->readopen = 0;
80103db1:	8b 45 08             	mov    0x8(%ebp),%eax
80103db4:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103dbb:	00 00 00 
    wakeup(&p->nwrite);
80103dbe:	8b 45 08             	mov    0x8(%ebp),%eax
80103dc1:	05 38 02 00 00       	add    $0x238,%eax
80103dc6:	89 04 24             	mov    %eax,(%esp)
80103dc9:	e8 6f 0d 00 00       	call   80104b3d <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103dce:	8b 45 08             	mov    0x8(%ebp),%eax
80103dd1:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103dd7:	85 c0                	test   %eax,%eax
80103dd9:	75 25                	jne    80103e00 <pipeclose+0x85>
80103ddb:	8b 45 08             	mov    0x8(%ebp),%eax
80103dde:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103de4:	85 c0                	test   %eax,%eax
80103de6:	75 18                	jne    80103e00 <pipeclose+0x85>
    release(&p->lock);
80103de8:	8b 45 08             	mov    0x8(%ebp),%eax
80103deb:	89 04 24             	mov    %eax,(%esp)
80103dee:	e8 da 0f 00 00       	call   80104dcd <release>
    kfree((char*)p);
80103df3:	8b 45 08             	mov    0x8(%ebp),%eax
80103df6:	89 04 24             	mov    %eax,(%esp)
80103df9:	e8 68 ec ff ff       	call   80102a66 <kfree>
80103dfe:	eb 0b                	jmp    80103e0b <pipeclose+0x90>
  } else
    release(&p->lock);
80103e00:	8b 45 08             	mov    0x8(%ebp),%eax
80103e03:	89 04 24             	mov    %eax,(%esp)
80103e06:	e8 c2 0f 00 00       	call   80104dcd <release>
}
80103e0b:	c9                   	leave  
80103e0c:	c3                   	ret    

80103e0d <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103e0d:	55                   	push   %ebp
80103e0e:	89 e5                	mov    %esp,%ebp
80103e10:	53                   	push   %ebx
80103e11:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80103e14:	8b 45 08             	mov    0x8(%ebp),%eax
80103e17:	89 04 24             	mov    %eax,(%esp)
80103e1a:	e8 4c 0f 00 00       	call   80104d6b <acquire>
  for(i = 0; i < n; i++){
80103e1f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103e26:	e9 a6 00 00 00       	jmp    80103ed1 <pipewrite+0xc4>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
80103e2b:	8b 45 08             	mov    0x8(%ebp),%eax
80103e2e:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103e34:	85 c0                	test   %eax,%eax
80103e36:	74 0d                	je     80103e45 <pipewrite+0x38>
80103e38:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103e3e:	8b 40 24             	mov    0x24(%eax),%eax
80103e41:	85 c0                	test   %eax,%eax
80103e43:	74 15                	je     80103e5a <pipewrite+0x4d>
        release(&p->lock);
80103e45:	8b 45 08             	mov    0x8(%ebp),%eax
80103e48:	89 04 24             	mov    %eax,(%esp)
80103e4b:	e8 7d 0f 00 00       	call   80104dcd <release>
        return -1;
80103e50:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e55:	e9 9d 00 00 00       	jmp    80103ef7 <pipewrite+0xea>
      }
      wakeup(&p->nread);
80103e5a:	8b 45 08             	mov    0x8(%ebp),%eax
80103e5d:	05 34 02 00 00       	add    $0x234,%eax
80103e62:	89 04 24             	mov    %eax,(%esp)
80103e65:	e8 d3 0c 00 00       	call   80104b3d <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103e6a:	8b 45 08             	mov    0x8(%ebp),%eax
80103e6d:	8b 55 08             	mov    0x8(%ebp),%edx
80103e70:	81 c2 38 02 00 00    	add    $0x238,%edx
80103e76:	89 44 24 04          	mov    %eax,0x4(%esp)
80103e7a:	89 14 24             	mov    %edx,(%esp)
80103e7d:	e8 cf 0b 00 00       	call   80104a51 <sleep>
80103e82:	eb 01                	jmp    80103e85 <pipewrite+0x78>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103e84:	90                   	nop
80103e85:	8b 45 08             	mov    0x8(%ebp),%eax
80103e88:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80103e8e:	8b 45 08             	mov    0x8(%ebp),%eax
80103e91:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103e97:	05 00 02 00 00       	add    $0x200,%eax
80103e9c:	39 c2                	cmp    %eax,%edx
80103e9e:	74 8b                	je     80103e2b <pipewrite+0x1e>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103ea0:	8b 45 08             	mov    0x8(%ebp),%eax
80103ea3:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103ea9:	89 c3                	mov    %eax,%ebx
80103eab:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
80103eb1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103eb4:	03 55 0c             	add    0xc(%ebp),%edx
80103eb7:	0f b6 0a             	movzbl (%edx),%ecx
80103eba:	8b 55 08             	mov    0x8(%ebp),%edx
80103ebd:	88 4c 1a 34          	mov    %cl,0x34(%edx,%ebx,1)
80103ec1:	8d 50 01             	lea    0x1(%eax),%edx
80103ec4:	8b 45 08             	mov    0x8(%ebp),%eax
80103ec7:	89 90 38 02 00 00    	mov    %edx,0x238(%eax)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80103ecd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103ed1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ed4:	3b 45 10             	cmp    0x10(%ebp),%eax
80103ed7:	7c ab                	jl     80103e84 <pipewrite+0x77>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103ed9:	8b 45 08             	mov    0x8(%ebp),%eax
80103edc:	05 34 02 00 00       	add    $0x234,%eax
80103ee1:	89 04 24             	mov    %eax,(%esp)
80103ee4:	e8 54 0c 00 00       	call   80104b3d <wakeup>
  release(&p->lock);
80103ee9:	8b 45 08             	mov    0x8(%ebp),%eax
80103eec:	89 04 24             	mov    %eax,(%esp)
80103eef:	e8 d9 0e 00 00       	call   80104dcd <release>
  return n;
80103ef4:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103ef7:	83 c4 24             	add    $0x24,%esp
80103efa:	5b                   	pop    %ebx
80103efb:	5d                   	pop    %ebp
80103efc:	c3                   	ret    

80103efd <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103efd:	55                   	push   %ebp
80103efe:	89 e5                	mov    %esp,%ebp
80103f00:	53                   	push   %ebx
80103f01:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80103f04:	8b 45 08             	mov    0x8(%ebp),%eax
80103f07:	89 04 24             	mov    %eax,(%esp)
80103f0a:	e8 5c 0e 00 00       	call   80104d6b <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103f0f:	eb 3a                	jmp    80103f4b <piperead+0x4e>
    if(proc->killed){
80103f11:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103f17:	8b 40 24             	mov    0x24(%eax),%eax
80103f1a:	85 c0                	test   %eax,%eax
80103f1c:	74 15                	je     80103f33 <piperead+0x36>
      release(&p->lock);
80103f1e:	8b 45 08             	mov    0x8(%ebp),%eax
80103f21:	89 04 24             	mov    %eax,(%esp)
80103f24:	e8 a4 0e 00 00       	call   80104dcd <release>
      return -1;
80103f29:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f2e:	e9 b6 00 00 00       	jmp    80103fe9 <piperead+0xec>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103f33:	8b 45 08             	mov    0x8(%ebp),%eax
80103f36:	8b 55 08             	mov    0x8(%ebp),%edx
80103f39:	81 c2 34 02 00 00    	add    $0x234,%edx
80103f3f:	89 44 24 04          	mov    %eax,0x4(%esp)
80103f43:	89 14 24             	mov    %edx,(%esp)
80103f46:	e8 06 0b 00 00       	call   80104a51 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103f4b:	8b 45 08             	mov    0x8(%ebp),%eax
80103f4e:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103f54:	8b 45 08             	mov    0x8(%ebp),%eax
80103f57:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103f5d:	39 c2                	cmp    %eax,%edx
80103f5f:	75 0d                	jne    80103f6e <piperead+0x71>
80103f61:	8b 45 08             	mov    0x8(%ebp),%eax
80103f64:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103f6a:	85 c0                	test   %eax,%eax
80103f6c:	75 a3                	jne    80103f11 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103f6e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103f75:	eb 49                	jmp    80103fc0 <piperead+0xc3>
    if(p->nread == p->nwrite)
80103f77:	8b 45 08             	mov    0x8(%ebp),%eax
80103f7a:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103f80:	8b 45 08             	mov    0x8(%ebp),%eax
80103f83:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103f89:	39 c2                	cmp    %eax,%edx
80103f8b:	74 3d                	je     80103fca <piperead+0xcd>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103f8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f90:	89 c2                	mov    %eax,%edx
80103f92:	03 55 0c             	add    0xc(%ebp),%edx
80103f95:	8b 45 08             	mov    0x8(%ebp),%eax
80103f98:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103f9e:	89 c3                	mov    %eax,%ebx
80103fa0:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
80103fa6:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103fa9:	0f b6 4c 19 34       	movzbl 0x34(%ecx,%ebx,1),%ecx
80103fae:	88 0a                	mov    %cl,(%edx)
80103fb0:	8d 50 01             	lea    0x1(%eax),%edx
80103fb3:	8b 45 08             	mov    0x8(%ebp),%eax
80103fb6:	89 90 34 02 00 00    	mov    %edx,0x234(%eax)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103fbc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103fc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fc3:	3b 45 10             	cmp    0x10(%ebp),%eax
80103fc6:	7c af                	jl     80103f77 <piperead+0x7a>
80103fc8:	eb 01                	jmp    80103fcb <piperead+0xce>
    if(p->nread == p->nwrite)
      break;
80103fca:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103fcb:	8b 45 08             	mov    0x8(%ebp),%eax
80103fce:	05 38 02 00 00       	add    $0x238,%eax
80103fd3:	89 04 24             	mov    %eax,(%esp)
80103fd6:	e8 62 0b 00 00       	call   80104b3d <wakeup>
  release(&p->lock);
80103fdb:	8b 45 08             	mov    0x8(%ebp),%eax
80103fde:	89 04 24             	mov    %eax,(%esp)
80103fe1:	e8 e7 0d 00 00       	call   80104dcd <release>
  return i;
80103fe6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103fe9:	83 c4 24             	add    $0x24,%esp
80103fec:	5b                   	pop    %ebx
80103fed:	5d                   	pop    %ebp
80103fee:	c3                   	ret    
	...

80103ff0 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80103ff0:	55                   	push   %ebp
80103ff1:	89 e5                	mov    %esp,%ebp
80103ff3:	53                   	push   %ebx
80103ff4:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103ff7:	9c                   	pushf  
80103ff8:	5b                   	pop    %ebx
80103ff9:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80103ffc:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103fff:	83 c4 10             	add    $0x10,%esp
80104002:	5b                   	pop    %ebx
80104003:	5d                   	pop    %ebp
80104004:	c3                   	ret    

80104005 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104005:	55                   	push   %ebp
80104006:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104008:	fb                   	sti    
}
80104009:	5d                   	pop    %ebp
8010400a:	c3                   	ret    

8010400b <up>:
static void wakeup1(void *chan);


int
up(struct proc *p)
{
8010400b:	55                   	push   %ebp
8010400c:	89 e5                	mov    %esp,%ebp
8010400e:	83 ec 28             	sub    $0x28,%esp
  int aux = ((p->current_level >0) ? p->current_level-1 : p->current_level);
80104011:	8b 45 08             	mov    0x8(%ebp),%eax
80104014:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
8010401a:	85 c0                	test   %eax,%eax
8010401c:	7e 0e                	jle    8010402c <up+0x21>
8010401e:	8b 45 08             	mov    0x8(%ebp),%eax
80104021:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80104027:	83 e8 01             	sub    $0x1,%eax
8010402a:	eb 09                	jmp    80104035 <up+0x2a>
8010402c:	8b 45 08             	mov    0x8(%ebp),%eax
8010402f:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80104035:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cprintf("UP al proceso '%s' al level %d \n",p->name,aux);
80104038:	8b 45 08             	mov    0x8(%ebp),%eax
8010403b:	8d 50 6c             	lea    0x6c(%eax),%edx
8010403e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104041:	89 44 24 08          	mov    %eax,0x8(%esp)
80104045:	89 54 24 04          	mov    %edx,0x4(%esp)
80104049:	c7 04 24 6c 86 10 80 	movl   $0x8010866c,(%esp)
80104050:	e8 4c c3 ff ff       	call   801003a1 <cprintf>
  return aux;
80104055:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104058:	c9                   	leave  
80104059:	c3                   	ret    

8010405a <down>:

int
down(struct proc *p)
{
8010405a:	55                   	push   %ebp
8010405b:	89 e5                	mov    %esp,%ebp
8010405d:	83 ec 28             	sub    $0x28,%esp
  int aux = ((p->current_level < 3)?p->current_level+1 : p->current_level);
80104060:	8b 45 08             	mov    0x8(%ebp),%eax
80104063:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80104069:	83 f8 02             	cmp    $0x2,%eax
8010406c:	7f 0e                	jg     8010407c <down+0x22>
8010406e:	8b 45 08             	mov    0x8(%ebp),%eax
80104071:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80104077:	83 c0 01             	add    $0x1,%eax
8010407a:	eb 09                	jmp    80104085 <down+0x2b>
8010407c:	8b 45 08             	mov    0x8(%ebp),%eax
8010407f:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80104085:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cprintf("DOWN al proceso '%s' al level %d \n",p->name,aux);
80104088:	8b 45 08             	mov    0x8(%ebp),%eax
8010408b:	8d 50 6c             	lea    0x6c(%eax),%edx
8010408e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104091:	89 44 24 08          	mov    %eax,0x8(%esp)
80104095:	89 54 24 04          	mov    %edx,0x4(%esp)
80104099:	c7 04 24 90 86 10 80 	movl   $0x80108690,(%esp)
801040a0:	e8 fc c2 ff ff       	call   801003a1 <cprintf>
  return aux;
801040a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801040a8:	c9                   	leave  
801040a9:	c3                   	ret    

801040aa <encolar>:

static void
encolar(struct proc *p,int level)
{
801040aa:	55                   	push   %ebp
801040ab:	89 e5                	mov    %esp,%ebp
  if( ptable.mlf[level].first == 0)
801040ad:	8b 45 0c             	mov    0xc(%ebp),%eax
801040b0:	05 46 04 00 00       	add    $0x446,%eax
801040b5:	8b 04 c5 24 ff 10 80 	mov    -0x7fef00dc(,%eax,8),%eax
801040bc:	85 c0                	test   %eax,%eax
801040be:	75 34                	jne    801040f4 <encolar+0x4a>
  {
    ptable.mlf[level].last = p;   
801040c0:	8b 45 0c             	mov    0xc(%ebp),%eax
801040c3:	8d 90 46 04 00 00    	lea    0x446(%eax),%edx
801040c9:	8b 45 08             	mov    0x8(%ebp),%eax
801040cc:	89 04 d5 28 ff 10 80 	mov    %eax,-0x7fef00d8(,%edx,8)
    ptable.mlf[level].first = p;  
801040d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801040d6:	8d 90 46 04 00 00    	lea    0x446(%eax),%edx
801040dc:	8b 45 08             	mov    0x8(%ebp),%eax
801040df:	89 04 d5 24 ff 10 80 	mov    %eax,-0x7fef00dc(,%edx,8)
	p->current_level = level;
801040e6:	8b 45 08             	mov    0x8(%ebp),%eax
801040e9:	8b 55 0c             	mov    0xc(%ebp),%edx
801040ec:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
801040f2:	eb 37                	jmp    8010412b <encolar+0x81>
//    cprintf("Primer elemento en ptable.proc del nivel %d   \n",level);
  }
  else
  {
    ptable.mlf[level].last->next = p; 
801040f4:	8b 45 0c             	mov    0xc(%ebp),%eax
801040f7:	05 46 04 00 00       	add    $0x446,%eax
801040fc:	8b 04 c5 28 ff 10 80 	mov    -0x7fef00d8(,%eax,8),%eax
80104103:	8b 55 08             	mov    0x8(%ebp),%edx
80104106:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
    ptable.mlf[level].last = p;   
8010410c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010410f:	8d 90 46 04 00 00    	lea    0x446(%eax),%edx
80104115:	8b 45 08             	mov    0x8(%ebp),%eax
80104118:	89 04 d5 28 ff 10 80 	mov    %eax,-0x7fef00d8(,%edx,8)
	p->current_level = level;
8010411f:	8b 45 08             	mov    0x8(%ebp),%eax
80104122:	8b 55 0c             	mov    0xc(%ebp),%edx
80104125:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
//    cprintf("Encole un proceso en ptable.proc de nivel %d   \n",level);
  }
}
8010412b:	5d                   	pop    %ebp
8010412c:	c3                   	ret    

8010412d <desencolar>:

static void
desencolar(struct proc *p)
{
8010412d:	55                   	push   %ebp
8010412e:	89 e5                	mov    %esp,%ebp
  if(ptable.mlf[p->current_level].last->pid ==ptable.mlf[p->current_level].first->pid)
80104130:	8b 45 08             	mov    0x8(%ebp),%eax
80104133:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80104139:	05 46 04 00 00       	add    $0x446,%eax
8010413e:	8b 04 c5 28 ff 10 80 	mov    -0x7fef00d8(,%eax,8),%eax
80104145:	8b 50 10             	mov    0x10(%eax),%edx
80104148:	8b 45 08             	mov    0x8(%ebp),%eax
8010414b:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80104151:	05 46 04 00 00       	add    $0x446,%eax
80104156:	8b 04 c5 24 ff 10 80 	mov    -0x7fef00dc(,%eax,8),%eax
8010415d:	8b 40 10             	mov    0x10(%eax),%eax
80104160:	39 c2                	cmp    %eax,%edx
80104162:	75 34                	jne    80104198 <desencolar+0x6b>
  {
    ptable.mlf[p->current_level].last = 0;
80104164:	8b 45 08             	mov    0x8(%ebp),%eax
80104167:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
8010416d:	05 46 04 00 00       	add    $0x446,%eax
80104172:	c7 04 c5 28 ff 10 80 	movl   $0x0,-0x7fef00d8(,%eax,8)
80104179:	00 00 00 00 
    ptable.mlf[p->current_level].first = 0;
8010417d:	8b 45 08             	mov    0x8(%ebp),%eax
80104180:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80104186:	05 46 04 00 00       	add    $0x446,%eax
8010418b:	c7 04 c5 24 ff 10 80 	movl   $0x0,-0x7fef00dc(,%eax,8)
80104192:	00 00 00 00 
80104196:	eb 1f                	jmp    801041b7 <desencolar+0x8a>
//    cprintf("Desencole el proceso de ptable.proc %s   \n",p->name);
  }
  else
  {
    ptable.mlf[p->current_level].first = p->next;
80104198:	8b 45 08             	mov    0x8(%ebp),%eax
8010419b:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
801041a1:	8b 45 08             	mov    0x8(%ebp),%eax
801041a4:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801041aa:	81 c2 46 04 00 00    	add    $0x446,%edx
801041b0:	89 04 d5 24 ff 10 80 	mov    %eax,-0x7fef00dc(,%edx,8)
//    cprintf("Desencole el proceso de ptable.proc %s   \n",p->name);
  }
}
801041b7:	5d                   	pop    %ebp
801041b8:	c3                   	ret    

801041b9 <make_runnable>:

static void 
make_runnable(struct proc *p,int level)
{
801041b9:	55                   	push   %ebp
801041ba:	89 e5                	mov    %esp,%ebp
801041bc:	83 ec 08             	sub    $0x8,%esp
  encolar(p,level);
801041bf:	8b 45 0c             	mov    0xc(%ebp),%eax
801041c2:	89 44 24 04          	mov    %eax,0x4(%esp)
801041c6:	8b 45 08             	mov    0x8(%ebp),%eax
801041c9:	89 04 24             	mov    %eax,(%esp)
801041cc:	e8 d9 fe ff ff       	call   801040aa <encolar>
  p->state= RUNNABLE;
801041d1:	8b 45 08             	mov    0x8(%ebp),%eax
801041d4:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
801041db:	c9                   	leave  
801041dc:	c3                   	ret    

801041dd <make_running>:

static void 
make_running(struct proc *p)
{
801041dd:	55                   	push   %ebp
801041de:	89 e5                	mov    %esp,%ebp
801041e0:	83 ec 04             	sub    $0x4,%esp
  desencolar(p);
801041e3:	8b 45 08             	mov    0x8(%ebp),%eax
801041e6:	89 04 24             	mov    %eax,(%esp)
801041e9:	e8 3f ff ff ff       	call   8010412d <desencolar>
  p->state= RUNNING;
801041ee:	8b 45 08             	mov    0x8(%ebp),%eax
801041f1:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
}
801041f8:	c9                   	leave  
801041f9:	c3                   	ret    

801041fa <pinit>:

void
pinit(void)
{
801041fa:	55                   	push   %ebp
801041fb:	89 e5                	mov    %esp,%ebp
801041fd:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80104200:	c7 44 24 04 b3 86 10 	movl   $0x801086b3,0x4(%esp)
80104207:	80 
80104208:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
8010420f:	e8 36 0b 00 00       	call   80104d4a <initlock>
}
80104214:	c9                   	leave  
80104215:	c3                   	ret    

80104216 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104216:	55                   	push   %ebp
80104217:	89 e5                	mov    %esp,%ebp
80104219:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
8010421c:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
80104223:	e8 43 0b 00 00       	call   80104d6b <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104228:	c7 45 f4 54 ff 10 80 	movl   $0x8010ff54,-0xc(%ebp)
8010422f:	eb 11                	jmp    80104242 <allocproc+0x2c>
    if(p->state == UNUSED)
80104231:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104234:	8b 40 0c             	mov    0xc(%eax),%eax
80104237:	85 c0                	test   %eax,%eax
80104239:	74 26                	je     80104261 <allocproc+0x4b>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010423b:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104242:	81 7d f4 54 21 11 80 	cmpl   $0x80112154,-0xc(%ebp)
80104249:	72 e6                	jb     80104231 <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
8010424b:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
80104252:	e8 76 0b 00 00       	call   80104dcd <release>
  return 0;
80104257:	b8 00 00 00 00       	mov    $0x0,%eax
8010425c:	e9 b5 00 00 00       	jmp    80104316 <allocproc+0x100>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
80104261:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
80104262:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104265:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
8010426c:	a1 04 b0 10 80       	mov    0x8010b004,%eax
80104271:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104274:	89 42 10             	mov    %eax,0x10(%edx)
80104277:	83 c0 01             	add    $0x1,%eax
8010427a:	a3 04 b0 10 80       	mov    %eax,0x8010b004
  release(&ptable.lock);
8010427f:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
80104286:	e8 42 0b 00 00       	call   80104dcd <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
8010428b:	e8 6f e8 ff ff       	call   80102aff <kalloc>
80104290:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104293:	89 42 08             	mov    %eax,0x8(%edx)
80104296:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104299:	8b 40 08             	mov    0x8(%eax),%eax
8010429c:	85 c0                	test   %eax,%eax
8010429e:	75 11                	jne    801042b1 <allocproc+0x9b>
    p->state = UNUSED;
801042a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042a3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
801042aa:	b8 00 00 00 00       	mov    $0x0,%eax
801042af:	eb 65                	jmp    80104316 <allocproc+0x100>
  }
  sp = p->kstack + KSTACKSIZE;
801042b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042b4:	8b 40 08             	mov    0x8(%eax),%eax
801042b7:	05 00 10 00 00       	add    $0x1000,%eax
801042bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801042bf:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
801042c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042c6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801042c9:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
801042cc:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
801042d0:	ba 04 64 10 80       	mov    $0x80106404,%edx
801042d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801042d8:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
801042da:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
801042de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042e1:	8b 55 f0             	mov    -0x10(%ebp),%edx
801042e4:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
801042e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042ea:	8b 40 1c             	mov    0x1c(%eax),%eax
801042ed:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801042f4:	00 
801042f5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801042fc:	00 
801042fd:	89 04 24             	mov    %eax,(%esp)
80104300:	e8 b5 0c 00 00       	call   80104fba <memset>
  p->context->eip = (uint)forkret;
80104305:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104308:	8b 40 1c             	mov    0x1c(%eax),%eax
8010430b:	ba 25 4a 10 80       	mov    $0x80104a25,%edx
80104310:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80104313:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104316:	c9                   	leave  
80104317:	c3                   	ret    

80104318 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104318:	55                   	push   %ebp
80104319:	89 e5                	mov    %esp,%ebp
8010431b:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
8010431e:	e8 f3 fe ff ff       	call   80104216 <allocproc>
80104323:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
80104326:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104329:	a3 48 b6 10 80       	mov    %eax,0x8010b648
  if((p->pgdir = setupkvm(kalloc)) == 0)
8010432e:	c7 04 24 ff 2a 10 80 	movl   $0x80102aff,(%esp)
80104335:	e8 13 38 00 00       	call   80107b4d <setupkvm>
8010433a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010433d:	89 42 04             	mov    %eax,0x4(%edx)
80104340:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104343:	8b 40 04             	mov    0x4(%eax),%eax
80104346:	85 c0                	test   %eax,%eax
80104348:	75 0c                	jne    80104356 <userinit+0x3e>
    panic("userinit: out of memory?");
8010434a:	c7 04 24 ba 86 10 80 	movl   $0x801086ba,(%esp)
80104351:	e8 e7 c1 ff ff       	call   8010053d <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104356:	ba 2c 00 00 00       	mov    $0x2c,%edx
8010435b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010435e:	8b 40 04             	mov    0x4(%eax),%eax
80104361:	89 54 24 08          	mov    %edx,0x8(%esp)
80104365:	c7 44 24 04 e0 b4 10 	movl   $0x8010b4e0,0x4(%esp)
8010436c:	80 
8010436d:	89 04 24             	mov    %eax,(%esp)
80104370:	e8 30 3a 00 00       	call   80107da5 <inituvm>
  p->sz = PGSIZE;
80104375:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104378:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
8010437e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104381:	8b 40 18             	mov    0x18(%eax),%eax
80104384:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
8010438b:	00 
8010438c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104393:	00 
80104394:	89 04 24             	mov    %eax,(%esp)
80104397:	e8 1e 0c 00 00       	call   80104fba <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010439c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010439f:	8b 40 18             	mov    0x18(%eax),%eax
801043a2:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801043a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ab:	8b 40 18             	mov    0x18(%eax),%eax
801043ae:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
801043b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043b7:	8b 40 18             	mov    0x18(%eax),%eax
801043ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043bd:	8b 52 18             	mov    0x18(%edx),%edx
801043c0:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801043c4:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801043c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043cb:	8b 40 18             	mov    0x18(%eax),%eax
801043ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043d1:	8b 52 18             	mov    0x18(%edx),%edx
801043d4:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801043d8:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801043dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043df:	8b 40 18             	mov    0x18(%eax),%eax
801043e2:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801043e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ec:	8b 40 18             	mov    0x18(%eax),%eax
801043ef:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801043f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043f9:	8b 40 18             	mov    0x18(%eax),%eax
801043fc:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104403:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104406:	83 c0 6c             	add    $0x6c,%eax
80104409:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104410:	00 
80104411:	c7 44 24 04 d3 86 10 	movl   $0x801086d3,0x4(%esp)
80104418:	80 
80104419:	89 04 24             	mov    %eax,(%esp)
8010441c:	e8 cd 0d 00 00       	call   801051ee <safestrcpy>
  p->cwd = namei("/");
80104421:	c7 04 24 dc 86 10 80 	movl   $0x801086dc,(%esp)
80104428:	e8 dd df ff ff       	call   8010240a <namei>
8010442d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104430:	89 42 68             	mov    %eax,0x68(%edx)

  make_runnable(p,0);
80104433:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010443a:	00 
8010443b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010443e:	89 04 24             	mov    %eax,(%esp)
80104441:	e8 73 fd ff ff       	call   801041b9 <make_runnable>
  //p->state = RUNNABLE;
}
80104446:	c9                   	leave  
80104447:	c3                   	ret    

80104448 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104448:	55                   	push   %ebp
80104449:	89 e5                	mov    %esp,%ebp
8010444b:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
8010444e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104454:	8b 00                	mov    (%eax),%eax
80104456:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104459:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010445d:	7e 34                	jle    80104493 <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
8010445f:	8b 45 08             	mov    0x8(%ebp),%eax
80104462:	89 c2                	mov    %eax,%edx
80104464:	03 55 f4             	add    -0xc(%ebp),%edx
80104467:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010446d:	8b 40 04             	mov    0x4(%eax),%eax
80104470:	89 54 24 08          	mov    %edx,0x8(%esp)
80104474:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104477:	89 54 24 04          	mov    %edx,0x4(%esp)
8010447b:	89 04 24             	mov    %eax,(%esp)
8010447e:	e8 9c 3a 00 00       	call   80107f1f <allocuvm>
80104483:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104486:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010448a:	75 41                	jne    801044cd <growproc+0x85>
      return -1;
8010448c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104491:	eb 58                	jmp    801044eb <growproc+0xa3>
  } else if(n < 0){
80104493:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104497:	79 34                	jns    801044cd <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104499:	8b 45 08             	mov    0x8(%ebp),%eax
8010449c:	89 c2                	mov    %eax,%edx
8010449e:	03 55 f4             	add    -0xc(%ebp),%edx
801044a1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801044a7:	8b 40 04             	mov    0x4(%eax),%eax
801044aa:	89 54 24 08          	mov    %edx,0x8(%esp)
801044ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044b1:	89 54 24 04          	mov    %edx,0x4(%esp)
801044b5:	89 04 24             	mov    %eax,(%esp)
801044b8:	e8 3c 3b 00 00       	call   80107ff9 <deallocuvm>
801044bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
801044c0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801044c4:	75 07                	jne    801044cd <growproc+0x85>
      return -1;
801044c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044cb:	eb 1e                	jmp    801044eb <growproc+0xa3>
  }
  proc->sz = sz;
801044cd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801044d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044d6:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
801044d8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801044de:	89 04 24             	mov    %eax,(%esp)
801044e1:	e8 58 37 00 00       	call   80107c3e <switchuvm>
  return 0;
801044e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801044eb:	c9                   	leave  
801044ec:	c3                   	ret    

801044ed <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
801044ed:	55                   	push   %ebp
801044ee:	89 e5                	mov    %esp,%ebp
801044f0:	57                   	push   %edi
801044f1:	56                   	push   %esi
801044f2:	53                   	push   %ebx
801044f3:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
801044f6:	e8 1b fd ff ff       	call   80104216 <allocproc>
801044fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
801044fe:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104502:	75 0a                	jne    8010450e <fork+0x21>
    return -1;
80104504:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104509:	e9 43 01 00 00       	jmp    80104651 <fork+0x164>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
8010450e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104514:	8b 10                	mov    (%eax),%edx
80104516:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010451c:	8b 40 04             	mov    0x4(%eax),%eax
8010451f:	89 54 24 04          	mov    %edx,0x4(%esp)
80104523:	89 04 24             	mov    %eax,(%esp)
80104526:	e8 5e 3c 00 00       	call   80108189 <copyuvm>
8010452b:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010452e:	89 42 04             	mov    %eax,0x4(%edx)
80104531:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104534:	8b 40 04             	mov    0x4(%eax),%eax
80104537:	85 c0                	test   %eax,%eax
80104539:	75 2c                	jne    80104567 <fork+0x7a>
    kfree(np->kstack);
8010453b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010453e:	8b 40 08             	mov    0x8(%eax),%eax
80104541:	89 04 24             	mov    %eax,(%esp)
80104544:	e8 1d e5 ff ff       	call   80102a66 <kfree>
    np->kstack = 0;
80104549:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010454c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104553:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104556:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
8010455d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104562:	e9 ea 00 00 00       	jmp    80104651 <fork+0x164>
  }
  np->sz = proc->sz;
80104567:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010456d:	8b 10                	mov    (%eax),%edx
8010456f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104572:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104574:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010457b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010457e:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80104581:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104584:	8b 50 18             	mov    0x18(%eax),%edx
80104587:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010458d:	8b 40 18             	mov    0x18(%eax),%eax
80104590:	89 c3                	mov    %eax,%ebx
80104592:	b8 13 00 00 00       	mov    $0x13,%eax
80104597:	89 d7                	mov    %edx,%edi
80104599:	89 de                	mov    %ebx,%esi
8010459b:	89 c1                	mov    %eax,%ecx
8010459d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
8010459f:	8b 45 e0             	mov    -0x20(%ebp),%eax
801045a2:	8b 40 18             	mov    0x18(%eax),%eax
801045a5:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
801045ac:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801045b3:	eb 3d                	jmp    801045f2 <fork+0x105>
    if(proc->ofile[i])
801045b5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045bb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801045be:	83 c2 08             	add    $0x8,%edx
801045c1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801045c5:	85 c0                	test   %eax,%eax
801045c7:	74 25                	je     801045ee <fork+0x101>
      np->ofile[i] = filedup(proc->ofile[i]);
801045c9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045cf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801045d2:	83 c2 08             	add    $0x8,%edx
801045d5:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801045d9:	89 04 24             	mov    %eax,(%esp)
801045dc:	e8 9b c9 ff ff       	call   80100f7c <filedup>
801045e1:	8b 55 e0             	mov    -0x20(%ebp),%edx
801045e4:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801045e7:	83 c1 08             	add    $0x8,%ecx
801045ea:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
801045ee:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801045f2:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801045f6:	7e bd                	jle    801045b5 <fork+0xc8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
801045f8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045fe:	8b 40 68             	mov    0x68(%eax),%eax
80104601:	89 04 24             	mov    %eax,(%esp)
80104604:	e8 2d d2 ff ff       	call   80101836 <idup>
80104609:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010460c:	89 42 68             	mov    %eax,0x68(%edx)
 
  pid = np->pid;
8010460f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104612:	8b 40 10             	mov    0x10(%eax),%eax
80104615:	89 45 dc             	mov    %eax,-0x24(%ebp)
  make_runnable(np,0);
80104618:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010461f:	00 
80104620:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104623:	89 04 24             	mov    %eax,(%esp)
80104626:	e8 8e fb ff ff       	call   801041b9 <make_runnable>
  //np->state = RUNNABLE;
  safestrcpy(np->name, proc->name, sizeof(proc->name));
8010462b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104631:	8d 50 6c             	lea    0x6c(%eax),%edx
80104634:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104637:	83 c0 6c             	add    $0x6c,%eax
8010463a:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104641:	00 
80104642:	89 54 24 04          	mov    %edx,0x4(%esp)
80104646:	89 04 24             	mov    %eax,(%esp)
80104649:	e8 a0 0b 00 00       	call   801051ee <safestrcpy>
  return pid;
8010464e:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80104651:	83 c4 2c             	add    $0x2c,%esp
80104654:	5b                   	pop    %ebx
80104655:	5e                   	pop    %esi
80104656:	5f                   	pop    %edi
80104657:	5d                   	pop    %ebp
80104658:	c3                   	ret    

80104659 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104659:	55                   	push   %ebp
8010465a:	89 e5                	mov    %esp,%ebp
8010465c:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
8010465f:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104666:	a1 48 b6 10 80       	mov    0x8010b648,%eax
8010466b:	39 c2                	cmp    %eax,%edx
8010466d:	75 0c                	jne    8010467b <exit+0x22>
    panic("init exiting");
8010466f:	c7 04 24 de 86 10 80 	movl   $0x801086de,(%esp)
80104676:	e8 c2 be ff ff       	call   8010053d <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010467b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104682:	eb 44                	jmp    801046c8 <exit+0x6f>
    if(proc->ofile[fd]){
80104684:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010468a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010468d:	83 c2 08             	add    $0x8,%edx
80104690:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104694:	85 c0                	test   %eax,%eax
80104696:	74 2c                	je     801046c4 <exit+0x6b>
      fileclose(proc->ofile[fd]);
80104698:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010469e:	8b 55 f0             	mov    -0x10(%ebp),%edx
801046a1:	83 c2 08             	add    $0x8,%edx
801046a4:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801046a8:	89 04 24             	mov    %eax,(%esp)
801046ab:	e8 14 c9 ff ff       	call   80100fc4 <fileclose>
      proc->ofile[fd] = 0;
801046b0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046b6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801046b9:	83 c2 08             	add    $0x8,%edx
801046bc:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801046c3:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801046c4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801046c8:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801046cc:	7e b6                	jle    80104684 <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  iput(proc->cwd);
801046ce:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046d4:	8b 40 68             	mov    0x68(%eax),%eax
801046d7:	89 04 24             	mov    %eax,(%esp)
801046da:	e8 3c d3 ff ff       	call   80101a1b <iput>
  proc->cwd = 0;
801046df:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046e5:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801046ec:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
801046f3:	e8 73 06 00 00       	call   80104d6b <acquire>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
801046f8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046fe:	8b 40 14             	mov    0x14(%eax),%eax
80104701:	89 04 24             	mov    %eax,(%esp)
80104704:	e8 e3 03 00 00       	call   80104aec <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104709:	c7 45 f4 54 ff 10 80 	movl   $0x8010ff54,-0xc(%ebp)
80104710:	eb 3b                	jmp    8010474d <exit+0xf4>
    if(p->parent == proc){
80104712:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104715:	8b 50 14             	mov    0x14(%eax),%edx
80104718:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010471e:	39 c2                	cmp    %eax,%edx
80104720:	75 24                	jne    80104746 <exit+0xed>
      p->parent = initproc;
80104722:	8b 15 48 b6 10 80    	mov    0x8010b648,%edx
80104728:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010472b:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
8010472e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104731:	8b 40 0c             	mov    0xc(%eax),%eax
80104734:	83 f8 05             	cmp    $0x5,%eax
80104737:	75 0d                	jne    80104746 <exit+0xed>
        wakeup1(initproc);
80104739:	a1 48 b6 10 80       	mov    0x8010b648,%eax
8010473e:	89 04 24             	mov    %eax,(%esp)
80104741:	e8 a6 03 00 00       	call   80104aec <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104746:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
8010474d:	81 7d f4 54 21 11 80 	cmpl   $0x80112154,-0xc(%ebp)
80104754:	72 bc                	jb     80104712 <exit+0xb9>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80104756:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010475c:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104763:	e8 c5 01 00 00       	call   8010492d <sched>
  panic("zombie exit");
80104768:	c7 04 24 eb 86 10 80 	movl   $0x801086eb,(%esp)
8010476f:	e8 c9 bd ff ff       	call   8010053d <panic>

80104774 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104774:	55                   	push   %ebp
80104775:	89 e5                	mov    %esp,%ebp
80104777:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
8010477a:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
80104781:	e8 e5 05 00 00       	call   80104d6b <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104786:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010478d:	c7 45 f4 54 ff 10 80 	movl   $0x8010ff54,-0xc(%ebp)
80104794:	e9 9d 00 00 00       	jmp    80104836 <wait+0xc2>
      if(p->parent != proc)
80104799:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010479c:	8b 50 14             	mov    0x14(%eax),%edx
8010479f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047a5:	39 c2                	cmp    %eax,%edx
801047a7:	0f 85 81 00 00 00    	jne    8010482e <wait+0xba>
        continue;
      havekids = 1;
801047ad:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801047b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047b7:	8b 40 0c             	mov    0xc(%eax),%eax
801047ba:	83 f8 05             	cmp    $0x5,%eax
801047bd:	75 70                	jne    8010482f <wait+0xbb>
        // Found one.
        pid = p->pid;
801047bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047c2:	8b 40 10             	mov    0x10(%eax),%eax
801047c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
801047c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047cb:	8b 40 08             	mov    0x8(%eax),%eax
801047ce:	89 04 24             	mov    %eax,(%esp)
801047d1:	e8 90 e2 ff ff       	call   80102a66 <kfree>
        p->kstack = 0;
801047d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047d9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801047e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047e3:	8b 40 04             	mov    0x4(%eax),%eax
801047e6:	89 04 24             	mov    %eax,(%esp)
801047e9:	e8 c7 38 00 00       	call   801080b5 <freevm>
        p->state = UNUSED;
801047ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047f1:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
801047f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047fb:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104802:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104805:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
8010480c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010480f:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104813:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104816:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
8010481d:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
80104824:	e8 a4 05 00 00       	call   80104dcd <release>
        return pid;
80104829:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010482c:	eb 56                	jmp    80104884 <wait+0x110>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
8010482e:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010482f:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104836:	81 7d f4 54 21 11 80 	cmpl   $0x80112154,-0xc(%ebp)
8010483d:	0f 82 56 ff ff ff    	jb     80104799 <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104843:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104847:	74 0d                	je     80104856 <wait+0xe2>
80104849:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010484f:	8b 40 24             	mov    0x24(%eax),%eax
80104852:	85 c0                	test   %eax,%eax
80104854:	74 13                	je     80104869 <wait+0xf5>
      release(&ptable.lock);
80104856:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
8010485d:	e8 6b 05 00 00       	call   80104dcd <release>
      return -1;
80104862:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104867:	eb 1b                	jmp    80104884 <wait+0x110>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104869:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010486f:	c7 44 24 04 20 ff 10 	movl   $0x8010ff20,0x4(%esp)
80104876:	80 
80104877:	89 04 24             	mov    %eax,(%esp)
8010487a:	e8 d2 01 00 00       	call   80104a51 <sleep>
  }
8010487f:	e9 02 ff ff ff       	jmp    80104786 <wait+0x12>
}
80104884:	c9                   	leave  
80104885:	c3                   	ret    

80104886 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104886:	55                   	push   %ebp
80104887:	89 e5                	mov    %esp,%ebp
80104889:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
8010488c:	e8 74 f7 ff ff       	call   80104005 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104891:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
80104898:	e8 ce 04 00 00       	call   80104d6b <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010489d:	c7 45 f4 54 ff 10 80 	movl   $0x8010ff54,-0xc(%ebp)
801048a4:	eb 6d                	jmp    80104913 <scheduler+0x8d>
      if(p->state != RUNNABLE)
801048a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048a9:	8b 40 0c             	mov    0xc(%eax),%eax
801048ac:	83 f8 03             	cmp    $0x3,%eax
801048af:	75 5a                	jne    8010490b <scheduler+0x85>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
801048b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048b4:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
801048ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048bd:	89 04 24             	mov    %eax,(%esp)
801048c0:	e8 79 33 00 00       	call   80107c3e <switchuvm>
      make_running(p);
801048c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048c8:	89 04 24             	mov    %eax,(%esp)
801048cb:	e8 0d f9 ff ff       	call   801041dd <make_running>
//      cprintf("El proceso %s pasa a RUNNING por SHEDULE \n",p->name);
      //p->state = RUNNING;
	  p->quantum = 0;
801048d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048d3:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)
      swtch(&cpu->scheduler, proc->context);
801048da:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048e0:	8b 40 1c             	mov    0x1c(%eax),%eax
801048e3:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801048ea:	83 c2 04             	add    $0x4,%edx
801048ed:	89 44 24 04          	mov    %eax,0x4(%esp)
801048f1:	89 14 24             	mov    %edx,(%esp)
801048f4:	e8 6b 09 00 00       	call   80105264 <swtch>
      switchkvm();
801048f9:	e8 23 33 00 00       	call   80107c21 <switchkvm>
	  // cprintf("%s  JOSE \n",p->quantum);
      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
801048fe:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104905:	00 00 00 00 
80104909:	eb 01                	jmp    8010490c <scheduler+0x86>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
8010490b:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010490c:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104913:	81 7d f4 54 21 11 80 	cmpl   $0x80112154,-0xc(%ebp)
8010491a:	72 8a                	jb     801048a6 <scheduler+0x20>
	  // cprintf("%s  JOSE \n",p->quantum);
      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
8010491c:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
80104923:	e8 a5 04 00 00       	call   80104dcd <release>

  }
80104928:	e9 5f ff ff ff       	jmp    8010488c <scheduler+0x6>

8010492d <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
8010492d:	55                   	push   %ebp
8010492e:	89 e5                	mov    %esp,%ebp
80104930:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
80104933:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
8010493a:	e8 4a 05 00 00       	call   80104e89 <holding>
8010493f:	85 c0                	test   %eax,%eax
80104941:	75 0c                	jne    8010494f <sched+0x22>
    panic("sched ptable.lock");
80104943:	c7 04 24 f7 86 10 80 	movl   $0x801086f7,(%esp)
8010494a:	e8 ee bb ff ff       	call   8010053d <panic>
  if(cpu->ncli != 1)
8010494f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104955:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010495b:	83 f8 01             	cmp    $0x1,%eax
8010495e:	74 0c                	je     8010496c <sched+0x3f>
    panic("sched locks");
80104960:	c7 04 24 09 87 10 80 	movl   $0x80108709,(%esp)
80104967:	e8 d1 bb ff ff       	call   8010053d <panic>
  if(proc->state == RUNNING)
8010496c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104972:	8b 40 0c             	mov    0xc(%eax),%eax
80104975:	83 f8 04             	cmp    $0x4,%eax
80104978:	75 0c                	jne    80104986 <sched+0x59>
    panic("sched running");
8010497a:	c7 04 24 15 87 10 80 	movl   $0x80108715,(%esp)
80104981:	e8 b7 bb ff ff       	call   8010053d <panic>
  if(readeflags()&FL_IF)
80104986:	e8 65 f6 ff ff       	call   80103ff0 <readeflags>
8010498b:	25 00 02 00 00       	and    $0x200,%eax
80104990:	85 c0                	test   %eax,%eax
80104992:	74 0c                	je     801049a0 <sched+0x73>
    panic("sched interruptible");
80104994:	c7 04 24 23 87 10 80 	movl   $0x80108723,(%esp)
8010499b:	e8 9d bb ff ff       	call   8010053d <panic>
  intena = cpu->intena;
801049a0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801049a6:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801049ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
801049af:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801049b5:	8b 40 04             	mov    0x4(%eax),%eax
801049b8:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801049bf:	83 c2 1c             	add    $0x1c,%edx
801049c2:	89 44 24 04          	mov    %eax,0x4(%esp)
801049c6:	89 14 24             	mov    %edx,(%esp)
801049c9:	e8 96 08 00 00       	call   80105264 <swtch>
  cpu->intena = intena;
801049ce:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801049d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801049d7:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
801049dd:	c9                   	leave  
801049de:	c3                   	ret    

801049df <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
801049df:	55                   	push   %ebp
801049e0:	89 e5                	mov    %esp,%ebp
801049e2:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801049e5:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
801049ec:	e8 7a 03 00 00       	call   80104d6b <acquire>
 // cprintf("El proceso %s pasa a RUNNABLE por YIELD \n",proc->name);
  make_runnable(proc,down(proc));//baja de nivel en la cola
801049f1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049f7:	89 04 24             	mov    %eax,(%esp)
801049fa:	e8 5b f6 ff ff       	call   8010405a <down>
801049ff:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104a06:	89 44 24 04          	mov    %eax,0x4(%esp)
80104a0a:	89 14 24             	mov    %edx,(%esp)
80104a0d:	e8 a7 f7 ff ff       	call   801041b9 <make_runnable>
  //proc->state = RUNNABLE;
  sched();
80104a12:	e8 16 ff ff ff       	call   8010492d <sched>
  release(&ptable.lock);
80104a17:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
80104a1e:	e8 aa 03 00 00       	call   80104dcd <release>
}
80104a23:	c9                   	leave  
80104a24:	c3                   	ret    

80104a25 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104a25:	55                   	push   %ebp
80104a26:	89 e5                	mov    %esp,%ebp
80104a28:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104a2b:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
80104a32:	e8 96 03 00 00       	call   80104dcd <release>

  if (first) {
80104a37:	a1 20 b0 10 80       	mov    0x8010b020,%eax
80104a3c:	85 c0                	test   %eax,%eax
80104a3e:	74 0f                	je     80104a4f <forkret+0x2a>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104a40:	c7 05 20 b0 10 80 00 	movl   $0x0,0x8010b020
80104a47:	00 00 00 
    initlog();
80104a4a:	e8 c1 e5 ff ff       	call   80103010 <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104a4f:	c9                   	leave  
80104a50:	c3                   	ret    

80104a51 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104a51:	55                   	push   %ebp
80104a52:	89 e5                	mov    %esp,%ebp
80104a54:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
80104a57:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a5d:	85 c0                	test   %eax,%eax
80104a5f:	75 0c                	jne    80104a6d <sleep+0x1c>
    panic("sleep");
80104a61:	c7 04 24 37 87 10 80 	movl   $0x80108737,(%esp)
80104a68:	e8 d0 ba ff ff       	call   8010053d <panic>

  if(lk == 0)
80104a6d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104a71:	75 0c                	jne    80104a7f <sleep+0x2e>
    panic("sleep without lk");
80104a73:	c7 04 24 3d 87 10 80 	movl   $0x8010873d,(%esp)
80104a7a:	e8 be ba ff ff       	call   8010053d <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104a7f:	81 7d 0c 20 ff 10 80 	cmpl   $0x8010ff20,0xc(%ebp)
80104a86:	74 17                	je     80104a9f <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104a88:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
80104a8f:	e8 d7 02 00 00       	call   80104d6b <acquire>
    release(lk);
80104a94:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a97:	89 04 24             	mov    %eax,(%esp)
80104a9a:	e8 2e 03 00 00       	call   80104dcd <release>
  }

  // Go to sleep.
  proc->chan = chan;
80104a9f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104aa5:	8b 55 08             	mov    0x8(%ebp),%edx
80104aa8:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104aab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ab1:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104ab8:	e8 70 fe ff ff       	call   8010492d <sched>

  // Tidy up.
  proc->chan = 0;
80104abd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ac3:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104aca:	81 7d 0c 20 ff 10 80 	cmpl   $0x8010ff20,0xc(%ebp)
80104ad1:	74 17                	je     80104aea <sleep+0x99>
    release(&ptable.lock);
80104ad3:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
80104ada:	e8 ee 02 00 00       	call   80104dcd <release>
    acquire(lk);
80104adf:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ae2:	89 04 24             	mov    %eax,(%esp)
80104ae5:	e8 81 02 00 00       	call   80104d6b <acquire>
  }
}
80104aea:	c9                   	leave  
80104aeb:	c3                   	ret    

80104aec <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104aec:	55                   	push   %ebp
80104aed:	89 e5                	mov    %esp,%ebp
80104aef:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104af2:	c7 45 f4 54 ff 10 80 	movl   $0x8010ff54,-0xc(%ebp)
80104af9:	eb 37                	jmp    80104b32 <wakeup1+0x46>
    if(p->state == SLEEPING && p->chan == chan)
80104afb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104afe:	8b 40 0c             	mov    0xc(%eax),%eax
80104b01:	83 f8 02             	cmp    $0x2,%eax
80104b04:	75 25                	jne    80104b2b <wakeup1+0x3f>
80104b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b09:	8b 40 20             	mov    0x20(%eax),%eax
80104b0c:	3b 45 08             	cmp    0x8(%ebp),%eax
80104b0f:	75 1a                	jne    80104b2b <wakeup1+0x3f>
    {
//      cprintf("El proceso %s pasa a RUNNABLE por WAKEUP \n",p->name);
      make_runnable(p,up(p));//Sube de nivel
80104b11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b14:	89 04 24             	mov    %eax,(%esp)
80104b17:	e8 ef f4 ff ff       	call   8010400b <up>
80104b1c:	89 44 24 04          	mov    %eax,0x4(%esp)
80104b20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b23:	89 04 24             	mov    %eax,(%esp)
80104b26:	e8 8e f6 ff ff       	call   801041b9 <make_runnable>
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104b2b:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104b32:	81 7d f4 54 21 11 80 	cmpl   $0x80112154,-0xc(%ebp)
80104b39:	72 c0                	jb     80104afb <wakeup1+0xf>
    {
//      cprintf("El proceso %s pasa a RUNNABLE por WAKEUP \n",p->name);
      make_runnable(p,up(p));//Sube de nivel
    }
      //p->state = RUNNABLE;
}
80104b3b:	c9                   	leave  
80104b3c:	c3                   	ret    

80104b3d <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104b3d:	55                   	push   %ebp
80104b3e:	89 e5                	mov    %esp,%ebp
80104b40:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104b43:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
80104b4a:	e8 1c 02 00 00       	call   80104d6b <acquire>
  wakeup1(chan);
80104b4f:	8b 45 08             	mov    0x8(%ebp),%eax
80104b52:	89 04 24             	mov    %eax,(%esp)
80104b55:	e8 92 ff ff ff       	call   80104aec <wakeup1>
  release(&ptable.lock);
80104b5a:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
80104b61:	e8 67 02 00 00       	call   80104dcd <release>
}
80104b66:	c9                   	leave  
80104b67:	c3                   	ret    

80104b68 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104b68:	55                   	push   %ebp
80104b69:	89 e5                	mov    %esp,%ebp
80104b6b:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104b6e:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
80104b75:	e8 f1 01 00 00       	call   80104d6b <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b7a:	c7 45 f4 54 ff 10 80 	movl   $0x8010ff54,-0xc(%ebp)
80104b81:	eb 68                	jmp    80104beb <kill+0x83>
    if(p->pid == pid){
80104b83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b86:	8b 40 10             	mov    0x10(%eax),%eax
80104b89:	3b 45 08             	cmp    0x8(%ebp),%eax
80104b8c:	75 56                	jne    80104be4 <kill+0x7c>
      p->killed = 1;
80104b8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b91:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104b98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b9b:	8b 40 0c             	mov    0xc(%eax),%eax
80104b9e:	83 f8 02             	cmp    $0x2,%eax
80104ba1:	75 2e                	jne    80104bd1 <kill+0x69>
      {
        cprintf("El proceso %s pasa a RUNNABLE por KILL \n",p->name);
80104ba3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ba6:	83 c0 6c             	add    $0x6c,%eax
80104ba9:	89 44 24 04          	mov    %eax,0x4(%esp)
80104bad:	c7 04 24 50 87 10 80 	movl   $0x80108750,(%esp)
80104bb4:	e8 e8 b7 ff ff       	call   801003a1 <cprintf>
        make_runnable(p,p->current_level);//Queda el nivel q estaba
80104bb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bbc:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80104bc2:	89 44 24 04          	mov    %eax,0x4(%esp)
80104bc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bc9:	89 04 24             	mov    %eax,(%esp)
80104bcc:	e8 e8 f5 ff ff       	call   801041b9 <make_runnable>
        //p->state = RUNNABLE;
      }
      release(&ptable.lock);
80104bd1:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
80104bd8:	e8 f0 01 00 00       	call   80104dcd <release>
      return 0;
80104bdd:	b8 00 00 00 00       	mov    $0x0,%eax
80104be2:	eb 21                	jmp    80104c05 <kill+0x9d>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104be4:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104beb:	81 7d f4 54 21 11 80 	cmpl   $0x80112154,-0xc(%ebp)
80104bf2:	72 8f                	jb     80104b83 <kill+0x1b>
      }
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104bf4:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
80104bfb:	e8 cd 01 00 00       	call   80104dcd <release>
  return -1;
80104c00:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104c05:	c9                   	leave  
80104c06:	c3                   	ret    

80104c07 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104c07:	55                   	push   %ebp
80104c08:	89 e5                	mov    %esp,%ebp
80104c0a:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c0d:	c7 45 f0 54 ff 10 80 	movl   $0x8010ff54,-0x10(%ebp)
80104c14:	e9 db 00 00 00       	jmp    80104cf4 <procdump+0xed>
    if(p->state == UNUSED)
80104c19:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c1c:	8b 40 0c             	mov    0xc(%eax),%eax
80104c1f:	85 c0                	test   %eax,%eax
80104c21:	0f 84 c5 00 00 00    	je     80104cec <procdump+0xe5>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104c27:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c2a:	8b 40 0c             	mov    0xc(%eax),%eax
80104c2d:	83 f8 05             	cmp    $0x5,%eax
80104c30:	77 23                	ja     80104c55 <procdump+0x4e>
80104c32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c35:	8b 40 0c             	mov    0xc(%eax),%eax
80104c38:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104c3f:	85 c0                	test   %eax,%eax
80104c41:	74 12                	je     80104c55 <procdump+0x4e>
      state = states[p->state];
80104c43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c46:	8b 40 0c             	mov    0xc(%eax),%eax
80104c49:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104c50:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104c53:	eb 07                	jmp    80104c5c <procdump+0x55>
    else
      state = "???";
80104c55:	c7 45 ec 79 87 10 80 	movl   $0x80108779,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104c5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c5f:	8d 50 6c             	lea    0x6c(%eax),%edx
80104c62:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c65:	8b 40 10             	mov    0x10(%eax),%eax
80104c68:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104c6c:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104c6f:	89 54 24 08          	mov    %edx,0x8(%esp)
80104c73:	89 44 24 04          	mov    %eax,0x4(%esp)
80104c77:	c7 04 24 7d 87 10 80 	movl   $0x8010877d,(%esp)
80104c7e:	e8 1e b7 ff ff       	call   801003a1 <cprintf>
    if(p->state == SLEEPING){
80104c83:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c86:	8b 40 0c             	mov    0xc(%eax),%eax
80104c89:	83 f8 02             	cmp    $0x2,%eax
80104c8c:	75 50                	jne    80104cde <procdump+0xd7>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104c8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c91:	8b 40 1c             	mov    0x1c(%eax),%eax
80104c94:	8b 40 0c             	mov    0xc(%eax),%eax
80104c97:	83 c0 08             	add    $0x8,%eax
80104c9a:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80104c9d:	89 54 24 04          	mov    %edx,0x4(%esp)
80104ca1:	89 04 24             	mov    %eax,(%esp)
80104ca4:	e8 73 01 00 00       	call   80104e1c <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104ca9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104cb0:	eb 1b                	jmp    80104ccd <procdump+0xc6>
        cprintf(" %p", pc[i]);
80104cb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cb5:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104cb9:	89 44 24 04          	mov    %eax,0x4(%esp)
80104cbd:	c7 04 24 86 87 10 80 	movl   $0x80108786,(%esp)
80104cc4:	e8 d8 b6 ff ff       	call   801003a1 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104cc9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104ccd:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104cd1:	7f 0b                	jg     80104cde <procdump+0xd7>
80104cd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cd6:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104cda:	85 c0                	test   %eax,%eax
80104cdc:	75 d4                	jne    80104cb2 <procdump+0xab>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104cde:	c7 04 24 8a 87 10 80 	movl   $0x8010878a,(%esp)
80104ce5:	e8 b7 b6 ff ff       	call   801003a1 <cprintf>
80104cea:	eb 01                	jmp    80104ced <procdump+0xe6>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80104cec:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ced:	81 45 f0 88 00 00 00 	addl   $0x88,-0x10(%ebp)
80104cf4:	81 7d f0 54 21 11 80 	cmpl   $0x80112154,-0x10(%ebp)
80104cfb:	0f 82 18 ff ff ff    	jb     80104c19 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104d01:	c9                   	leave  
80104d02:	c3                   	ret    
	...

80104d04 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104d04:	55                   	push   %ebp
80104d05:	89 e5                	mov    %esp,%ebp
80104d07:	53                   	push   %ebx
80104d08:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104d0b:	9c                   	pushf  
80104d0c:	5b                   	pop    %ebx
80104d0d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80104d10:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104d13:	83 c4 10             	add    $0x10,%esp
80104d16:	5b                   	pop    %ebx
80104d17:	5d                   	pop    %ebp
80104d18:	c3                   	ret    

80104d19 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80104d19:	55                   	push   %ebp
80104d1a:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104d1c:	fa                   	cli    
}
80104d1d:	5d                   	pop    %ebp
80104d1e:	c3                   	ret    

80104d1f <sti>:

static inline void
sti(void)
{
80104d1f:	55                   	push   %ebp
80104d20:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104d22:	fb                   	sti    
}
80104d23:	5d                   	pop    %ebp
80104d24:	c3                   	ret    

80104d25 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80104d25:	55                   	push   %ebp
80104d26:	89 e5                	mov    %esp,%ebp
80104d28:	53                   	push   %ebx
80104d29:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
80104d2c:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104d2f:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
80104d32:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104d35:	89 c3                	mov    %eax,%ebx
80104d37:	89 d8                	mov    %ebx,%eax
80104d39:	f0 87 02             	lock xchg %eax,(%edx)
80104d3c:	89 c3                	mov    %eax,%ebx
80104d3e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80104d41:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104d44:	83 c4 10             	add    $0x10,%esp
80104d47:	5b                   	pop    %ebx
80104d48:	5d                   	pop    %ebp
80104d49:	c3                   	ret    

80104d4a <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104d4a:	55                   	push   %ebp
80104d4b:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104d4d:	8b 45 08             	mov    0x8(%ebp),%eax
80104d50:	8b 55 0c             	mov    0xc(%ebp),%edx
80104d53:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104d56:	8b 45 08             	mov    0x8(%ebp),%eax
80104d59:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104d5f:	8b 45 08             	mov    0x8(%ebp),%eax
80104d62:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104d69:	5d                   	pop    %ebp
80104d6a:	c3                   	ret    

80104d6b <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104d6b:	55                   	push   %ebp
80104d6c:	89 e5                	mov    %esp,%ebp
80104d6e:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104d71:	e8 3d 01 00 00       	call   80104eb3 <pushcli>
  if(holding(lk))
80104d76:	8b 45 08             	mov    0x8(%ebp),%eax
80104d79:	89 04 24             	mov    %eax,(%esp)
80104d7c:	e8 08 01 00 00       	call   80104e89 <holding>
80104d81:	85 c0                	test   %eax,%eax
80104d83:	74 0c                	je     80104d91 <acquire+0x26>
    panic("acquire");
80104d85:	c7 04 24 b6 87 10 80 	movl   $0x801087b6,(%esp)
80104d8c:	e8 ac b7 ff ff       	call   8010053d <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80104d91:	90                   	nop
80104d92:	8b 45 08             	mov    0x8(%ebp),%eax
80104d95:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80104d9c:	00 
80104d9d:	89 04 24             	mov    %eax,(%esp)
80104da0:	e8 80 ff ff ff       	call   80104d25 <xchg>
80104da5:	85 c0                	test   %eax,%eax
80104da7:	75 e9                	jne    80104d92 <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80104da9:	8b 45 08             	mov    0x8(%ebp),%eax
80104dac:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104db3:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80104db6:	8b 45 08             	mov    0x8(%ebp),%eax
80104db9:	83 c0 0c             	add    $0xc,%eax
80104dbc:	89 44 24 04          	mov    %eax,0x4(%esp)
80104dc0:	8d 45 08             	lea    0x8(%ebp),%eax
80104dc3:	89 04 24             	mov    %eax,(%esp)
80104dc6:	e8 51 00 00 00       	call   80104e1c <getcallerpcs>
}
80104dcb:	c9                   	leave  
80104dcc:	c3                   	ret    

80104dcd <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104dcd:	55                   	push   %ebp
80104dce:	89 e5                	mov    %esp,%ebp
80104dd0:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80104dd3:	8b 45 08             	mov    0x8(%ebp),%eax
80104dd6:	89 04 24             	mov    %eax,(%esp)
80104dd9:	e8 ab 00 00 00       	call   80104e89 <holding>
80104dde:	85 c0                	test   %eax,%eax
80104de0:	75 0c                	jne    80104dee <release+0x21>
    panic("release");
80104de2:	c7 04 24 be 87 10 80 	movl   $0x801087be,(%esp)
80104de9:	e8 4f b7 ff ff       	call   8010053d <panic>

  lk->pcs[0] = 0;
80104dee:	8b 45 08             	mov    0x8(%ebp),%eax
80104df1:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104df8:	8b 45 08             	mov    0x8(%ebp),%eax
80104dfb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80104e02:	8b 45 08             	mov    0x8(%ebp),%eax
80104e05:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104e0c:	00 
80104e0d:	89 04 24             	mov    %eax,(%esp)
80104e10:	e8 10 ff ff ff       	call   80104d25 <xchg>

  popcli();
80104e15:	e8 e1 00 00 00       	call   80104efb <popcli>
}
80104e1a:	c9                   	leave  
80104e1b:	c3                   	ret    

80104e1c <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104e1c:	55                   	push   %ebp
80104e1d:	89 e5                	mov    %esp,%ebp
80104e1f:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80104e22:	8b 45 08             	mov    0x8(%ebp),%eax
80104e25:	83 e8 08             	sub    $0x8,%eax
80104e28:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104e2b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104e32:	eb 32                	jmp    80104e66 <getcallerpcs+0x4a>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104e34:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104e38:	74 47                	je     80104e81 <getcallerpcs+0x65>
80104e3a:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104e41:	76 3e                	jbe    80104e81 <getcallerpcs+0x65>
80104e43:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104e47:	74 38                	je     80104e81 <getcallerpcs+0x65>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104e49:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e4c:	c1 e0 02             	shl    $0x2,%eax
80104e4f:	03 45 0c             	add    0xc(%ebp),%eax
80104e52:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104e55:	8b 52 04             	mov    0x4(%edx),%edx
80104e58:	89 10                	mov    %edx,(%eax)
    ebp = (uint*)ebp[0]; // saved %ebp
80104e5a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e5d:	8b 00                	mov    (%eax),%eax
80104e5f:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80104e62:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104e66:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104e6a:	7e c8                	jle    80104e34 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80104e6c:	eb 13                	jmp    80104e81 <getcallerpcs+0x65>
    pcs[i] = 0;
80104e6e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e71:	c1 e0 02             	shl    $0x2,%eax
80104e74:	03 45 0c             	add    0xc(%ebp),%eax
80104e77:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80104e7d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104e81:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104e85:	7e e7                	jle    80104e6e <getcallerpcs+0x52>
    pcs[i] = 0;
}
80104e87:	c9                   	leave  
80104e88:	c3                   	ret    

80104e89 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104e89:	55                   	push   %ebp
80104e8a:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80104e8c:	8b 45 08             	mov    0x8(%ebp),%eax
80104e8f:	8b 00                	mov    (%eax),%eax
80104e91:	85 c0                	test   %eax,%eax
80104e93:	74 17                	je     80104eac <holding+0x23>
80104e95:	8b 45 08             	mov    0x8(%ebp),%eax
80104e98:	8b 50 08             	mov    0x8(%eax),%edx
80104e9b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104ea1:	39 c2                	cmp    %eax,%edx
80104ea3:	75 07                	jne    80104eac <holding+0x23>
80104ea5:	b8 01 00 00 00       	mov    $0x1,%eax
80104eaa:	eb 05                	jmp    80104eb1 <holding+0x28>
80104eac:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104eb1:	5d                   	pop    %ebp
80104eb2:	c3                   	ret    

80104eb3 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104eb3:	55                   	push   %ebp
80104eb4:	89 e5                	mov    %esp,%ebp
80104eb6:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80104eb9:	e8 46 fe ff ff       	call   80104d04 <readeflags>
80104ebe:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80104ec1:	e8 53 fe ff ff       	call   80104d19 <cli>
  if(cpu->ncli++ == 0)
80104ec6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104ecc:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80104ed2:	85 d2                	test   %edx,%edx
80104ed4:	0f 94 c1             	sete   %cl
80104ed7:	83 c2 01             	add    $0x1,%edx
80104eda:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80104ee0:	84 c9                	test   %cl,%cl
80104ee2:	74 15                	je     80104ef9 <pushcli+0x46>
    cpu->intena = eflags & FL_IF;
80104ee4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104eea:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104eed:	81 e2 00 02 00 00    	and    $0x200,%edx
80104ef3:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104ef9:	c9                   	leave  
80104efa:	c3                   	ret    

80104efb <popcli>:

void
popcli(void)
{
80104efb:	55                   	push   %ebp
80104efc:	89 e5                	mov    %esp,%ebp
80104efe:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
80104f01:	e8 fe fd ff ff       	call   80104d04 <readeflags>
80104f06:	25 00 02 00 00       	and    $0x200,%eax
80104f0b:	85 c0                	test   %eax,%eax
80104f0d:	74 0c                	je     80104f1b <popcli+0x20>
    panic("popcli - interruptible");
80104f0f:	c7 04 24 c6 87 10 80 	movl   $0x801087c6,(%esp)
80104f16:	e8 22 b6 ff ff       	call   8010053d <panic>
  if(--cpu->ncli < 0)
80104f1b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104f21:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80104f27:	83 ea 01             	sub    $0x1,%edx
80104f2a:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80104f30:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104f36:	85 c0                	test   %eax,%eax
80104f38:	79 0c                	jns    80104f46 <popcli+0x4b>
    panic("popcli");
80104f3a:	c7 04 24 dd 87 10 80 	movl   $0x801087dd,(%esp)
80104f41:	e8 f7 b5 ff ff       	call   8010053d <panic>
  if(cpu->ncli == 0 && cpu->intena)
80104f46:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104f4c:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104f52:	85 c0                	test   %eax,%eax
80104f54:	75 15                	jne    80104f6b <popcli+0x70>
80104f56:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104f5c:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104f62:	85 c0                	test   %eax,%eax
80104f64:	74 05                	je     80104f6b <popcli+0x70>
    sti();
80104f66:	e8 b4 fd ff ff       	call   80104d1f <sti>
}
80104f6b:	c9                   	leave  
80104f6c:	c3                   	ret    
80104f6d:	00 00                	add    %al,(%eax)
	...

80104f70 <stosb>:
80104f70:	55                   	push   %ebp
80104f71:	89 e5                	mov    %esp,%ebp
80104f73:	57                   	push   %edi
80104f74:	53                   	push   %ebx
80104f75:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104f78:	8b 55 10             	mov    0x10(%ebp),%edx
80104f7b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f7e:	89 cb                	mov    %ecx,%ebx
80104f80:	89 df                	mov    %ebx,%edi
80104f82:	89 d1                	mov    %edx,%ecx
80104f84:	fc                   	cld    
80104f85:	f3 aa                	rep stos %al,%es:(%edi)
80104f87:	89 ca                	mov    %ecx,%edx
80104f89:	89 fb                	mov    %edi,%ebx
80104f8b:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104f8e:	89 55 10             	mov    %edx,0x10(%ebp)
80104f91:	5b                   	pop    %ebx
80104f92:	5f                   	pop    %edi
80104f93:	5d                   	pop    %ebp
80104f94:	c3                   	ret    

80104f95 <stosl>:
80104f95:	55                   	push   %ebp
80104f96:	89 e5                	mov    %esp,%ebp
80104f98:	57                   	push   %edi
80104f99:	53                   	push   %ebx
80104f9a:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104f9d:	8b 55 10             	mov    0x10(%ebp),%edx
80104fa0:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fa3:	89 cb                	mov    %ecx,%ebx
80104fa5:	89 df                	mov    %ebx,%edi
80104fa7:	89 d1                	mov    %edx,%ecx
80104fa9:	fc                   	cld    
80104faa:	f3 ab                	rep stos %eax,%es:(%edi)
80104fac:	89 ca                	mov    %ecx,%edx
80104fae:	89 fb                	mov    %edi,%ebx
80104fb0:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104fb3:	89 55 10             	mov    %edx,0x10(%ebp)
80104fb6:	5b                   	pop    %ebx
80104fb7:	5f                   	pop    %edi
80104fb8:	5d                   	pop    %ebp
80104fb9:	c3                   	ret    

80104fba <memset>:
80104fba:	55                   	push   %ebp
80104fbb:	89 e5                	mov    %esp,%ebp
80104fbd:	83 ec 0c             	sub    $0xc,%esp
80104fc0:	8b 45 08             	mov    0x8(%ebp),%eax
80104fc3:	83 e0 03             	and    $0x3,%eax
80104fc6:	85 c0                	test   %eax,%eax
80104fc8:	75 49                	jne    80105013 <memset+0x59>
80104fca:	8b 45 10             	mov    0x10(%ebp),%eax
80104fcd:	83 e0 03             	and    $0x3,%eax
80104fd0:	85 c0                	test   %eax,%eax
80104fd2:	75 3f                	jne    80105013 <memset+0x59>
80104fd4:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
80104fdb:	8b 45 10             	mov    0x10(%ebp),%eax
80104fde:	c1 e8 02             	shr    $0x2,%eax
80104fe1:	89 c2                	mov    %eax,%edx
80104fe3:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fe6:	89 c1                	mov    %eax,%ecx
80104fe8:	c1 e1 18             	shl    $0x18,%ecx
80104feb:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fee:	c1 e0 10             	shl    $0x10,%eax
80104ff1:	09 c1                	or     %eax,%ecx
80104ff3:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ff6:	c1 e0 08             	shl    $0x8,%eax
80104ff9:	09 c8                	or     %ecx,%eax
80104ffb:	0b 45 0c             	or     0xc(%ebp),%eax
80104ffe:	89 54 24 08          	mov    %edx,0x8(%esp)
80105002:	89 44 24 04          	mov    %eax,0x4(%esp)
80105006:	8b 45 08             	mov    0x8(%ebp),%eax
80105009:	89 04 24             	mov    %eax,(%esp)
8010500c:	e8 84 ff ff ff       	call   80104f95 <stosl>
80105011:	eb 19                	jmp    8010502c <memset+0x72>
80105013:	8b 45 10             	mov    0x10(%ebp),%eax
80105016:	89 44 24 08          	mov    %eax,0x8(%esp)
8010501a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010501d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105021:	8b 45 08             	mov    0x8(%ebp),%eax
80105024:	89 04 24             	mov    %eax,(%esp)
80105027:	e8 44 ff ff ff       	call   80104f70 <stosb>
8010502c:	8b 45 08             	mov    0x8(%ebp),%eax
8010502f:	c9                   	leave  
80105030:	c3                   	ret    

80105031 <memcmp>:
80105031:	55                   	push   %ebp
80105032:	89 e5                	mov    %esp,%ebp
80105034:	83 ec 10             	sub    $0x10,%esp
80105037:	8b 45 08             	mov    0x8(%ebp),%eax
8010503a:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010503d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105040:	89 45 f8             	mov    %eax,-0x8(%ebp)
80105043:	eb 32                	jmp    80105077 <memcmp+0x46>
80105045:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105048:	0f b6 10             	movzbl (%eax),%edx
8010504b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010504e:	0f b6 00             	movzbl (%eax),%eax
80105051:	38 c2                	cmp    %al,%dl
80105053:	74 1a                	je     8010506f <memcmp+0x3e>
80105055:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105058:	0f b6 00             	movzbl (%eax),%eax
8010505b:	0f b6 d0             	movzbl %al,%edx
8010505e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105061:	0f b6 00             	movzbl (%eax),%eax
80105064:	0f b6 c0             	movzbl %al,%eax
80105067:	89 d1                	mov    %edx,%ecx
80105069:	29 c1                	sub    %eax,%ecx
8010506b:	89 c8                	mov    %ecx,%eax
8010506d:	eb 1c                	jmp    8010508b <memcmp+0x5a>
8010506f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105073:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105077:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010507b:	0f 95 c0             	setne  %al
8010507e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105082:	84 c0                	test   %al,%al
80105084:	75 bf                	jne    80105045 <memcmp+0x14>
80105086:	b8 00 00 00 00       	mov    $0x0,%eax
8010508b:	c9                   	leave  
8010508c:	c3                   	ret    

8010508d <memmove>:
8010508d:	55                   	push   %ebp
8010508e:	89 e5                	mov    %esp,%ebp
80105090:	83 ec 10             	sub    $0x10,%esp
80105093:	8b 45 0c             	mov    0xc(%ebp),%eax
80105096:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105099:	8b 45 08             	mov    0x8(%ebp),%eax
8010509c:	89 45 f8             	mov    %eax,-0x8(%ebp)
8010509f:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050a2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801050a5:	73 55                	jae    801050fc <memmove+0x6f>
801050a7:	8b 45 10             	mov    0x10(%ebp),%eax
801050aa:	8b 55 fc             	mov    -0x4(%ebp),%edx
801050ad:	8d 04 02             	lea    (%edx,%eax,1),%eax
801050b0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801050b3:	76 4a                	jbe    801050ff <memmove+0x72>
801050b5:	8b 45 10             	mov    0x10(%ebp),%eax
801050b8:	01 45 fc             	add    %eax,-0x4(%ebp)
801050bb:	8b 45 10             	mov    0x10(%ebp),%eax
801050be:	01 45 f8             	add    %eax,-0x8(%ebp)
801050c1:	eb 13                	jmp    801050d6 <memmove+0x49>
801050c3:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
801050c7:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801050cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050ce:	0f b6 10             	movzbl (%eax),%edx
801050d1:	8b 45 f8             	mov    -0x8(%ebp),%eax
801050d4:	88 10                	mov    %dl,(%eax)
801050d6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801050da:	0f 95 c0             	setne  %al
801050dd:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801050e1:	84 c0                	test   %al,%al
801050e3:	75 de                	jne    801050c3 <memmove+0x36>
801050e5:	eb 28                	jmp    8010510f <memmove+0x82>
801050e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050ea:	0f b6 10             	movzbl (%eax),%edx
801050ed:	8b 45 f8             	mov    -0x8(%ebp),%eax
801050f0:	88 10                	mov    %dl,(%eax)
801050f2:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801050f6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801050fa:	eb 04                	jmp    80105100 <memmove+0x73>
801050fc:	90                   	nop
801050fd:	eb 01                	jmp    80105100 <memmove+0x73>
801050ff:	90                   	nop
80105100:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105104:	0f 95 c0             	setne  %al
80105107:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010510b:	84 c0                	test   %al,%al
8010510d:	75 d8                	jne    801050e7 <memmove+0x5a>
8010510f:	8b 45 08             	mov    0x8(%ebp),%eax
80105112:	c9                   	leave  
80105113:	c3                   	ret    

80105114 <memcpy>:
80105114:	55                   	push   %ebp
80105115:	89 e5                	mov    %esp,%ebp
80105117:	83 ec 0c             	sub    $0xc,%esp
8010511a:	8b 45 10             	mov    0x10(%ebp),%eax
8010511d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105121:	8b 45 0c             	mov    0xc(%ebp),%eax
80105124:	89 44 24 04          	mov    %eax,0x4(%esp)
80105128:	8b 45 08             	mov    0x8(%ebp),%eax
8010512b:	89 04 24             	mov    %eax,(%esp)
8010512e:	e8 5a ff ff ff       	call   8010508d <memmove>
80105133:	c9                   	leave  
80105134:	c3                   	ret    

80105135 <strncmp>:
80105135:	55                   	push   %ebp
80105136:	89 e5                	mov    %esp,%ebp
80105138:	eb 0c                	jmp    80105146 <strncmp+0x11>
8010513a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010513e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105142:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
80105146:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010514a:	74 1a                	je     80105166 <strncmp+0x31>
8010514c:	8b 45 08             	mov    0x8(%ebp),%eax
8010514f:	0f b6 00             	movzbl (%eax),%eax
80105152:	84 c0                	test   %al,%al
80105154:	74 10                	je     80105166 <strncmp+0x31>
80105156:	8b 45 08             	mov    0x8(%ebp),%eax
80105159:	0f b6 10             	movzbl (%eax),%edx
8010515c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010515f:	0f b6 00             	movzbl (%eax),%eax
80105162:	38 c2                	cmp    %al,%dl
80105164:	74 d4                	je     8010513a <strncmp+0x5>
80105166:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010516a:	75 07                	jne    80105173 <strncmp+0x3e>
8010516c:	b8 00 00 00 00       	mov    $0x0,%eax
80105171:	eb 18                	jmp    8010518b <strncmp+0x56>
80105173:	8b 45 08             	mov    0x8(%ebp),%eax
80105176:	0f b6 00             	movzbl (%eax),%eax
80105179:	0f b6 d0             	movzbl %al,%edx
8010517c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010517f:	0f b6 00             	movzbl (%eax),%eax
80105182:	0f b6 c0             	movzbl %al,%eax
80105185:	89 d1                	mov    %edx,%ecx
80105187:	29 c1                	sub    %eax,%ecx
80105189:	89 c8                	mov    %ecx,%eax
8010518b:	5d                   	pop    %ebp
8010518c:	c3                   	ret    

8010518d <strncpy>:
8010518d:	55                   	push   %ebp
8010518e:	89 e5                	mov    %esp,%ebp
80105190:	83 ec 10             	sub    $0x10,%esp
80105193:	8b 45 08             	mov    0x8(%ebp),%eax
80105196:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105199:	90                   	nop
8010519a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010519e:	0f 9f c0             	setg   %al
801051a1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801051a5:	84 c0                	test   %al,%al
801051a7:	74 30                	je     801051d9 <strncpy+0x4c>
801051a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801051ac:	0f b6 10             	movzbl (%eax),%edx
801051af:	8b 45 08             	mov    0x8(%ebp),%eax
801051b2:	88 10                	mov    %dl,(%eax)
801051b4:	8b 45 08             	mov    0x8(%ebp),%eax
801051b7:	0f b6 00             	movzbl (%eax),%eax
801051ba:	84 c0                	test   %al,%al
801051bc:	0f 95 c0             	setne  %al
801051bf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801051c3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
801051c7:	84 c0                	test   %al,%al
801051c9:	75 cf                	jne    8010519a <strncpy+0xd>
801051cb:	eb 0d                	jmp    801051da <strncpy+0x4d>
801051cd:	8b 45 08             	mov    0x8(%ebp),%eax
801051d0:	c6 00 00             	movb   $0x0,(%eax)
801051d3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801051d7:	eb 01                	jmp    801051da <strncpy+0x4d>
801051d9:	90                   	nop
801051da:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801051de:	0f 9f c0             	setg   %al
801051e1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801051e5:	84 c0                	test   %al,%al
801051e7:	75 e4                	jne    801051cd <strncpy+0x40>
801051e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051ec:	c9                   	leave  
801051ed:	c3                   	ret    

801051ee <safestrcpy>:
801051ee:	55                   	push   %ebp
801051ef:	89 e5                	mov    %esp,%ebp
801051f1:	83 ec 10             	sub    $0x10,%esp
801051f4:	8b 45 08             	mov    0x8(%ebp),%eax
801051f7:	89 45 fc             	mov    %eax,-0x4(%ebp)
801051fa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801051fe:	7f 05                	jg     80105205 <safestrcpy+0x17>
80105200:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105203:	eb 35                	jmp    8010523a <safestrcpy+0x4c>
80105205:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105209:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010520d:	7e 22                	jle    80105231 <safestrcpy+0x43>
8010520f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105212:	0f b6 10             	movzbl (%eax),%edx
80105215:	8b 45 08             	mov    0x8(%ebp),%eax
80105218:	88 10                	mov    %dl,(%eax)
8010521a:	8b 45 08             	mov    0x8(%ebp),%eax
8010521d:	0f b6 00             	movzbl (%eax),%eax
80105220:	84 c0                	test   %al,%al
80105222:	0f 95 c0             	setne  %al
80105225:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105229:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
8010522d:	84 c0                	test   %al,%al
8010522f:	75 d4                	jne    80105205 <safestrcpy+0x17>
80105231:	8b 45 08             	mov    0x8(%ebp),%eax
80105234:	c6 00 00             	movb   $0x0,(%eax)
80105237:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010523a:	c9                   	leave  
8010523b:	c3                   	ret    

8010523c <strlen>:
8010523c:	55                   	push   %ebp
8010523d:	89 e5                	mov    %esp,%ebp
8010523f:	83 ec 10             	sub    $0x10,%esp
80105242:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105249:	eb 04                	jmp    8010524f <strlen+0x13>
8010524b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010524f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105252:	03 45 08             	add    0x8(%ebp),%eax
80105255:	0f b6 00             	movzbl (%eax),%eax
80105258:	84 c0                	test   %al,%al
8010525a:	75 ef                	jne    8010524b <strlen+0xf>
8010525c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010525f:	c9                   	leave  
80105260:	c3                   	ret    
80105261:	00 00                	add    %al,(%eax)
	...

80105264 <swtch>:
80105264:	8b 44 24 04          	mov    0x4(%esp),%eax
80105268:	8b 54 24 08          	mov    0x8(%esp),%edx
8010526c:	55                   	push   %ebp
8010526d:	53                   	push   %ebx
8010526e:	56                   	push   %esi
8010526f:	57                   	push   %edi
80105270:	89 20                	mov    %esp,(%eax)
80105272:	89 d4                	mov    %edx,%esp
80105274:	5f                   	pop    %edi
80105275:	5e                   	pop    %esi
80105276:	5b                   	pop    %ebx
80105277:	5d                   	pop    %ebp
80105278:	c3                   	ret    
80105279:	00 00                	add    %al,(%eax)
	...

8010527c <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
8010527c:	55                   	push   %ebp
8010527d:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
8010527f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105285:	8b 00                	mov    (%eax),%eax
80105287:	3b 45 08             	cmp    0x8(%ebp),%eax
8010528a:	76 12                	jbe    8010529e <fetchint+0x22>
8010528c:	8b 45 08             	mov    0x8(%ebp),%eax
8010528f:	8d 50 04             	lea    0x4(%eax),%edx
80105292:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105298:	8b 00                	mov    (%eax),%eax
8010529a:	39 c2                	cmp    %eax,%edx
8010529c:	76 07                	jbe    801052a5 <fetchint+0x29>
    return -1;
8010529e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052a3:	eb 0f                	jmp    801052b4 <fetchint+0x38>
  *ip = *(int*)(addr);
801052a5:	8b 45 08             	mov    0x8(%ebp),%eax
801052a8:	8b 10                	mov    (%eax),%edx
801052aa:	8b 45 0c             	mov    0xc(%ebp),%eax
801052ad:	89 10                	mov    %edx,(%eax)
  return 0;
801052af:	b8 00 00 00 00       	mov    $0x0,%eax
}
801052b4:	5d                   	pop    %ebp
801052b5:	c3                   	ret    

801052b6 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801052b6:	55                   	push   %ebp
801052b7:	89 e5                	mov    %esp,%ebp
801052b9:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
801052bc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052c2:	8b 00                	mov    (%eax),%eax
801052c4:	3b 45 08             	cmp    0x8(%ebp),%eax
801052c7:	77 07                	ja     801052d0 <fetchstr+0x1a>
    return -1;
801052c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052ce:	eb 48                	jmp    80105318 <fetchstr+0x62>
  *pp = (char*)addr;
801052d0:	8b 55 08             	mov    0x8(%ebp),%edx
801052d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801052d6:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
801052d8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052de:	8b 00                	mov    (%eax),%eax
801052e0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
801052e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801052e6:	8b 00                	mov    (%eax),%eax
801052e8:	89 45 fc             	mov    %eax,-0x4(%ebp)
801052eb:	eb 1e                	jmp    8010530b <fetchstr+0x55>
    if(*s == 0)
801052ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052f0:	0f b6 00             	movzbl (%eax),%eax
801052f3:	84 c0                	test   %al,%al
801052f5:	75 10                	jne    80105307 <fetchstr+0x51>
      return s - *pp;
801052f7:	8b 55 fc             	mov    -0x4(%ebp),%edx
801052fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801052fd:	8b 00                	mov    (%eax),%eax
801052ff:	89 d1                	mov    %edx,%ecx
80105301:	29 c1                	sub    %eax,%ecx
80105303:	89 c8                	mov    %ecx,%eax
80105305:	eb 11                	jmp    80105318 <fetchstr+0x62>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80105307:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010530b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010530e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105311:	72 da                	jb     801052ed <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80105313:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105318:	c9                   	leave  
80105319:	c3                   	ret    

8010531a <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010531a:	55                   	push   %ebp
8010531b:	89 e5                	mov    %esp,%ebp
8010531d:	83 ec 08             	sub    $0x8,%esp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105320:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105326:	8b 40 18             	mov    0x18(%eax),%eax
80105329:	8b 50 44             	mov    0x44(%eax),%edx
8010532c:	8b 45 08             	mov    0x8(%ebp),%eax
8010532f:	c1 e0 02             	shl    $0x2,%eax
80105332:	01 d0                	add    %edx,%eax
80105334:	8d 50 04             	lea    0x4(%eax),%edx
80105337:	8b 45 0c             	mov    0xc(%ebp),%eax
8010533a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010533e:	89 14 24             	mov    %edx,(%esp)
80105341:	e8 36 ff ff ff       	call   8010527c <fetchint>
}
80105346:	c9                   	leave  
80105347:	c3                   	ret    

80105348 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105348:	55                   	push   %ebp
80105349:	89 e5                	mov    %esp,%ebp
8010534b:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
8010534e:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105351:	89 44 24 04          	mov    %eax,0x4(%esp)
80105355:	8b 45 08             	mov    0x8(%ebp),%eax
80105358:	89 04 24             	mov    %eax,(%esp)
8010535b:	e8 ba ff ff ff       	call   8010531a <argint>
80105360:	85 c0                	test   %eax,%eax
80105362:	79 07                	jns    8010536b <argptr+0x23>
    return -1;
80105364:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105369:	eb 3d                	jmp    801053a8 <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
8010536b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010536e:	89 c2                	mov    %eax,%edx
80105370:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105376:	8b 00                	mov    (%eax),%eax
80105378:	39 c2                	cmp    %eax,%edx
8010537a:	73 16                	jae    80105392 <argptr+0x4a>
8010537c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010537f:	89 c2                	mov    %eax,%edx
80105381:	8b 45 10             	mov    0x10(%ebp),%eax
80105384:	01 c2                	add    %eax,%edx
80105386:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010538c:	8b 00                	mov    (%eax),%eax
8010538e:	39 c2                	cmp    %eax,%edx
80105390:	76 07                	jbe    80105399 <argptr+0x51>
    return -1;
80105392:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105397:	eb 0f                	jmp    801053a8 <argptr+0x60>
  *pp = (char*)i;
80105399:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010539c:	89 c2                	mov    %eax,%edx
8010539e:	8b 45 0c             	mov    0xc(%ebp),%eax
801053a1:	89 10                	mov    %edx,(%eax)
  return 0;
801053a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801053a8:	c9                   	leave  
801053a9:	c3                   	ret    

801053aa <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801053aa:	55                   	push   %ebp
801053ab:	89 e5                	mov    %esp,%ebp
801053ad:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
801053b0:	8d 45 fc             	lea    -0x4(%ebp),%eax
801053b3:	89 44 24 04          	mov    %eax,0x4(%esp)
801053b7:	8b 45 08             	mov    0x8(%ebp),%eax
801053ba:	89 04 24             	mov    %eax,(%esp)
801053bd:	e8 58 ff ff ff       	call   8010531a <argint>
801053c2:	85 c0                	test   %eax,%eax
801053c4:	79 07                	jns    801053cd <argstr+0x23>
    return -1;
801053c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053cb:	eb 12                	jmp    801053df <argstr+0x35>
  return fetchstr(addr, pp);
801053cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053d0:	8b 55 0c             	mov    0xc(%ebp),%edx
801053d3:	89 54 24 04          	mov    %edx,0x4(%esp)
801053d7:	89 04 24             	mov    %eax,(%esp)
801053da:	e8 d7 fe ff ff       	call   801052b6 <fetchstr>
}
801053df:	c9                   	leave  
801053e0:	c3                   	ret    

801053e1 <syscall>:
[SYS_procstat]   sys_procstat,
};

void
syscall(void)
{
801053e1:	55                   	push   %ebp
801053e2:	89 e5                	mov    %esp,%ebp
801053e4:	53                   	push   %ebx
801053e5:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
801053e8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053ee:	8b 40 18             	mov    0x18(%eax),%eax
801053f1:	8b 40 1c             	mov    0x1c(%eax),%eax
801053f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num >= 0 && num < SYS_open && syscalls[num]) {
801053f7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801053fb:	78 2e                	js     8010542b <syscall+0x4a>
801053fd:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
80105401:	7f 28                	jg     8010542b <syscall+0x4a>
80105403:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105406:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
8010540d:	85 c0                	test   %eax,%eax
8010540f:	74 1a                	je     8010542b <syscall+0x4a>
    proc->tf->eax = syscalls[num]();
80105411:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105417:	8b 58 18             	mov    0x18(%eax),%ebx
8010541a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010541d:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105424:	ff d0                	call   *%eax
80105426:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105429:	eb 73                	jmp    8010549e <syscall+0xbd>
  } else if (num >= SYS_open && num < NELEM(syscalls) && syscalls[num]) {
8010542b:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
8010542f:	7e 30                	jle    80105461 <syscall+0x80>
80105431:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105434:	83 f8 16             	cmp    $0x16,%eax
80105437:	77 28                	ja     80105461 <syscall+0x80>
80105439:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010543c:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105443:	85 c0                	test   %eax,%eax
80105445:	74 1a                	je     80105461 <syscall+0x80>
    proc->tf->eax = syscalls[num]();
80105447:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010544d:	8b 58 18             	mov    0x18(%eax),%ebx
80105450:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105453:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
8010545a:	ff d0                	call   *%eax
8010545c:	89 43 1c             	mov    %eax,0x1c(%ebx)
8010545f:	eb 3d                	jmp    8010549e <syscall+0xbd>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80105461:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105467:	8d 48 6c             	lea    0x6c(%eax),%ecx
8010546a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  if(num >= 0 && num < SYS_open && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else if (num >= SYS_open && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105470:	8b 40 10             	mov    0x10(%eax),%eax
80105473:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105476:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010547a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010547e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105482:	c7 04 24 e4 87 10 80 	movl   $0x801087e4,(%esp)
80105489:	e8 13 af ff ff       	call   801003a1 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
8010548e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105494:	8b 40 18             	mov    0x18(%eax),%eax
80105497:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
8010549e:	83 c4 24             	add    $0x24,%esp
801054a1:	5b                   	pop    %ebx
801054a2:	5d                   	pop    %ebp
801054a3:	c3                   	ret    

801054a4 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801054a4:	55                   	push   %ebp
801054a5:	89 e5                	mov    %esp,%ebp
801054a7:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801054aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
801054ad:	89 44 24 04          	mov    %eax,0x4(%esp)
801054b1:	8b 45 08             	mov    0x8(%ebp),%eax
801054b4:	89 04 24             	mov    %eax,(%esp)
801054b7:	e8 5e fe ff ff       	call   8010531a <argint>
801054bc:	85 c0                	test   %eax,%eax
801054be:	79 07                	jns    801054c7 <argfd+0x23>
    return -1;
801054c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054c5:	eb 50                	jmp    80105517 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
801054c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054ca:	85 c0                	test   %eax,%eax
801054cc:	78 21                	js     801054ef <argfd+0x4b>
801054ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054d1:	83 f8 0f             	cmp    $0xf,%eax
801054d4:	7f 19                	jg     801054ef <argfd+0x4b>
801054d6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054dc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801054df:	83 c2 08             	add    $0x8,%edx
801054e2:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801054e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801054e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801054ed:	75 07                	jne    801054f6 <argfd+0x52>
    return -1;
801054ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054f4:	eb 21                	jmp    80105517 <argfd+0x73>
  if(pfd)
801054f6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801054fa:	74 08                	je     80105504 <argfd+0x60>
    *pfd = fd;
801054fc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801054ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80105502:	89 10                	mov    %edx,(%eax)
  if(pf)
80105504:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105508:	74 08                	je     80105512 <argfd+0x6e>
    *pf = f;
8010550a:	8b 45 10             	mov    0x10(%ebp),%eax
8010550d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105510:	89 10                	mov    %edx,(%eax)
  return 0;
80105512:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105517:	c9                   	leave  
80105518:	c3                   	ret    

80105519 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105519:	55                   	push   %ebp
8010551a:	89 e5                	mov    %esp,%ebp
8010551c:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
8010551f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105526:	eb 30                	jmp    80105558 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80105528:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010552e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105531:	83 c2 08             	add    $0x8,%edx
80105534:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105538:	85 c0                	test   %eax,%eax
8010553a:	75 18                	jne    80105554 <fdalloc+0x3b>
      proc->ofile[fd] = f;
8010553c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105542:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105545:	8d 4a 08             	lea    0x8(%edx),%ecx
80105548:	8b 55 08             	mov    0x8(%ebp),%edx
8010554b:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
8010554f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105552:	eb 0f                	jmp    80105563 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105554:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105558:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
8010555c:	7e ca                	jle    80105528 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
8010555e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105563:	c9                   	leave  
80105564:	c3                   	ret    

80105565 <sys_dup>:

int
sys_dup(void)
{
80105565:	55                   	push   %ebp
80105566:	89 e5                	mov    %esp,%ebp
80105568:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
8010556b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010556e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105572:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105579:	00 
8010557a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105581:	e8 1e ff ff ff       	call   801054a4 <argfd>
80105586:	85 c0                	test   %eax,%eax
80105588:	79 07                	jns    80105591 <sys_dup+0x2c>
    return -1;
8010558a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010558f:	eb 29                	jmp    801055ba <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105591:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105594:	89 04 24             	mov    %eax,(%esp)
80105597:	e8 7d ff ff ff       	call   80105519 <fdalloc>
8010559c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010559f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801055a3:	79 07                	jns    801055ac <sys_dup+0x47>
    return -1;
801055a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055aa:	eb 0e                	jmp    801055ba <sys_dup+0x55>
  filedup(f);
801055ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055af:	89 04 24             	mov    %eax,(%esp)
801055b2:	e8 c5 b9 ff ff       	call   80100f7c <filedup>
  return fd;
801055b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801055ba:	c9                   	leave  
801055bb:	c3                   	ret    

801055bc <sys_read>:

int
sys_read(void)
{
801055bc:	55                   	push   %ebp
801055bd:	89 e5                	mov    %esp,%ebp
801055bf:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801055c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801055c5:	89 44 24 08          	mov    %eax,0x8(%esp)
801055c9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801055d0:	00 
801055d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801055d8:	e8 c7 fe ff ff       	call   801054a4 <argfd>
801055dd:	85 c0                	test   %eax,%eax
801055df:	78 35                	js     80105616 <sys_read+0x5a>
801055e1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801055e4:	89 44 24 04          	mov    %eax,0x4(%esp)
801055e8:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801055ef:	e8 26 fd ff ff       	call   8010531a <argint>
801055f4:	85 c0                	test   %eax,%eax
801055f6:	78 1e                	js     80105616 <sys_read+0x5a>
801055f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055fb:	89 44 24 08          	mov    %eax,0x8(%esp)
801055ff:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105602:	89 44 24 04          	mov    %eax,0x4(%esp)
80105606:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010560d:	e8 36 fd ff ff       	call   80105348 <argptr>
80105612:	85 c0                	test   %eax,%eax
80105614:	79 07                	jns    8010561d <sys_read+0x61>
    return -1;
80105616:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010561b:	eb 19                	jmp    80105636 <sys_read+0x7a>
  return fileread(f, p, n);
8010561d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105620:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105623:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105626:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010562a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010562e:	89 04 24             	mov    %eax,(%esp)
80105631:	e8 b3 ba ff ff       	call   801010e9 <fileread>
}
80105636:	c9                   	leave  
80105637:	c3                   	ret    

80105638 <sys_write>:

int
sys_write(void)
{
80105638:	55                   	push   %ebp
80105639:	89 e5                	mov    %esp,%ebp
8010563b:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010563e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105641:	89 44 24 08          	mov    %eax,0x8(%esp)
80105645:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010564c:	00 
8010564d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105654:	e8 4b fe ff ff       	call   801054a4 <argfd>
80105659:	85 c0                	test   %eax,%eax
8010565b:	78 35                	js     80105692 <sys_write+0x5a>
8010565d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105660:	89 44 24 04          	mov    %eax,0x4(%esp)
80105664:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010566b:	e8 aa fc ff ff       	call   8010531a <argint>
80105670:	85 c0                	test   %eax,%eax
80105672:	78 1e                	js     80105692 <sys_write+0x5a>
80105674:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105677:	89 44 24 08          	mov    %eax,0x8(%esp)
8010567b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010567e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105682:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105689:	e8 ba fc ff ff       	call   80105348 <argptr>
8010568e:	85 c0                	test   %eax,%eax
80105690:	79 07                	jns    80105699 <sys_write+0x61>
    return -1;
80105692:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105697:	eb 19                	jmp    801056b2 <sys_write+0x7a>
  return filewrite(f, p, n);
80105699:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010569c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010569f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056a2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801056a6:	89 54 24 04          	mov    %edx,0x4(%esp)
801056aa:	89 04 24             	mov    %eax,(%esp)
801056ad:	e8 f3 ba ff ff       	call   801011a5 <filewrite>
}
801056b2:	c9                   	leave  
801056b3:	c3                   	ret    

801056b4 <sys_close>:

int
sys_close(void)
{
801056b4:	55                   	push   %ebp
801056b5:	89 e5                	mov    %esp,%ebp
801056b7:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
801056ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
801056bd:	89 44 24 08          	mov    %eax,0x8(%esp)
801056c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
801056c4:	89 44 24 04          	mov    %eax,0x4(%esp)
801056c8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801056cf:	e8 d0 fd ff ff       	call   801054a4 <argfd>
801056d4:	85 c0                	test   %eax,%eax
801056d6:	79 07                	jns    801056df <sys_close+0x2b>
    return -1;
801056d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056dd:	eb 24                	jmp    80105703 <sys_close+0x4f>
  proc->ofile[fd] = 0;
801056df:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801056e8:	83 c2 08             	add    $0x8,%edx
801056eb:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801056f2:	00 
  fileclose(f);
801056f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056f6:	89 04 24             	mov    %eax,(%esp)
801056f9:	e8 c6 b8 ff ff       	call   80100fc4 <fileclose>
  return 0;
801056fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105703:	c9                   	leave  
80105704:	c3                   	ret    

80105705 <sys_fstat>:

int
sys_fstat(void)
{
80105705:	55                   	push   %ebp
80105706:	89 e5                	mov    %esp,%ebp
80105708:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010570b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010570e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105712:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105719:	00 
8010571a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105721:	e8 7e fd ff ff       	call   801054a4 <argfd>
80105726:	85 c0                	test   %eax,%eax
80105728:	78 1f                	js     80105749 <sys_fstat+0x44>
8010572a:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105731:	00 
80105732:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105735:	89 44 24 04          	mov    %eax,0x4(%esp)
80105739:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105740:	e8 03 fc ff ff       	call   80105348 <argptr>
80105745:	85 c0                	test   %eax,%eax
80105747:	79 07                	jns    80105750 <sys_fstat+0x4b>
    return -1;
80105749:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010574e:	eb 12                	jmp    80105762 <sys_fstat+0x5d>
  return filestat(f, st);
80105750:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105753:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105756:	89 54 24 04          	mov    %edx,0x4(%esp)
8010575a:	89 04 24             	mov    %eax,(%esp)
8010575d:	e8 38 b9 ff ff       	call   8010109a <filestat>
}
80105762:	c9                   	leave  
80105763:	c3                   	ret    

80105764 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105764:	55                   	push   %ebp
80105765:	89 e5                	mov    %esp,%ebp
80105767:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010576a:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010576d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105771:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105778:	e8 2d fc ff ff       	call   801053aa <argstr>
8010577d:	85 c0                	test   %eax,%eax
8010577f:	78 17                	js     80105798 <sys_link+0x34>
80105781:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105784:	89 44 24 04          	mov    %eax,0x4(%esp)
80105788:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010578f:	e8 16 fc ff ff       	call   801053aa <argstr>
80105794:	85 c0                	test   %eax,%eax
80105796:	79 0a                	jns    801057a2 <sys_link+0x3e>
    return -1;
80105798:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010579d:	e9 3c 01 00 00       	jmp    801058de <sys_link+0x17a>
  if((ip = namei(old)) == 0)
801057a2:	8b 45 d8             	mov    -0x28(%ebp),%eax
801057a5:	89 04 24             	mov    %eax,(%esp)
801057a8:	e8 5d cc ff ff       	call   8010240a <namei>
801057ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
801057b0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801057b4:	75 0a                	jne    801057c0 <sys_link+0x5c>
    return -1;
801057b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057bb:	e9 1e 01 00 00       	jmp    801058de <sys_link+0x17a>

  begin_trans();
801057c0:	e8 58 da ff ff       	call   8010321d <begin_trans>

  ilock(ip);
801057c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057c8:	89 04 24             	mov    %eax,(%esp)
801057cb:	e8 98 c0 ff ff       	call   80101868 <ilock>
  if(ip->type == T_DIR){
801057d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057d3:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801057d7:	66 83 f8 01          	cmp    $0x1,%ax
801057db:	75 1a                	jne    801057f7 <sys_link+0x93>
    iunlockput(ip);
801057dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057e0:	89 04 24             	mov    %eax,(%esp)
801057e3:	e8 04 c3 ff ff       	call   80101aec <iunlockput>
    commit_trans();
801057e8:	e8 79 da ff ff       	call   80103266 <commit_trans>
    return -1;
801057ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057f2:	e9 e7 00 00 00       	jmp    801058de <sys_link+0x17a>
  }

  ip->nlink++;
801057f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057fa:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801057fe:	8d 50 01             	lea    0x1(%eax),%edx
80105801:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105804:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105808:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010580b:	89 04 24             	mov    %eax,(%esp)
8010580e:	e8 99 be ff ff       	call   801016ac <iupdate>
  iunlock(ip);
80105813:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105816:	89 04 24             	mov    %eax,(%esp)
80105819:	e8 98 c1 ff ff       	call   801019b6 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
8010581e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105821:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105824:	89 54 24 04          	mov    %edx,0x4(%esp)
80105828:	89 04 24             	mov    %eax,(%esp)
8010582b:	e8 fc cb ff ff       	call   8010242c <nameiparent>
80105830:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105833:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105837:	74 68                	je     801058a1 <sys_link+0x13d>
    goto bad;
  ilock(dp);
80105839:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010583c:	89 04 24             	mov    %eax,(%esp)
8010583f:	e8 24 c0 ff ff       	call   80101868 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105844:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105847:	8b 10                	mov    (%eax),%edx
80105849:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010584c:	8b 00                	mov    (%eax),%eax
8010584e:	39 c2                	cmp    %eax,%edx
80105850:	75 20                	jne    80105872 <sys_link+0x10e>
80105852:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105855:	8b 40 04             	mov    0x4(%eax),%eax
80105858:	89 44 24 08          	mov    %eax,0x8(%esp)
8010585c:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010585f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105863:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105866:	89 04 24             	mov    %eax,(%esp)
80105869:	e8 db c8 ff ff       	call   80102149 <dirlink>
8010586e:	85 c0                	test   %eax,%eax
80105870:	79 0d                	jns    8010587f <sys_link+0x11b>
    iunlockput(dp);
80105872:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105875:	89 04 24             	mov    %eax,(%esp)
80105878:	e8 6f c2 ff ff       	call   80101aec <iunlockput>
    goto bad;
8010587d:	eb 23                	jmp    801058a2 <sys_link+0x13e>
  }
  iunlockput(dp);
8010587f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105882:	89 04 24             	mov    %eax,(%esp)
80105885:	e8 62 c2 ff ff       	call   80101aec <iunlockput>
  iput(ip);
8010588a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010588d:	89 04 24             	mov    %eax,(%esp)
80105890:	e8 86 c1 ff ff       	call   80101a1b <iput>

  commit_trans();
80105895:	e8 cc d9 ff ff       	call   80103266 <commit_trans>

  return 0;
8010589a:	b8 00 00 00 00       	mov    $0x0,%eax
8010589f:	eb 3d                	jmp    801058de <sys_link+0x17a>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
801058a1:	90                   	nop
  commit_trans();

  return 0;

bad:
  ilock(ip);
801058a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058a5:	89 04 24             	mov    %eax,(%esp)
801058a8:	e8 bb bf ff ff       	call   80101868 <ilock>
  ip->nlink--;
801058ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058b0:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801058b4:	8d 50 ff             	lea    -0x1(%eax),%edx
801058b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058ba:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801058be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058c1:	89 04 24             	mov    %eax,(%esp)
801058c4:	e8 e3 bd ff ff       	call   801016ac <iupdate>
  iunlockput(ip);
801058c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058cc:	89 04 24             	mov    %eax,(%esp)
801058cf:	e8 18 c2 ff ff       	call   80101aec <iunlockput>
  commit_trans();
801058d4:	e8 8d d9 ff ff       	call   80103266 <commit_trans>
  return -1;
801058d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801058de:	c9                   	leave  
801058df:	c3                   	ret    

801058e0 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801058e0:	55                   	push   %ebp
801058e1:	89 e5                	mov    %esp,%ebp
801058e3:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801058e6:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801058ed:	eb 4b                	jmp    8010593a <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801058ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058f2:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801058f9:	00 
801058fa:	89 44 24 08          	mov    %eax,0x8(%esp)
801058fe:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105901:	89 44 24 04          	mov    %eax,0x4(%esp)
80105905:	8b 45 08             	mov    0x8(%ebp),%eax
80105908:	89 04 24             	mov    %eax,(%esp)
8010590b:	e8 4e c4 ff ff       	call   80101d5e <readi>
80105910:	83 f8 10             	cmp    $0x10,%eax
80105913:	74 0c                	je     80105921 <isdirempty+0x41>
      panic("isdirempty: readi");
80105915:	c7 04 24 00 88 10 80 	movl   $0x80108800,(%esp)
8010591c:	e8 1c ac ff ff       	call   8010053d <panic>
    if(de.inum != 0)
80105921:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105925:	66 85 c0             	test   %ax,%ax
80105928:	74 07                	je     80105931 <isdirempty+0x51>
      return 0;
8010592a:	b8 00 00 00 00       	mov    $0x0,%eax
8010592f:	eb 1b                	jmp    8010594c <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105931:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105934:	83 c0 10             	add    $0x10,%eax
80105937:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010593a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010593d:	8b 45 08             	mov    0x8(%ebp),%eax
80105940:	8b 40 18             	mov    0x18(%eax),%eax
80105943:	39 c2                	cmp    %eax,%edx
80105945:	72 a8                	jb     801058ef <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105947:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010594c:	c9                   	leave  
8010594d:	c3                   	ret    

8010594e <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
8010594e:	55                   	push   %ebp
8010594f:	89 e5                	mov    %esp,%ebp
80105951:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105954:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105957:	89 44 24 04          	mov    %eax,0x4(%esp)
8010595b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105962:	e8 43 fa ff ff       	call   801053aa <argstr>
80105967:	85 c0                	test   %eax,%eax
80105969:	79 0a                	jns    80105975 <sys_unlink+0x27>
    return -1;
8010596b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105970:	e9 aa 01 00 00       	jmp    80105b1f <sys_unlink+0x1d1>
  if((dp = nameiparent(path, name)) == 0)
80105975:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105978:	8d 55 d2             	lea    -0x2e(%ebp),%edx
8010597b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010597f:	89 04 24             	mov    %eax,(%esp)
80105982:	e8 a5 ca ff ff       	call   8010242c <nameiparent>
80105987:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010598a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010598e:	75 0a                	jne    8010599a <sys_unlink+0x4c>
    return -1;
80105990:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105995:	e9 85 01 00 00       	jmp    80105b1f <sys_unlink+0x1d1>

  begin_trans();
8010599a:	e8 7e d8 ff ff       	call   8010321d <begin_trans>

  ilock(dp);
8010599f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059a2:	89 04 24             	mov    %eax,(%esp)
801059a5:	e8 be be ff ff       	call   80101868 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801059aa:	c7 44 24 04 12 88 10 	movl   $0x80108812,0x4(%esp)
801059b1:	80 
801059b2:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801059b5:	89 04 24             	mov    %eax,(%esp)
801059b8:	e8 a2 c6 ff ff       	call   8010205f <namecmp>
801059bd:	85 c0                	test   %eax,%eax
801059bf:	0f 84 45 01 00 00    	je     80105b0a <sys_unlink+0x1bc>
801059c5:	c7 44 24 04 14 88 10 	movl   $0x80108814,0x4(%esp)
801059cc:	80 
801059cd:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801059d0:	89 04 24             	mov    %eax,(%esp)
801059d3:	e8 87 c6 ff ff       	call   8010205f <namecmp>
801059d8:	85 c0                	test   %eax,%eax
801059da:	0f 84 2a 01 00 00    	je     80105b0a <sys_unlink+0x1bc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801059e0:	8d 45 c8             	lea    -0x38(%ebp),%eax
801059e3:	89 44 24 08          	mov    %eax,0x8(%esp)
801059e7:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801059ea:	89 44 24 04          	mov    %eax,0x4(%esp)
801059ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059f1:	89 04 24             	mov    %eax,(%esp)
801059f4:	e8 88 c6 ff ff       	call   80102081 <dirlookup>
801059f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801059fc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105a00:	0f 84 03 01 00 00    	je     80105b09 <sys_unlink+0x1bb>
    goto bad;
  ilock(ip);
80105a06:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a09:	89 04 24             	mov    %eax,(%esp)
80105a0c:	e8 57 be ff ff       	call   80101868 <ilock>

  if(ip->nlink < 1)
80105a11:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a14:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105a18:	66 85 c0             	test   %ax,%ax
80105a1b:	7f 0c                	jg     80105a29 <sys_unlink+0xdb>
    panic("unlink: nlink < 1");
80105a1d:	c7 04 24 17 88 10 80 	movl   $0x80108817,(%esp)
80105a24:	e8 14 ab ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105a29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a2c:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105a30:	66 83 f8 01          	cmp    $0x1,%ax
80105a34:	75 1f                	jne    80105a55 <sys_unlink+0x107>
80105a36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a39:	89 04 24             	mov    %eax,(%esp)
80105a3c:	e8 9f fe ff ff       	call   801058e0 <isdirempty>
80105a41:	85 c0                	test   %eax,%eax
80105a43:	75 10                	jne    80105a55 <sys_unlink+0x107>
    iunlockput(ip);
80105a45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a48:	89 04 24             	mov    %eax,(%esp)
80105a4b:	e8 9c c0 ff ff       	call   80101aec <iunlockput>
    goto bad;
80105a50:	e9 b5 00 00 00       	jmp    80105b0a <sys_unlink+0x1bc>
  }

  memset(&de, 0, sizeof(de));
80105a55:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105a5c:	00 
80105a5d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105a64:	00 
80105a65:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105a68:	89 04 24             	mov    %eax,(%esp)
80105a6b:	e8 4a f5 ff ff       	call   80104fba <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105a70:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105a73:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105a7a:	00 
80105a7b:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a7f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105a82:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a89:	89 04 24             	mov    %eax,(%esp)
80105a8c:	e8 38 c4 ff ff       	call   80101ec9 <writei>
80105a91:	83 f8 10             	cmp    $0x10,%eax
80105a94:	74 0c                	je     80105aa2 <sys_unlink+0x154>
    panic("unlink: writei");
80105a96:	c7 04 24 29 88 10 80 	movl   $0x80108829,(%esp)
80105a9d:	e8 9b aa ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR){
80105aa2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aa5:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105aa9:	66 83 f8 01          	cmp    $0x1,%ax
80105aad:	75 1c                	jne    80105acb <sys_unlink+0x17d>
    dp->nlink--;
80105aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ab2:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105ab6:	8d 50 ff             	lea    -0x1(%eax),%edx
80105ab9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105abc:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105ac0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ac3:	89 04 24             	mov    %eax,(%esp)
80105ac6:	e8 e1 bb ff ff       	call   801016ac <iupdate>
  }
  iunlockput(dp);
80105acb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ace:	89 04 24             	mov    %eax,(%esp)
80105ad1:	e8 16 c0 ff ff       	call   80101aec <iunlockput>

  ip->nlink--;
80105ad6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ad9:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105add:	8d 50 ff             	lea    -0x1(%eax),%edx
80105ae0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ae3:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105ae7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aea:	89 04 24             	mov    %eax,(%esp)
80105aed:	e8 ba bb ff ff       	call   801016ac <iupdate>
  iunlockput(ip);
80105af2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105af5:	89 04 24             	mov    %eax,(%esp)
80105af8:	e8 ef bf ff ff       	call   80101aec <iunlockput>

  commit_trans();
80105afd:	e8 64 d7 ff ff       	call   80103266 <commit_trans>

  return 0;
80105b02:	b8 00 00 00 00       	mov    $0x0,%eax
80105b07:	eb 16                	jmp    80105b1f <sys_unlink+0x1d1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80105b09:	90                   	nop
  commit_trans();

  return 0;

bad:
  iunlockput(dp);
80105b0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b0d:	89 04 24             	mov    %eax,(%esp)
80105b10:	e8 d7 bf ff ff       	call   80101aec <iunlockput>
  commit_trans();
80105b15:	e8 4c d7 ff ff       	call   80103266 <commit_trans>
  return -1;
80105b1a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b1f:	c9                   	leave  
80105b20:	c3                   	ret    

80105b21 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105b21:	55                   	push   %ebp
80105b22:	89 e5                	mov    %esp,%ebp
80105b24:	83 ec 48             	sub    $0x48,%esp
80105b27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105b2a:	8b 55 10             	mov    0x10(%ebp),%edx
80105b2d:	8b 45 14             	mov    0x14(%ebp),%eax
80105b30:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105b34:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105b38:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105b3c:	8d 45 de             	lea    -0x22(%ebp),%eax
80105b3f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b43:	8b 45 08             	mov    0x8(%ebp),%eax
80105b46:	89 04 24             	mov    %eax,(%esp)
80105b49:	e8 de c8 ff ff       	call   8010242c <nameiparent>
80105b4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b51:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b55:	75 0a                	jne    80105b61 <create+0x40>
    return 0;
80105b57:	b8 00 00 00 00       	mov    $0x0,%eax
80105b5c:	e9 7e 01 00 00       	jmp    80105cdf <create+0x1be>
  ilock(dp);
80105b61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b64:	89 04 24             	mov    %eax,(%esp)
80105b67:	e8 fc bc ff ff       	call   80101868 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105b6c:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105b6f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b73:	8d 45 de             	lea    -0x22(%ebp),%eax
80105b76:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b7d:	89 04 24             	mov    %eax,(%esp)
80105b80:	e8 fc c4 ff ff       	call   80102081 <dirlookup>
80105b85:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b88:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b8c:	74 47                	je     80105bd5 <create+0xb4>
    iunlockput(dp);
80105b8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b91:	89 04 24             	mov    %eax,(%esp)
80105b94:	e8 53 bf ff ff       	call   80101aec <iunlockput>
    ilock(ip);
80105b99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b9c:	89 04 24             	mov    %eax,(%esp)
80105b9f:	e8 c4 bc ff ff       	call   80101868 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80105ba4:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105ba9:	75 15                	jne    80105bc0 <create+0x9f>
80105bab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bae:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105bb2:	66 83 f8 02          	cmp    $0x2,%ax
80105bb6:	75 08                	jne    80105bc0 <create+0x9f>
      return ip;
80105bb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bbb:	e9 1f 01 00 00       	jmp    80105cdf <create+0x1be>
    iunlockput(ip);
80105bc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bc3:	89 04 24             	mov    %eax,(%esp)
80105bc6:	e8 21 bf ff ff       	call   80101aec <iunlockput>
    return 0;
80105bcb:	b8 00 00 00 00       	mov    $0x0,%eax
80105bd0:	e9 0a 01 00 00       	jmp    80105cdf <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105bd5:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105bd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bdc:	8b 00                	mov    (%eax),%eax
80105bde:	89 54 24 04          	mov    %edx,0x4(%esp)
80105be2:	89 04 24             	mov    %eax,(%esp)
80105be5:	e8 e5 b9 ff ff       	call   801015cf <ialloc>
80105bea:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105bed:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105bf1:	75 0c                	jne    80105bff <create+0xde>
    panic("create: ialloc");
80105bf3:	c7 04 24 38 88 10 80 	movl   $0x80108838,(%esp)
80105bfa:	e8 3e a9 ff ff       	call   8010053d <panic>

  ilock(ip);
80105bff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c02:	89 04 24             	mov    %eax,(%esp)
80105c05:	e8 5e bc ff ff       	call   80101868 <ilock>
  ip->major = major;
80105c0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c0d:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105c11:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80105c15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c18:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105c1c:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80105c20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c23:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80105c29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c2c:	89 04 24             	mov    %eax,(%esp)
80105c2f:	e8 78 ba ff ff       	call   801016ac <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80105c34:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105c39:	75 6a                	jne    80105ca5 <create+0x184>
    dp->nlink++;  // for ".."
80105c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c3e:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105c42:	8d 50 01             	lea    0x1(%eax),%edx
80105c45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c48:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105c4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c4f:	89 04 24             	mov    %eax,(%esp)
80105c52:	e8 55 ba ff ff       	call   801016ac <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105c57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c5a:	8b 40 04             	mov    0x4(%eax),%eax
80105c5d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c61:	c7 44 24 04 12 88 10 	movl   $0x80108812,0x4(%esp)
80105c68:	80 
80105c69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c6c:	89 04 24             	mov    %eax,(%esp)
80105c6f:	e8 d5 c4 ff ff       	call   80102149 <dirlink>
80105c74:	85 c0                	test   %eax,%eax
80105c76:	78 21                	js     80105c99 <create+0x178>
80105c78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c7b:	8b 40 04             	mov    0x4(%eax),%eax
80105c7e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c82:	c7 44 24 04 14 88 10 	movl   $0x80108814,0x4(%esp)
80105c89:	80 
80105c8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c8d:	89 04 24             	mov    %eax,(%esp)
80105c90:	e8 b4 c4 ff ff       	call   80102149 <dirlink>
80105c95:	85 c0                	test   %eax,%eax
80105c97:	79 0c                	jns    80105ca5 <create+0x184>
      panic("create dots");
80105c99:	c7 04 24 47 88 10 80 	movl   $0x80108847,(%esp)
80105ca0:	e8 98 a8 ff ff       	call   8010053d <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105ca5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ca8:	8b 40 04             	mov    0x4(%eax),%eax
80105cab:	89 44 24 08          	mov    %eax,0x8(%esp)
80105caf:	8d 45 de             	lea    -0x22(%ebp),%eax
80105cb2:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cb9:	89 04 24             	mov    %eax,(%esp)
80105cbc:	e8 88 c4 ff ff       	call   80102149 <dirlink>
80105cc1:	85 c0                	test   %eax,%eax
80105cc3:	79 0c                	jns    80105cd1 <create+0x1b0>
    panic("create: dirlink");
80105cc5:	c7 04 24 53 88 10 80 	movl   $0x80108853,(%esp)
80105ccc:	e8 6c a8 ff ff       	call   8010053d <panic>

  iunlockput(dp);
80105cd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cd4:	89 04 24             	mov    %eax,(%esp)
80105cd7:	e8 10 be ff ff       	call   80101aec <iunlockput>

  return ip;
80105cdc:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105cdf:	c9                   	leave  
80105ce0:	c3                   	ret    

80105ce1 <sys_open>:

int
sys_open(void)
{
80105ce1:	55                   	push   %ebp
80105ce2:	89 e5                	mov    %esp,%ebp
80105ce4:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105ce7:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105cea:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105cf5:	e8 b0 f6 ff ff       	call   801053aa <argstr>
80105cfa:	85 c0                	test   %eax,%eax
80105cfc:	78 17                	js     80105d15 <sys_open+0x34>
80105cfe:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105d01:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d05:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105d0c:	e8 09 f6 ff ff       	call   8010531a <argint>
80105d11:	85 c0                	test   %eax,%eax
80105d13:	79 0a                	jns    80105d1f <sys_open+0x3e>
    return -1;
80105d15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d1a:	e9 46 01 00 00       	jmp    80105e65 <sys_open+0x184>
  if(omode & O_CREATE){
80105d1f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105d22:	25 00 02 00 00       	and    $0x200,%eax
80105d27:	85 c0                	test   %eax,%eax
80105d29:	74 40                	je     80105d6b <sys_open+0x8a>
    begin_trans();
80105d2b:	e8 ed d4 ff ff       	call   8010321d <begin_trans>
    ip = create(path, T_FILE, 0, 0);
80105d30:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105d33:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105d3a:	00 
80105d3b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105d42:	00 
80105d43:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80105d4a:	00 
80105d4b:	89 04 24             	mov    %eax,(%esp)
80105d4e:	e8 ce fd ff ff       	call   80105b21 <create>
80105d53:	89 45 f4             	mov    %eax,-0xc(%ebp)
    commit_trans();
80105d56:	e8 0b d5 ff ff       	call   80103266 <commit_trans>
    if(ip == 0)
80105d5b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d5f:	75 5c                	jne    80105dbd <sys_open+0xdc>
      return -1;
80105d61:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d66:	e9 fa 00 00 00       	jmp    80105e65 <sys_open+0x184>
  } else {
    if((ip = namei(path)) == 0)
80105d6b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105d6e:	89 04 24             	mov    %eax,(%esp)
80105d71:	e8 94 c6 ff ff       	call   8010240a <namei>
80105d76:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d79:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d7d:	75 0a                	jne    80105d89 <sys_open+0xa8>
      return -1;
80105d7f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d84:	e9 dc 00 00 00       	jmp    80105e65 <sys_open+0x184>
    ilock(ip);
80105d89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d8c:	89 04 24             	mov    %eax,(%esp)
80105d8f:	e8 d4 ba ff ff       	call   80101868 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80105d94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d97:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105d9b:	66 83 f8 01          	cmp    $0x1,%ax
80105d9f:	75 1c                	jne    80105dbd <sys_open+0xdc>
80105da1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105da4:	85 c0                	test   %eax,%eax
80105da6:	74 15                	je     80105dbd <sys_open+0xdc>
      iunlockput(ip);
80105da8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dab:	89 04 24             	mov    %eax,(%esp)
80105dae:	e8 39 bd ff ff       	call   80101aec <iunlockput>
      return -1;
80105db3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105db8:	e9 a8 00 00 00       	jmp    80105e65 <sys_open+0x184>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105dbd:	e8 5a b1 ff ff       	call   80100f1c <filealloc>
80105dc2:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105dc5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105dc9:	74 14                	je     80105ddf <sys_open+0xfe>
80105dcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dce:	89 04 24             	mov    %eax,(%esp)
80105dd1:	e8 43 f7 ff ff       	call   80105519 <fdalloc>
80105dd6:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105dd9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105ddd:	79 23                	jns    80105e02 <sys_open+0x121>
    if(f)
80105ddf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105de3:	74 0b                	je     80105df0 <sys_open+0x10f>
      fileclose(f);
80105de5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105de8:	89 04 24             	mov    %eax,(%esp)
80105deb:	e8 d4 b1 ff ff       	call   80100fc4 <fileclose>
    iunlockput(ip);
80105df0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105df3:	89 04 24             	mov    %eax,(%esp)
80105df6:	e8 f1 bc ff ff       	call   80101aec <iunlockput>
    return -1;
80105dfb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e00:	eb 63                	jmp    80105e65 <sys_open+0x184>
  }
  iunlock(ip);
80105e02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e05:	89 04 24             	mov    %eax,(%esp)
80105e08:	e8 a9 bb ff ff       	call   801019b6 <iunlock>

  f->type = FD_INODE;
80105e0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e10:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105e16:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e19:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105e1c:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105e1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e22:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105e29:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e2c:	83 e0 01             	and    $0x1,%eax
80105e2f:	85 c0                	test   %eax,%eax
80105e31:	0f 94 c2             	sete   %dl
80105e34:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e37:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105e3a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e3d:	83 e0 01             	and    $0x1,%eax
80105e40:	84 c0                	test   %al,%al
80105e42:	75 0a                	jne    80105e4e <sys_open+0x16d>
80105e44:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e47:	83 e0 02             	and    $0x2,%eax
80105e4a:	85 c0                	test   %eax,%eax
80105e4c:	74 07                	je     80105e55 <sys_open+0x174>
80105e4e:	b8 01 00 00 00       	mov    $0x1,%eax
80105e53:	eb 05                	jmp    80105e5a <sys_open+0x179>
80105e55:	b8 00 00 00 00       	mov    $0x0,%eax
80105e5a:	89 c2                	mov    %eax,%edx
80105e5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e5f:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105e62:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105e65:	c9                   	leave  
80105e66:	c3                   	ret    

80105e67 <sys_mkdir>:

int
sys_mkdir(void)
{
80105e67:	55                   	push   %ebp
80105e68:	89 e5                	mov    %esp,%ebp
80105e6a:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_trans();
80105e6d:	e8 ab d3 ff ff       	call   8010321d <begin_trans>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105e72:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e75:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e79:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105e80:	e8 25 f5 ff ff       	call   801053aa <argstr>
80105e85:	85 c0                	test   %eax,%eax
80105e87:	78 2c                	js     80105eb5 <sys_mkdir+0x4e>
80105e89:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e8c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105e93:	00 
80105e94:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105e9b:	00 
80105e9c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80105ea3:	00 
80105ea4:	89 04 24             	mov    %eax,(%esp)
80105ea7:	e8 75 fc ff ff       	call   80105b21 <create>
80105eac:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105eaf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105eb3:	75 0c                	jne    80105ec1 <sys_mkdir+0x5a>
    commit_trans();
80105eb5:	e8 ac d3 ff ff       	call   80103266 <commit_trans>
    return -1;
80105eba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ebf:	eb 15                	jmp    80105ed6 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
80105ec1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ec4:	89 04 24             	mov    %eax,(%esp)
80105ec7:	e8 20 bc ff ff       	call   80101aec <iunlockput>
  commit_trans();
80105ecc:	e8 95 d3 ff ff       	call   80103266 <commit_trans>
  return 0;
80105ed1:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ed6:	c9                   	leave  
80105ed7:	c3                   	ret    

80105ed8 <sys_mknod>:

int
sys_mknod(void)
{
80105ed8:	55                   	push   %ebp
80105ed9:	89 e5                	mov    %esp,%ebp
80105edb:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
80105ede:	e8 3a d3 ff ff       	call   8010321d <begin_trans>
  if((len=argstr(0, &path)) < 0 ||
80105ee3:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105ee6:	89 44 24 04          	mov    %eax,0x4(%esp)
80105eea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ef1:	e8 b4 f4 ff ff       	call   801053aa <argstr>
80105ef6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ef9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105efd:	78 5e                	js     80105f5d <sys_mknod+0x85>
     argint(1, &major) < 0 ||
80105eff:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105f02:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f06:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105f0d:	e8 08 f4 ff ff       	call   8010531a <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
80105f12:	85 c0                	test   %eax,%eax
80105f14:	78 47                	js     80105f5d <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80105f16:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105f19:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f1d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105f24:	e8 f1 f3 ff ff       	call   8010531a <argint>
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80105f29:	85 c0                	test   %eax,%eax
80105f2b:	78 30                	js     80105f5d <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80105f2d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f30:	0f bf c8             	movswl %ax,%ecx
80105f33:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f36:	0f bf d0             	movswl %ax,%edx
80105f39:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80105f3c:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80105f40:	89 54 24 08          	mov    %edx,0x8(%esp)
80105f44:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80105f4b:	00 
80105f4c:	89 04 24             	mov    %eax,(%esp)
80105f4f:	e8 cd fb ff ff       	call   80105b21 <create>
80105f54:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f57:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f5b:	75 0c                	jne    80105f69 <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    commit_trans();
80105f5d:	e8 04 d3 ff ff       	call   80103266 <commit_trans>
    return -1;
80105f62:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f67:	eb 15                	jmp    80105f7e <sys_mknod+0xa6>
  }
  iunlockput(ip);
80105f69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f6c:	89 04 24             	mov    %eax,(%esp)
80105f6f:	e8 78 bb ff ff       	call   80101aec <iunlockput>
  commit_trans();
80105f74:	e8 ed d2 ff ff       	call   80103266 <commit_trans>
  return 0;
80105f79:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f7e:	c9                   	leave  
80105f7f:	c3                   	ret    

80105f80 <sys_chdir>:

int
sys_chdir(void)
{
80105f80:	55                   	push   %ebp
80105f81:	89 e5                	mov    %esp,%ebp
80105f83:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0)
80105f86:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105f89:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f8d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105f94:	e8 11 f4 ff ff       	call   801053aa <argstr>
80105f99:	85 c0                	test   %eax,%eax
80105f9b:	78 14                	js     80105fb1 <sys_chdir+0x31>
80105f9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fa0:	89 04 24             	mov    %eax,(%esp)
80105fa3:	e8 62 c4 ff ff       	call   8010240a <namei>
80105fa8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105fab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105faf:	75 07                	jne    80105fb8 <sys_chdir+0x38>
    return -1;
80105fb1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fb6:	eb 57                	jmp    8010600f <sys_chdir+0x8f>
  ilock(ip);
80105fb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fbb:	89 04 24             	mov    %eax,(%esp)
80105fbe:	e8 a5 b8 ff ff       	call   80101868 <ilock>
  if(ip->type != T_DIR){
80105fc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fc6:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105fca:	66 83 f8 01          	cmp    $0x1,%ax
80105fce:	74 12                	je     80105fe2 <sys_chdir+0x62>
    iunlockput(ip);
80105fd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fd3:	89 04 24             	mov    %eax,(%esp)
80105fd6:	e8 11 bb ff ff       	call   80101aec <iunlockput>
    return -1;
80105fdb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fe0:	eb 2d                	jmp    8010600f <sys_chdir+0x8f>
  }
  iunlock(ip);
80105fe2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fe5:	89 04 24             	mov    %eax,(%esp)
80105fe8:	e8 c9 b9 ff ff       	call   801019b6 <iunlock>
  iput(proc->cwd);
80105fed:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105ff3:	8b 40 68             	mov    0x68(%eax),%eax
80105ff6:	89 04 24             	mov    %eax,(%esp)
80105ff9:	e8 1d ba ff ff       	call   80101a1b <iput>
  proc->cwd = ip;
80105ffe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106004:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106007:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
8010600a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010600f:	c9                   	leave  
80106010:	c3                   	ret    

80106011 <sys_exec>:

int
sys_exec(void)
{
80106011:	55                   	push   %ebp
80106012:	89 e5                	mov    %esp,%ebp
80106014:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
8010601a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010601d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106021:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106028:	e8 7d f3 ff ff       	call   801053aa <argstr>
8010602d:	85 c0                	test   %eax,%eax
8010602f:	78 1a                	js     8010604b <sys_exec+0x3a>
80106031:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106037:	89 44 24 04          	mov    %eax,0x4(%esp)
8010603b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106042:	e8 d3 f2 ff ff       	call   8010531a <argint>
80106047:	85 c0                	test   %eax,%eax
80106049:	79 0a                	jns    80106055 <sys_exec+0x44>
    return -1;
8010604b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106050:	e9 cc 00 00 00       	jmp    80106121 <sys_exec+0x110>
  }
  memset(argv, 0, sizeof(argv));
80106055:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
8010605c:	00 
8010605d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106064:	00 
80106065:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010606b:	89 04 24             	mov    %eax,(%esp)
8010606e:	e8 47 ef ff ff       	call   80104fba <memset>
  for(i=0;; i++){
80106073:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
8010607a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010607d:	83 f8 1f             	cmp    $0x1f,%eax
80106080:	76 0a                	jbe    8010608c <sys_exec+0x7b>
      return -1;
80106082:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106087:	e9 95 00 00 00       	jmp    80106121 <sys_exec+0x110>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
8010608c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010608f:	c1 e0 02             	shl    $0x2,%eax
80106092:	89 c2                	mov    %eax,%edx
80106094:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
8010609a:	01 c2                	add    %eax,%edx
8010609c:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801060a2:	89 44 24 04          	mov    %eax,0x4(%esp)
801060a6:	89 14 24             	mov    %edx,(%esp)
801060a9:	e8 ce f1 ff ff       	call   8010527c <fetchint>
801060ae:	85 c0                	test   %eax,%eax
801060b0:	79 07                	jns    801060b9 <sys_exec+0xa8>
      return -1;
801060b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060b7:	eb 68                	jmp    80106121 <sys_exec+0x110>
    if(uarg == 0){
801060b9:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801060bf:	85 c0                	test   %eax,%eax
801060c1:	75 26                	jne    801060e9 <sys_exec+0xd8>
      argv[i] = 0;
801060c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060c6:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801060cd:	00 00 00 00 
      break;
801060d1:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801060d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060d5:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801060db:	89 54 24 04          	mov    %edx,0x4(%esp)
801060df:	89 04 24             	mov    %eax,(%esp)
801060e2:	e8 15 aa ff ff       	call   80100afc <exec>
801060e7:	eb 38                	jmp    80106121 <sys_exec+0x110>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
801060e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060ec:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801060f3:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801060f9:	01 c2                	add    %eax,%edx
801060fb:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106101:	89 54 24 04          	mov    %edx,0x4(%esp)
80106105:	89 04 24             	mov    %eax,(%esp)
80106108:	e8 a9 f1 ff ff       	call   801052b6 <fetchstr>
8010610d:	85 c0                	test   %eax,%eax
8010610f:	79 07                	jns    80106118 <sys_exec+0x107>
      return -1;
80106111:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106116:	eb 09                	jmp    80106121 <sys_exec+0x110>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106118:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
8010611c:	e9 59 ff ff ff       	jmp    8010607a <sys_exec+0x69>
  return exec(path, argv);
}
80106121:	c9                   	leave  
80106122:	c3                   	ret    

80106123 <sys_pipe>:

int
sys_pipe(void)
{
80106123:	55                   	push   %ebp
80106124:	89 e5                	mov    %esp,%ebp
80106126:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106129:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80106130:	00 
80106131:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106134:	89 44 24 04          	mov    %eax,0x4(%esp)
80106138:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010613f:	e8 04 f2 ff ff       	call   80105348 <argptr>
80106144:	85 c0                	test   %eax,%eax
80106146:	79 0a                	jns    80106152 <sys_pipe+0x2f>
    return -1;
80106148:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010614d:	e9 9b 00 00 00       	jmp    801061ed <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
80106152:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106155:	89 44 24 04          	mov    %eax,0x4(%esp)
80106159:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010615c:	89 04 24             	mov    %eax,(%esp)
8010615f:	e8 d4 da ff ff       	call   80103c38 <pipealloc>
80106164:	85 c0                	test   %eax,%eax
80106166:	79 07                	jns    8010616f <sys_pipe+0x4c>
    return -1;
80106168:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010616d:	eb 7e                	jmp    801061ed <sys_pipe+0xca>
  fd0 = -1;
8010616f:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106176:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106179:	89 04 24             	mov    %eax,(%esp)
8010617c:	e8 98 f3 ff ff       	call   80105519 <fdalloc>
80106181:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106184:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106188:	78 14                	js     8010619e <sys_pipe+0x7b>
8010618a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010618d:	89 04 24             	mov    %eax,(%esp)
80106190:	e8 84 f3 ff ff       	call   80105519 <fdalloc>
80106195:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106198:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010619c:	79 37                	jns    801061d5 <sys_pipe+0xb2>
    if(fd0 >= 0)
8010619e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061a2:	78 14                	js     801061b8 <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
801061a4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801061ad:	83 c2 08             	add    $0x8,%edx
801061b0:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801061b7:	00 
    fileclose(rf);
801061b8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801061bb:	89 04 24             	mov    %eax,(%esp)
801061be:	e8 01 ae ff ff       	call   80100fc4 <fileclose>
    fileclose(wf);
801061c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061c6:	89 04 24             	mov    %eax,(%esp)
801061c9:	e8 f6 ad ff ff       	call   80100fc4 <fileclose>
    return -1;
801061ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061d3:	eb 18                	jmp    801061ed <sys_pipe+0xca>
  }
  fd[0] = fd0;
801061d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801061d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801061db:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801061dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801061e0:	8d 50 04             	lea    0x4(%eax),%edx
801061e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061e6:	89 02                	mov    %eax,(%edx)
  return 0;
801061e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061ed:	c9                   	leave  
801061ee:	c3                   	ret    
	...

801061f0 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
801061f0:	55                   	push   %ebp
801061f1:	89 e5                	mov    %esp,%ebp
801061f3:	83 ec 08             	sub    $0x8,%esp
  return fork();
801061f6:	e8 f2 e2 ff ff       	call   801044ed <fork>
}
801061fb:	c9                   	leave  
801061fc:	c3                   	ret    

801061fd <sys_exit>:

int
sys_exit(void)
{
801061fd:	55                   	push   %ebp
801061fe:	89 e5                	mov    %esp,%ebp
80106200:	83 ec 08             	sub    $0x8,%esp
  exit();
80106203:	e8 51 e4 ff ff       	call   80104659 <exit>
  return 0;  // not reached
80106208:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010620d:	c9                   	leave  
8010620e:	c3                   	ret    

8010620f <sys_wait>:

int
sys_wait(void)
{
8010620f:	55                   	push   %ebp
80106210:	89 e5                	mov    %esp,%ebp
80106212:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106215:	e8 5a e5 ff ff       	call   80104774 <wait>
}
8010621a:	c9                   	leave  
8010621b:	c3                   	ret    

8010621c <sys_kill>:

int
sys_kill(void)
{
8010621c:	55                   	push   %ebp
8010621d:	89 e5                	mov    %esp,%ebp
8010621f:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106222:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106225:	89 44 24 04          	mov    %eax,0x4(%esp)
80106229:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106230:	e8 e5 f0 ff ff       	call   8010531a <argint>
80106235:	85 c0                	test   %eax,%eax
80106237:	79 07                	jns    80106240 <sys_kill+0x24>
    return -1;
80106239:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010623e:	eb 0b                	jmp    8010624b <sys_kill+0x2f>
  return kill(pid);
80106240:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106243:	89 04 24             	mov    %eax,(%esp)
80106246:	e8 1d e9 ff ff       	call   80104b68 <kill>
}
8010624b:	c9                   	leave  
8010624c:	c3                   	ret    

8010624d <sys_getpid>:

int
sys_getpid(void)
{
8010624d:	55                   	push   %ebp
8010624e:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80106250:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106256:	8b 40 10             	mov    0x10(%eax),%eax
}
80106259:	5d                   	pop    %ebp
8010625a:	c3                   	ret    

8010625b <sys_sbrk>:

int
sys_sbrk(void)
{
8010625b:	55                   	push   %ebp
8010625c:	89 e5                	mov    %esp,%ebp
8010625e:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106261:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106264:	89 44 24 04          	mov    %eax,0x4(%esp)
80106268:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010626f:	e8 a6 f0 ff ff       	call   8010531a <argint>
80106274:	85 c0                	test   %eax,%eax
80106276:	79 07                	jns    8010627f <sys_sbrk+0x24>
    return -1;
80106278:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010627d:	eb 24                	jmp    801062a3 <sys_sbrk+0x48>
  addr = proc->sz;
8010627f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106285:	8b 00                	mov    (%eax),%eax
80106287:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
8010628a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010628d:	89 04 24             	mov    %eax,(%esp)
80106290:	e8 b3 e1 ff ff       	call   80104448 <growproc>
80106295:	85 c0                	test   %eax,%eax
80106297:	79 07                	jns    801062a0 <sys_sbrk+0x45>
    return -1;
80106299:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010629e:	eb 03                	jmp    801062a3 <sys_sbrk+0x48>
  return addr;
801062a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801062a3:	c9                   	leave  
801062a4:	c3                   	ret    

801062a5 <sys_sleep>:

int
sys_sleep(void)
{
801062a5:	55                   	push   %ebp
801062a6:	89 e5                	mov    %esp,%ebp
801062a8:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
801062ab:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062ae:	89 44 24 04          	mov    %eax,0x4(%esp)
801062b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801062b9:	e8 5c f0 ff ff       	call   8010531a <argint>
801062be:	85 c0                	test   %eax,%eax
801062c0:	79 07                	jns    801062c9 <sys_sleep+0x24>
    return -1;
801062c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062c7:	eb 6c                	jmp    80106335 <sys_sleep+0x90>
  acquire(&tickslock);
801062c9:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
801062d0:	e8 96 ea ff ff       	call   80104d6b <acquire>
  ticks0 = ticks;
801062d5:	a1 c0 29 11 80       	mov    0x801129c0,%eax
801062da:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801062dd:	eb 34                	jmp    80106313 <sys_sleep+0x6e>
    if(proc->killed){
801062df:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062e5:	8b 40 24             	mov    0x24(%eax),%eax
801062e8:	85 c0                	test   %eax,%eax
801062ea:	74 13                	je     801062ff <sys_sleep+0x5a>
      release(&tickslock);
801062ec:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
801062f3:	e8 d5 ea ff ff       	call   80104dcd <release>
      return -1;
801062f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062fd:	eb 36                	jmp    80106335 <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
801062ff:	c7 44 24 04 80 21 11 	movl   $0x80112180,0x4(%esp)
80106306:	80 
80106307:	c7 04 24 c0 29 11 80 	movl   $0x801129c0,(%esp)
8010630e:	e8 3e e7 ff ff       	call   80104a51 <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106313:	a1 c0 29 11 80       	mov    0x801129c0,%eax
80106318:	89 c2                	mov    %eax,%edx
8010631a:	2b 55 f4             	sub    -0xc(%ebp),%edx
8010631d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106320:	39 c2                	cmp    %eax,%edx
80106322:	72 bb                	jb     801062df <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106324:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
8010632b:	e8 9d ea ff ff       	call   80104dcd <release>
  return 0;
80106330:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106335:	c9                   	leave  
80106336:	c3                   	ret    

80106337 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106337:	55                   	push   %ebp
80106338:	89 e5                	mov    %esp,%ebp
8010633a:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
8010633d:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
80106344:	e8 22 ea ff ff       	call   80104d6b <acquire>
  xticks = ticks;
80106349:	a1 c0 29 11 80       	mov    0x801129c0,%eax
8010634e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106351:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
80106358:	e8 70 ea ff ff       	call   80104dcd <release>
  return xticks;
8010635d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106360:	c9                   	leave  
80106361:	c3                   	ret    

80106362 <sys_procstat>:

int
sys_procstat(void)
{
80106362:	55                   	push   %ebp
80106363:	89 e5                	mov    %esp,%ebp
80106365:	83 ec 08             	sub    $0x8,%esp
	procdump();
80106368:	e8 9a e8 ff ff       	call   80104c07 <procdump>
	return(0);
8010636d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106372:	c9                   	leave  
80106373:	c3                   	ret    

80106374 <outb>:
80106374:	55                   	push   %ebp
80106375:	89 e5                	mov    %esp,%ebp
80106377:	83 ec 08             	sub    $0x8,%esp
8010637a:	8b 55 08             	mov    0x8(%ebp),%edx
8010637d:	8b 45 0c             	mov    0xc(%ebp),%eax
80106380:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106384:	88 45 f8             	mov    %al,-0x8(%ebp)
80106387:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010638b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010638f:	ee                   	out    %al,(%dx)
80106390:	c9                   	leave  
80106391:	c3                   	ret    

80106392 <timerinit>:
80106392:	55                   	push   %ebp
80106393:	89 e5                	mov    %esp,%ebp
80106395:	83 ec 18             	sub    $0x18,%esp
80106398:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
8010639f:	00 
801063a0:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
801063a7:	e8 c8 ff ff ff       	call   80106374 <outb>
801063ac:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
801063b3:	00 
801063b4:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
801063bb:	e8 b4 ff ff ff       	call   80106374 <outb>
801063c0:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
801063c7:	00 
801063c8:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
801063cf:	e8 a0 ff ff ff       	call   80106374 <outb>
801063d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801063db:	e8 e1 d6 ff ff       	call   80103ac1 <picenable>
801063e0:	c9                   	leave  
801063e1:	c3                   	ret    
	...

801063e4 <alltraps>:
801063e4:	1e                   	push   %ds
801063e5:	06                   	push   %es
801063e6:	0f a0                	push   %fs
801063e8:	0f a8                	push   %gs
801063ea:	60                   	pusha  
801063eb:	66 b8 10 00          	mov    $0x10,%ax
801063ef:	8e d8                	mov    %eax,%ds
801063f1:	8e c0                	mov    %eax,%es
801063f3:	66 b8 18 00          	mov    $0x18,%ax
801063f7:	8e e0                	mov    %eax,%fs
801063f9:	8e e8                	mov    %eax,%gs
801063fb:	54                   	push   %esp
801063fc:	e8 de 01 00 00       	call   801065df <trap>
80106401:	83 c4 04             	add    $0x4,%esp

80106404 <trapret>:
80106404:	61                   	popa   
80106405:	0f a9                	pop    %gs
80106407:	0f a1                	pop    %fs
80106409:	07                   	pop    %es
8010640a:	1f                   	pop    %ds
8010640b:	83 c4 08             	add    $0x8,%esp
8010640e:	cf                   	iret   
	...

80106410 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106410:	55                   	push   %ebp
80106411:	89 e5                	mov    %esp,%ebp
80106413:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106416:	8b 45 0c             	mov    0xc(%ebp),%eax
80106419:	83 e8 01             	sub    $0x1,%eax
8010641c:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106420:	8b 45 08             	mov    0x8(%ebp),%eax
80106423:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106427:	8b 45 08             	mov    0x8(%ebp),%eax
8010642a:	c1 e8 10             	shr    $0x10,%eax
8010642d:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106431:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106434:	0f 01 18             	lidtl  (%eax)
}
80106437:	c9                   	leave  
80106438:	c3                   	ret    

80106439 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106439:	55                   	push   %ebp
8010643a:	89 e5                	mov    %esp,%ebp
8010643c:	53                   	push   %ebx
8010643d:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106440:	0f 20 d3             	mov    %cr2,%ebx
80106443:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return val;
80106446:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80106449:	83 c4 10             	add    $0x10,%esp
8010644c:	5b                   	pop    %ebx
8010644d:	5d                   	pop    %ebp
8010644e:	c3                   	ret    

8010644f <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
8010644f:	55                   	push   %ebp
80106450:	89 e5                	mov    %esp,%ebp
80106452:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80106455:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010645c:	e9 c3 00 00 00       	jmp    80106524 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106461:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106464:	8b 04 85 9c b0 10 80 	mov    -0x7fef4f64(,%eax,4),%eax
8010646b:	89 c2                	mov    %eax,%edx
8010646d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106470:	66 89 14 c5 c0 21 11 	mov    %dx,-0x7feede40(,%eax,8)
80106477:	80 
80106478:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010647b:	66 c7 04 c5 c2 21 11 	movw   $0x8,-0x7feede3e(,%eax,8)
80106482:	80 08 00 
80106485:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106488:	0f b6 14 c5 c4 21 11 	movzbl -0x7feede3c(,%eax,8),%edx
8010648f:	80 
80106490:	83 e2 e0             	and    $0xffffffe0,%edx
80106493:	88 14 c5 c4 21 11 80 	mov    %dl,-0x7feede3c(,%eax,8)
8010649a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010649d:	0f b6 14 c5 c4 21 11 	movzbl -0x7feede3c(,%eax,8),%edx
801064a4:	80 
801064a5:	83 e2 1f             	and    $0x1f,%edx
801064a8:	88 14 c5 c4 21 11 80 	mov    %dl,-0x7feede3c(,%eax,8)
801064af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064b2:	0f b6 14 c5 c5 21 11 	movzbl -0x7feede3b(,%eax,8),%edx
801064b9:	80 
801064ba:	83 e2 f0             	and    $0xfffffff0,%edx
801064bd:	83 ca 0e             	or     $0xe,%edx
801064c0:	88 14 c5 c5 21 11 80 	mov    %dl,-0x7feede3b(,%eax,8)
801064c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064ca:	0f b6 14 c5 c5 21 11 	movzbl -0x7feede3b(,%eax,8),%edx
801064d1:	80 
801064d2:	83 e2 ef             	and    $0xffffffef,%edx
801064d5:	88 14 c5 c5 21 11 80 	mov    %dl,-0x7feede3b(,%eax,8)
801064dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064df:	0f b6 14 c5 c5 21 11 	movzbl -0x7feede3b(,%eax,8),%edx
801064e6:	80 
801064e7:	83 e2 9f             	and    $0xffffff9f,%edx
801064ea:	88 14 c5 c5 21 11 80 	mov    %dl,-0x7feede3b(,%eax,8)
801064f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064f4:	0f b6 14 c5 c5 21 11 	movzbl -0x7feede3b(,%eax,8),%edx
801064fb:	80 
801064fc:	83 ca 80             	or     $0xffffff80,%edx
801064ff:	88 14 c5 c5 21 11 80 	mov    %dl,-0x7feede3b(,%eax,8)
80106506:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106509:	8b 04 85 9c b0 10 80 	mov    -0x7fef4f64(,%eax,4),%eax
80106510:	c1 e8 10             	shr    $0x10,%eax
80106513:	89 c2                	mov    %eax,%edx
80106515:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106518:	66 89 14 c5 c6 21 11 	mov    %dx,-0x7feede3a(,%eax,8)
8010651f:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106520:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106524:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010652b:	0f 8e 30 ff ff ff    	jle    80106461 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106531:	a1 9c b1 10 80       	mov    0x8010b19c,%eax
80106536:	66 a3 c0 23 11 80    	mov    %ax,0x801123c0
8010653c:	66 c7 05 c2 23 11 80 	movw   $0x8,0x801123c2
80106543:	08 00 
80106545:	0f b6 05 c4 23 11 80 	movzbl 0x801123c4,%eax
8010654c:	83 e0 e0             	and    $0xffffffe0,%eax
8010654f:	a2 c4 23 11 80       	mov    %al,0x801123c4
80106554:	0f b6 05 c4 23 11 80 	movzbl 0x801123c4,%eax
8010655b:	83 e0 1f             	and    $0x1f,%eax
8010655e:	a2 c4 23 11 80       	mov    %al,0x801123c4
80106563:	0f b6 05 c5 23 11 80 	movzbl 0x801123c5,%eax
8010656a:	83 c8 0f             	or     $0xf,%eax
8010656d:	a2 c5 23 11 80       	mov    %al,0x801123c5
80106572:	0f b6 05 c5 23 11 80 	movzbl 0x801123c5,%eax
80106579:	83 e0 ef             	and    $0xffffffef,%eax
8010657c:	a2 c5 23 11 80       	mov    %al,0x801123c5
80106581:	0f b6 05 c5 23 11 80 	movzbl 0x801123c5,%eax
80106588:	83 c8 60             	or     $0x60,%eax
8010658b:	a2 c5 23 11 80       	mov    %al,0x801123c5
80106590:	0f b6 05 c5 23 11 80 	movzbl 0x801123c5,%eax
80106597:	83 c8 80             	or     $0xffffff80,%eax
8010659a:	a2 c5 23 11 80       	mov    %al,0x801123c5
8010659f:	a1 9c b1 10 80       	mov    0x8010b19c,%eax
801065a4:	c1 e8 10             	shr    $0x10,%eax
801065a7:	66 a3 c6 23 11 80    	mov    %ax,0x801123c6
  
  initlock(&tickslock, "time");
801065ad:	c7 44 24 04 64 88 10 	movl   $0x80108864,0x4(%esp)
801065b4:	80 
801065b5:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
801065bc:	e8 89 e7 ff ff       	call   80104d4a <initlock>
}
801065c1:	c9                   	leave  
801065c2:	c3                   	ret    

801065c3 <idtinit>:

void
idtinit(void)
{
801065c3:	55                   	push   %ebp
801065c4:	89 e5                	mov    %esp,%ebp
801065c6:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
801065c9:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
801065d0:	00 
801065d1:	c7 04 24 c0 21 11 80 	movl   $0x801121c0,(%esp)
801065d8:	e8 33 fe ff ff       	call   80106410 <lidt>
}
801065dd:	c9                   	leave  
801065de:	c3                   	ret    

801065df <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801065df:	55                   	push   %ebp
801065e0:	89 e5                	mov    %esp,%ebp
801065e2:	57                   	push   %edi
801065e3:	56                   	push   %esi
801065e4:	53                   	push   %ebx
801065e5:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
801065e8:	8b 45 08             	mov    0x8(%ebp),%eax
801065eb:	8b 40 30             	mov    0x30(%eax),%eax
801065ee:	83 f8 40             	cmp    $0x40,%eax
801065f1:	75 3e                	jne    80106631 <trap+0x52>
    if(proc->killed)
801065f3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065f9:	8b 40 24             	mov    0x24(%eax),%eax
801065fc:	85 c0                	test   %eax,%eax
801065fe:	74 05                	je     80106605 <trap+0x26>
      exit();
80106600:	e8 54 e0 ff ff       	call   80104659 <exit>
    proc->tf = tf;
80106605:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010660b:	8b 55 08             	mov    0x8(%ebp),%edx
8010660e:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106611:	e8 cb ed ff ff       	call   801053e1 <syscall>
    if(proc->killed)
80106616:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010661c:	8b 40 24             	mov    0x24(%eax),%eax
8010661f:	85 c0                	test   %eax,%eax
80106621:	0f 84 7f 02 00 00    	je     801068a6 <trap+0x2c7>
      exit();
80106627:	e8 2d e0 ff ff       	call   80104659 <exit>
    return;
8010662c:	e9 75 02 00 00       	jmp    801068a6 <trap+0x2c7>
  }

  switch(tf->trapno){
80106631:	8b 45 08             	mov    0x8(%ebp),%eax
80106634:	8b 40 30             	mov    0x30(%eax),%eax
80106637:	83 e8 20             	sub    $0x20,%eax
8010663a:	83 f8 1f             	cmp    $0x1f,%eax
8010663d:	0f 87 bc 00 00 00    	ja     801066ff <trap+0x120>
80106643:	8b 04 85 38 89 10 80 	mov    -0x7fef76c8(,%eax,4),%eax
8010664a:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
8010664c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106652:	0f b6 00             	movzbl (%eax),%eax
80106655:	84 c0                	test   %al,%al
80106657:	75 31                	jne    8010668a <trap+0xab>
      acquire(&tickslock);
80106659:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
80106660:	e8 06 e7 ff ff       	call   80104d6b <acquire>
      ticks++;
80106665:	a1 c0 29 11 80       	mov    0x801129c0,%eax
8010666a:	83 c0 01             	add    $0x1,%eax
8010666d:	a3 c0 29 11 80       	mov    %eax,0x801129c0
      wakeup(&ticks);
80106672:	c7 04 24 c0 29 11 80 	movl   $0x801129c0,(%esp)
80106679:	e8 bf e4 ff ff       	call   80104b3d <wakeup>
      release(&tickslock);
8010667e:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
80106685:	e8 43 e7 ff ff       	call   80104dcd <release>
    }
    lapiceoi();
8010668a:	e8 5b c8 ff ff       	call   80102eea <lapiceoi>
    break;
8010668f:	e9 41 01 00 00       	jmp    801067d5 <trap+0x1f6>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106694:	e8 58 c0 ff ff       	call   801026f1 <ideintr>
    lapiceoi();
80106699:	e8 4c c8 ff ff       	call   80102eea <lapiceoi>
    break;
8010669e:	e9 32 01 00 00       	jmp    801067d5 <trap+0x1f6>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801066a3:	e8 1f c6 ff ff       	call   80102cc7 <kbdintr>
    lapiceoi();
801066a8:	e8 3d c8 ff ff       	call   80102eea <lapiceoi>
    break;
801066ad:	e9 23 01 00 00       	jmp    801067d5 <trap+0x1f6>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801066b2:	e8 f5 03 00 00       	call   80106aac <uartintr>
    lapiceoi();
801066b7:	e8 2e c8 ff ff       	call   80102eea <lapiceoi>
    break;
801066bc:	e9 14 01 00 00       	jmp    801067d5 <trap+0x1f6>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
            cpu->id, tf->cs, tf->eip);
801066c1:	8b 45 08             	mov    0x8(%ebp),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801066c4:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
801066c7:	8b 45 08             	mov    0x8(%ebp),%eax
801066ca:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801066ce:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
801066d1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801066d7:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801066da:	0f b6 c0             	movzbl %al,%eax
801066dd:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801066e1:	89 54 24 08          	mov    %edx,0x8(%esp)
801066e5:	89 44 24 04          	mov    %eax,0x4(%esp)
801066e9:	c7 04 24 6c 88 10 80 	movl   $0x8010886c,(%esp)
801066f0:	e8 ac 9c ff ff       	call   801003a1 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
801066f5:	e8 f0 c7 ff ff       	call   80102eea <lapiceoi>
    break;
801066fa:	e9 d6 00 00 00       	jmp    801067d5 <trap+0x1f6>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
801066ff:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106705:	85 c0                	test   %eax,%eax
80106707:	74 11                	je     8010671a <trap+0x13b>
80106709:	8b 45 08             	mov    0x8(%ebp),%eax
8010670c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106710:	0f b7 c0             	movzwl %ax,%eax
80106713:	83 e0 03             	and    $0x3,%eax
80106716:	85 c0                	test   %eax,%eax
80106718:	75 46                	jne    80106760 <trap+0x181>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010671a:	e8 1a fd ff ff       	call   80106439 <rcr2>
              tf->trapno, cpu->id, tf->eip, rcr2());
8010671f:	8b 55 08             	mov    0x8(%ebp),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106722:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106725:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010672c:	0f b6 12             	movzbl (%edx),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010672f:	0f b6 ca             	movzbl %dl,%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106732:	8b 55 08             	mov    0x8(%ebp),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106735:	8b 52 30             	mov    0x30(%edx),%edx
80106738:	89 44 24 10          	mov    %eax,0x10(%esp)
8010673c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80106740:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106744:	89 54 24 04          	mov    %edx,0x4(%esp)
80106748:	c7 04 24 90 88 10 80 	movl   $0x80108890,(%esp)
8010674f:	e8 4d 9c ff ff       	call   801003a1 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80106754:	c7 04 24 c2 88 10 80 	movl   $0x801088c2,(%esp)
8010675b:	e8 dd 9d ff ff       	call   8010053d <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106760:	e8 d4 fc ff ff       	call   80106439 <rcr2>
80106765:	89 c2                	mov    %eax,%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106767:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010676a:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
8010676d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106773:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106776:	0f b6 f0             	movzbl %al,%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106779:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010677c:	8b 58 34             	mov    0x34(%eax),%ebx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
8010677f:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106782:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106785:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010678b:	83 c0 6c             	add    $0x6c,%eax
8010678e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106791:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106797:	8b 40 10             	mov    0x10(%eax),%eax
8010679a:	89 54 24 1c          	mov    %edx,0x1c(%esp)
8010679e:	89 7c 24 18          	mov    %edi,0x18(%esp)
801067a2:	89 74 24 14          	mov    %esi,0x14(%esp)
801067a6:	89 5c 24 10          	mov    %ebx,0x10(%esp)
801067aa:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801067ae:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801067b1:	89 54 24 08          	mov    %edx,0x8(%esp)
801067b5:	89 44 24 04          	mov    %eax,0x4(%esp)
801067b9:	c7 04 24 c8 88 10 80 	movl   $0x801088c8,(%esp)
801067c0:	e8 dc 9b ff ff       	call   801003a1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
801067c5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801067cb:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801067d2:	eb 01                	jmp    801067d5 <trap+0x1f6>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
801067d4:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801067d5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801067db:	85 c0                	test   %eax,%eax
801067dd:	74 24                	je     80106803 <trap+0x224>
801067df:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801067e5:	8b 40 24             	mov    0x24(%eax),%eax
801067e8:	85 c0                	test   %eax,%eax
801067ea:	74 17                	je     80106803 <trap+0x224>
801067ec:	8b 45 08             	mov    0x8(%ebp),%eax
801067ef:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801067f3:	0f b7 c0             	movzwl %ax,%eax
801067f6:	83 e0 03             	and    $0x3,%eax
801067f9:	83 f8 03             	cmp    $0x3,%eax
801067fc:	75 05                	jne    80106803 <trap+0x224>
    exit();
801067fe:	e8 56 de ff ff       	call   80104659 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER) {
80106803:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106809:	85 c0                	test   %eax,%eax
8010680b:	74 69                	je     80106876 <trap+0x297>
8010680d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106813:	8b 40 0c             	mov    0xc(%eax),%eax
80106816:	83 f8 04             	cmp    $0x4,%eax
80106819:	75 5b                	jne    80106876 <trap+0x297>
8010681b:	8b 45 08             	mov    0x8(%ebp),%eax
8010681e:	8b 40 30             	mov    0x30(%eax),%eax
80106821:	83 f8 20             	cmp    $0x20,%eax
80106824:	75 50                	jne    80106876 <trap+0x297>
	  proc->quantum+=1;
80106826:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010682c:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80106833:	8b 52 7c             	mov    0x7c(%edx),%edx
80106836:	83 c2 01             	add    $0x1,%edx
80106839:	89 50 7c             	mov    %edx,0x7c(%eax)
	  //cprintf("El Proceso '%s', lleva el QUANTUM  %d    \n",proc->name,proc->quantum);  Este print muestra el nombre del proceso y cual es su quantum
	  if(proc->quantum == MAX_QUANTUM) //Controla el limite de tiempo de uso del CPU agotado
8010683c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106842:	8b 40 7c             	mov    0x7c(%eax),%eax
80106845:	83 f8 04             	cmp    $0x4,%eax
80106848:	75 2c                	jne    80106876 <trap+0x297>
      {
       cprintf("El Proceso '%s', lleva el QUANTUM  %d    \n",proc->name,proc->quantum);
8010684a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106850:	8b 40 7c             	mov    0x7c(%eax),%eax
80106853:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010685a:	83 c2 6c             	add    $0x6c,%edx
8010685d:	89 44 24 08          	mov    %eax,0x8(%esp)
80106861:	89 54 24 04          	mov    %edx,0x4(%esp)
80106865:	c7 04 24 0c 89 10 80 	movl   $0x8010890c,(%esp)
8010686c:	e8 30 9b ff ff       	call   801003a1 <cprintf>
       yield();
80106871:	e8 69 e1 ff ff       	call   801049df <yield>
       }
	}

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106876:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010687c:	85 c0                	test   %eax,%eax
8010687e:	74 27                	je     801068a7 <trap+0x2c8>
80106880:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106886:	8b 40 24             	mov    0x24(%eax),%eax
80106889:	85 c0                	test   %eax,%eax
8010688b:	74 1a                	je     801068a7 <trap+0x2c8>
8010688d:	8b 45 08             	mov    0x8(%ebp),%eax
80106890:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106894:	0f b7 c0             	movzwl %ax,%eax
80106897:	83 e0 03             	and    $0x3,%eax
8010689a:	83 f8 03             	cmp    $0x3,%eax
8010689d:	75 08                	jne    801068a7 <trap+0x2c8>
    exit();
8010689f:	e8 b5 dd ff ff       	call   80104659 <exit>
801068a4:	eb 01                	jmp    801068a7 <trap+0x2c8>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
801068a6:	90                   	nop
	}

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
801068a7:	83 c4 3c             	add    $0x3c,%esp
801068aa:	5b                   	pop    %ebx
801068ab:	5e                   	pop    %esi
801068ac:	5f                   	pop    %edi
801068ad:	5d                   	pop    %ebp
801068ae:	c3                   	ret    
	...

801068b0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801068b0:	55                   	push   %ebp
801068b1:	89 e5                	mov    %esp,%ebp
801068b3:	53                   	push   %ebx
801068b4:	83 ec 14             	sub    $0x14,%esp
801068b7:	8b 45 08             	mov    0x8(%ebp),%eax
801068ba:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801068be:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
801068c2:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
801068c6:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
801068ca:	ec                   	in     (%dx),%al
801068cb:	89 c3                	mov    %eax,%ebx
801068cd:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
801068d0:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
801068d4:	83 c4 14             	add    $0x14,%esp
801068d7:	5b                   	pop    %ebx
801068d8:	5d                   	pop    %ebp
801068d9:	c3                   	ret    

801068da <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801068da:	55                   	push   %ebp
801068db:	89 e5                	mov    %esp,%ebp
801068dd:	83 ec 08             	sub    $0x8,%esp
801068e0:	8b 55 08             	mov    0x8(%ebp),%edx
801068e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801068e6:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801068ea:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801068ed:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801068f1:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801068f5:	ee                   	out    %al,(%dx)
}
801068f6:	c9                   	leave  
801068f7:	c3                   	ret    

801068f8 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801068f8:	55                   	push   %ebp
801068f9:	89 e5                	mov    %esp,%ebp
801068fb:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801068fe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106905:	00 
80106906:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
8010690d:	e8 c8 ff ff ff       	call   801068da <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106912:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80106919:	00 
8010691a:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106921:	e8 b4 ff ff ff       	call   801068da <outb>
  outb(COM1+0, 115200/9600);
80106926:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
8010692d:	00 
8010692e:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106935:	e8 a0 ff ff ff       	call   801068da <outb>
  outb(COM1+1, 0);
8010693a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106941:	00 
80106942:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106949:	e8 8c ff ff ff       	call   801068da <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010694e:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106955:	00 
80106956:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
8010695d:	e8 78 ff ff ff       	call   801068da <outb>
  outb(COM1+4, 0);
80106962:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106969:	00 
8010696a:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80106971:	e8 64 ff ff ff       	call   801068da <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106976:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010697d:	00 
8010697e:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106985:	e8 50 ff ff ff       	call   801068da <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
8010698a:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106991:	e8 1a ff ff ff       	call   801068b0 <inb>
80106996:	3c ff                	cmp    $0xff,%al
80106998:	74 6c                	je     80106a06 <uartinit+0x10e>
    return;
  uart = 1;
8010699a:	c7 05 4c b6 10 80 01 	movl   $0x1,0x8010b64c
801069a1:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801069a4:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
801069ab:	e8 00 ff ff ff       	call   801068b0 <inb>
  inb(COM1+0);
801069b0:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801069b7:	e8 f4 fe ff ff       	call   801068b0 <inb>
  picenable(IRQ_COM1);
801069bc:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
801069c3:	e8 f9 d0 ff ff       	call   80103ac1 <picenable>
  ioapicenable(IRQ_COM1, 0);
801069c8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801069cf:	00 
801069d0:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
801069d7:	e8 9a bf ff ff       	call   80102976 <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801069dc:	c7 45 f4 b8 89 10 80 	movl   $0x801089b8,-0xc(%ebp)
801069e3:	eb 15                	jmp    801069fa <uartinit+0x102>
    uartputc(*p);
801069e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069e8:	0f b6 00             	movzbl (%eax),%eax
801069eb:	0f be c0             	movsbl %al,%eax
801069ee:	89 04 24             	mov    %eax,(%esp)
801069f1:	e8 13 00 00 00       	call   80106a09 <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801069f6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801069fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069fd:	0f b6 00             	movzbl (%eax),%eax
80106a00:	84 c0                	test   %al,%al
80106a02:	75 e1                	jne    801069e5 <uartinit+0xed>
80106a04:	eb 01                	jmp    80106a07 <uartinit+0x10f>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80106a06:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80106a07:	c9                   	leave  
80106a08:	c3                   	ret    

80106a09 <uartputc>:

void
uartputc(int c)
{
80106a09:	55                   	push   %ebp
80106a0a:	89 e5                	mov    %esp,%ebp
80106a0c:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80106a0f:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106a14:	85 c0                	test   %eax,%eax
80106a16:	74 4d                	je     80106a65 <uartputc+0x5c>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106a18:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106a1f:	eb 10                	jmp    80106a31 <uartputc+0x28>
    microdelay(10);
80106a21:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80106a28:	e8 e2 c4 ff ff       	call   80102f0f <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106a2d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106a31:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106a35:	7f 16                	jg     80106a4d <uartputc+0x44>
80106a37:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106a3e:	e8 6d fe ff ff       	call   801068b0 <inb>
80106a43:	0f b6 c0             	movzbl %al,%eax
80106a46:	83 e0 20             	and    $0x20,%eax
80106a49:	85 c0                	test   %eax,%eax
80106a4b:	74 d4                	je     80106a21 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80106a4d:	8b 45 08             	mov    0x8(%ebp),%eax
80106a50:	0f b6 c0             	movzbl %al,%eax
80106a53:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a57:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106a5e:	e8 77 fe ff ff       	call   801068da <outb>
80106a63:	eb 01                	jmp    80106a66 <uartputc+0x5d>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80106a65:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80106a66:	c9                   	leave  
80106a67:	c3                   	ret    

80106a68 <uartgetc>:

static int
uartgetc(void)
{
80106a68:	55                   	push   %ebp
80106a69:	89 e5                	mov    %esp,%ebp
80106a6b:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80106a6e:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106a73:	85 c0                	test   %eax,%eax
80106a75:	75 07                	jne    80106a7e <uartgetc+0x16>
    return -1;
80106a77:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a7c:	eb 2c                	jmp    80106aaa <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80106a7e:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106a85:	e8 26 fe ff ff       	call   801068b0 <inb>
80106a8a:	0f b6 c0             	movzbl %al,%eax
80106a8d:	83 e0 01             	and    $0x1,%eax
80106a90:	85 c0                	test   %eax,%eax
80106a92:	75 07                	jne    80106a9b <uartgetc+0x33>
    return -1;
80106a94:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a99:	eb 0f                	jmp    80106aaa <uartgetc+0x42>
  return inb(COM1+0);
80106a9b:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106aa2:	e8 09 fe ff ff       	call   801068b0 <inb>
80106aa7:	0f b6 c0             	movzbl %al,%eax
}
80106aaa:	c9                   	leave  
80106aab:	c3                   	ret    

80106aac <uartintr>:

void
uartintr(void)
{
80106aac:	55                   	push   %ebp
80106aad:	89 e5                	mov    %esp,%ebp
80106aaf:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80106ab2:	c7 04 24 68 6a 10 80 	movl   $0x80106a68,(%esp)
80106ab9:	e8 ef 9c ff ff       	call   801007ad <consoleintr>
}
80106abe:	c9                   	leave  
80106abf:	c3                   	ret    

80106ac0 <vector0>:
80106ac0:	6a 00                	push   $0x0
80106ac2:	6a 00                	push   $0x0
80106ac4:	e9 1b f9 ff ff       	jmp    801063e4 <alltraps>

80106ac9 <vector1>:
80106ac9:	6a 00                	push   $0x0
80106acb:	6a 01                	push   $0x1
80106acd:	e9 12 f9 ff ff       	jmp    801063e4 <alltraps>

80106ad2 <vector2>:
80106ad2:	6a 00                	push   $0x0
80106ad4:	6a 02                	push   $0x2
80106ad6:	e9 09 f9 ff ff       	jmp    801063e4 <alltraps>

80106adb <vector3>:
80106adb:	6a 00                	push   $0x0
80106add:	6a 03                	push   $0x3
80106adf:	e9 00 f9 ff ff       	jmp    801063e4 <alltraps>

80106ae4 <vector4>:
80106ae4:	6a 00                	push   $0x0
80106ae6:	6a 04                	push   $0x4
80106ae8:	e9 f7 f8 ff ff       	jmp    801063e4 <alltraps>

80106aed <vector5>:
80106aed:	6a 00                	push   $0x0
80106aef:	6a 05                	push   $0x5
80106af1:	e9 ee f8 ff ff       	jmp    801063e4 <alltraps>

80106af6 <vector6>:
80106af6:	6a 00                	push   $0x0
80106af8:	6a 06                	push   $0x6
80106afa:	e9 e5 f8 ff ff       	jmp    801063e4 <alltraps>

80106aff <vector7>:
80106aff:	6a 00                	push   $0x0
80106b01:	6a 07                	push   $0x7
80106b03:	e9 dc f8 ff ff       	jmp    801063e4 <alltraps>

80106b08 <vector8>:
80106b08:	6a 08                	push   $0x8
80106b0a:	e9 d5 f8 ff ff       	jmp    801063e4 <alltraps>

80106b0f <vector9>:
80106b0f:	6a 00                	push   $0x0
80106b11:	6a 09                	push   $0x9
80106b13:	e9 cc f8 ff ff       	jmp    801063e4 <alltraps>

80106b18 <vector10>:
80106b18:	6a 0a                	push   $0xa
80106b1a:	e9 c5 f8 ff ff       	jmp    801063e4 <alltraps>

80106b1f <vector11>:
80106b1f:	6a 0b                	push   $0xb
80106b21:	e9 be f8 ff ff       	jmp    801063e4 <alltraps>

80106b26 <vector12>:
80106b26:	6a 0c                	push   $0xc
80106b28:	e9 b7 f8 ff ff       	jmp    801063e4 <alltraps>

80106b2d <vector13>:
80106b2d:	6a 0d                	push   $0xd
80106b2f:	e9 b0 f8 ff ff       	jmp    801063e4 <alltraps>

80106b34 <vector14>:
80106b34:	6a 0e                	push   $0xe
80106b36:	e9 a9 f8 ff ff       	jmp    801063e4 <alltraps>

80106b3b <vector15>:
80106b3b:	6a 00                	push   $0x0
80106b3d:	6a 0f                	push   $0xf
80106b3f:	e9 a0 f8 ff ff       	jmp    801063e4 <alltraps>

80106b44 <vector16>:
80106b44:	6a 00                	push   $0x0
80106b46:	6a 10                	push   $0x10
80106b48:	e9 97 f8 ff ff       	jmp    801063e4 <alltraps>

80106b4d <vector17>:
80106b4d:	6a 11                	push   $0x11
80106b4f:	e9 90 f8 ff ff       	jmp    801063e4 <alltraps>

80106b54 <vector18>:
80106b54:	6a 00                	push   $0x0
80106b56:	6a 12                	push   $0x12
80106b58:	e9 87 f8 ff ff       	jmp    801063e4 <alltraps>

80106b5d <vector19>:
80106b5d:	6a 00                	push   $0x0
80106b5f:	6a 13                	push   $0x13
80106b61:	e9 7e f8 ff ff       	jmp    801063e4 <alltraps>

80106b66 <vector20>:
80106b66:	6a 00                	push   $0x0
80106b68:	6a 14                	push   $0x14
80106b6a:	e9 75 f8 ff ff       	jmp    801063e4 <alltraps>

80106b6f <vector21>:
80106b6f:	6a 00                	push   $0x0
80106b71:	6a 15                	push   $0x15
80106b73:	e9 6c f8 ff ff       	jmp    801063e4 <alltraps>

80106b78 <vector22>:
80106b78:	6a 00                	push   $0x0
80106b7a:	6a 16                	push   $0x16
80106b7c:	e9 63 f8 ff ff       	jmp    801063e4 <alltraps>

80106b81 <vector23>:
80106b81:	6a 00                	push   $0x0
80106b83:	6a 17                	push   $0x17
80106b85:	e9 5a f8 ff ff       	jmp    801063e4 <alltraps>

80106b8a <vector24>:
80106b8a:	6a 00                	push   $0x0
80106b8c:	6a 18                	push   $0x18
80106b8e:	e9 51 f8 ff ff       	jmp    801063e4 <alltraps>

80106b93 <vector25>:
80106b93:	6a 00                	push   $0x0
80106b95:	6a 19                	push   $0x19
80106b97:	e9 48 f8 ff ff       	jmp    801063e4 <alltraps>

80106b9c <vector26>:
80106b9c:	6a 00                	push   $0x0
80106b9e:	6a 1a                	push   $0x1a
80106ba0:	e9 3f f8 ff ff       	jmp    801063e4 <alltraps>

80106ba5 <vector27>:
80106ba5:	6a 00                	push   $0x0
80106ba7:	6a 1b                	push   $0x1b
80106ba9:	e9 36 f8 ff ff       	jmp    801063e4 <alltraps>

80106bae <vector28>:
80106bae:	6a 00                	push   $0x0
80106bb0:	6a 1c                	push   $0x1c
80106bb2:	e9 2d f8 ff ff       	jmp    801063e4 <alltraps>

80106bb7 <vector29>:
80106bb7:	6a 00                	push   $0x0
80106bb9:	6a 1d                	push   $0x1d
80106bbb:	e9 24 f8 ff ff       	jmp    801063e4 <alltraps>

80106bc0 <vector30>:
80106bc0:	6a 00                	push   $0x0
80106bc2:	6a 1e                	push   $0x1e
80106bc4:	e9 1b f8 ff ff       	jmp    801063e4 <alltraps>

80106bc9 <vector31>:
80106bc9:	6a 00                	push   $0x0
80106bcb:	6a 1f                	push   $0x1f
80106bcd:	e9 12 f8 ff ff       	jmp    801063e4 <alltraps>

80106bd2 <vector32>:
80106bd2:	6a 00                	push   $0x0
80106bd4:	6a 20                	push   $0x20
80106bd6:	e9 09 f8 ff ff       	jmp    801063e4 <alltraps>

80106bdb <vector33>:
80106bdb:	6a 00                	push   $0x0
80106bdd:	6a 21                	push   $0x21
80106bdf:	e9 00 f8 ff ff       	jmp    801063e4 <alltraps>

80106be4 <vector34>:
80106be4:	6a 00                	push   $0x0
80106be6:	6a 22                	push   $0x22
80106be8:	e9 f7 f7 ff ff       	jmp    801063e4 <alltraps>

80106bed <vector35>:
80106bed:	6a 00                	push   $0x0
80106bef:	6a 23                	push   $0x23
80106bf1:	e9 ee f7 ff ff       	jmp    801063e4 <alltraps>

80106bf6 <vector36>:
80106bf6:	6a 00                	push   $0x0
80106bf8:	6a 24                	push   $0x24
80106bfa:	e9 e5 f7 ff ff       	jmp    801063e4 <alltraps>

80106bff <vector37>:
80106bff:	6a 00                	push   $0x0
80106c01:	6a 25                	push   $0x25
80106c03:	e9 dc f7 ff ff       	jmp    801063e4 <alltraps>

80106c08 <vector38>:
80106c08:	6a 00                	push   $0x0
80106c0a:	6a 26                	push   $0x26
80106c0c:	e9 d3 f7 ff ff       	jmp    801063e4 <alltraps>

80106c11 <vector39>:
80106c11:	6a 00                	push   $0x0
80106c13:	6a 27                	push   $0x27
80106c15:	e9 ca f7 ff ff       	jmp    801063e4 <alltraps>

80106c1a <vector40>:
80106c1a:	6a 00                	push   $0x0
80106c1c:	6a 28                	push   $0x28
80106c1e:	e9 c1 f7 ff ff       	jmp    801063e4 <alltraps>

80106c23 <vector41>:
80106c23:	6a 00                	push   $0x0
80106c25:	6a 29                	push   $0x29
80106c27:	e9 b8 f7 ff ff       	jmp    801063e4 <alltraps>

80106c2c <vector42>:
80106c2c:	6a 00                	push   $0x0
80106c2e:	6a 2a                	push   $0x2a
80106c30:	e9 af f7 ff ff       	jmp    801063e4 <alltraps>

80106c35 <vector43>:
80106c35:	6a 00                	push   $0x0
80106c37:	6a 2b                	push   $0x2b
80106c39:	e9 a6 f7 ff ff       	jmp    801063e4 <alltraps>

80106c3e <vector44>:
80106c3e:	6a 00                	push   $0x0
80106c40:	6a 2c                	push   $0x2c
80106c42:	e9 9d f7 ff ff       	jmp    801063e4 <alltraps>

80106c47 <vector45>:
80106c47:	6a 00                	push   $0x0
80106c49:	6a 2d                	push   $0x2d
80106c4b:	e9 94 f7 ff ff       	jmp    801063e4 <alltraps>

80106c50 <vector46>:
80106c50:	6a 00                	push   $0x0
80106c52:	6a 2e                	push   $0x2e
80106c54:	e9 8b f7 ff ff       	jmp    801063e4 <alltraps>

80106c59 <vector47>:
80106c59:	6a 00                	push   $0x0
80106c5b:	6a 2f                	push   $0x2f
80106c5d:	e9 82 f7 ff ff       	jmp    801063e4 <alltraps>

80106c62 <vector48>:
80106c62:	6a 00                	push   $0x0
80106c64:	6a 30                	push   $0x30
80106c66:	e9 79 f7 ff ff       	jmp    801063e4 <alltraps>

80106c6b <vector49>:
80106c6b:	6a 00                	push   $0x0
80106c6d:	6a 31                	push   $0x31
80106c6f:	e9 70 f7 ff ff       	jmp    801063e4 <alltraps>

80106c74 <vector50>:
80106c74:	6a 00                	push   $0x0
80106c76:	6a 32                	push   $0x32
80106c78:	e9 67 f7 ff ff       	jmp    801063e4 <alltraps>

80106c7d <vector51>:
80106c7d:	6a 00                	push   $0x0
80106c7f:	6a 33                	push   $0x33
80106c81:	e9 5e f7 ff ff       	jmp    801063e4 <alltraps>

80106c86 <vector52>:
80106c86:	6a 00                	push   $0x0
80106c88:	6a 34                	push   $0x34
80106c8a:	e9 55 f7 ff ff       	jmp    801063e4 <alltraps>

80106c8f <vector53>:
80106c8f:	6a 00                	push   $0x0
80106c91:	6a 35                	push   $0x35
80106c93:	e9 4c f7 ff ff       	jmp    801063e4 <alltraps>

80106c98 <vector54>:
80106c98:	6a 00                	push   $0x0
80106c9a:	6a 36                	push   $0x36
80106c9c:	e9 43 f7 ff ff       	jmp    801063e4 <alltraps>

80106ca1 <vector55>:
80106ca1:	6a 00                	push   $0x0
80106ca3:	6a 37                	push   $0x37
80106ca5:	e9 3a f7 ff ff       	jmp    801063e4 <alltraps>

80106caa <vector56>:
80106caa:	6a 00                	push   $0x0
80106cac:	6a 38                	push   $0x38
80106cae:	e9 31 f7 ff ff       	jmp    801063e4 <alltraps>

80106cb3 <vector57>:
80106cb3:	6a 00                	push   $0x0
80106cb5:	6a 39                	push   $0x39
80106cb7:	e9 28 f7 ff ff       	jmp    801063e4 <alltraps>

80106cbc <vector58>:
80106cbc:	6a 00                	push   $0x0
80106cbe:	6a 3a                	push   $0x3a
80106cc0:	e9 1f f7 ff ff       	jmp    801063e4 <alltraps>

80106cc5 <vector59>:
80106cc5:	6a 00                	push   $0x0
80106cc7:	6a 3b                	push   $0x3b
80106cc9:	e9 16 f7 ff ff       	jmp    801063e4 <alltraps>

80106cce <vector60>:
80106cce:	6a 00                	push   $0x0
80106cd0:	6a 3c                	push   $0x3c
80106cd2:	e9 0d f7 ff ff       	jmp    801063e4 <alltraps>

80106cd7 <vector61>:
80106cd7:	6a 00                	push   $0x0
80106cd9:	6a 3d                	push   $0x3d
80106cdb:	e9 04 f7 ff ff       	jmp    801063e4 <alltraps>

80106ce0 <vector62>:
80106ce0:	6a 00                	push   $0x0
80106ce2:	6a 3e                	push   $0x3e
80106ce4:	e9 fb f6 ff ff       	jmp    801063e4 <alltraps>

80106ce9 <vector63>:
80106ce9:	6a 00                	push   $0x0
80106ceb:	6a 3f                	push   $0x3f
80106ced:	e9 f2 f6 ff ff       	jmp    801063e4 <alltraps>

80106cf2 <vector64>:
80106cf2:	6a 00                	push   $0x0
80106cf4:	6a 40                	push   $0x40
80106cf6:	e9 e9 f6 ff ff       	jmp    801063e4 <alltraps>

80106cfb <vector65>:
80106cfb:	6a 00                	push   $0x0
80106cfd:	6a 41                	push   $0x41
80106cff:	e9 e0 f6 ff ff       	jmp    801063e4 <alltraps>

80106d04 <vector66>:
80106d04:	6a 00                	push   $0x0
80106d06:	6a 42                	push   $0x42
80106d08:	e9 d7 f6 ff ff       	jmp    801063e4 <alltraps>

80106d0d <vector67>:
80106d0d:	6a 00                	push   $0x0
80106d0f:	6a 43                	push   $0x43
80106d11:	e9 ce f6 ff ff       	jmp    801063e4 <alltraps>

80106d16 <vector68>:
80106d16:	6a 00                	push   $0x0
80106d18:	6a 44                	push   $0x44
80106d1a:	e9 c5 f6 ff ff       	jmp    801063e4 <alltraps>

80106d1f <vector69>:
80106d1f:	6a 00                	push   $0x0
80106d21:	6a 45                	push   $0x45
80106d23:	e9 bc f6 ff ff       	jmp    801063e4 <alltraps>

80106d28 <vector70>:
80106d28:	6a 00                	push   $0x0
80106d2a:	6a 46                	push   $0x46
80106d2c:	e9 b3 f6 ff ff       	jmp    801063e4 <alltraps>

80106d31 <vector71>:
80106d31:	6a 00                	push   $0x0
80106d33:	6a 47                	push   $0x47
80106d35:	e9 aa f6 ff ff       	jmp    801063e4 <alltraps>

80106d3a <vector72>:
80106d3a:	6a 00                	push   $0x0
80106d3c:	6a 48                	push   $0x48
80106d3e:	e9 a1 f6 ff ff       	jmp    801063e4 <alltraps>

80106d43 <vector73>:
80106d43:	6a 00                	push   $0x0
80106d45:	6a 49                	push   $0x49
80106d47:	e9 98 f6 ff ff       	jmp    801063e4 <alltraps>

80106d4c <vector74>:
80106d4c:	6a 00                	push   $0x0
80106d4e:	6a 4a                	push   $0x4a
80106d50:	e9 8f f6 ff ff       	jmp    801063e4 <alltraps>

80106d55 <vector75>:
80106d55:	6a 00                	push   $0x0
80106d57:	6a 4b                	push   $0x4b
80106d59:	e9 86 f6 ff ff       	jmp    801063e4 <alltraps>

80106d5e <vector76>:
80106d5e:	6a 00                	push   $0x0
80106d60:	6a 4c                	push   $0x4c
80106d62:	e9 7d f6 ff ff       	jmp    801063e4 <alltraps>

80106d67 <vector77>:
80106d67:	6a 00                	push   $0x0
80106d69:	6a 4d                	push   $0x4d
80106d6b:	e9 74 f6 ff ff       	jmp    801063e4 <alltraps>

80106d70 <vector78>:
80106d70:	6a 00                	push   $0x0
80106d72:	6a 4e                	push   $0x4e
80106d74:	e9 6b f6 ff ff       	jmp    801063e4 <alltraps>

80106d79 <vector79>:
80106d79:	6a 00                	push   $0x0
80106d7b:	6a 4f                	push   $0x4f
80106d7d:	e9 62 f6 ff ff       	jmp    801063e4 <alltraps>

80106d82 <vector80>:
80106d82:	6a 00                	push   $0x0
80106d84:	6a 50                	push   $0x50
80106d86:	e9 59 f6 ff ff       	jmp    801063e4 <alltraps>

80106d8b <vector81>:
80106d8b:	6a 00                	push   $0x0
80106d8d:	6a 51                	push   $0x51
80106d8f:	e9 50 f6 ff ff       	jmp    801063e4 <alltraps>

80106d94 <vector82>:
80106d94:	6a 00                	push   $0x0
80106d96:	6a 52                	push   $0x52
80106d98:	e9 47 f6 ff ff       	jmp    801063e4 <alltraps>

80106d9d <vector83>:
80106d9d:	6a 00                	push   $0x0
80106d9f:	6a 53                	push   $0x53
80106da1:	e9 3e f6 ff ff       	jmp    801063e4 <alltraps>

80106da6 <vector84>:
80106da6:	6a 00                	push   $0x0
80106da8:	6a 54                	push   $0x54
80106daa:	e9 35 f6 ff ff       	jmp    801063e4 <alltraps>

80106daf <vector85>:
80106daf:	6a 00                	push   $0x0
80106db1:	6a 55                	push   $0x55
80106db3:	e9 2c f6 ff ff       	jmp    801063e4 <alltraps>

80106db8 <vector86>:
80106db8:	6a 00                	push   $0x0
80106dba:	6a 56                	push   $0x56
80106dbc:	e9 23 f6 ff ff       	jmp    801063e4 <alltraps>

80106dc1 <vector87>:
80106dc1:	6a 00                	push   $0x0
80106dc3:	6a 57                	push   $0x57
80106dc5:	e9 1a f6 ff ff       	jmp    801063e4 <alltraps>

80106dca <vector88>:
80106dca:	6a 00                	push   $0x0
80106dcc:	6a 58                	push   $0x58
80106dce:	e9 11 f6 ff ff       	jmp    801063e4 <alltraps>

80106dd3 <vector89>:
80106dd3:	6a 00                	push   $0x0
80106dd5:	6a 59                	push   $0x59
80106dd7:	e9 08 f6 ff ff       	jmp    801063e4 <alltraps>

80106ddc <vector90>:
80106ddc:	6a 00                	push   $0x0
80106dde:	6a 5a                	push   $0x5a
80106de0:	e9 ff f5 ff ff       	jmp    801063e4 <alltraps>

80106de5 <vector91>:
80106de5:	6a 00                	push   $0x0
80106de7:	6a 5b                	push   $0x5b
80106de9:	e9 f6 f5 ff ff       	jmp    801063e4 <alltraps>

80106dee <vector92>:
80106dee:	6a 00                	push   $0x0
80106df0:	6a 5c                	push   $0x5c
80106df2:	e9 ed f5 ff ff       	jmp    801063e4 <alltraps>

80106df7 <vector93>:
80106df7:	6a 00                	push   $0x0
80106df9:	6a 5d                	push   $0x5d
80106dfb:	e9 e4 f5 ff ff       	jmp    801063e4 <alltraps>

80106e00 <vector94>:
80106e00:	6a 00                	push   $0x0
80106e02:	6a 5e                	push   $0x5e
80106e04:	e9 db f5 ff ff       	jmp    801063e4 <alltraps>

80106e09 <vector95>:
80106e09:	6a 00                	push   $0x0
80106e0b:	6a 5f                	push   $0x5f
80106e0d:	e9 d2 f5 ff ff       	jmp    801063e4 <alltraps>

80106e12 <vector96>:
80106e12:	6a 00                	push   $0x0
80106e14:	6a 60                	push   $0x60
80106e16:	e9 c9 f5 ff ff       	jmp    801063e4 <alltraps>

80106e1b <vector97>:
80106e1b:	6a 00                	push   $0x0
80106e1d:	6a 61                	push   $0x61
80106e1f:	e9 c0 f5 ff ff       	jmp    801063e4 <alltraps>

80106e24 <vector98>:
80106e24:	6a 00                	push   $0x0
80106e26:	6a 62                	push   $0x62
80106e28:	e9 b7 f5 ff ff       	jmp    801063e4 <alltraps>

80106e2d <vector99>:
80106e2d:	6a 00                	push   $0x0
80106e2f:	6a 63                	push   $0x63
80106e31:	e9 ae f5 ff ff       	jmp    801063e4 <alltraps>

80106e36 <vector100>:
80106e36:	6a 00                	push   $0x0
80106e38:	6a 64                	push   $0x64
80106e3a:	e9 a5 f5 ff ff       	jmp    801063e4 <alltraps>

80106e3f <vector101>:
80106e3f:	6a 00                	push   $0x0
80106e41:	6a 65                	push   $0x65
80106e43:	e9 9c f5 ff ff       	jmp    801063e4 <alltraps>

80106e48 <vector102>:
80106e48:	6a 00                	push   $0x0
80106e4a:	6a 66                	push   $0x66
80106e4c:	e9 93 f5 ff ff       	jmp    801063e4 <alltraps>

80106e51 <vector103>:
80106e51:	6a 00                	push   $0x0
80106e53:	6a 67                	push   $0x67
80106e55:	e9 8a f5 ff ff       	jmp    801063e4 <alltraps>

80106e5a <vector104>:
80106e5a:	6a 00                	push   $0x0
80106e5c:	6a 68                	push   $0x68
80106e5e:	e9 81 f5 ff ff       	jmp    801063e4 <alltraps>

80106e63 <vector105>:
80106e63:	6a 00                	push   $0x0
80106e65:	6a 69                	push   $0x69
80106e67:	e9 78 f5 ff ff       	jmp    801063e4 <alltraps>

80106e6c <vector106>:
80106e6c:	6a 00                	push   $0x0
80106e6e:	6a 6a                	push   $0x6a
80106e70:	e9 6f f5 ff ff       	jmp    801063e4 <alltraps>

80106e75 <vector107>:
80106e75:	6a 00                	push   $0x0
80106e77:	6a 6b                	push   $0x6b
80106e79:	e9 66 f5 ff ff       	jmp    801063e4 <alltraps>

80106e7e <vector108>:
80106e7e:	6a 00                	push   $0x0
80106e80:	6a 6c                	push   $0x6c
80106e82:	e9 5d f5 ff ff       	jmp    801063e4 <alltraps>

80106e87 <vector109>:
80106e87:	6a 00                	push   $0x0
80106e89:	6a 6d                	push   $0x6d
80106e8b:	e9 54 f5 ff ff       	jmp    801063e4 <alltraps>

80106e90 <vector110>:
80106e90:	6a 00                	push   $0x0
80106e92:	6a 6e                	push   $0x6e
80106e94:	e9 4b f5 ff ff       	jmp    801063e4 <alltraps>

80106e99 <vector111>:
80106e99:	6a 00                	push   $0x0
80106e9b:	6a 6f                	push   $0x6f
80106e9d:	e9 42 f5 ff ff       	jmp    801063e4 <alltraps>

80106ea2 <vector112>:
80106ea2:	6a 00                	push   $0x0
80106ea4:	6a 70                	push   $0x70
80106ea6:	e9 39 f5 ff ff       	jmp    801063e4 <alltraps>

80106eab <vector113>:
80106eab:	6a 00                	push   $0x0
80106ead:	6a 71                	push   $0x71
80106eaf:	e9 30 f5 ff ff       	jmp    801063e4 <alltraps>

80106eb4 <vector114>:
80106eb4:	6a 00                	push   $0x0
80106eb6:	6a 72                	push   $0x72
80106eb8:	e9 27 f5 ff ff       	jmp    801063e4 <alltraps>

80106ebd <vector115>:
80106ebd:	6a 00                	push   $0x0
80106ebf:	6a 73                	push   $0x73
80106ec1:	e9 1e f5 ff ff       	jmp    801063e4 <alltraps>

80106ec6 <vector116>:
80106ec6:	6a 00                	push   $0x0
80106ec8:	6a 74                	push   $0x74
80106eca:	e9 15 f5 ff ff       	jmp    801063e4 <alltraps>

80106ecf <vector117>:
80106ecf:	6a 00                	push   $0x0
80106ed1:	6a 75                	push   $0x75
80106ed3:	e9 0c f5 ff ff       	jmp    801063e4 <alltraps>

80106ed8 <vector118>:
80106ed8:	6a 00                	push   $0x0
80106eda:	6a 76                	push   $0x76
80106edc:	e9 03 f5 ff ff       	jmp    801063e4 <alltraps>

80106ee1 <vector119>:
80106ee1:	6a 00                	push   $0x0
80106ee3:	6a 77                	push   $0x77
80106ee5:	e9 fa f4 ff ff       	jmp    801063e4 <alltraps>

80106eea <vector120>:
80106eea:	6a 00                	push   $0x0
80106eec:	6a 78                	push   $0x78
80106eee:	e9 f1 f4 ff ff       	jmp    801063e4 <alltraps>

80106ef3 <vector121>:
80106ef3:	6a 00                	push   $0x0
80106ef5:	6a 79                	push   $0x79
80106ef7:	e9 e8 f4 ff ff       	jmp    801063e4 <alltraps>

80106efc <vector122>:
80106efc:	6a 00                	push   $0x0
80106efe:	6a 7a                	push   $0x7a
80106f00:	e9 df f4 ff ff       	jmp    801063e4 <alltraps>

80106f05 <vector123>:
80106f05:	6a 00                	push   $0x0
80106f07:	6a 7b                	push   $0x7b
80106f09:	e9 d6 f4 ff ff       	jmp    801063e4 <alltraps>

80106f0e <vector124>:
80106f0e:	6a 00                	push   $0x0
80106f10:	6a 7c                	push   $0x7c
80106f12:	e9 cd f4 ff ff       	jmp    801063e4 <alltraps>

80106f17 <vector125>:
80106f17:	6a 00                	push   $0x0
80106f19:	6a 7d                	push   $0x7d
80106f1b:	e9 c4 f4 ff ff       	jmp    801063e4 <alltraps>

80106f20 <vector126>:
80106f20:	6a 00                	push   $0x0
80106f22:	6a 7e                	push   $0x7e
80106f24:	e9 bb f4 ff ff       	jmp    801063e4 <alltraps>

80106f29 <vector127>:
80106f29:	6a 00                	push   $0x0
80106f2b:	6a 7f                	push   $0x7f
80106f2d:	e9 b2 f4 ff ff       	jmp    801063e4 <alltraps>

80106f32 <vector128>:
80106f32:	6a 00                	push   $0x0
80106f34:	68 80 00 00 00       	push   $0x80
80106f39:	e9 a6 f4 ff ff       	jmp    801063e4 <alltraps>

80106f3e <vector129>:
80106f3e:	6a 00                	push   $0x0
80106f40:	68 81 00 00 00       	push   $0x81
80106f45:	e9 9a f4 ff ff       	jmp    801063e4 <alltraps>

80106f4a <vector130>:
80106f4a:	6a 00                	push   $0x0
80106f4c:	68 82 00 00 00       	push   $0x82
80106f51:	e9 8e f4 ff ff       	jmp    801063e4 <alltraps>

80106f56 <vector131>:
80106f56:	6a 00                	push   $0x0
80106f58:	68 83 00 00 00       	push   $0x83
80106f5d:	e9 82 f4 ff ff       	jmp    801063e4 <alltraps>

80106f62 <vector132>:
80106f62:	6a 00                	push   $0x0
80106f64:	68 84 00 00 00       	push   $0x84
80106f69:	e9 76 f4 ff ff       	jmp    801063e4 <alltraps>

80106f6e <vector133>:
80106f6e:	6a 00                	push   $0x0
80106f70:	68 85 00 00 00       	push   $0x85
80106f75:	e9 6a f4 ff ff       	jmp    801063e4 <alltraps>

80106f7a <vector134>:
80106f7a:	6a 00                	push   $0x0
80106f7c:	68 86 00 00 00       	push   $0x86
80106f81:	e9 5e f4 ff ff       	jmp    801063e4 <alltraps>

80106f86 <vector135>:
80106f86:	6a 00                	push   $0x0
80106f88:	68 87 00 00 00       	push   $0x87
80106f8d:	e9 52 f4 ff ff       	jmp    801063e4 <alltraps>

80106f92 <vector136>:
80106f92:	6a 00                	push   $0x0
80106f94:	68 88 00 00 00       	push   $0x88
80106f99:	e9 46 f4 ff ff       	jmp    801063e4 <alltraps>

80106f9e <vector137>:
80106f9e:	6a 00                	push   $0x0
80106fa0:	68 89 00 00 00       	push   $0x89
80106fa5:	e9 3a f4 ff ff       	jmp    801063e4 <alltraps>

80106faa <vector138>:
80106faa:	6a 00                	push   $0x0
80106fac:	68 8a 00 00 00       	push   $0x8a
80106fb1:	e9 2e f4 ff ff       	jmp    801063e4 <alltraps>

80106fb6 <vector139>:
80106fb6:	6a 00                	push   $0x0
80106fb8:	68 8b 00 00 00       	push   $0x8b
80106fbd:	e9 22 f4 ff ff       	jmp    801063e4 <alltraps>

80106fc2 <vector140>:
80106fc2:	6a 00                	push   $0x0
80106fc4:	68 8c 00 00 00       	push   $0x8c
80106fc9:	e9 16 f4 ff ff       	jmp    801063e4 <alltraps>

80106fce <vector141>:
80106fce:	6a 00                	push   $0x0
80106fd0:	68 8d 00 00 00       	push   $0x8d
80106fd5:	e9 0a f4 ff ff       	jmp    801063e4 <alltraps>

80106fda <vector142>:
80106fda:	6a 00                	push   $0x0
80106fdc:	68 8e 00 00 00       	push   $0x8e
80106fe1:	e9 fe f3 ff ff       	jmp    801063e4 <alltraps>

80106fe6 <vector143>:
80106fe6:	6a 00                	push   $0x0
80106fe8:	68 8f 00 00 00       	push   $0x8f
80106fed:	e9 f2 f3 ff ff       	jmp    801063e4 <alltraps>

80106ff2 <vector144>:
80106ff2:	6a 00                	push   $0x0
80106ff4:	68 90 00 00 00       	push   $0x90
80106ff9:	e9 e6 f3 ff ff       	jmp    801063e4 <alltraps>

80106ffe <vector145>:
80106ffe:	6a 00                	push   $0x0
80107000:	68 91 00 00 00       	push   $0x91
80107005:	e9 da f3 ff ff       	jmp    801063e4 <alltraps>

8010700a <vector146>:
8010700a:	6a 00                	push   $0x0
8010700c:	68 92 00 00 00       	push   $0x92
80107011:	e9 ce f3 ff ff       	jmp    801063e4 <alltraps>

80107016 <vector147>:
80107016:	6a 00                	push   $0x0
80107018:	68 93 00 00 00       	push   $0x93
8010701d:	e9 c2 f3 ff ff       	jmp    801063e4 <alltraps>

80107022 <vector148>:
80107022:	6a 00                	push   $0x0
80107024:	68 94 00 00 00       	push   $0x94
80107029:	e9 b6 f3 ff ff       	jmp    801063e4 <alltraps>

8010702e <vector149>:
8010702e:	6a 00                	push   $0x0
80107030:	68 95 00 00 00       	push   $0x95
80107035:	e9 aa f3 ff ff       	jmp    801063e4 <alltraps>

8010703a <vector150>:
8010703a:	6a 00                	push   $0x0
8010703c:	68 96 00 00 00       	push   $0x96
80107041:	e9 9e f3 ff ff       	jmp    801063e4 <alltraps>

80107046 <vector151>:
80107046:	6a 00                	push   $0x0
80107048:	68 97 00 00 00       	push   $0x97
8010704d:	e9 92 f3 ff ff       	jmp    801063e4 <alltraps>

80107052 <vector152>:
80107052:	6a 00                	push   $0x0
80107054:	68 98 00 00 00       	push   $0x98
80107059:	e9 86 f3 ff ff       	jmp    801063e4 <alltraps>

8010705e <vector153>:
8010705e:	6a 00                	push   $0x0
80107060:	68 99 00 00 00       	push   $0x99
80107065:	e9 7a f3 ff ff       	jmp    801063e4 <alltraps>

8010706a <vector154>:
8010706a:	6a 00                	push   $0x0
8010706c:	68 9a 00 00 00       	push   $0x9a
80107071:	e9 6e f3 ff ff       	jmp    801063e4 <alltraps>

80107076 <vector155>:
80107076:	6a 00                	push   $0x0
80107078:	68 9b 00 00 00       	push   $0x9b
8010707d:	e9 62 f3 ff ff       	jmp    801063e4 <alltraps>

80107082 <vector156>:
80107082:	6a 00                	push   $0x0
80107084:	68 9c 00 00 00       	push   $0x9c
80107089:	e9 56 f3 ff ff       	jmp    801063e4 <alltraps>

8010708e <vector157>:
8010708e:	6a 00                	push   $0x0
80107090:	68 9d 00 00 00       	push   $0x9d
80107095:	e9 4a f3 ff ff       	jmp    801063e4 <alltraps>

8010709a <vector158>:
8010709a:	6a 00                	push   $0x0
8010709c:	68 9e 00 00 00       	push   $0x9e
801070a1:	e9 3e f3 ff ff       	jmp    801063e4 <alltraps>

801070a6 <vector159>:
801070a6:	6a 00                	push   $0x0
801070a8:	68 9f 00 00 00       	push   $0x9f
801070ad:	e9 32 f3 ff ff       	jmp    801063e4 <alltraps>

801070b2 <vector160>:
801070b2:	6a 00                	push   $0x0
801070b4:	68 a0 00 00 00       	push   $0xa0
801070b9:	e9 26 f3 ff ff       	jmp    801063e4 <alltraps>

801070be <vector161>:
801070be:	6a 00                	push   $0x0
801070c0:	68 a1 00 00 00       	push   $0xa1
801070c5:	e9 1a f3 ff ff       	jmp    801063e4 <alltraps>

801070ca <vector162>:
801070ca:	6a 00                	push   $0x0
801070cc:	68 a2 00 00 00       	push   $0xa2
801070d1:	e9 0e f3 ff ff       	jmp    801063e4 <alltraps>

801070d6 <vector163>:
801070d6:	6a 00                	push   $0x0
801070d8:	68 a3 00 00 00       	push   $0xa3
801070dd:	e9 02 f3 ff ff       	jmp    801063e4 <alltraps>

801070e2 <vector164>:
801070e2:	6a 00                	push   $0x0
801070e4:	68 a4 00 00 00       	push   $0xa4
801070e9:	e9 f6 f2 ff ff       	jmp    801063e4 <alltraps>

801070ee <vector165>:
801070ee:	6a 00                	push   $0x0
801070f0:	68 a5 00 00 00       	push   $0xa5
801070f5:	e9 ea f2 ff ff       	jmp    801063e4 <alltraps>

801070fa <vector166>:
801070fa:	6a 00                	push   $0x0
801070fc:	68 a6 00 00 00       	push   $0xa6
80107101:	e9 de f2 ff ff       	jmp    801063e4 <alltraps>

80107106 <vector167>:
80107106:	6a 00                	push   $0x0
80107108:	68 a7 00 00 00       	push   $0xa7
8010710d:	e9 d2 f2 ff ff       	jmp    801063e4 <alltraps>

80107112 <vector168>:
80107112:	6a 00                	push   $0x0
80107114:	68 a8 00 00 00       	push   $0xa8
80107119:	e9 c6 f2 ff ff       	jmp    801063e4 <alltraps>

8010711e <vector169>:
8010711e:	6a 00                	push   $0x0
80107120:	68 a9 00 00 00       	push   $0xa9
80107125:	e9 ba f2 ff ff       	jmp    801063e4 <alltraps>

8010712a <vector170>:
8010712a:	6a 00                	push   $0x0
8010712c:	68 aa 00 00 00       	push   $0xaa
80107131:	e9 ae f2 ff ff       	jmp    801063e4 <alltraps>

80107136 <vector171>:
80107136:	6a 00                	push   $0x0
80107138:	68 ab 00 00 00       	push   $0xab
8010713d:	e9 a2 f2 ff ff       	jmp    801063e4 <alltraps>

80107142 <vector172>:
80107142:	6a 00                	push   $0x0
80107144:	68 ac 00 00 00       	push   $0xac
80107149:	e9 96 f2 ff ff       	jmp    801063e4 <alltraps>

8010714e <vector173>:
8010714e:	6a 00                	push   $0x0
80107150:	68 ad 00 00 00       	push   $0xad
80107155:	e9 8a f2 ff ff       	jmp    801063e4 <alltraps>

8010715a <vector174>:
8010715a:	6a 00                	push   $0x0
8010715c:	68 ae 00 00 00       	push   $0xae
80107161:	e9 7e f2 ff ff       	jmp    801063e4 <alltraps>

80107166 <vector175>:
80107166:	6a 00                	push   $0x0
80107168:	68 af 00 00 00       	push   $0xaf
8010716d:	e9 72 f2 ff ff       	jmp    801063e4 <alltraps>

80107172 <vector176>:
80107172:	6a 00                	push   $0x0
80107174:	68 b0 00 00 00       	push   $0xb0
80107179:	e9 66 f2 ff ff       	jmp    801063e4 <alltraps>

8010717e <vector177>:
8010717e:	6a 00                	push   $0x0
80107180:	68 b1 00 00 00       	push   $0xb1
80107185:	e9 5a f2 ff ff       	jmp    801063e4 <alltraps>

8010718a <vector178>:
8010718a:	6a 00                	push   $0x0
8010718c:	68 b2 00 00 00       	push   $0xb2
80107191:	e9 4e f2 ff ff       	jmp    801063e4 <alltraps>

80107196 <vector179>:
80107196:	6a 00                	push   $0x0
80107198:	68 b3 00 00 00       	push   $0xb3
8010719d:	e9 42 f2 ff ff       	jmp    801063e4 <alltraps>

801071a2 <vector180>:
801071a2:	6a 00                	push   $0x0
801071a4:	68 b4 00 00 00       	push   $0xb4
801071a9:	e9 36 f2 ff ff       	jmp    801063e4 <alltraps>

801071ae <vector181>:
801071ae:	6a 00                	push   $0x0
801071b0:	68 b5 00 00 00       	push   $0xb5
801071b5:	e9 2a f2 ff ff       	jmp    801063e4 <alltraps>

801071ba <vector182>:
801071ba:	6a 00                	push   $0x0
801071bc:	68 b6 00 00 00       	push   $0xb6
801071c1:	e9 1e f2 ff ff       	jmp    801063e4 <alltraps>

801071c6 <vector183>:
801071c6:	6a 00                	push   $0x0
801071c8:	68 b7 00 00 00       	push   $0xb7
801071cd:	e9 12 f2 ff ff       	jmp    801063e4 <alltraps>

801071d2 <vector184>:
801071d2:	6a 00                	push   $0x0
801071d4:	68 b8 00 00 00       	push   $0xb8
801071d9:	e9 06 f2 ff ff       	jmp    801063e4 <alltraps>

801071de <vector185>:
801071de:	6a 00                	push   $0x0
801071e0:	68 b9 00 00 00       	push   $0xb9
801071e5:	e9 fa f1 ff ff       	jmp    801063e4 <alltraps>

801071ea <vector186>:
801071ea:	6a 00                	push   $0x0
801071ec:	68 ba 00 00 00       	push   $0xba
801071f1:	e9 ee f1 ff ff       	jmp    801063e4 <alltraps>

801071f6 <vector187>:
801071f6:	6a 00                	push   $0x0
801071f8:	68 bb 00 00 00       	push   $0xbb
801071fd:	e9 e2 f1 ff ff       	jmp    801063e4 <alltraps>

80107202 <vector188>:
80107202:	6a 00                	push   $0x0
80107204:	68 bc 00 00 00       	push   $0xbc
80107209:	e9 d6 f1 ff ff       	jmp    801063e4 <alltraps>

8010720e <vector189>:
8010720e:	6a 00                	push   $0x0
80107210:	68 bd 00 00 00       	push   $0xbd
80107215:	e9 ca f1 ff ff       	jmp    801063e4 <alltraps>

8010721a <vector190>:
8010721a:	6a 00                	push   $0x0
8010721c:	68 be 00 00 00       	push   $0xbe
80107221:	e9 be f1 ff ff       	jmp    801063e4 <alltraps>

80107226 <vector191>:
80107226:	6a 00                	push   $0x0
80107228:	68 bf 00 00 00       	push   $0xbf
8010722d:	e9 b2 f1 ff ff       	jmp    801063e4 <alltraps>

80107232 <vector192>:
80107232:	6a 00                	push   $0x0
80107234:	68 c0 00 00 00       	push   $0xc0
80107239:	e9 a6 f1 ff ff       	jmp    801063e4 <alltraps>

8010723e <vector193>:
8010723e:	6a 00                	push   $0x0
80107240:	68 c1 00 00 00       	push   $0xc1
80107245:	e9 9a f1 ff ff       	jmp    801063e4 <alltraps>

8010724a <vector194>:
8010724a:	6a 00                	push   $0x0
8010724c:	68 c2 00 00 00       	push   $0xc2
80107251:	e9 8e f1 ff ff       	jmp    801063e4 <alltraps>

80107256 <vector195>:
80107256:	6a 00                	push   $0x0
80107258:	68 c3 00 00 00       	push   $0xc3
8010725d:	e9 82 f1 ff ff       	jmp    801063e4 <alltraps>

80107262 <vector196>:
80107262:	6a 00                	push   $0x0
80107264:	68 c4 00 00 00       	push   $0xc4
80107269:	e9 76 f1 ff ff       	jmp    801063e4 <alltraps>

8010726e <vector197>:
8010726e:	6a 00                	push   $0x0
80107270:	68 c5 00 00 00       	push   $0xc5
80107275:	e9 6a f1 ff ff       	jmp    801063e4 <alltraps>

8010727a <vector198>:
8010727a:	6a 00                	push   $0x0
8010727c:	68 c6 00 00 00       	push   $0xc6
80107281:	e9 5e f1 ff ff       	jmp    801063e4 <alltraps>

80107286 <vector199>:
80107286:	6a 00                	push   $0x0
80107288:	68 c7 00 00 00       	push   $0xc7
8010728d:	e9 52 f1 ff ff       	jmp    801063e4 <alltraps>

80107292 <vector200>:
80107292:	6a 00                	push   $0x0
80107294:	68 c8 00 00 00       	push   $0xc8
80107299:	e9 46 f1 ff ff       	jmp    801063e4 <alltraps>

8010729e <vector201>:
8010729e:	6a 00                	push   $0x0
801072a0:	68 c9 00 00 00       	push   $0xc9
801072a5:	e9 3a f1 ff ff       	jmp    801063e4 <alltraps>

801072aa <vector202>:
801072aa:	6a 00                	push   $0x0
801072ac:	68 ca 00 00 00       	push   $0xca
801072b1:	e9 2e f1 ff ff       	jmp    801063e4 <alltraps>

801072b6 <vector203>:
801072b6:	6a 00                	push   $0x0
801072b8:	68 cb 00 00 00       	push   $0xcb
801072bd:	e9 22 f1 ff ff       	jmp    801063e4 <alltraps>

801072c2 <vector204>:
801072c2:	6a 00                	push   $0x0
801072c4:	68 cc 00 00 00       	push   $0xcc
801072c9:	e9 16 f1 ff ff       	jmp    801063e4 <alltraps>

801072ce <vector205>:
801072ce:	6a 00                	push   $0x0
801072d0:	68 cd 00 00 00       	push   $0xcd
801072d5:	e9 0a f1 ff ff       	jmp    801063e4 <alltraps>

801072da <vector206>:
801072da:	6a 00                	push   $0x0
801072dc:	68 ce 00 00 00       	push   $0xce
801072e1:	e9 fe f0 ff ff       	jmp    801063e4 <alltraps>

801072e6 <vector207>:
801072e6:	6a 00                	push   $0x0
801072e8:	68 cf 00 00 00       	push   $0xcf
801072ed:	e9 f2 f0 ff ff       	jmp    801063e4 <alltraps>

801072f2 <vector208>:
801072f2:	6a 00                	push   $0x0
801072f4:	68 d0 00 00 00       	push   $0xd0
801072f9:	e9 e6 f0 ff ff       	jmp    801063e4 <alltraps>

801072fe <vector209>:
801072fe:	6a 00                	push   $0x0
80107300:	68 d1 00 00 00       	push   $0xd1
80107305:	e9 da f0 ff ff       	jmp    801063e4 <alltraps>

8010730a <vector210>:
8010730a:	6a 00                	push   $0x0
8010730c:	68 d2 00 00 00       	push   $0xd2
80107311:	e9 ce f0 ff ff       	jmp    801063e4 <alltraps>

80107316 <vector211>:
80107316:	6a 00                	push   $0x0
80107318:	68 d3 00 00 00       	push   $0xd3
8010731d:	e9 c2 f0 ff ff       	jmp    801063e4 <alltraps>

80107322 <vector212>:
80107322:	6a 00                	push   $0x0
80107324:	68 d4 00 00 00       	push   $0xd4
80107329:	e9 b6 f0 ff ff       	jmp    801063e4 <alltraps>

8010732e <vector213>:
8010732e:	6a 00                	push   $0x0
80107330:	68 d5 00 00 00       	push   $0xd5
80107335:	e9 aa f0 ff ff       	jmp    801063e4 <alltraps>

8010733a <vector214>:
8010733a:	6a 00                	push   $0x0
8010733c:	68 d6 00 00 00       	push   $0xd6
80107341:	e9 9e f0 ff ff       	jmp    801063e4 <alltraps>

80107346 <vector215>:
80107346:	6a 00                	push   $0x0
80107348:	68 d7 00 00 00       	push   $0xd7
8010734d:	e9 92 f0 ff ff       	jmp    801063e4 <alltraps>

80107352 <vector216>:
80107352:	6a 00                	push   $0x0
80107354:	68 d8 00 00 00       	push   $0xd8
80107359:	e9 86 f0 ff ff       	jmp    801063e4 <alltraps>

8010735e <vector217>:
8010735e:	6a 00                	push   $0x0
80107360:	68 d9 00 00 00       	push   $0xd9
80107365:	e9 7a f0 ff ff       	jmp    801063e4 <alltraps>

8010736a <vector218>:
8010736a:	6a 00                	push   $0x0
8010736c:	68 da 00 00 00       	push   $0xda
80107371:	e9 6e f0 ff ff       	jmp    801063e4 <alltraps>

80107376 <vector219>:
80107376:	6a 00                	push   $0x0
80107378:	68 db 00 00 00       	push   $0xdb
8010737d:	e9 62 f0 ff ff       	jmp    801063e4 <alltraps>

80107382 <vector220>:
80107382:	6a 00                	push   $0x0
80107384:	68 dc 00 00 00       	push   $0xdc
80107389:	e9 56 f0 ff ff       	jmp    801063e4 <alltraps>

8010738e <vector221>:
8010738e:	6a 00                	push   $0x0
80107390:	68 dd 00 00 00       	push   $0xdd
80107395:	e9 4a f0 ff ff       	jmp    801063e4 <alltraps>

8010739a <vector222>:
8010739a:	6a 00                	push   $0x0
8010739c:	68 de 00 00 00       	push   $0xde
801073a1:	e9 3e f0 ff ff       	jmp    801063e4 <alltraps>

801073a6 <vector223>:
801073a6:	6a 00                	push   $0x0
801073a8:	68 df 00 00 00       	push   $0xdf
801073ad:	e9 32 f0 ff ff       	jmp    801063e4 <alltraps>

801073b2 <vector224>:
801073b2:	6a 00                	push   $0x0
801073b4:	68 e0 00 00 00       	push   $0xe0
801073b9:	e9 26 f0 ff ff       	jmp    801063e4 <alltraps>

801073be <vector225>:
801073be:	6a 00                	push   $0x0
801073c0:	68 e1 00 00 00       	push   $0xe1
801073c5:	e9 1a f0 ff ff       	jmp    801063e4 <alltraps>

801073ca <vector226>:
801073ca:	6a 00                	push   $0x0
801073cc:	68 e2 00 00 00       	push   $0xe2
801073d1:	e9 0e f0 ff ff       	jmp    801063e4 <alltraps>

801073d6 <vector227>:
801073d6:	6a 00                	push   $0x0
801073d8:	68 e3 00 00 00       	push   $0xe3
801073dd:	e9 02 f0 ff ff       	jmp    801063e4 <alltraps>

801073e2 <vector228>:
801073e2:	6a 00                	push   $0x0
801073e4:	68 e4 00 00 00       	push   $0xe4
801073e9:	e9 f6 ef ff ff       	jmp    801063e4 <alltraps>

801073ee <vector229>:
801073ee:	6a 00                	push   $0x0
801073f0:	68 e5 00 00 00       	push   $0xe5
801073f5:	e9 ea ef ff ff       	jmp    801063e4 <alltraps>

801073fa <vector230>:
801073fa:	6a 00                	push   $0x0
801073fc:	68 e6 00 00 00       	push   $0xe6
80107401:	e9 de ef ff ff       	jmp    801063e4 <alltraps>

80107406 <vector231>:
80107406:	6a 00                	push   $0x0
80107408:	68 e7 00 00 00       	push   $0xe7
8010740d:	e9 d2 ef ff ff       	jmp    801063e4 <alltraps>

80107412 <vector232>:
80107412:	6a 00                	push   $0x0
80107414:	68 e8 00 00 00       	push   $0xe8
80107419:	e9 c6 ef ff ff       	jmp    801063e4 <alltraps>

8010741e <vector233>:
8010741e:	6a 00                	push   $0x0
80107420:	68 e9 00 00 00       	push   $0xe9
80107425:	e9 ba ef ff ff       	jmp    801063e4 <alltraps>

8010742a <vector234>:
8010742a:	6a 00                	push   $0x0
8010742c:	68 ea 00 00 00       	push   $0xea
80107431:	e9 ae ef ff ff       	jmp    801063e4 <alltraps>

80107436 <vector235>:
80107436:	6a 00                	push   $0x0
80107438:	68 eb 00 00 00       	push   $0xeb
8010743d:	e9 a2 ef ff ff       	jmp    801063e4 <alltraps>

80107442 <vector236>:
80107442:	6a 00                	push   $0x0
80107444:	68 ec 00 00 00       	push   $0xec
80107449:	e9 96 ef ff ff       	jmp    801063e4 <alltraps>

8010744e <vector237>:
8010744e:	6a 00                	push   $0x0
80107450:	68 ed 00 00 00       	push   $0xed
80107455:	e9 8a ef ff ff       	jmp    801063e4 <alltraps>

8010745a <vector238>:
8010745a:	6a 00                	push   $0x0
8010745c:	68 ee 00 00 00       	push   $0xee
80107461:	e9 7e ef ff ff       	jmp    801063e4 <alltraps>

80107466 <vector239>:
80107466:	6a 00                	push   $0x0
80107468:	68 ef 00 00 00       	push   $0xef
8010746d:	e9 72 ef ff ff       	jmp    801063e4 <alltraps>

80107472 <vector240>:
80107472:	6a 00                	push   $0x0
80107474:	68 f0 00 00 00       	push   $0xf0
80107479:	e9 66 ef ff ff       	jmp    801063e4 <alltraps>

8010747e <vector241>:
8010747e:	6a 00                	push   $0x0
80107480:	68 f1 00 00 00       	push   $0xf1
80107485:	e9 5a ef ff ff       	jmp    801063e4 <alltraps>

8010748a <vector242>:
8010748a:	6a 00                	push   $0x0
8010748c:	68 f2 00 00 00       	push   $0xf2
80107491:	e9 4e ef ff ff       	jmp    801063e4 <alltraps>

80107496 <vector243>:
80107496:	6a 00                	push   $0x0
80107498:	68 f3 00 00 00       	push   $0xf3
8010749d:	e9 42 ef ff ff       	jmp    801063e4 <alltraps>

801074a2 <vector244>:
801074a2:	6a 00                	push   $0x0
801074a4:	68 f4 00 00 00       	push   $0xf4
801074a9:	e9 36 ef ff ff       	jmp    801063e4 <alltraps>

801074ae <vector245>:
801074ae:	6a 00                	push   $0x0
801074b0:	68 f5 00 00 00       	push   $0xf5
801074b5:	e9 2a ef ff ff       	jmp    801063e4 <alltraps>

801074ba <vector246>:
801074ba:	6a 00                	push   $0x0
801074bc:	68 f6 00 00 00       	push   $0xf6
801074c1:	e9 1e ef ff ff       	jmp    801063e4 <alltraps>

801074c6 <vector247>:
801074c6:	6a 00                	push   $0x0
801074c8:	68 f7 00 00 00       	push   $0xf7
801074cd:	e9 12 ef ff ff       	jmp    801063e4 <alltraps>

801074d2 <vector248>:
801074d2:	6a 00                	push   $0x0
801074d4:	68 f8 00 00 00       	push   $0xf8
801074d9:	e9 06 ef ff ff       	jmp    801063e4 <alltraps>

801074de <vector249>:
801074de:	6a 00                	push   $0x0
801074e0:	68 f9 00 00 00       	push   $0xf9
801074e5:	e9 fa ee ff ff       	jmp    801063e4 <alltraps>

801074ea <vector250>:
801074ea:	6a 00                	push   $0x0
801074ec:	68 fa 00 00 00       	push   $0xfa
801074f1:	e9 ee ee ff ff       	jmp    801063e4 <alltraps>

801074f6 <vector251>:
801074f6:	6a 00                	push   $0x0
801074f8:	68 fb 00 00 00       	push   $0xfb
801074fd:	e9 e2 ee ff ff       	jmp    801063e4 <alltraps>

80107502 <vector252>:
80107502:	6a 00                	push   $0x0
80107504:	68 fc 00 00 00       	push   $0xfc
80107509:	e9 d6 ee ff ff       	jmp    801063e4 <alltraps>

8010750e <vector253>:
8010750e:	6a 00                	push   $0x0
80107510:	68 fd 00 00 00       	push   $0xfd
80107515:	e9 ca ee ff ff       	jmp    801063e4 <alltraps>

8010751a <vector254>:
8010751a:	6a 00                	push   $0x0
8010751c:	68 fe 00 00 00       	push   $0xfe
80107521:	e9 be ee ff ff       	jmp    801063e4 <alltraps>

80107526 <vector255>:
80107526:	6a 00                	push   $0x0
80107528:	68 ff 00 00 00       	push   $0xff
8010752d:	e9 b2 ee ff ff       	jmp    801063e4 <alltraps>
	...

80107534 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107534:	55                   	push   %ebp
80107535:	89 e5                	mov    %esp,%ebp
80107537:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010753a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010753d:	83 e8 01             	sub    $0x1,%eax
80107540:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107544:	8b 45 08             	mov    0x8(%ebp),%eax
80107547:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010754b:	8b 45 08             	mov    0x8(%ebp),%eax
8010754e:	c1 e8 10             	shr    $0x10,%eax
80107551:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107555:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107558:	0f 01 10             	lgdtl  (%eax)
}
8010755b:	c9                   	leave  
8010755c:	c3                   	ret    

8010755d <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
8010755d:	55                   	push   %ebp
8010755e:	89 e5                	mov    %esp,%ebp
80107560:	83 ec 04             	sub    $0x4,%esp
80107563:	8b 45 08             	mov    0x8(%ebp),%eax
80107566:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
8010756a:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010756e:	0f 00 d8             	ltr    %ax
}
80107571:	c9                   	leave  
80107572:	c3                   	ret    

80107573 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80107573:	55                   	push   %ebp
80107574:	89 e5                	mov    %esp,%ebp
80107576:	83 ec 04             	sub    $0x4,%esp
80107579:	8b 45 08             	mov    0x8(%ebp),%eax
8010757c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80107580:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107584:	8e e8                	mov    %eax,%gs
}
80107586:	c9                   	leave  
80107587:	c3                   	ret    

80107588 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80107588:	55                   	push   %ebp
80107589:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010758b:	8b 45 08             	mov    0x8(%ebp),%eax
8010758e:	0f 22 d8             	mov    %eax,%cr3
}
80107591:	5d                   	pop    %ebp
80107592:	c3                   	ret    

80107593 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80107593:	55                   	push   %ebp
80107594:	89 e5                	mov    %esp,%ebp
80107596:	8b 45 08             	mov    0x8(%ebp),%eax
80107599:	05 00 00 00 80       	add    $0x80000000,%eax
8010759e:	5d                   	pop    %ebp
8010759f:	c3                   	ret    

801075a0 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801075a0:	55                   	push   %ebp
801075a1:	89 e5                	mov    %esp,%ebp
801075a3:	8b 45 08             	mov    0x8(%ebp),%eax
801075a6:	05 00 00 00 80       	add    $0x80000000,%eax
801075ab:	5d                   	pop    %ebp
801075ac:	c3                   	ret    

801075ad <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801075ad:	55                   	push   %ebp
801075ae:	89 e5                	mov    %esp,%ebp
801075b0:	53                   	push   %ebx
801075b1:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
801075b4:	e8 d5 b8 ff ff       	call   80102e8e <cpunum>
801075b9:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801075bf:	05 20 f9 10 80       	add    $0x8010f920,%eax
801075c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801075c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ca:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801075d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075d3:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801075d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075dc:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801075e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075e3:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801075e7:	83 e2 f0             	and    $0xfffffff0,%edx
801075ea:	83 ca 0a             	or     $0xa,%edx
801075ed:	88 50 7d             	mov    %dl,0x7d(%eax)
801075f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075f3:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801075f7:	83 ca 10             	or     $0x10,%edx
801075fa:	88 50 7d             	mov    %dl,0x7d(%eax)
801075fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107600:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107604:	83 e2 9f             	and    $0xffffff9f,%edx
80107607:	88 50 7d             	mov    %dl,0x7d(%eax)
8010760a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010760d:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107611:	83 ca 80             	or     $0xffffff80,%edx
80107614:	88 50 7d             	mov    %dl,0x7d(%eax)
80107617:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010761a:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010761e:	83 ca 0f             	or     $0xf,%edx
80107621:	88 50 7e             	mov    %dl,0x7e(%eax)
80107624:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107627:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010762b:	83 e2 ef             	and    $0xffffffef,%edx
8010762e:	88 50 7e             	mov    %dl,0x7e(%eax)
80107631:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107634:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107638:	83 e2 df             	and    $0xffffffdf,%edx
8010763b:	88 50 7e             	mov    %dl,0x7e(%eax)
8010763e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107641:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107645:	83 ca 40             	or     $0x40,%edx
80107648:	88 50 7e             	mov    %dl,0x7e(%eax)
8010764b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010764e:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107652:	83 ca 80             	or     $0xffffff80,%edx
80107655:	88 50 7e             	mov    %dl,0x7e(%eax)
80107658:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010765b:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
8010765f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107662:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107669:	ff ff 
8010766b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010766e:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107675:	00 00 
80107677:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010767a:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107681:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107684:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010768b:	83 e2 f0             	and    $0xfffffff0,%edx
8010768e:	83 ca 02             	or     $0x2,%edx
80107691:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107697:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010769a:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801076a1:	83 ca 10             	or     $0x10,%edx
801076a4:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801076aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076ad:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801076b4:	83 e2 9f             	and    $0xffffff9f,%edx
801076b7:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801076bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076c0:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801076c7:	83 ca 80             	or     $0xffffff80,%edx
801076ca:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801076d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076d3:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801076da:	83 ca 0f             	or     $0xf,%edx
801076dd:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801076e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076e6:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801076ed:	83 e2 ef             	and    $0xffffffef,%edx
801076f0:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801076f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076f9:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107700:	83 e2 df             	and    $0xffffffdf,%edx
80107703:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107709:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010770c:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107713:	83 ca 40             	or     $0x40,%edx
80107716:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010771c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010771f:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107726:	83 ca 80             	or     $0xffffff80,%edx
80107729:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010772f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107732:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107739:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010773c:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107743:	ff ff 
80107745:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107748:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
8010774f:	00 00 
80107751:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107754:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
8010775b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010775e:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107765:	83 e2 f0             	and    $0xfffffff0,%edx
80107768:	83 ca 0a             	or     $0xa,%edx
8010776b:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107771:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107774:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010777b:	83 ca 10             	or     $0x10,%edx
8010777e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107784:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107787:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010778e:	83 ca 60             	or     $0x60,%edx
80107791:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107797:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010779a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801077a1:	83 ca 80             	or     $0xffffff80,%edx
801077a4:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801077aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ad:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801077b4:	83 ca 0f             	or     $0xf,%edx
801077b7:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801077bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077c0:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801077c7:	83 e2 ef             	and    $0xffffffef,%edx
801077ca:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801077d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077d3:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801077da:	83 e2 df             	and    $0xffffffdf,%edx
801077dd:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801077e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077e6:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801077ed:	83 ca 40             	or     $0x40,%edx
801077f0:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801077f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077f9:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107800:	83 ca 80             	or     $0xffffff80,%edx
80107803:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107809:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010780c:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107813:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107816:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
8010781d:	ff ff 
8010781f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107822:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107829:	00 00 
8010782b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010782e:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107835:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107838:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010783f:	83 e2 f0             	and    $0xfffffff0,%edx
80107842:	83 ca 02             	or     $0x2,%edx
80107845:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010784b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010784e:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107855:	83 ca 10             	or     $0x10,%edx
80107858:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010785e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107861:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107868:	83 ca 60             	or     $0x60,%edx
8010786b:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107871:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107874:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010787b:	83 ca 80             	or     $0xffffff80,%edx
8010787e:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107884:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107887:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010788e:	83 ca 0f             	or     $0xf,%edx
80107891:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107897:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010789a:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801078a1:	83 e2 ef             	and    $0xffffffef,%edx
801078a4:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801078aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078ad:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801078b4:	83 e2 df             	and    $0xffffffdf,%edx
801078b7:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801078bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078c0:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801078c7:	83 ca 40             	or     $0x40,%edx
801078ca:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801078d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078d3:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801078da:	83 ca 80             	or     $0xffffff80,%edx
801078dd:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801078e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078e6:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
801078ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078f0:	05 b4 00 00 00       	add    $0xb4,%eax
801078f5:	89 c3                	mov    %eax,%ebx
801078f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078fa:	05 b4 00 00 00       	add    $0xb4,%eax
801078ff:	c1 e8 10             	shr    $0x10,%eax
80107902:	89 c1                	mov    %eax,%ecx
80107904:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107907:	05 b4 00 00 00       	add    $0xb4,%eax
8010790c:	c1 e8 18             	shr    $0x18,%eax
8010790f:	89 c2                	mov    %eax,%edx
80107911:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107914:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
8010791b:	00 00 
8010791d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107920:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107927:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010792a:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
80107930:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107933:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
8010793a:	83 e1 f0             	and    $0xfffffff0,%ecx
8010793d:	83 c9 02             	or     $0x2,%ecx
80107940:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107946:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107949:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107950:	83 c9 10             	or     $0x10,%ecx
80107953:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107959:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010795c:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107963:	83 e1 9f             	and    $0xffffff9f,%ecx
80107966:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
8010796c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010796f:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107976:	83 c9 80             	or     $0xffffff80,%ecx
80107979:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
8010797f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107982:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107989:	83 e1 f0             	and    $0xfffffff0,%ecx
8010798c:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107992:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107995:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
8010799c:	83 e1 ef             	and    $0xffffffef,%ecx
8010799f:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
801079a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079a8:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
801079af:	83 e1 df             	and    $0xffffffdf,%ecx
801079b2:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
801079b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079bb:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
801079c2:	83 c9 40             	or     $0x40,%ecx
801079c5:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
801079cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ce:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
801079d5:	83 c9 80             	or     $0xffffff80,%ecx
801079d8:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
801079de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079e1:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
801079e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ea:	83 c0 70             	add    $0x70,%eax
801079ed:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
801079f4:	00 
801079f5:	89 04 24             	mov    %eax,(%esp)
801079f8:	e8 37 fb ff ff       	call   80107534 <lgdt>
  loadgs(SEG_KCPU << 3);
801079fd:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80107a04:	e8 6a fb ff ff       	call   80107573 <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
80107a09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a0c:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107a12:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107a19:	00 00 00 00 
}
80107a1d:	83 c4 24             	add    $0x24,%esp
80107a20:	5b                   	pop    %ebx
80107a21:	5d                   	pop    %ebp
80107a22:	c3                   	ret    

80107a23 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107a23:	55                   	push   %ebp
80107a24:	89 e5                	mov    %esp,%ebp
80107a26:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107a29:	8b 45 0c             	mov    0xc(%ebp),%eax
80107a2c:	c1 e8 16             	shr    $0x16,%eax
80107a2f:	c1 e0 02             	shl    $0x2,%eax
80107a32:	03 45 08             	add    0x8(%ebp),%eax
80107a35:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107a38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a3b:	8b 00                	mov    (%eax),%eax
80107a3d:	83 e0 01             	and    $0x1,%eax
80107a40:	84 c0                	test   %al,%al
80107a42:	74 17                	je     80107a5b <walkpgdir+0x38>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107a44:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a47:	8b 00                	mov    (%eax),%eax
80107a49:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107a4e:	89 04 24             	mov    %eax,(%esp)
80107a51:	e8 4a fb ff ff       	call   801075a0 <p2v>
80107a56:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107a59:	eb 4b                	jmp    80107aa6 <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107a5b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107a5f:	74 0e                	je     80107a6f <walkpgdir+0x4c>
80107a61:	e8 99 b0 ff ff       	call   80102aff <kalloc>
80107a66:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107a69:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107a6d:	75 07                	jne    80107a76 <walkpgdir+0x53>
      return 0;
80107a6f:	b8 00 00 00 00       	mov    $0x0,%eax
80107a74:	eb 41                	jmp    80107ab7 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107a76:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107a7d:	00 
80107a7e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107a85:	00 
80107a86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a89:	89 04 24             	mov    %eax,(%esp)
80107a8c:	e8 29 d5 ff ff       	call   80104fba <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107a91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a94:	89 04 24             	mov    %eax,(%esp)
80107a97:	e8 f7 fa ff ff       	call   80107593 <v2p>
80107a9c:	89 c2                	mov    %eax,%edx
80107a9e:	83 ca 07             	or     $0x7,%edx
80107aa1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107aa4:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107aa6:	8b 45 0c             	mov    0xc(%ebp),%eax
80107aa9:	c1 e8 0c             	shr    $0xc,%eax
80107aac:	25 ff 03 00 00       	and    $0x3ff,%eax
80107ab1:	c1 e0 02             	shl    $0x2,%eax
80107ab4:	03 45 f4             	add    -0xc(%ebp),%eax
}
80107ab7:	c9                   	leave  
80107ab8:	c3                   	ret    

80107ab9 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107ab9:	55                   	push   %ebp
80107aba:	89 e5                	mov    %esp,%ebp
80107abc:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107abf:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ac2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ac7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107aca:	8b 45 0c             	mov    0xc(%ebp),%eax
80107acd:	03 45 10             	add    0x10(%ebp),%eax
80107ad0:	83 e8 01             	sub    $0x1,%eax
80107ad3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ad8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107adb:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80107ae2:	00 
80107ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae6:	89 44 24 04          	mov    %eax,0x4(%esp)
80107aea:	8b 45 08             	mov    0x8(%ebp),%eax
80107aed:	89 04 24             	mov    %eax,(%esp)
80107af0:	e8 2e ff ff ff       	call   80107a23 <walkpgdir>
80107af5:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107af8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107afc:	75 07                	jne    80107b05 <mappages+0x4c>
      return -1;
80107afe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107b03:	eb 46                	jmp    80107b4b <mappages+0x92>
    if(*pte & PTE_P)
80107b05:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b08:	8b 00                	mov    (%eax),%eax
80107b0a:	83 e0 01             	and    $0x1,%eax
80107b0d:	84 c0                	test   %al,%al
80107b0f:	74 0c                	je     80107b1d <mappages+0x64>
      panic("remap");
80107b11:	c7 04 24 c0 89 10 80 	movl   $0x801089c0,(%esp)
80107b18:	e8 20 8a ff ff       	call   8010053d <panic>
    *pte = pa | perm | PTE_P;
80107b1d:	8b 45 18             	mov    0x18(%ebp),%eax
80107b20:	0b 45 14             	or     0x14(%ebp),%eax
80107b23:	89 c2                	mov    %eax,%edx
80107b25:	83 ca 01             	or     $0x1,%edx
80107b28:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b2b:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107b2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b30:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107b33:	74 10                	je     80107b45 <mappages+0x8c>
      break;
    a += PGSIZE;
80107b35:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107b3c:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107b43:	eb 96                	jmp    80107adb <mappages+0x22>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80107b45:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107b46:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107b4b:	c9                   	leave  
80107b4c:	c3                   	ret    

80107b4d <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm()
{
80107b4d:	55                   	push   %ebp
80107b4e:	89 e5                	mov    %esp,%ebp
80107b50:	53                   	push   %ebx
80107b51:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107b54:	e8 a6 af ff ff       	call   80102aff <kalloc>
80107b59:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107b5c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107b60:	75 0a                	jne    80107b6c <setupkvm+0x1f>
    return 0;
80107b62:	b8 00 00 00 00       	mov    $0x0,%eax
80107b67:	e9 98 00 00 00       	jmp    80107c04 <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
80107b6c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107b73:	00 
80107b74:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107b7b:	00 
80107b7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b7f:	89 04 24             	mov    %eax,(%esp)
80107b82:	e8 33 d4 ff ff       	call   80104fba <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80107b87:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
80107b8e:	e8 0d fa ff ff       	call   801075a0 <p2v>
80107b93:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80107b98:	76 0c                	jbe    80107ba6 <setupkvm+0x59>
    panic("PHYSTOP too high");
80107b9a:	c7 04 24 c6 89 10 80 	movl   $0x801089c6,(%esp)
80107ba1:	e8 97 89 ff ff       	call   8010053d <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107ba6:	c7 45 f4 a0 b4 10 80 	movl   $0x8010b4a0,-0xc(%ebp)
80107bad:	eb 49                	jmp    80107bf8 <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
80107baf:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107bb2:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80107bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107bb8:	8b 50 04             	mov    0x4(%eax),%edx
80107bbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bbe:	8b 58 08             	mov    0x8(%eax),%ebx
80107bc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bc4:	8b 40 04             	mov    0x4(%eax),%eax
80107bc7:	29 c3                	sub    %eax,%ebx
80107bc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bcc:	8b 00                	mov    (%eax),%eax
80107bce:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80107bd2:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107bd6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107bda:	89 44 24 04          	mov    %eax,0x4(%esp)
80107bde:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107be1:	89 04 24             	mov    %eax,(%esp)
80107be4:	e8 d0 fe ff ff       	call   80107ab9 <mappages>
80107be9:	85 c0                	test   %eax,%eax
80107beb:	79 07                	jns    80107bf4 <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80107bed:	b8 00 00 00 00       	mov    $0x0,%eax
80107bf2:	eb 10                	jmp    80107c04 <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107bf4:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107bf8:	81 7d f4 e0 b4 10 80 	cmpl   $0x8010b4e0,-0xc(%ebp)
80107bff:	72 ae                	jb     80107baf <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80107c01:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107c04:	83 c4 34             	add    $0x34,%esp
80107c07:	5b                   	pop    %ebx
80107c08:	5d                   	pop    %ebp
80107c09:	c3                   	ret    

80107c0a <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107c0a:	55                   	push   %ebp
80107c0b:	89 e5                	mov    %esp,%ebp
80107c0d:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107c10:	e8 38 ff ff ff       	call   80107b4d <setupkvm>
80107c15:	a3 18 2a 11 80       	mov    %eax,0x80112a18
  switchkvm();
80107c1a:	e8 02 00 00 00       	call   80107c21 <switchkvm>
}
80107c1f:	c9                   	leave  
80107c20:	c3                   	ret    

80107c21 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107c21:	55                   	push   %ebp
80107c22:	89 e5                	mov    %esp,%ebp
80107c24:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80107c27:	a1 18 2a 11 80       	mov    0x80112a18,%eax
80107c2c:	89 04 24             	mov    %eax,(%esp)
80107c2f:	e8 5f f9 ff ff       	call   80107593 <v2p>
80107c34:	89 04 24             	mov    %eax,(%esp)
80107c37:	e8 4c f9 ff ff       	call   80107588 <lcr3>
}
80107c3c:	c9                   	leave  
80107c3d:	c3                   	ret    

80107c3e <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107c3e:	55                   	push   %ebp
80107c3f:	89 e5                	mov    %esp,%ebp
80107c41:	53                   	push   %ebx
80107c42:	83 ec 14             	sub    $0x14,%esp
  pushcli();
80107c45:	e8 69 d2 ff ff       	call   80104eb3 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80107c4a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107c50:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107c57:	83 c2 08             	add    $0x8,%edx
80107c5a:	89 d3                	mov    %edx,%ebx
80107c5c:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107c63:	83 c2 08             	add    $0x8,%edx
80107c66:	c1 ea 10             	shr    $0x10,%edx
80107c69:	89 d1                	mov    %edx,%ecx
80107c6b:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107c72:	83 c2 08             	add    $0x8,%edx
80107c75:	c1 ea 18             	shr    $0x18,%edx
80107c78:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80107c7f:	67 00 
80107c81:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
80107c88:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
80107c8e:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107c95:	83 e1 f0             	and    $0xfffffff0,%ecx
80107c98:	83 c9 09             	or     $0x9,%ecx
80107c9b:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107ca1:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107ca8:	83 c9 10             	or     $0x10,%ecx
80107cab:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107cb1:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107cb8:	83 e1 9f             	and    $0xffffff9f,%ecx
80107cbb:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107cc1:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107cc8:	83 c9 80             	or     $0xffffff80,%ecx
80107ccb:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107cd1:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107cd8:	83 e1 f0             	and    $0xfffffff0,%ecx
80107cdb:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107ce1:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107ce8:	83 e1 ef             	and    $0xffffffef,%ecx
80107ceb:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107cf1:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107cf8:	83 e1 df             	and    $0xffffffdf,%ecx
80107cfb:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107d01:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107d08:	83 c9 40             	or     $0x40,%ecx
80107d0b:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107d11:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107d18:	83 e1 7f             	and    $0x7f,%ecx
80107d1b:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107d21:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80107d27:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107d2d:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107d34:	83 e2 ef             	and    $0xffffffef,%edx
80107d37:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80107d3d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107d43:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80107d49:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107d4f:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80107d56:	8b 52 08             	mov    0x8(%edx),%edx
80107d59:	81 c2 00 10 00 00    	add    $0x1000,%edx
80107d5f:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80107d62:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
80107d69:	e8 ef f7 ff ff       	call   8010755d <ltr>
  if(p->pgdir == 0)
80107d6e:	8b 45 08             	mov    0x8(%ebp),%eax
80107d71:	8b 40 04             	mov    0x4(%eax),%eax
80107d74:	85 c0                	test   %eax,%eax
80107d76:	75 0c                	jne    80107d84 <switchuvm+0x146>
    panic("switchuvm: no pgdir");
80107d78:	c7 04 24 d7 89 10 80 	movl   $0x801089d7,(%esp)
80107d7f:	e8 b9 87 ff ff       	call   8010053d <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80107d84:	8b 45 08             	mov    0x8(%ebp),%eax
80107d87:	8b 40 04             	mov    0x4(%eax),%eax
80107d8a:	89 04 24             	mov    %eax,(%esp)
80107d8d:	e8 01 f8 ff ff       	call   80107593 <v2p>
80107d92:	89 04 24             	mov    %eax,(%esp)
80107d95:	e8 ee f7 ff ff       	call   80107588 <lcr3>
  popcli();
80107d9a:	e8 5c d1 ff ff       	call   80104efb <popcli>
}
80107d9f:	83 c4 14             	add    $0x14,%esp
80107da2:	5b                   	pop    %ebx
80107da3:	5d                   	pop    %ebp
80107da4:	c3                   	ret    

80107da5 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107da5:	55                   	push   %ebp
80107da6:	89 e5                	mov    %esp,%ebp
80107da8:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80107dab:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107db2:	76 0c                	jbe    80107dc0 <inituvm+0x1b>
    panic("inituvm: more than a page");
80107db4:	c7 04 24 eb 89 10 80 	movl   $0x801089eb,(%esp)
80107dbb:	e8 7d 87 ff ff       	call   8010053d <panic>
  mem = kalloc();
80107dc0:	e8 3a ad ff ff       	call   80102aff <kalloc>
80107dc5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107dc8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107dcf:	00 
80107dd0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107dd7:	00 
80107dd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ddb:	89 04 24             	mov    %eax,(%esp)
80107dde:	e8 d7 d1 ff ff       	call   80104fba <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80107de3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107de6:	89 04 24             	mov    %eax,(%esp)
80107de9:	e8 a5 f7 ff ff       	call   80107593 <v2p>
80107dee:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80107df5:	00 
80107df6:	89 44 24 0c          	mov    %eax,0xc(%esp)
80107dfa:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107e01:	00 
80107e02:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107e09:	00 
80107e0a:	8b 45 08             	mov    0x8(%ebp),%eax
80107e0d:	89 04 24             	mov    %eax,(%esp)
80107e10:	e8 a4 fc ff ff       	call   80107ab9 <mappages>
  memmove(mem, init, sz);
80107e15:	8b 45 10             	mov    0x10(%ebp),%eax
80107e18:	89 44 24 08          	mov    %eax,0x8(%esp)
80107e1c:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e1f:	89 44 24 04          	mov    %eax,0x4(%esp)
80107e23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e26:	89 04 24             	mov    %eax,(%esp)
80107e29:	e8 5f d2 ff ff       	call   8010508d <memmove>
}
80107e2e:	c9                   	leave  
80107e2f:	c3                   	ret    

80107e30 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107e30:	55                   	push   %ebp
80107e31:	89 e5                	mov    %esp,%ebp
80107e33:	53                   	push   %ebx
80107e34:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107e37:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e3a:	25 ff 0f 00 00       	and    $0xfff,%eax
80107e3f:	85 c0                	test   %eax,%eax
80107e41:	74 0c                	je     80107e4f <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107e43:	c7 04 24 08 8a 10 80 	movl   $0x80108a08,(%esp)
80107e4a:	e8 ee 86 ff ff       	call   8010053d <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107e4f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107e56:	e9 ad 00 00 00       	jmp    80107f08 <loaduvm+0xd8>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107e5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e5e:	8b 55 0c             	mov    0xc(%ebp),%edx
80107e61:	01 d0                	add    %edx,%eax
80107e63:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80107e6a:	00 
80107e6b:	89 44 24 04          	mov    %eax,0x4(%esp)
80107e6f:	8b 45 08             	mov    0x8(%ebp),%eax
80107e72:	89 04 24             	mov    %eax,(%esp)
80107e75:	e8 a9 fb ff ff       	call   80107a23 <walkpgdir>
80107e7a:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107e7d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107e81:	75 0c                	jne    80107e8f <loaduvm+0x5f>
      panic("loaduvm: address should exist");
80107e83:	c7 04 24 2b 8a 10 80 	movl   $0x80108a2b,(%esp)
80107e8a:	e8 ae 86 ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
80107e8f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e92:	8b 00                	mov    (%eax),%eax
80107e94:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e99:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107e9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e9f:	8b 55 18             	mov    0x18(%ebp),%edx
80107ea2:	89 d1                	mov    %edx,%ecx
80107ea4:	29 c1                	sub    %eax,%ecx
80107ea6:	89 c8                	mov    %ecx,%eax
80107ea8:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107ead:	77 11                	ja     80107ec0 <loaduvm+0x90>
      n = sz - i;
80107eaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eb2:	8b 55 18             	mov    0x18(%ebp),%edx
80107eb5:	89 d1                	mov    %edx,%ecx
80107eb7:	29 c1                	sub    %eax,%ecx
80107eb9:	89 c8                	mov    %ecx,%eax
80107ebb:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107ebe:	eb 07                	jmp    80107ec7 <loaduvm+0x97>
    else
      n = PGSIZE;
80107ec0:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80107ec7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eca:	8b 55 14             	mov    0x14(%ebp),%edx
80107ecd:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80107ed0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107ed3:	89 04 24             	mov    %eax,(%esp)
80107ed6:	e8 c5 f6 ff ff       	call   801075a0 <p2v>
80107edb:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107ede:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107ee2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107ee6:	89 44 24 04          	mov    %eax,0x4(%esp)
80107eea:	8b 45 10             	mov    0x10(%ebp),%eax
80107eed:	89 04 24             	mov    %eax,(%esp)
80107ef0:	e8 69 9e ff ff       	call   80101d5e <readi>
80107ef5:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107ef8:	74 07                	je     80107f01 <loaduvm+0xd1>
      return -1;
80107efa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107eff:	eb 18                	jmp    80107f19 <loaduvm+0xe9>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80107f01:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107f08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f0b:	3b 45 18             	cmp    0x18(%ebp),%eax
80107f0e:	0f 82 47 ff ff ff    	jb     80107e5b <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80107f14:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107f19:	83 c4 24             	add    $0x24,%esp
80107f1c:	5b                   	pop    %ebx
80107f1d:	5d                   	pop    %ebp
80107f1e:	c3                   	ret    

80107f1f <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107f1f:	55                   	push   %ebp
80107f20:	89 e5                	mov    %esp,%ebp
80107f22:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107f25:	8b 45 10             	mov    0x10(%ebp),%eax
80107f28:	85 c0                	test   %eax,%eax
80107f2a:	79 0a                	jns    80107f36 <allocuvm+0x17>
    return 0;
80107f2c:	b8 00 00 00 00       	mov    $0x0,%eax
80107f31:	e9 c1 00 00 00       	jmp    80107ff7 <allocuvm+0xd8>
  if(newsz < oldsz)
80107f36:	8b 45 10             	mov    0x10(%ebp),%eax
80107f39:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107f3c:	73 08                	jae    80107f46 <allocuvm+0x27>
    return oldsz;
80107f3e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f41:	e9 b1 00 00 00       	jmp    80107ff7 <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
80107f46:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f49:	05 ff 0f 00 00       	add    $0xfff,%eax
80107f4e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f53:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107f56:	e9 8d 00 00 00       	jmp    80107fe8 <allocuvm+0xc9>
    mem = kalloc();
80107f5b:	e8 9f ab ff ff       	call   80102aff <kalloc>
80107f60:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107f63:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107f67:	75 2c                	jne    80107f95 <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
80107f69:	c7 04 24 49 8a 10 80 	movl   $0x80108a49,(%esp)
80107f70:	e8 2c 84 ff ff       	call   801003a1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80107f75:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f78:	89 44 24 08          	mov    %eax,0x8(%esp)
80107f7c:	8b 45 10             	mov    0x10(%ebp),%eax
80107f7f:	89 44 24 04          	mov    %eax,0x4(%esp)
80107f83:	8b 45 08             	mov    0x8(%ebp),%eax
80107f86:	89 04 24             	mov    %eax,(%esp)
80107f89:	e8 6b 00 00 00       	call   80107ff9 <deallocuvm>
      return 0;
80107f8e:	b8 00 00 00 00       	mov    $0x0,%eax
80107f93:	eb 62                	jmp    80107ff7 <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
80107f95:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107f9c:	00 
80107f9d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107fa4:	00 
80107fa5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fa8:	89 04 24             	mov    %eax,(%esp)
80107fab:	e8 0a d0 ff ff       	call   80104fba <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80107fb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fb3:	89 04 24             	mov    %eax,(%esp)
80107fb6:	e8 d8 f5 ff ff       	call   80107593 <v2p>
80107fbb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107fbe:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80107fc5:	00 
80107fc6:	89 44 24 0c          	mov    %eax,0xc(%esp)
80107fca:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107fd1:	00 
80107fd2:	89 54 24 04          	mov    %edx,0x4(%esp)
80107fd6:	8b 45 08             	mov    0x8(%ebp),%eax
80107fd9:	89 04 24             	mov    %eax,(%esp)
80107fdc:	e8 d8 fa ff ff       	call   80107ab9 <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80107fe1:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107fe8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107feb:	3b 45 10             	cmp    0x10(%ebp),%eax
80107fee:	0f 82 67 ff ff ff    	jb     80107f5b <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80107ff4:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107ff7:	c9                   	leave  
80107ff8:	c3                   	ret    

80107ff9 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107ff9:	55                   	push   %ebp
80107ffa:	89 e5                	mov    %esp,%ebp
80107ffc:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107fff:	8b 45 10             	mov    0x10(%ebp),%eax
80108002:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108005:	72 08                	jb     8010800f <deallocuvm+0x16>
    return oldsz;
80108007:	8b 45 0c             	mov    0xc(%ebp),%eax
8010800a:	e9 a4 00 00 00       	jmp    801080b3 <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
8010800f:	8b 45 10             	mov    0x10(%ebp),%eax
80108012:	05 ff 0f 00 00       	add    $0xfff,%eax
80108017:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010801c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
8010801f:	e9 80 00 00 00       	jmp    801080a4 <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108024:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108027:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010802e:	00 
8010802f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108033:	8b 45 08             	mov    0x8(%ebp),%eax
80108036:	89 04 24             	mov    %eax,(%esp)
80108039:	e8 e5 f9 ff ff       	call   80107a23 <walkpgdir>
8010803e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108041:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108045:	75 09                	jne    80108050 <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
80108047:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
8010804e:	eb 4d                	jmp    8010809d <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
80108050:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108053:	8b 00                	mov    (%eax),%eax
80108055:	83 e0 01             	and    $0x1,%eax
80108058:	84 c0                	test   %al,%al
8010805a:	74 41                	je     8010809d <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
8010805c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010805f:	8b 00                	mov    (%eax),%eax
80108061:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108066:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108069:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010806d:	75 0c                	jne    8010807b <deallocuvm+0x82>
        panic("kfree");
8010806f:	c7 04 24 61 8a 10 80 	movl   $0x80108a61,(%esp)
80108076:	e8 c2 84 ff ff       	call   8010053d <panic>
      char *v = p2v(pa);
8010807b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010807e:	89 04 24             	mov    %eax,(%esp)
80108081:	e8 1a f5 ff ff       	call   801075a0 <p2v>
80108086:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108089:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010808c:	89 04 24             	mov    %eax,(%esp)
8010808f:	e8 d2 a9 ff ff       	call   80102a66 <kfree>
      *pte = 0;
80108094:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108097:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
8010809d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801080a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080a7:	3b 45 0c             	cmp    0xc(%ebp),%eax
801080aa:	0f 82 74 ff ff ff    	jb     80108024 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
801080b0:	8b 45 10             	mov    0x10(%ebp),%eax
}
801080b3:	c9                   	leave  
801080b4:	c3                   	ret    

801080b5 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801080b5:	55                   	push   %ebp
801080b6:	89 e5                	mov    %esp,%ebp
801080b8:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
801080bb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801080bf:	75 0c                	jne    801080cd <freevm+0x18>
    panic("freevm: no pgdir");
801080c1:	c7 04 24 67 8a 10 80 	movl   $0x80108a67,(%esp)
801080c8:	e8 70 84 ff ff       	call   8010053d <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801080cd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801080d4:	00 
801080d5:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
801080dc:	80 
801080dd:	8b 45 08             	mov    0x8(%ebp),%eax
801080e0:	89 04 24             	mov    %eax,(%esp)
801080e3:	e8 11 ff ff ff       	call   80107ff9 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
801080e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801080ef:	eb 3c                	jmp    8010812d <freevm+0x78>
    if(pgdir[i] & PTE_P){
801080f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080f4:	c1 e0 02             	shl    $0x2,%eax
801080f7:	03 45 08             	add    0x8(%ebp),%eax
801080fa:	8b 00                	mov    (%eax),%eax
801080fc:	83 e0 01             	and    $0x1,%eax
801080ff:	84 c0                	test   %al,%al
80108101:	74 26                	je     80108129 <freevm+0x74>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80108103:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108106:	c1 e0 02             	shl    $0x2,%eax
80108109:	03 45 08             	add    0x8(%ebp),%eax
8010810c:	8b 00                	mov    (%eax),%eax
8010810e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108113:	89 04 24             	mov    %eax,(%esp)
80108116:	e8 85 f4 ff ff       	call   801075a0 <p2v>
8010811b:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
8010811e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108121:	89 04 24             	mov    %eax,(%esp)
80108124:	e8 3d a9 ff ff       	call   80102a66 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108129:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010812d:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108134:	76 bb                	jbe    801080f1 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108136:	8b 45 08             	mov    0x8(%ebp),%eax
80108139:	89 04 24             	mov    %eax,(%esp)
8010813c:	e8 25 a9 ff ff       	call   80102a66 <kfree>
}
80108141:	c9                   	leave  
80108142:	c3                   	ret    

80108143 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108143:	55                   	push   %ebp
80108144:	89 e5                	mov    %esp,%ebp
80108146:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108149:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108150:	00 
80108151:	8b 45 0c             	mov    0xc(%ebp),%eax
80108154:	89 44 24 04          	mov    %eax,0x4(%esp)
80108158:	8b 45 08             	mov    0x8(%ebp),%eax
8010815b:	89 04 24             	mov    %eax,(%esp)
8010815e:	e8 c0 f8 ff ff       	call   80107a23 <walkpgdir>
80108163:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108166:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010816a:	75 0c                	jne    80108178 <clearpteu+0x35>
    panic("clearpteu");
8010816c:	c7 04 24 78 8a 10 80 	movl   $0x80108a78,(%esp)
80108173:	e8 c5 83 ff ff       	call   8010053d <panic>
  *pte &= ~PTE_U;
80108178:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010817b:	8b 00                	mov    (%eax),%eax
8010817d:	89 c2                	mov    %eax,%edx
8010817f:	83 e2 fb             	and    $0xfffffffb,%edx
80108182:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108185:	89 10                	mov    %edx,(%eax)
}
80108187:	c9                   	leave  
80108188:	c3                   	ret    

80108189 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108189:	55                   	push   %ebp
8010818a:	89 e5                	mov    %esp,%ebp
8010818c:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
8010818f:	e8 b9 f9 ff ff       	call   80107b4d <setupkvm>
80108194:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108197:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010819b:	75 0a                	jne    801081a7 <copyuvm+0x1e>
    return 0;
8010819d:	b8 00 00 00 00       	mov    $0x0,%eax
801081a2:	e9 f1 00 00 00       	jmp    80108298 <copyuvm+0x10f>
  for(i = 0; i < sz; i += PGSIZE){
801081a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801081ae:	e9 c0 00 00 00       	jmp    80108273 <copyuvm+0xea>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801081b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081b6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801081bd:	00 
801081be:	89 44 24 04          	mov    %eax,0x4(%esp)
801081c2:	8b 45 08             	mov    0x8(%ebp),%eax
801081c5:	89 04 24             	mov    %eax,(%esp)
801081c8:	e8 56 f8 ff ff       	call   80107a23 <walkpgdir>
801081cd:	89 45 ec             	mov    %eax,-0x14(%ebp)
801081d0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801081d4:	75 0c                	jne    801081e2 <copyuvm+0x59>
      panic("copyuvm: pte should exist");
801081d6:	c7 04 24 82 8a 10 80 	movl   $0x80108a82,(%esp)
801081dd:	e8 5b 83 ff ff       	call   8010053d <panic>
    if(!(*pte & PTE_P))
801081e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081e5:	8b 00                	mov    (%eax),%eax
801081e7:	83 e0 01             	and    $0x1,%eax
801081ea:	85 c0                	test   %eax,%eax
801081ec:	75 0c                	jne    801081fa <copyuvm+0x71>
      panic("copyuvm: page not present");
801081ee:	c7 04 24 9c 8a 10 80 	movl   $0x80108a9c,(%esp)
801081f5:	e8 43 83 ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
801081fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081fd:	8b 00                	mov    (%eax),%eax
801081ff:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108204:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if((mem = kalloc()) == 0)
80108207:	e8 f3 a8 ff ff       	call   80102aff <kalloc>
8010820c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010820f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108213:	74 6f                	je     80108284 <copyuvm+0xfb>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
80108215:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108218:	89 04 24             	mov    %eax,(%esp)
8010821b:	e8 80 f3 ff ff       	call   801075a0 <p2v>
80108220:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108227:	00 
80108228:	89 44 24 04          	mov    %eax,0x4(%esp)
8010822c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010822f:	89 04 24             	mov    %eax,(%esp)
80108232:	e8 56 ce ff ff       	call   8010508d <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
80108237:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010823a:	89 04 24             	mov    %eax,(%esp)
8010823d:	e8 51 f3 ff ff       	call   80107593 <v2p>
80108242:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108245:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
8010824c:	00 
8010824d:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108251:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108258:	00 
80108259:	89 54 24 04          	mov    %edx,0x4(%esp)
8010825d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108260:	89 04 24             	mov    %eax,(%esp)
80108263:	e8 51 f8 ff ff       	call   80107ab9 <mappages>
80108268:	85 c0                	test   %eax,%eax
8010826a:	78 1b                	js     80108287 <copyuvm+0xfe>
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
8010826c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108273:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108276:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108279:	0f 82 34 ff ff ff    	jb     801081b3 <copyuvm+0x2a>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
      goto bad;
  }
  return d;
8010827f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108282:	eb 14                	jmp    80108298 <copyuvm+0x10f>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
80108284:	90                   	nop
80108285:	eb 01                	jmp    80108288 <copyuvm+0xff>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
      goto bad;
80108287:	90                   	nop
  }
  return d;

bad:
  freevm(d);
80108288:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010828b:	89 04 24             	mov    %eax,(%esp)
8010828e:	e8 22 fe ff ff       	call   801080b5 <freevm>
  return 0;
80108293:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108298:	c9                   	leave  
80108299:	c3                   	ret    

8010829a <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010829a:	55                   	push   %ebp
8010829b:	89 e5                	mov    %esp,%ebp
8010829d:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801082a0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801082a7:	00 
801082a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801082ab:	89 44 24 04          	mov    %eax,0x4(%esp)
801082af:	8b 45 08             	mov    0x8(%ebp),%eax
801082b2:	89 04 24             	mov    %eax,(%esp)
801082b5:	e8 69 f7 ff ff       	call   80107a23 <walkpgdir>
801082ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801082bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082c0:	8b 00                	mov    (%eax),%eax
801082c2:	83 e0 01             	and    $0x1,%eax
801082c5:	85 c0                	test   %eax,%eax
801082c7:	75 07                	jne    801082d0 <uva2ka+0x36>
    return 0;
801082c9:	b8 00 00 00 00       	mov    $0x0,%eax
801082ce:	eb 25                	jmp    801082f5 <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
801082d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082d3:	8b 00                	mov    (%eax),%eax
801082d5:	83 e0 04             	and    $0x4,%eax
801082d8:	85 c0                	test   %eax,%eax
801082da:	75 07                	jne    801082e3 <uva2ka+0x49>
    return 0;
801082dc:	b8 00 00 00 00       	mov    $0x0,%eax
801082e1:	eb 12                	jmp    801082f5 <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
801082e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082e6:	8b 00                	mov    (%eax),%eax
801082e8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801082ed:	89 04 24             	mov    %eax,(%esp)
801082f0:	e8 ab f2 ff ff       	call   801075a0 <p2v>
}
801082f5:	c9                   	leave  
801082f6:	c3                   	ret    

801082f7 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801082f7:	55                   	push   %ebp
801082f8:	89 e5                	mov    %esp,%ebp
801082fa:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801082fd:	8b 45 10             	mov    0x10(%ebp),%eax
80108300:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108303:	e9 8b 00 00 00       	jmp    80108393 <copyout+0x9c>
    va0 = (uint)PGROUNDDOWN(va);
80108308:	8b 45 0c             	mov    0xc(%ebp),%eax
8010830b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108310:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108313:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108316:	89 44 24 04          	mov    %eax,0x4(%esp)
8010831a:	8b 45 08             	mov    0x8(%ebp),%eax
8010831d:	89 04 24             	mov    %eax,(%esp)
80108320:	e8 75 ff ff ff       	call   8010829a <uva2ka>
80108325:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108328:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010832c:	75 07                	jne    80108335 <copyout+0x3e>
      return -1;
8010832e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108333:	eb 6d                	jmp    801083a2 <copyout+0xab>
    n = PGSIZE - (va - va0);
80108335:	8b 45 0c             	mov    0xc(%ebp),%eax
80108338:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010833b:	89 d1                	mov    %edx,%ecx
8010833d:	29 c1                	sub    %eax,%ecx
8010833f:	89 c8                	mov    %ecx,%eax
80108341:	05 00 10 00 00       	add    $0x1000,%eax
80108346:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108349:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010834c:	3b 45 14             	cmp    0x14(%ebp),%eax
8010834f:	76 06                	jbe    80108357 <copyout+0x60>
      n = len;
80108351:	8b 45 14             	mov    0x14(%ebp),%eax
80108354:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108357:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010835a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010835d:	89 d1                	mov    %edx,%ecx
8010835f:	29 c1                	sub    %eax,%ecx
80108361:	89 c8                	mov    %ecx,%eax
80108363:	03 45 e8             	add    -0x18(%ebp),%eax
80108366:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108369:	89 54 24 08          	mov    %edx,0x8(%esp)
8010836d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108370:	89 54 24 04          	mov    %edx,0x4(%esp)
80108374:	89 04 24             	mov    %eax,(%esp)
80108377:	e8 11 cd ff ff       	call   8010508d <memmove>
    len -= n;
8010837c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010837f:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108382:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108385:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108388:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010838b:	05 00 10 00 00       	add    $0x1000,%eax
80108390:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108393:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108397:	0f 85 6b ff ff ff    	jne    80108308 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
8010839d:	b8 00 00 00 00       	mov    $0x0,%eax
}
801083a2:	c9                   	leave  
801083a3:	c3                   	ret    
