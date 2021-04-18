
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 80 11 00       	mov    $0x118000,%eax
    movl %eax, %cr3
c0100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
c0100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
c010000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
c0100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
c0100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
c0100016:	8d 05 1e 00 10 c0    	lea    0xc010001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
c010001c:	ff e0                	jmp    *%eax

c010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
c010001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
c0100020:	a3 00 80 11 c0       	mov    %eax,0xc0118000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 70 11 c0       	mov    $0xc0117000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
c010002f:	e8 02 00 00 00       	call   c0100036 <kern_init>

c0100034 <spin>:

# should never get here
spin:
    jmp spin
c0100034:	eb fe                	jmp    c0100034 <spin>

c0100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
c0100036:	55                   	push   %ebp
c0100037:	89 e5                	mov    %esp,%ebp
c0100039:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
c010003c:	ba 28 af 11 c0       	mov    $0xc011af28,%edx
c0100041:	b8 00 a0 11 c0       	mov    $0xc011a000,%eax
c0100046:	29 c2                	sub    %eax,%edx
c0100048:	89 d0                	mov    %edx,%eax
c010004a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100055:	00 
c0100056:	c7 04 24 00 a0 11 c0 	movl   $0xc011a000,(%esp)
c010005d:	e8 8b 5c 00 00       	call   c0105ced <memset>

    cons_init();                // init the console
c0100062:	e8 c8 14 00 00       	call   c010152f <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 80 5e 10 c0 	movl   $0xc0105e80,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 9c 5e 10 c0 	movl   $0xc0105e9c,(%esp)
c010007c:	e8 c7 02 00 00       	call   c0100348 <cprintf>

    print_kerninfo();
c0100081:	e8 f6 07 00 00       	call   c010087c <print_kerninfo>

    grade_backtrace();
c0100086:	e8 86 00 00 00       	call   c0100111 <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 28 42 00 00       	call   c01042b8 <pmm_init>

    pic_init();                 // init interrupt controller
c0100090:	e8 03 16 00 00       	call   c0101698 <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100095:	e8 55 17 00 00       	call   c01017ef <idt_init>

    clock_init();               // init clock interrupt
c010009a:	e8 46 0c 00 00       	call   c0100ce5 <clock_init>
    intr_enable();              // enable irq interrupt
c010009f:	e8 62 15 00 00       	call   c0101606 <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
c01000a4:	eb fe                	jmp    c01000a4 <kern_init+0x6e>

c01000a6 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000a6:	55                   	push   %ebp
c01000a7:	89 e5                	mov    %esp,%ebp
c01000a9:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000ac:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000b3:	00 
c01000b4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000bb:	00 
c01000bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000c3:	e8 3e 0b 00 00       	call   c0100c06 <mon_backtrace>
}
c01000c8:	c9                   	leave  
c01000c9:	c3                   	ret    

c01000ca <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000ca:	55                   	push   %ebp
c01000cb:	89 e5                	mov    %esp,%ebp
c01000cd:	53                   	push   %ebx
c01000ce:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000d1:	8d 5d 0c             	lea    0xc(%ebp),%ebx
c01000d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c01000d7:	8d 55 08             	lea    0x8(%ebp),%edx
c01000da:	8b 45 08             	mov    0x8(%ebp),%eax
c01000dd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01000e1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01000e5:	89 54 24 04          	mov    %edx,0x4(%esp)
c01000e9:	89 04 24             	mov    %eax,(%esp)
c01000ec:	e8 b5 ff ff ff       	call   c01000a6 <grade_backtrace2>
}
c01000f1:	83 c4 14             	add    $0x14,%esp
c01000f4:	5b                   	pop    %ebx
c01000f5:	5d                   	pop    %ebp
c01000f6:	c3                   	ret    

c01000f7 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c01000f7:	55                   	push   %ebp
c01000f8:	89 e5                	mov    %esp,%ebp
c01000fa:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c01000fd:	8b 45 10             	mov    0x10(%ebp),%eax
c0100100:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100104:	8b 45 08             	mov    0x8(%ebp),%eax
c0100107:	89 04 24             	mov    %eax,(%esp)
c010010a:	e8 bb ff ff ff       	call   c01000ca <grade_backtrace1>
}
c010010f:	c9                   	leave  
c0100110:	c3                   	ret    

c0100111 <grade_backtrace>:

void
grade_backtrace(void) {
c0100111:	55                   	push   %ebp
c0100112:	89 e5                	mov    %esp,%ebp
c0100114:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c0100117:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c010011c:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c0100123:	ff 
c0100124:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100128:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010012f:	e8 c3 ff ff ff       	call   c01000f7 <grade_backtrace0>
}
c0100134:	c9                   	leave  
c0100135:	c3                   	ret    

c0100136 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c0100136:	55                   	push   %ebp
c0100137:	89 e5                	mov    %esp,%ebp
c0100139:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c010013c:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c010013f:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c0100142:	8c 45 f2             	mov    %es,-0xe(%ebp)
c0100145:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c0100148:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010014c:	0f b7 c0             	movzwl %ax,%eax
c010014f:	83 e0 03             	and    $0x3,%eax
c0100152:	89 c2                	mov    %eax,%edx
c0100154:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c0100159:	89 54 24 08          	mov    %edx,0x8(%esp)
c010015d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100161:	c7 04 24 a1 5e 10 c0 	movl   $0xc0105ea1,(%esp)
c0100168:	e8 db 01 00 00       	call   c0100348 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c010016d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100171:	0f b7 d0             	movzwl %ax,%edx
c0100174:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c0100179:	89 54 24 08          	mov    %edx,0x8(%esp)
c010017d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100181:	c7 04 24 af 5e 10 c0 	movl   $0xc0105eaf,(%esp)
c0100188:	e8 bb 01 00 00       	call   c0100348 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c010018d:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0100191:	0f b7 d0             	movzwl %ax,%edx
c0100194:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c0100199:	89 54 24 08          	mov    %edx,0x8(%esp)
c010019d:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001a1:	c7 04 24 bd 5e 10 c0 	movl   $0xc0105ebd,(%esp)
c01001a8:	e8 9b 01 00 00       	call   c0100348 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001ad:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001b1:	0f b7 d0             	movzwl %ax,%edx
c01001b4:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c01001b9:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001bd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001c1:	c7 04 24 cb 5e 10 c0 	movl   $0xc0105ecb,(%esp)
c01001c8:	e8 7b 01 00 00       	call   c0100348 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001cd:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001d1:	0f b7 d0             	movzwl %ax,%edx
c01001d4:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c01001d9:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001dd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001e1:	c7 04 24 d9 5e 10 c0 	movl   $0xc0105ed9,(%esp)
c01001e8:	e8 5b 01 00 00       	call   c0100348 <cprintf>
    round ++;
c01001ed:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c01001f2:	83 c0 01             	add    $0x1,%eax
c01001f5:	a3 00 a0 11 c0       	mov    %eax,0xc011a000
}
c01001fa:	c9                   	leave  
c01001fb:	c3                   	ret    

c01001fc <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c01001fc:	55                   	push   %ebp
c01001fd:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c01001ff:	5d                   	pop    %ebp
c0100200:	c3                   	ret    

c0100201 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c0100201:	55                   	push   %ebp
c0100202:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c0100204:	5d                   	pop    %ebp
c0100205:	c3                   	ret    

c0100206 <lab1_switch_test>:

static void
lab1_switch_test(void) {
c0100206:	55                   	push   %ebp
c0100207:	89 e5                	mov    %esp,%ebp
c0100209:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c010020c:	e8 25 ff ff ff       	call   c0100136 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c0100211:	c7 04 24 e8 5e 10 c0 	movl   $0xc0105ee8,(%esp)
c0100218:	e8 2b 01 00 00       	call   c0100348 <cprintf>
    lab1_switch_to_user();
c010021d:	e8 da ff ff ff       	call   c01001fc <lab1_switch_to_user>
    lab1_print_cur_status();
c0100222:	e8 0f ff ff ff       	call   c0100136 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100227:	c7 04 24 08 5f 10 c0 	movl   $0xc0105f08,(%esp)
c010022e:	e8 15 01 00 00       	call   c0100348 <cprintf>
    lab1_switch_to_kernel();
c0100233:	e8 c9 ff ff ff       	call   c0100201 <lab1_switch_to_kernel>
    lab1_print_cur_status();
c0100238:	e8 f9 fe ff ff       	call   c0100136 <lab1_print_cur_status>
}
c010023d:	c9                   	leave  
c010023e:	c3                   	ret    

c010023f <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c010023f:	55                   	push   %ebp
c0100240:	89 e5                	mov    %esp,%ebp
c0100242:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c0100245:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100249:	74 13                	je     c010025e <readline+0x1f>
        cprintf("%s", prompt);
c010024b:	8b 45 08             	mov    0x8(%ebp),%eax
c010024e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100252:	c7 04 24 27 5f 10 c0 	movl   $0xc0105f27,(%esp)
c0100259:	e8 ea 00 00 00       	call   c0100348 <cprintf>
    }
    int i = 0, c;
c010025e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c0100265:	e8 66 01 00 00       	call   c01003d0 <getchar>
c010026a:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c010026d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100271:	79 07                	jns    c010027a <readline+0x3b>
            return NULL;
c0100273:	b8 00 00 00 00       	mov    $0x0,%eax
c0100278:	eb 79                	jmp    c01002f3 <readline+0xb4>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c010027a:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c010027e:	7e 28                	jle    c01002a8 <readline+0x69>
c0100280:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c0100287:	7f 1f                	jg     c01002a8 <readline+0x69>
            cputchar(c);
c0100289:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010028c:	89 04 24             	mov    %eax,(%esp)
c010028f:	e8 da 00 00 00       	call   c010036e <cputchar>
            buf[i ++] = c;
c0100294:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100297:	8d 50 01             	lea    0x1(%eax),%edx
c010029a:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010029d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01002a0:	88 90 20 a0 11 c0    	mov    %dl,-0x3fee5fe0(%eax)
c01002a6:	eb 46                	jmp    c01002ee <readline+0xaf>
        }
        else if (c == '\b' && i > 0) {
c01002a8:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01002ac:	75 17                	jne    c01002c5 <readline+0x86>
c01002ae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01002b2:	7e 11                	jle    c01002c5 <readline+0x86>
            cputchar(c);
c01002b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002b7:	89 04 24             	mov    %eax,(%esp)
c01002ba:	e8 af 00 00 00       	call   c010036e <cputchar>
            i --;
c01002bf:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01002c3:	eb 29                	jmp    c01002ee <readline+0xaf>
        }
        else if (c == '\n' || c == '\r') {
c01002c5:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01002c9:	74 06                	je     c01002d1 <readline+0x92>
c01002cb:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01002cf:	75 1d                	jne    c01002ee <readline+0xaf>
            cputchar(c);
c01002d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002d4:	89 04 24             	mov    %eax,(%esp)
c01002d7:	e8 92 00 00 00       	call   c010036e <cputchar>
            buf[i] = '\0';
c01002dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002df:	05 20 a0 11 c0       	add    $0xc011a020,%eax
c01002e4:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01002e7:	b8 20 a0 11 c0       	mov    $0xc011a020,%eax
c01002ec:	eb 05                	jmp    c01002f3 <readline+0xb4>
        }
    }
c01002ee:	e9 72 ff ff ff       	jmp    c0100265 <readline+0x26>
}
c01002f3:	c9                   	leave  
c01002f4:	c3                   	ret    

c01002f5 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c01002f5:	55                   	push   %ebp
c01002f6:	89 e5                	mov    %esp,%ebp
c01002f8:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c01002fb:	8b 45 08             	mov    0x8(%ebp),%eax
c01002fe:	89 04 24             	mov    %eax,(%esp)
c0100301:	e8 55 12 00 00       	call   c010155b <cons_putc>
    (*cnt) ++;
c0100306:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100309:	8b 00                	mov    (%eax),%eax
c010030b:	8d 50 01             	lea    0x1(%eax),%edx
c010030e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100311:	89 10                	mov    %edx,(%eax)
}
c0100313:	c9                   	leave  
c0100314:	c3                   	ret    

c0100315 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c0100315:	55                   	push   %ebp
c0100316:	89 e5                	mov    %esp,%ebp
c0100318:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c010031b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c0100322:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100325:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0100329:	8b 45 08             	mov    0x8(%ebp),%eax
c010032c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100330:	8d 45 f4             	lea    -0xc(%ebp),%eax
c0100333:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100337:	c7 04 24 f5 02 10 c0 	movl   $0xc01002f5,(%esp)
c010033e:	e8 c3 51 00 00       	call   c0105506 <vprintfmt>
    return cnt;
c0100343:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100346:	c9                   	leave  
c0100347:	c3                   	ret    

c0100348 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c0100348:	55                   	push   %ebp
c0100349:	89 e5                	mov    %esp,%ebp
c010034b:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010034e:	8d 45 0c             	lea    0xc(%ebp),%eax
c0100351:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c0100354:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100357:	89 44 24 04          	mov    %eax,0x4(%esp)
c010035b:	8b 45 08             	mov    0x8(%ebp),%eax
c010035e:	89 04 24             	mov    %eax,(%esp)
c0100361:	e8 af ff ff ff       	call   c0100315 <vcprintf>
c0100366:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0100369:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010036c:	c9                   	leave  
c010036d:	c3                   	ret    

c010036e <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c010036e:	55                   	push   %ebp
c010036f:	89 e5                	mov    %esp,%ebp
c0100371:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100374:	8b 45 08             	mov    0x8(%ebp),%eax
c0100377:	89 04 24             	mov    %eax,(%esp)
c010037a:	e8 dc 11 00 00       	call   c010155b <cons_putc>
}
c010037f:	c9                   	leave  
c0100380:	c3                   	ret    

c0100381 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c0100381:	55                   	push   %ebp
c0100382:	89 e5                	mov    %esp,%ebp
c0100384:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100387:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c010038e:	eb 13                	jmp    c01003a3 <cputs+0x22>
        cputch(c, &cnt);
c0100390:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0100394:	8d 55 f0             	lea    -0x10(%ebp),%edx
c0100397:	89 54 24 04          	mov    %edx,0x4(%esp)
c010039b:	89 04 24             	mov    %eax,(%esp)
c010039e:	e8 52 ff ff ff       	call   c01002f5 <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
c01003a3:	8b 45 08             	mov    0x8(%ebp),%eax
c01003a6:	8d 50 01             	lea    0x1(%eax),%edx
c01003a9:	89 55 08             	mov    %edx,0x8(%ebp)
c01003ac:	0f b6 00             	movzbl (%eax),%eax
c01003af:	88 45 f7             	mov    %al,-0x9(%ebp)
c01003b2:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c01003b6:	75 d8                	jne    c0100390 <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
c01003b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
c01003bb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01003bf:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c01003c6:	e8 2a ff ff ff       	call   c01002f5 <cputch>
    return cnt;
c01003cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c01003ce:	c9                   	leave  
c01003cf:	c3                   	ret    

c01003d0 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c01003d0:	55                   	push   %ebp
c01003d1:	89 e5                	mov    %esp,%ebp
c01003d3:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c01003d6:	e8 bc 11 00 00       	call   c0101597 <cons_getc>
c01003db:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01003de:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003e2:	74 f2                	je     c01003d6 <getchar+0x6>
        /* do nothing */;
    return c;
c01003e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01003e7:	c9                   	leave  
c01003e8:	c3                   	ret    

c01003e9 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c01003e9:	55                   	push   %ebp
c01003ea:	89 e5                	mov    %esp,%ebp
c01003ec:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c01003ef:	8b 45 0c             	mov    0xc(%ebp),%eax
c01003f2:	8b 00                	mov    (%eax),%eax
c01003f4:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01003f7:	8b 45 10             	mov    0x10(%ebp),%eax
c01003fa:	8b 00                	mov    (%eax),%eax
c01003fc:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01003ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c0100406:	e9 d2 00 00 00       	jmp    c01004dd <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
c010040b:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010040e:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100411:	01 d0                	add    %edx,%eax
c0100413:	89 c2                	mov    %eax,%edx
c0100415:	c1 ea 1f             	shr    $0x1f,%edx
c0100418:	01 d0                	add    %edx,%eax
c010041a:	d1 f8                	sar    %eax
c010041c:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010041f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100422:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0100425:	eb 04                	jmp    c010042b <stab_binsearch+0x42>
            m --;
c0100427:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c010042b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010042e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100431:	7c 1f                	jl     c0100452 <stab_binsearch+0x69>
c0100433:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100436:	89 d0                	mov    %edx,%eax
c0100438:	01 c0                	add    %eax,%eax
c010043a:	01 d0                	add    %edx,%eax
c010043c:	c1 e0 02             	shl    $0x2,%eax
c010043f:	89 c2                	mov    %eax,%edx
c0100441:	8b 45 08             	mov    0x8(%ebp),%eax
c0100444:	01 d0                	add    %edx,%eax
c0100446:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010044a:	0f b6 c0             	movzbl %al,%eax
c010044d:	3b 45 14             	cmp    0x14(%ebp),%eax
c0100450:	75 d5                	jne    c0100427 <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
c0100452:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100455:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100458:	7d 0b                	jge    c0100465 <stab_binsearch+0x7c>
            l = true_m + 1;
c010045a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010045d:	83 c0 01             	add    $0x1,%eax
c0100460:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c0100463:	eb 78                	jmp    c01004dd <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
c0100465:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c010046c:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010046f:	89 d0                	mov    %edx,%eax
c0100471:	01 c0                	add    %eax,%eax
c0100473:	01 d0                	add    %edx,%eax
c0100475:	c1 e0 02             	shl    $0x2,%eax
c0100478:	89 c2                	mov    %eax,%edx
c010047a:	8b 45 08             	mov    0x8(%ebp),%eax
c010047d:	01 d0                	add    %edx,%eax
c010047f:	8b 40 08             	mov    0x8(%eax),%eax
c0100482:	3b 45 18             	cmp    0x18(%ebp),%eax
c0100485:	73 13                	jae    c010049a <stab_binsearch+0xb1>
            *region_left = m;
c0100487:	8b 45 0c             	mov    0xc(%ebp),%eax
c010048a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010048d:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c010048f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100492:	83 c0 01             	add    $0x1,%eax
c0100495:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100498:	eb 43                	jmp    c01004dd <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
c010049a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010049d:	89 d0                	mov    %edx,%eax
c010049f:	01 c0                	add    %eax,%eax
c01004a1:	01 d0                	add    %edx,%eax
c01004a3:	c1 e0 02             	shl    $0x2,%eax
c01004a6:	89 c2                	mov    %eax,%edx
c01004a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01004ab:	01 d0                	add    %edx,%eax
c01004ad:	8b 40 08             	mov    0x8(%eax),%eax
c01004b0:	3b 45 18             	cmp    0x18(%ebp),%eax
c01004b3:	76 16                	jbe    c01004cb <stab_binsearch+0xe2>
            *region_right = m - 1;
c01004b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004b8:	8d 50 ff             	lea    -0x1(%eax),%edx
c01004bb:	8b 45 10             	mov    0x10(%ebp),%eax
c01004be:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c01004c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004c3:	83 e8 01             	sub    $0x1,%eax
c01004c6:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004c9:	eb 12                	jmp    c01004dd <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01004cb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004ce:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004d1:	89 10                	mov    %edx,(%eax)
            l = m;
c01004d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004d6:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01004d9:	83 45 18 01          	addl   $0x1,0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
c01004dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01004e0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01004e3:	0f 8e 22 ff ff ff    	jle    c010040b <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
c01004e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01004ed:	75 0f                	jne    c01004fe <stab_binsearch+0x115>
        *region_right = *region_left - 1;
c01004ef:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004f2:	8b 00                	mov    (%eax),%eax
c01004f4:	8d 50 ff             	lea    -0x1(%eax),%edx
c01004f7:	8b 45 10             	mov    0x10(%ebp),%eax
c01004fa:	89 10                	mov    %edx,(%eax)
c01004fc:	eb 3f                	jmp    c010053d <stab_binsearch+0x154>
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
c01004fe:	8b 45 10             	mov    0x10(%ebp),%eax
c0100501:	8b 00                	mov    (%eax),%eax
c0100503:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c0100506:	eb 04                	jmp    c010050c <stab_binsearch+0x123>
c0100508:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
c010050c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010050f:	8b 00                	mov    (%eax),%eax
c0100511:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100514:	7d 1f                	jge    c0100535 <stab_binsearch+0x14c>
c0100516:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100519:	89 d0                	mov    %edx,%eax
c010051b:	01 c0                	add    %eax,%eax
c010051d:	01 d0                	add    %edx,%eax
c010051f:	c1 e0 02             	shl    $0x2,%eax
c0100522:	89 c2                	mov    %eax,%edx
c0100524:	8b 45 08             	mov    0x8(%ebp),%eax
c0100527:	01 d0                	add    %edx,%eax
c0100529:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010052d:	0f b6 c0             	movzbl %al,%eax
c0100530:	3b 45 14             	cmp    0x14(%ebp),%eax
c0100533:	75 d3                	jne    c0100508 <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
c0100535:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100538:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010053b:	89 10                	mov    %edx,(%eax)
    }
}
c010053d:	c9                   	leave  
c010053e:	c3                   	ret    

c010053f <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c010053f:	55                   	push   %ebp
c0100540:	89 e5                	mov    %esp,%ebp
c0100542:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c0100545:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100548:	c7 00 2c 5f 10 c0    	movl   $0xc0105f2c,(%eax)
    info->eip_line = 0;
c010054e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100551:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c0100558:	8b 45 0c             	mov    0xc(%ebp),%eax
c010055b:	c7 40 08 2c 5f 10 c0 	movl   $0xc0105f2c,0x8(%eax)
    info->eip_fn_namelen = 9;
c0100562:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100565:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c010056c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010056f:	8b 55 08             	mov    0x8(%ebp),%edx
c0100572:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c0100575:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100578:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c010057f:	c7 45 f4 98 71 10 c0 	movl   $0xc0107198,-0xc(%ebp)
    stab_end = __STAB_END__;
c0100586:	c7 45 f0 ec 1c 11 c0 	movl   $0xc0111cec,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c010058d:	c7 45 ec ed 1c 11 c0 	movl   $0xc0111ced,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c0100594:	c7 45 e8 22 47 11 c0 	movl   $0xc0114722,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c010059b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010059e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01005a1:	76 0d                	jbe    c01005b0 <debuginfo_eip+0x71>
c01005a3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01005a6:	83 e8 01             	sub    $0x1,%eax
c01005a9:	0f b6 00             	movzbl (%eax),%eax
c01005ac:	84 c0                	test   %al,%al
c01005ae:	74 0a                	je     c01005ba <debuginfo_eip+0x7b>
        return -1;
c01005b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01005b5:	e9 c0 02 00 00       	jmp    c010087a <debuginfo_eip+0x33b>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c01005ba:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c01005c1:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01005c7:	29 c2                	sub    %eax,%edx
c01005c9:	89 d0                	mov    %edx,%eax
c01005cb:	c1 f8 02             	sar    $0x2,%eax
c01005ce:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01005d4:	83 e8 01             	sub    $0x1,%eax
c01005d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01005da:	8b 45 08             	mov    0x8(%ebp),%eax
c01005dd:	89 44 24 10          	mov    %eax,0x10(%esp)
c01005e1:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c01005e8:	00 
c01005e9:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01005ec:	89 44 24 08          	mov    %eax,0x8(%esp)
c01005f0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c01005f3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01005f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01005fa:	89 04 24             	mov    %eax,(%esp)
c01005fd:	e8 e7 fd ff ff       	call   c01003e9 <stab_binsearch>
    if (lfile == 0)
c0100602:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100605:	85 c0                	test   %eax,%eax
c0100607:	75 0a                	jne    c0100613 <debuginfo_eip+0xd4>
        return -1;
c0100609:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010060e:	e9 67 02 00 00       	jmp    c010087a <debuginfo_eip+0x33b>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c0100613:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100616:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0100619:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010061c:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c010061f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100622:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100626:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c010062d:	00 
c010062e:	8d 45 d8             	lea    -0x28(%ebp),%eax
c0100631:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100635:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100638:	89 44 24 04          	mov    %eax,0x4(%esp)
c010063c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010063f:	89 04 24             	mov    %eax,(%esp)
c0100642:	e8 a2 fd ff ff       	call   c01003e9 <stab_binsearch>

    if (lfun <= rfun) {
c0100647:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010064a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010064d:	39 c2                	cmp    %eax,%edx
c010064f:	7f 7c                	jg     c01006cd <debuginfo_eip+0x18e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c0100651:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100654:	89 c2                	mov    %eax,%edx
c0100656:	89 d0                	mov    %edx,%eax
c0100658:	01 c0                	add    %eax,%eax
c010065a:	01 d0                	add    %edx,%eax
c010065c:	c1 e0 02             	shl    $0x2,%eax
c010065f:	89 c2                	mov    %eax,%edx
c0100661:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100664:	01 d0                	add    %edx,%eax
c0100666:	8b 10                	mov    (%eax),%edx
c0100668:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c010066b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010066e:	29 c1                	sub    %eax,%ecx
c0100670:	89 c8                	mov    %ecx,%eax
c0100672:	39 c2                	cmp    %eax,%edx
c0100674:	73 22                	jae    c0100698 <debuginfo_eip+0x159>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c0100676:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100679:	89 c2                	mov    %eax,%edx
c010067b:	89 d0                	mov    %edx,%eax
c010067d:	01 c0                	add    %eax,%eax
c010067f:	01 d0                	add    %edx,%eax
c0100681:	c1 e0 02             	shl    $0x2,%eax
c0100684:	89 c2                	mov    %eax,%edx
c0100686:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100689:	01 d0                	add    %edx,%eax
c010068b:	8b 10                	mov    (%eax),%edx
c010068d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100690:	01 c2                	add    %eax,%edx
c0100692:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100695:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c0100698:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010069b:	89 c2                	mov    %eax,%edx
c010069d:	89 d0                	mov    %edx,%eax
c010069f:	01 c0                	add    %eax,%eax
c01006a1:	01 d0                	add    %edx,%eax
c01006a3:	c1 e0 02             	shl    $0x2,%eax
c01006a6:	89 c2                	mov    %eax,%edx
c01006a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006ab:	01 d0                	add    %edx,%eax
c01006ad:	8b 50 08             	mov    0x8(%eax),%edx
c01006b0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006b3:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c01006b6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006b9:	8b 40 10             	mov    0x10(%eax),%eax
c01006bc:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c01006bf:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006c2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c01006c5:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01006c8:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01006cb:	eb 15                	jmp    c01006e2 <debuginfo_eip+0x1a3>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c01006cd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006d0:	8b 55 08             	mov    0x8(%ebp),%edx
c01006d3:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01006d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c01006dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006df:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01006e2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006e5:	8b 40 08             	mov    0x8(%eax),%eax
c01006e8:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c01006ef:	00 
c01006f0:	89 04 24             	mov    %eax,(%esp)
c01006f3:	e8 69 54 00 00       	call   c0105b61 <strfind>
c01006f8:	89 c2                	mov    %eax,%edx
c01006fa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006fd:	8b 40 08             	mov    0x8(%eax),%eax
c0100700:	29 c2                	sub    %eax,%edx
c0100702:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100705:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c0100708:	8b 45 08             	mov    0x8(%ebp),%eax
c010070b:	89 44 24 10          	mov    %eax,0x10(%esp)
c010070f:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c0100716:	00 
c0100717:	8d 45 d0             	lea    -0x30(%ebp),%eax
c010071a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010071e:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c0100721:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100725:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100728:	89 04 24             	mov    %eax,(%esp)
c010072b:	e8 b9 fc ff ff       	call   c01003e9 <stab_binsearch>
    if (lline <= rline) {
c0100730:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100733:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100736:	39 c2                	cmp    %eax,%edx
c0100738:	7f 24                	jg     c010075e <debuginfo_eip+0x21f>
        info->eip_line = stabs[rline].n_desc;
c010073a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010073d:	89 c2                	mov    %eax,%edx
c010073f:	89 d0                	mov    %edx,%eax
c0100741:	01 c0                	add    %eax,%eax
c0100743:	01 d0                	add    %edx,%eax
c0100745:	c1 e0 02             	shl    $0x2,%eax
c0100748:	89 c2                	mov    %eax,%edx
c010074a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010074d:	01 d0                	add    %edx,%eax
c010074f:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0100753:	0f b7 d0             	movzwl %ax,%edx
c0100756:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100759:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c010075c:	eb 13                	jmp    c0100771 <debuginfo_eip+0x232>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
c010075e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100763:	e9 12 01 00 00       	jmp    c010087a <debuginfo_eip+0x33b>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c0100768:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010076b:	83 e8 01             	sub    $0x1,%eax
c010076e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100771:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100774:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100777:	39 c2                	cmp    %eax,%edx
c0100779:	7c 56                	jl     c01007d1 <debuginfo_eip+0x292>
           && stabs[lline].n_type != N_SOL
c010077b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010077e:	89 c2                	mov    %eax,%edx
c0100780:	89 d0                	mov    %edx,%eax
c0100782:	01 c0                	add    %eax,%eax
c0100784:	01 d0                	add    %edx,%eax
c0100786:	c1 e0 02             	shl    $0x2,%eax
c0100789:	89 c2                	mov    %eax,%edx
c010078b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010078e:	01 d0                	add    %edx,%eax
c0100790:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100794:	3c 84                	cmp    $0x84,%al
c0100796:	74 39                	je     c01007d1 <debuginfo_eip+0x292>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c0100798:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010079b:	89 c2                	mov    %eax,%edx
c010079d:	89 d0                	mov    %edx,%eax
c010079f:	01 c0                	add    %eax,%eax
c01007a1:	01 d0                	add    %edx,%eax
c01007a3:	c1 e0 02             	shl    $0x2,%eax
c01007a6:	89 c2                	mov    %eax,%edx
c01007a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007ab:	01 d0                	add    %edx,%eax
c01007ad:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01007b1:	3c 64                	cmp    $0x64,%al
c01007b3:	75 b3                	jne    c0100768 <debuginfo_eip+0x229>
c01007b5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007b8:	89 c2                	mov    %eax,%edx
c01007ba:	89 d0                	mov    %edx,%eax
c01007bc:	01 c0                	add    %eax,%eax
c01007be:	01 d0                	add    %edx,%eax
c01007c0:	c1 e0 02             	shl    $0x2,%eax
c01007c3:	89 c2                	mov    %eax,%edx
c01007c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007c8:	01 d0                	add    %edx,%eax
c01007ca:	8b 40 08             	mov    0x8(%eax),%eax
c01007cd:	85 c0                	test   %eax,%eax
c01007cf:	74 97                	je     c0100768 <debuginfo_eip+0x229>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c01007d1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01007d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01007d7:	39 c2                	cmp    %eax,%edx
c01007d9:	7c 46                	jl     c0100821 <debuginfo_eip+0x2e2>
c01007db:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007de:	89 c2                	mov    %eax,%edx
c01007e0:	89 d0                	mov    %edx,%eax
c01007e2:	01 c0                	add    %eax,%eax
c01007e4:	01 d0                	add    %edx,%eax
c01007e6:	c1 e0 02             	shl    $0x2,%eax
c01007e9:	89 c2                	mov    %eax,%edx
c01007eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007ee:	01 d0                	add    %edx,%eax
c01007f0:	8b 10                	mov    (%eax),%edx
c01007f2:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c01007f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01007f8:	29 c1                	sub    %eax,%ecx
c01007fa:	89 c8                	mov    %ecx,%eax
c01007fc:	39 c2                	cmp    %eax,%edx
c01007fe:	73 21                	jae    c0100821 <debuginfo_eip+0x2e2>
        info->eip_file = stabstr + stabs[lline].n_strx;
c0100800:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100803:	89 c2                	mov    %eax,%edx
c0100805:	89 d0                	mov    %edx,%eax
c0100807:	01 c0                	add    %eax,%eax
c0100809:	01 d0                	add    %edx,%eax
c010080b:	c1 e0 02             	shl    $0x2,%eax
c010080e:	89 c2                	mov    %eax,%edx
c0100810:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100813:	01 d0                	add    %edx,%eax
c0100815:	8b 10                	mov    (%eax),%edx
c0100817:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010081a:	01 c2                	add    %eax,%edx
c010081c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010081f:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c0100821:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100824:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100827:	39 c2                	cmp    %eax,%edx
c0100829:	7d 4a                	jge    c0100875 <debuginfo_eip+0x336>
        for (lline = lfun + 1;
c010082b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010082e:	83 c0 01             	add    $0x1,%eax
c0100831:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0100834:	eb 18                	jmp    c010084e <debuginfo_eip+0x30f>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c0100836:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100839:	8b 40 14             	mov    0x14(%eax),%eax
c010083c:	8d 50 01             	lea    0x1(%eax),%edx
c010083f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100842:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
c0100845:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100848:	83 c0 01             	add    $0x1,%eax
c010084b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
c010084e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100851:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
c0100854:	39 c2                	cmp    %eax,%edx
c0100856:	7d 1d                	jge    c0100875 <debuginfo_eip+0x336>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100858:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010085b:	89 c2                	mov    %eax,%edx
c010085d:	89 d0                	mov    %edx,%eax
c010085f:	01 c0                	add    %eax,%eax
c0100861:	01 d0                	add    %edx,%eax
c0100863:	c1 e0 02             	shl    $0x2,%eax
c0100866:	89 c2                	mov    %eax,%edx
c0100868:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010086b:	01 d0                	add    %edx,%eax
c010086d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100871:	3c a0                	cmp    $0xa0,%al
c0100873:	74 c1                	je     c0100836 <debuginfo_eip+0x2f7>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
c0100875:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010087a:	c9                   	leave  
c010087b:	c3                   	ret    

c010087c <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c010087c:	55                   	push   %ebp
c010087d:	89 e5                	mov    %esp,%ebp
c010087f:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c0100882:	c7 04 24 36 5f 10 c0 	movl   $0xc0105f36,(%esp)
c0100889:	e8 ba fa ff ff       	call   c0100348 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c010088e:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c0100895:	c0 
c0100896:	c7 04 24 4f 5f 10 c0 	movl   $0xc0105f4f,(%esp)
c010089d:	e8 a6 fa ff ff       	call   c0100348 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c01008a2:	c7 44 24 04 76 5e 10 	movl   $0xc0105e76,0x4(%esp)
c01008a9:	c0 
c01008aa:	c7 04 24 67 5f 10 c0 	movl   $0xc0105f67,(%esp)
c01008b1:	e8 92 fa ff ff       	call   c0100348 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c01008b6:	c7 44 24 04 00 a0 11 	movl   $0xc011a000,0x4(%esp)
c01008bd:	c0 
c01008be:	c7 04 24 7f 5f 10 c0 	movl   $0xc0105f7f,(%esp)
c01008c5:	e8 7e fa ff ff       	call   c0100348 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c01008ca:	c7 44 24 04 28 af 11 	movl   $0xc011af28,0x4(%esp)
c01008d1:	c0 
c01008d2:	c7 04 24 97 5f 10 c0 	movl   $0xc0105f97,(%esp)
c01008d9:	e8 6a fa ff ff       	call   c0100348 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c01008de:	b8 28 af 11 c0       	mov    $0xc011af28,%eax
c01008e3:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01008e9:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c01008ee:	29 c2                	sub    %eax,%edx
c01008f0:	89 d0                	mov    %edx,%eax
c01008f2:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01008f8:	85 c0                	test   %eax,%eax
c01008fa:	0f 48 c2             	cmovs  %edx,%eax
c01008fd:	c1 f8 0a             	sar    $0xa,%eax
c0100900:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100904:	c7 04 24 b0 5f 10 c0 	movl   $0xc0105fb0,(%esp)
c010090b:	e8 38 fa ff ff       	call   c0100348 <cprintf>
}
c0100910:	c9                   	leave  
c0100911:	c3                   	ret    

c0100912 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c0100912:	55                   	push   %ebp
c0100913:	89 e5                	mov    %esp,%ebp
c0100915:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c010091b:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010091e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100922:	8b 45 08             	mov    0x8(%ebp),%eax
c0100925:	89 04 24             	mov    %eax,(%esp)
c0100928:	e8 12 fc ff ff       	call   c010053f <debuginfo_eip>
c010092d:	85 c0                	test   %eax,%eax
c010092f:	74 15                	je     c0100946 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c0100931:	8b 45 08             	mov    0x8(%ebp),%eax
c0100934:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100938:	c7 04 24 da 5f 10 c0 	movl   $0xc0105fda,(%esp)
c010093f:	e8 04 fa ff ff       	call   c0100348 <cprintf>
c0100944:	eb 6d                	jmp    c01009b3 <print_debuginfo+0xa1>
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100946:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010094d:	eb 1c                	jmp    c010096b <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
c010094f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100952:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100955:	01 d0                	add    %edx,%eax
c0100957:	0f b6 00             	movzbl (%eax),%eax
c010095a:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100960:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100963:	01 ca                	add    %ecx,%edx
c0100965:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100967:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010096b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010096e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100971:	7f dc                	jg     c010094f <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
c0100973:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100979:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010097c:	01 d0                	add    %edx,%eax
c010097e:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
c0100981:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100984:	8b 55 08             	mov    0x8(%ebp),%edx
c0100987:	89 d1                	mov    %edx,%ecx
c0100989:	29 c1                	sub    %eax,%ecx
c010098b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010098e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100991:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0100995:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c010099b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c010099f:	89 54 24 08          	mov    %edx,0x8(%esp)
c01009a3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009a7:	c7 04 24 f6 5f 10 c0 	movl   $0xc0105ff6,(%esp)
c01009ae:	e8 95 f9 ff ff       	call   c0100348 <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
c01009b3:	c9                   	leave  
c01009b4:	c3                   	ret    

c01009b5 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c01009b5:	55                   	push   %ebp
c01009b6:	89 e5                	mov    %esp,%ebp
c01009b8:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c01009bb:	8b 45 04             	mov    0x4(%ebp),%eax
c01009be:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c01009c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01009c4:	c9                   	leave  
c01009c5:	c3                   	ret    

c01009c6 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c01009c6:	55                   	push   %ebp
c01009c7:	89 e5                	mov    %esp,%ebp
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
}
c01009c9:	5d                   	pop    %ebp
c01009ca:	c3                   	ret    

c01009cb <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c01009cb:	55                   	push   %ebp
c01009cc:	89 e5                	mov    %esp,%ebp
c01009ce:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c01009d1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c01009d8:	eb 0c                	jmp    c01009e6 <parse+0x1b>
            *buf ++ = '\0';
c01009da:	8b 45 08             	mov    0x8(%ebp),%eax
c01009dd:	8d 50 01             	lea    0x1(%eax),%edx
c01009e0:	89 55 08             	mov    %edx,0x8(%ebp)
c01009e3:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c01009e6:	8b 45 08             	mov    0x8(%ebp),%eax
c01009e9:	0f b6 00             	movzbl (%eax),%eax
c01009ec:	84 c0                	test   %al,%al
c01009ee:	74 1d                	je     c0100a0d <parse+0x42>
c01009f0:	8b 45 08             	mov    0x8(%ebp),%eax
c01009f3:	0f b6 00             	movzbl (%eax),%eax
c01009f6:	0f be c0             	movsbl %al,%eax
c01009f9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009fd:	c7 04 24 88 60 10 c0 	movl   $0xc0106088,(%esp)
c0100a04:	e8 25 51 00 00       	call   c0105b2e <strchr>
c0100a09:	85 c0                	test   %eax,%eax
c0100a0b:	75 cd                	jne    c01009da <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
c0100a0d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a10:	0f b6 00             	movzbl (%eax),%eax
c0100a13:	84 c0                	test   %al,%al
c0100a15:	75 02                	jne    c0100a19 <parse+0x4e>
            break;
c0100a17:	eb 67                	jmp    c0100a80 <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100a19:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100a1d:	75 14                	jne    c0100a33 <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100a1f:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100a26:	00 
c0100a27:	c7 04 24 8d 60 10 c0 	movl   $0xc010608d,(%esp)
c0100a2e:	e8 15 f9 ff ff       	call   c0100348 <cprintf>
        }
        argv[argc ++] = buf;
c0100a33:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a36:	8d 50 01             	lea    0x1(%eax),%edx
c0100a39:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100a3c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100a43:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100a46:	01 c2                	add    %eax,%edx
c0100a48:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a4b:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100a4d:	eb 04                	jmp    c0100a53 <parse+0x88>
            buf ++;
c0100a4f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100a53:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a56:	0f b6 00             	movzbl (%eax),%eax
c0100a59:	84 c0                	test   %al,%al
c0100a5b:	74 1d                	je     c0100a7a <parse+0xaf>
c0100a5d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a60:	0f b6 00             	movzbl (%eax),%eax
c0100a63:	0f be c0             	movsbl %al,%eax
c0100a66:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a6a:	c7 04 24 88 60 10 c0 	movl   $0xc0106088,(%esp)
c0100a71:	e8 b8 50 00 00       	call   c0105b2e <strchr>
c0100a76:	85 c0                	test   %eax,%eax
c0100a78:	74 d5                	je     c0100a4f <parse+0x84>
            buf ++;
        }
    }
c0100a7a:	90                   	nop
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100a7b:	e9 66 ff ff ff       	jmp    c01009e6 <parse+0x1b>
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
c0100a80:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100a83:	c9                   	leave  
c0100a84:	c3                   	ret    

c0100a85 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100a85:	55                   	push   %ebp
c0100a86:	89 e5                	mov    %esp,%ebp
c0100a88:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100a8b:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100a8e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a92:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a95:	89 04 24             	mov    %eax,(%esp)
c0100a98:	e8 2e ff ff ff       	call   c01009cb <parse>
c0100a9d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100aa0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100aa4:	75 0a                	jne    c0100ab0 <runcmd+0x2b>
        return 0;
c0100aa6:	b8 00 00 00 00       	mov    $0x0,%eax
c0100aab:	e9 85 00 00 00       	jmp    c0100b35 <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100ab0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100ab7:	eb 5c                	jmp    c0100b15 <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100ab9:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100abc:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100abf:	89 d0                	mov    %edx,%eax
c0100ac1:	01 c0                	add    %eax,%eax
c0100ac3:	01 d0                	add    %edx,%eax
c0100ac5:	c1 e0 02             	shl    $0x2,%eax
c0100ac8:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100acd:	8b 00                	mov    (%eax),%eax
c0100acf:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100ad3:	89 04 24             	mov    %eax,(%esp)
c0100ad6:	e8 b4 4f 00 00       	call   c0105a8f <strcmp>
c0100adb:	85 c0                	test   %eax,%eax
c0100add:	75 32                	jne    c0100b11 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100adf:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100ae2:	89 d0                	mov    %edx,%eax
c0100ae4:	01 c0                	add    %eax,%eax
c0100ae6:	01 d0                	add    %edx,%eax
c0100ae8:	c1 e0 02             	shl    $0x2,%eax
c0100aeb:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100af0:	8b 40 08             	mov    0x8(%eax),%eax
c0100af3:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100af6:	8d 4a ff             	lea    -0x1(%edx),%ecx
c0100af9:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100afc:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100b00:	8d 55 b0             	lea    -0x50(%ebp),%edx
c0100b03:	83 c2 04             	add    $0x4,%edx
c0100b06:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100b0a:	89 0c 24             	mov    %ecx,(%esp)
c0100b0d:	ff d0                	call   *%eax
c0100b0f:	eb 24                	jmp    c0100b35 <runcmd+0xb0>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100b11:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100b15:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b18:	83 f8 02             	cmp    $0x2,%eax
c0100b1b:	76 9c                	jbe    c0100ab9 <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100b1d:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100b20:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b24:	c7 04 24 ab 60 10 c0 	movl   $0xc01060ab,(%esp)
c0100b2b:	e8 18 f8 ff ff       	call   c0100348 <cprintf>
    return 0;
c0100b30:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100b35:	c9                   	leave  
c0100b36:	c3                   	ret    

c0100b37 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100b37:	55                   	push   %ebp
c0100b38:	89 e5                	mov    %esp,%ebp
c0100b3a:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100b3d:	c7 04 24 c4 60 10 c0 	movl   $0xc01060c4,(%esp)
c0100b44:	e8 ff f7 ff ff       	call   c0100348 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100b49:	c7 04 24 ec 60 10 c0 	movl   $0xc01060ec,(%esp)
c0100b50:	e8 f3 f7 ff ff       	call   c0100348 <cprintf>

    if (tf != NULL) {
c0100b55:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100b59:	74 0b                	je     c0100b66 <kmonitor+0x2f>
        print_trapframe(tf);
c0100b5b:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b5e:	89 04 24             	mov    %eax,(%esp)
c0100b61:	e8 d5 0c 00 00       	call   c010183b <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100b66:	c7 04 24 11 61 10 c0 	movl   $0xc0106111,(%esp)
c0100b6d:	e8 cd f6 ff ff       	call   c010023f <readline>
c0100b72:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100b75:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100b79:	74 18                	je     c0100b93 <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
c0100b7b:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b7e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b82:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b85:	89 04 24             	mov    %eax,(%esp)
c0100b88:	e8 f8 fe ff ff       	call   c0100a85 <runcmd>
c0100b8d:	85 c0                	test   %eax,%eax
c0100b8f:	79 02                	jns    c0100b93 <kmonitor+0x5c>
                break;
c0100b91:	eb 02                	jmp    c0100b95 <kmonitor+0x5e>
            }
        }
    }
c0100b93:	eb d1                	jmp    c0100b66 <kmonitor+0x2f>
}
c0100b95:	c9                   	leave  
c0100b96:	c3                   	ret    

c0100b97 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100b97:	55                   	push   %ebp
c0100b98:	89 e5                	mov    %esp,%ebp
c0100b9a:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100b9d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100ba4:	eb 3f                	jmp    c0100be5 <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100ba6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100ba9:	89 d0                	mov    %edx,%eax
c0100bab:	01 c0                	add    %eax,%eax
c0100bad:	01 d0                	add    %edx,%eax
c0100baf:	c1 e0 02             	shl    $0x2,%eax
c0100bb2:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100bb7:	8b 48 04             	mov    0x4(%eax),%ecx
c0100bba:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100bbd:	89 d0                	mov    %edx,%eax
c0100bbf:	01 c0                	add    %eax,%eax
c0100bc1:	01 d0                	add    %edx,%eax
c0100bc3:	c1 e0 02             	shl    $0x2,%eax
c0100bc6:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100bcb:	8b 00                	mov    (%eax),%eax
c0100bcd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100bd1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bd5:	c7 04 24 15 61 10 c0 	movl   $0xc0106115,(%esp)
c0100bdc:	e8 67 f7 ff ff       	call   c0100348 <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100be1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100be5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100be8:	83 f8 02             	cmp    $0x2,%eax
c0100beb:	76 b9                	jbe    c0100ba6 <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
c0100bed:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100bf2:	c9                   	leave  
c0100bf3:	c3                   	ret    

c0100bf4 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100bf4:	55                   	push   %ebp
c0100bf5:	89 e5                	mov    %esp,%ebp
c0100bf7:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100bfa:	e8 7d fc ff ff       	call   c010087c <print_kerninfo>
    return 0;
c0100bff:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100c04:	c9                   	leave  
c0100c05:	c3                   	ret    

c0100c06 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100c06:	55                   	push   %ebp
c0100c07:	89 e5                	mov    %esp,%ebp
c0100c09:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100c0c:	e8 b5 fd ff ff       	call   c01009c6 <print_stackframe>
    return 0;
c0100c11:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100c16:	c9                   	leave  
c0100c17:	c3                   	ret    

c0100c18 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0100c18:	55                   	push   %ebp
c0100c19:	89 e5                	mov    %esp,%ebp
c0100c1b:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c0100c1e:	a1 20 a4 11 c0       	mov    0xc011a420,%eax
c0100c23:	85 c0                	test   %eax,%eax
c0100c25:	74 02                	je     c0100c29 <__panic+0x11>
        goto panic_dead;
c0100c27:	eb 59                	jmp    c0100c82 <__panic+0x6a>
    }
    is_panic = 1;
c0100c29:	c7 05 20 a4 11 c0 01 	movl   $0x1,0xc011a420
c0100c30:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100c33:	8d 45 14             	lea    0x14(%ebp),%eax
c0100c36:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100c39:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100c3c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100c40:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c43:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c47:	c7 04 24 1e 61 10 c0 	movl   $0xc010611e,(%esp)
c0100c4e:	e8 f5 f6 ff ff       	call   c0100348 <cprintf>
    vcprintf(fmt, ap);
c0100c53:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c56:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c5a:	8b 45 10             	mov    0x10(%ebp),%eax
c0100c5d:	89 04 24             	mov    %eax,(%esp)
c0100c60:	e8 b0 f6 ff ff       	call   c0100315 <vcprintf>
    cprintf("\n");
c0100c65:	c7 04 24 3a 61 10 c0 	movl   $0xc010613a,(%esp)
c0100c6c:	e8 d7 f6 ff ff       	call   c0100348 <cprintf>
    
    cprintf("stack trackback:\n");
c0100c71:	c7 04 24 3c 61 10 c0 	movl   $0xc010613c,(%esp)
c0100c78:	e8 cb f6 ff ff       	call   c0100348 <cprintf>
    print_stackframe();
c0100c7d:	e8 44 fd ff ff       	call   c01009c6 <print_stackframe>
    
    va_end(ap);

panic_dead:
    intr_disable();
c0100c82:	e8 85 09 00 00       	call   c010160c <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100c87:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100c8e:	e8 a4 fe ff ff       	call   c0100b37 <kmonitor>
    }
c0100c93:	eb f2                	jmp    c0100c87 <__panic+0x6f>

c0100c95 <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100c95:	55                   	push   %ebp
c0100c96:	89 e5                	mov    %esp,%ebp
c0100c98:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c0100c9b:	8d 45 14             	lea    0x14(%ebp),%eax
c0100c9e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100ca1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100ca4:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100ca8:	8b 45 08             	mov    0x8(%ebp),%eax
c0100cab:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100caf:	c7 04 24 4e 61 10 c0 	movl   $0xc010614e,(%esp)
c0100cb6:	e8 8d f6 ff ff       	call   c0100348 <cprintf>
    vcprintf(fmt, ap);
c0100cbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100cbe:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100cc2:	8b 45 10             	mov    0x10(%ebp),%eax
c0100cc5:	89 04 24             	mov    %eax,(%esp)
c0100cc8:	e8 48 f6 ff ff       	call   c0100315 <vcprintf>
    cprintf("\n");
c0100ccd:	c7 04 24 3a 61 10 c0 	movl   $0xc010613a,(%esp)
c0100cd4:	e8 6f f6 ff ff       	call   c0100348 <cprintf>
    va_end(ap);
}
c0100cd9:	c9                   	leave  
c0100cda:	c3                   	ret    

c0100cdb <is_kernel_panic>:

bool
is_kernel_panic(void) {
c0100cdb:	55                   	push   %ebp
c0100cdc:	89 e5                	mov    %esp,%ebp
    return is_panic;
c0100cde:	a1 20 a4 11 c0       	mov    0xc011a420,%eax
}
c0100ce3:	5d                   	pop    %ebp
c0100ce4:	c3                   	ret    

c0100ce5 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100ce5:	55                   	push   %ebp
c0100ce6:	89 e5                	mov    %esp,%ebp
c0100ce8:	83 ec 28             	sub    $0x28,%esp
c0100ceb:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
c0100cf1:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100cf5:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100cf9:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100cfd:	ee                   	out    %al,(%dx)
c0100cfe:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100d04:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
c0100d08:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100d0c:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100d10:	ee                   	out    %al,(%dx)
c0100d11:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
c0100d17:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
c0100d1b:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100d1f:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100d23:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100d24:	c7 05 0c af 11 c0 00 	movl   $0x0,0xc011af0c
c0100d2b:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100d2e:	c7 04 24 6c 61 10 c0 	movl   $0xc010616c,(%esp)
c0100d35:	e8 0e f6 ff ff       	call   c0100348 <cprintf>
    pic_enable(IRQ_TIMER);
c0100d3a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100d41:	e8 24 09 00 00       	call   c010166a <pic_enable>
}
c0100d46:	c9                   	leave  
c0100d47:	c3                   	ret    

c0100d48 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0100d48:	55                   	push   %ebp
c0100d49:	89 e5                	mov    %esp,%ebp
c0100d4b:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100d4e:	9c                   	pushf  
c0100d4f:	58                   	pop    %eax
c0100d50:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100d53:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100d56:	25 00 02 00 00       	and    $0x200,%eax
c0100d5b:	85 c0                	test   %eax,%eax
c0100d5d:	74 0c                	je     c0100d6b <__intr_save+0x23>
        intr_disable();
c0100d5f:	e8 a8 08 00 00       	call   c010160c <intr_disable>
        return 1;
c0100d64:	b8 01 00 00 00       	mov    $0x1,%eax
c0100d69:	eb 05                	jmp    c0100d70 <__intr_save+0x28>
    }
    return 0;
c0100d6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d70:	c9                   	leave  
c0100d71:	c3                   	ret    

c0100d72 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100d72:	55                   	push   %ebp
c0100d73:	89 e5                	mov    %esp,%ebp
c0100d75:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100d78:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100d7c:	74 05                	je     c0100d83 <__intr_restore+0x11>
        intr_enable();
c0100d7e:	e8 83 08 00 00       	call   c0101606 <intr_enable>
    }
}
c0100d83:	c9                   	leave  
c0100d84:	c3                   	ret    

c0100d85 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100d85:	55                   	push   %ebp
c0100d86:	89 e5                	mov    %esp,%ebp
c0100d88:	83 ec 10             	sub    $0x10,%esp
c0100d8b:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100d91:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100d95:	89 c2                	mov    %eax,%edx
c0100d97:	ec                   	in     (%dx),%al
c0100d98:	88 45 fd             	mov    %al,-0x3(%ebp)
c0100d9b:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100da1:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100da5:	89 c2                	mov    %eax,%edx
c0100da7:	ec                   	in     (%dx),%al
c0100da8:	88 45 f9             	mov    %al,-0x7(%ebp)
c0100dab:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0100db1:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100db5:	89 c2                	mov    %eax,%edx
c0100db7:	ec                   	in     (%dx),%al
c0100db8:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100dbb:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
c0100dc1:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100dc5:	89 c2                	mov    %eax,%edx
c0100dc7:	ec                   	in     (%dx),%al
c0100dc8:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100dcb:	c9                   	leave  
c0100dcc:	c3                   	ret    

c0100dcd <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100dcd:	55                   	push   %ebp
c0100dce:	89 e5                	mov    %esp,%ebp
c0100dd0:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100dd3:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100dda:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ddd:	0f b7 00             	movzwl (%eax),%eax
c0100de0:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100de4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100de7:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100dec:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100def:	0f b7 00             	movzwl (%eax),%eax
c0100df2:	66 3d 5a a5          	cmp    $0xa55a,%ax
c0100df6:	74 12                	je     c0100e0a <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100df8:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100dff:	66 c7 05 46 a4 11 c0 	movw   $0x3b4,0xc011a446
c0100e06:	b4 03 
c0100e08:	eb 13                	jmp    c0100e1d <cga_init+0x50>
    } else {
        *cp = was;
c0100e0a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e0d:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100e11:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100e14:	66 c7 05 46 a4 11 c0 	movw   $0x3d4,0xc011a446
c0100e1b:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100e1d:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100e24:	0f b7 c0             	movzwl %ax,%eax
c0100e27:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0100e2b:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100e2f:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100e33:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100e37:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c0100e38:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100e3f:	83 c0 01             	add    $0x1,%eax
c0100e42:	0f b7 c0             	movzwl %ax,%eax
c0100e45:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100e49:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0100e4d:	89 c2                	mov    %eax,%edx
c0100e4f:	ec                   	in     (%dx),%al
c0100e50:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0100e53:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100e57:	0f b6 c0             	movzbl %al,%eax
c0100e5a:	c1 e0 08             	shl    $0x8,%eax
c0100e5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0100e60:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100e67:	0f b7 c0             	movzwl %ax,%eax
c0100e6a:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c0100e6e:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100e72:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100e76:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100e7a:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c0100e7b:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100e82:	83 c0 01             	add    $0x1,%eax
c0100e85:	0f b7 c0             	movzwl %ax,%eax
c0100e88:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100e8c:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c0100e90:	89 c2                	mov    %eax,%edx
c0100e92:	ec                   	in     (%dx),%al
c0100e93:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
c0100e96:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100e9a:	0f b6 c0             	movzbl %al,%eax
c0100e9d:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0100ea0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ea3:	a3 40 a4 11 c0       	mov    %eax,0xc011a440
    crt_pos = pos;
c0100ea8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100eab:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
}
c0100eb1:	c9                   	leave  
c0100eb2:	c3                   	ret    

c0100eb3 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0100eb3:	55                   	push   %ebp
c0100eb4:	89 e5                	mov    %esp,%ebp
c0100eb6:	83 ec 48             	sub    $0x48,%esp
c0100eb9:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
c0100ebf:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ec3:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100ec7:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100ecb:	ee                   	out    %al,(%dx)
c0100ecc:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
c0100ed2:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
c0100ed6:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100eda:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100ede:	ee                   	out    %al,(%dx)
c0100edf:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
c0100ee5:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
c0100ee9:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100eed:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100ef1:	ee                   	out    %al,(%dx)
c0100ef2:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0100ef8:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
c0100efc:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100f00:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100f04:	ee                   	out    %al,(%dx)
c0100f05:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
c0100f0b:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
c0100f0f:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100f13:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0100f17:	ee                   	out    %al,(%dx)
c0100f18:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
c0100f1e:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
c0100f22:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0100f26:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0100f2a:	ee                   	out    %al,(%dx)
c0100f2b:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c0100f31:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
c0100f35:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0100f39:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0100f3d:	ee                   	out    %al,(%dx)
c0100f3e:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f44:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
c0100f48:	89 c2                	mov    %eax,%edx
c0100f4a:	ec                   	in     (%dx),%al
c0100f4b:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
c0100f4e:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c0100f52:	3c ff                	cmp    $0xff,%al
c0100f54:	0f 95 c0             	setne  %al
c0100f57:	0f b6 c0             	movzbl %al,%eax
c0100f5a:	a3 48 a4 11 c0       	mov    %eax,0xc011a448
c0100f5f:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f65:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
c0100f69:	89 c2                	mov    %eax,%edx
c0100f6b:	ec                   	in     (%dx),%al
c0100f6c:	88 45 d5             	mov    %al,-0x2b(%ebp)
c0100f6f:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
c0100f75:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
c0100f79:	89 c2                	mov    %eax,%edx
c0100f7b:	ec                   	in     (%dx),%al
c0100f7c:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c0100f7f:	a1 48 a4 11 c0       	mov    0xc011a448,%eax
c0100f84:	85 c0                	test   %eax,%eax
c0100f86:	74 0c                	je     c0100f94 <serial_init+0xe1>
        pic_enable(IRQ_COM1);
c0100f88:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0100f8f:	e8 d6 06 00 00       	call   c010166a <pic_enable>
    }
}
c0100f94:	c9                   	leave  
c0100f95:	c3                   	ret    

c0100f96 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c0100f96:	55                   	push   %ebp
c0100f97:	89 e5                	mov    %esp,%ebp
c0100f99:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0100f9c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0100fa3:	eb 09                	jmp    c0100fae <lpt_putc_sub+0x18>
        delay();
c0100fa5:	e8 db fd ff ff       	call   c0100d85 <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0100faa:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0100fae:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c0100fb4:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100fb8:	89 c2                	mov    %eax,%edx
c0100fba:	ec                   	in     (%dx),%al
c0100fbb:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0100fbe:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0100fc2:	84 c0                	test   %al,%al
c0100fc4:	78 09                	js     c0100fcf <lpt_putc_sub+0x39>
c0100fc6:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0100fcd:	7e d6                	jle    c0100fa5 <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
c0100fcf:	8b 45 08             	mov    0x8(%ebp),%eax
c0100fd2:	0f b6 c0             	movzbl %al,%eax
c0100fd5:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
c0100fdb:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100fde:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100fe2:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100fe6:	ee                   	out    %al,(%dx)
c0100fe7:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c0100fed:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c0100ff1:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100ff5:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100ff9:	ee                   	out    %al,(%dx)
c0100ffa:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
c0101000:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
c0101004:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101008:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010100c:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c010100d:	c9                   	leave  
c010100e:	c3                   	ret    

c010100f <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c010100f:	55                   	push   %ebp
c0101010:	89 e5                	mov    %esp,%ebp
c0101012:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101015:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101019:	74 0d                	je     c0101028 <lpt_putc+0x19>
        lpt_putc_sub(c);
c010101b:	8b 45 08             	mov    0x8(%ebp),%eax
c010101e:	89 04 24             	mov    %eax,(%esp)
c0101021:	e8 70 ff ff ff       	call   c0100f96 <lpt_putc_sub>
c0101026:	eb 24                	jmp    c010104c <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
c0101028:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010102f:	e8 62 ff ff ff       	call   c0100f96 <lpt_putc_sub>
        lpt_putc_sub(' ');
c0101034:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010103b:	e8 56 ff ff ff       	call   c0100f96 <lpt_putc_sub>
        lpt_putc_sub('\b');
c0101040:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101047:	e8 4a ff ff ff       	call   c0100f96 <lpt_putc_sub>
    }
}
c010104c:	c9                   	leave  
c010104d:	c3                   	ret    

c010104e <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c010104e:	55                   	push   %ebp
c010104f:	89 e5                	mov    %esp,%ebp
c0101051:	53                   	push   %ebx
c0101052:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c0101055:	8b 45 08             	mov    0x8(%ebp),%eax
c0101058:	b0 00                	mov    $0x0,%al
c010105a:	85 c0                	test   %eax,%eax
c010105c:	75 07                	jne    c0101065 <cga_putc+0x17>
        c |= 0x0700;
c010105e:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c0101065:	8b 45 08             	mov    0x8(%ebp),%eax
c0101068:	0f b6 c0             	movzbl %al,%eax
c010106b:	83 f8 0a             	cmp    $0xa,%eax
c010106e:	74 4c                	je     c01010bc <cga_putc+0x6e>
c0101070:	83 f8 0d             	cmp    $0xd,%eax
c0101073:	74 57                	je     c01010cc <cga_putc+0x7e>
c0101075:	83 f8 08             	cmp    $0x8,%eax
c0101078:	0f 85 88 00 00 00    	jne    c0101106 <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
c010107e:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c0101085:	66 85 c0             	test   %ax,%ax
c0101088:	74 30                	je     c01010ba <cga_putc+0x6c>
            crt_pos --;
c010108a:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c0101091:	83 e8 01             	sub    $0x1,%eax
c0101094:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c010109a:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c010109f:	0f b7 15 44 a4 11 c0 	movzwl 0xc011a444,%edx
c01010a6:	0f b7 d2             	movzwl %dx,%edx
c01010a9:	01 d2                	add    %edx,%edx
c01010ab:	01 c2                	add    %eax,%edx
c01010ad:	8b 45 08             	mov    0x8(%ebp),%eax
c01010b0:	b0 00                	mov    $0x0,%al
c01010b2:	83 c8 20             	or     $0x20,%eax
c01010b5:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c01010b8:	eb 72                	jmp    c010112c <cga_putc+0xde>
c01010ba:	eb 70                	jmp    c010112c <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
c01010bc:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c01010c3:	83 c0 50             	add    $0x50,%eax
c01010c6:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c01010cc:	0f b7 1d 44 a4 11 c0 	movzwl 0xc011a444,%ebx
c01010d3:	0f b7 0d 44 a4 11 c0 	movzwl 0xc011a444,%ecx
c01010da:	0f b7 c1             	movzwl %cx,%eax
c01010dd:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
c01010e3:	c1 e8 10             	shr    $0x10,%eax
c01010e6:	89 c2                	mov    %eax,%edx
c01010e8:	66 c1 ea 06          	shr    $0x6,%dx
c01010ec:	89 d0                	mov    %edx,%eax
c01010ee:	c1 e0 02             	shl    $0x2,%eax
c01010f1:	01 d0                	add    %edx,%eax
c01010f3:	c1 e0 04             	shl    $0x4,%eax
c01010f6:	29 c1                	sub    %eax,%ecx
c01010f8:	89 ca                	mov    %ecx,%edx
c01010fa:	89 d8                	mov    %ebx,%eax
c01010fc:	29 d0                	sub    %edx,%eax
c01010fe:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
        break;
c0101104:	eb 26                	jmp    c010112c <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c0101106:	8b 0d 40 a4 11 c0    	mov    0xc011a440,%ecx
c010110c:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c0101113:	8d 50 01             	lea    0x1(%eax),%edx
c0101116:	66 89 15 44 a4 11 c0 	mov    %dx,0xc011a444
c010111d:	0f b7 c0             	movzwl %ax,%eax
c0101120:	01 c0                	add    %eax,%eax
c0101122:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c0101125:	8b 45 08             	mov    0x8(%ebp),%eax
c0101128:	66 89 02             	mov    %ax,(%edx)
        break;
c010112b:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c010112c:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c0101133:	66 3d cf 07          	cmp    $0x7cf,%ax
c0101137:	76 5b                	jbe    c0101194 <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c0101139:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c010113e:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c0101144:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c0101149:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c0101150:	00 
c0101151:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101155:	89 04 24             	mov    %eax,(%esp)
c0101158:	e8 cf 4b 00 00       	call   c0105d2c <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c010115d:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c0101164:	eb 15                	jmp    c010117b <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
c0101166:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c010116b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010116e:	01 d2                	add    %edx,%edx
c0101170:	01 d0                	add    %edx,%eax
c0101172:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101177:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010117b:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c0101182:	7e e2                	jle    c0101166 <cga_putc+0x118>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
c0101184:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c010118b:	83 e8 50             	sub    $0x50,%eax
c010118e:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c0101194:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c010119b:	0f b7 c0             	movzwl %ax,%eax
c010119e:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c01011a2:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
c01011a6:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01011aa:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01011ae:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c01011af:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c01011b6:	66 c1 e8 08          	shr    $0x8,%ax
c01011ba:	0f b6 c0             	movzbl %al,%eax
c01011bd:	0f b7 15 46 a4 11 c0 	movzwl 0xc011a446,%edx
c01011c4:	83 c2 01             	add    $0x1,%edx
c01011c7:	0f b7 d2             	movzwl %dx,%edx
c01011ca:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
c01011ce:	88 45 ed             	mov    %al,-0x13(%ebp)
c01011d1:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01011d5:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01011d9:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c01011da:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c01011e1:	0f b7 c0             	movzwl %ax,%eax
c01011e4:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c01011e8:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
c01011ec:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01011f0:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01011f4:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c01011f5:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c01011fc:	0f b6 c0             	movzbl %al,%eax
c01011ff:	0f b7 15 46 a4 11 c0 	movzwl 0xc011a446,%edx
c0101206:	83 c2 01             	add    $0x1,%edx
c0101209:	0f b7 d2             	movzwl %dx,%edx
c010120c:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101210:	88 45 e5             	mov    %al,-0x1b(%ebp)
c0101213:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101217:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010121b:	ee                   	out    %al,(%dx)
}
c010121c:	83 c4 34             	add    $0x34,%esp
c010121f:	5b                   	pop    %ebx
c0101220:	5d                   	pop    %ebp
c0101221:	c3                   	ret    

c0101222 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c0101222:	55                   	push   %ebp
c0101223:	89 e5                	mov    %esp,%ebp
c0101225:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101228:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010122f:	eb 09                	jmp    c010123a <serial_putc_sub+0x18>
        delay();
c0101231:	e8 4f fb ff ff       	call   c0100d85 <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101236:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010123a:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101240:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101244:	89 c2                	mov    %eax,%edx
c0101246:	ec                   	in     (%dx),%al
c0101247:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c010124a:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010124e:	0f b6 c0             	movzbl %al,%eax
c0101251:	83 e0 20             	and    $0x20,%eax
c0101254:	85 c0                	test   %eax,%eax
c0101256:	75 09                	jne    c0101261 <serial_putc_sub+0x3f>
c0101258:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c010125f:	7e d0                	jle    c0101231 <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
c0101261:	8b 45 08             	mov    0x8(%ebp),%eax
c0101264:	0f b6 c0             	movzbl %al,%eax
c0101267:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c010126d:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101270:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101274:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101278:	ee                   	out    %al,(%dx)
}
c0101279:	c9                   	leave  
c010127a:	c3                   	ret    

c010127b <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c010127b:	55                   	push   %ebp
c010127c:	89 e5                	mov    %esp,%ebp
c010127e:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101281:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101285:	74 0d                	je     c0101294 <serial_putc+0x19>
        serial_putc_sub(c);
c0101287:	8b 45 08             	mov    0x8(%ebp),%eax
c010128a:	89 04 24             	mov    %eax,(%esp)
c010128d:	e8 90 ff ff ff       	call   c0101222 <serial_putc_sub>
c0101292:	eb 24                	jmp    c01012b8 <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
c0101294:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010129b:	e8 82 ff ff ff       	call   c0101222 <serial_putc_sub>
        serial_putc_sub(' ');
c01012a0:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01012a7:	e8 76 ff ff ff       	call   c0101222 <serial_putc_sub>
        serial_putc_sub('\b');
c01012ac:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01012b3:	e8 6a ff ff ff       	call   c0101222 <serial_putc_sub>
    }
}
c01012b8:	c9                   	leave  
c01012b9:	c3                   	ret    

c01012ba <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c01012ba:	55                   	push   %ebp
c01012bb:	89 e5                	mov    %esp,%ebp
c01012bd:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c01012c0:	eb 33                	jmp    c01012f5 <cons_intr+0x3b>
        if (c != 0) {
c01012c2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01012c6:	74 2d                	je     c01012f5 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c01012c8:	a1 64 a6 11 c0       	mov    0xc011a664,%eax
c01012cd:	8d 50 01             	lea    0x1(%eax),%edx
c01012d0:	89 15 64 a6 11 c0    	mov    %edx,0xc011a664
c01012d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01012d9:	88 90 60 a4 11 c0    	mov    %dl,-0x3fee5ba0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c01012df:	a1 64 a6 11 c0       	mov    0xc011a664,%eax
c01012e4:	3d 00 02 00 00       	cmp    $0x200,%eax
c01012e9:	75 0a                	jne    c01012f5 <cons_intr+0x3b>
                cons.wpos = 0;
c01012eb:	c7 05 64 a6 11 c0 00 	movl   $0x0,0xc011a664
c01012f2:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
c01012f5:	8b 45 08             	mov    0x8(%ebp),%eax
c01012f8:	ff d0                	call   *%eax
c01012fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01012fd:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c0101301:	75 bf                	jne    c01012c2 <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
c0101303:	c9                   	leave  
c0101304:	c3                   	ret    

c0101305 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c0101305:	55                   	push   %ebp
c0101306:	89 e5                	mov    %esp,%ebp
c0101308:	83 ec 10             	sub    $0x10,%esp
c010130b:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101311:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101315:	89 c2                	mov    %eax,%edx
c0101317:	ec                   	in     (%dx),%al
c0101318:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c010131b:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c010131f:	0f b6 c0             	movzbl %al,%eax
c0101322:	83 e0 01             	and    $0x1,%eax
c0101325:	85 c0                	test   %eax,%eax
c0101327:	75 07                	jne    c0101330 <serial_proc_data+0x2b>
        return -1;
c0101329:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010132e:	eb 2a                	jmp    c010135a <serial_proc_data+0x55>
c0101330:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101336:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010133a:	89 c2                	mov    %eax,%edx
c010133c:	ec                   	in     (%dx),%al
c010133d:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c0101340:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c0101344:	0f b6 c0             	movzbl %al,%eax
c0101347:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c010134a:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c010134e:	75 07                	jne    c0101357 <serial_proc_data+0x52>
        c = '\b';
c0101350:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c0101357:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010135a:	c9                   	leave  
c010135b:	c3                   	ret    

c010135c <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c010135c:	55                   	push   %ebp
c010135d:	89 e5                	mov    %esp,%ebp
c010135f:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c0101362:	a1 48 a4 11 c0       	mov    0xc011a448,%eax
c0101367:	85 c0                	test   %eax,%eax
c0101369:	74 0c                	je     c0101377 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c010136b:	c7 04 24 05 13 10 c0 	movl   $0xc0101305,(%esp)
c0101372:	e8 43 ff ff ff       	call   c01012ba <cons_intr>
    }
}
c0101377:	c9                   	leave  
c0101378:	c3                   	ret    

c0101379 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101379:	55                   	push   %ebp
c010137a:	89 e5                	mov    %esp,%ebp
c010137c:	83 ec 38             	sub    $0x38,%esp
c010137f:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101385:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101389:	89 c2                	mov    %eax,%edx
c010138b:	ec                   	in     (%dx),%al
c010138c:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c010138f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c0101393:	0f b6 c0             	movzbl %al,%eax
c0101396:	83 e0 01             	and    $0x1,%eax
c0101399:	85 c0                	test   %eax,%eax
c010139b:	75 0a                	jne    c01013a7 <kbd_proc_data+0x2e>
        return -1;
c010139d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01013a2:	e9 59 01 00 00       	jmp    c0101500 <kbd_proc_data+0x187>
c01013a7:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013ad:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01013b1:	89 c2                	mov    %eax,%edx
c01013b3:	ec                   	in     (%dx),%al
c01013b4:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c01013b7:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c01013bb:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c01013be:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c01013c2:	75 17                	jne    c01013db <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
c01013c4:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01013c9:	83 c8 40             	or     $0x40,%eax
c01013cc:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
        return 0;
c01013d1:	b8 00 00 00 00       	mov    $0x0,%eax
c01013d6:	e9 25 01 00 00       	jmp    c0101500 <kbd_proc_data+0x187>
    } else if (data & 0x80) {
c01013db:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01013df:	84 c0                	test   %al,%al
c01013e1:	79 47                	jns    c010142a <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c01013e3:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01013e8:	83 e0 40             	and    $0x40,%eax
c01013eb:	85 c0                	test   %eax,%eax
c01013ed:	75 09                	jne    c01013f8 <kbd_proc_data+0x7f>
c01013ef:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01013f3:	83 e0 7f             	and    $0x7f,%eax
c01013f6:	eb 04                	jmp    c01013fc <kbd_proc_data+0x83>
c01013f8:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01013fc:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c01013ff:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101403:	0f b6 80 40 70 11 c0 	movzbl -0x3fee8fc0(%eax),%eax
c010140a:	83 c8 40             	or     $0x40,%eax
c010140d:	0f b6 c0             	movzbl %al,%eax
c0101410:	f7 d0                	not    %eax
c0101412:	89 c2                	mov    %eax,%edx
c0101414:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101419:	21 d0                	and    %edx,%eax
c010141b:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
        return 0;
c0101420:	b8 00 00 00 00       	mov    $0x0,%eax
c0101425:	e9 d6 00 00 00       	jmp    c0101500 <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
c010142a:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c010142f:	83 e0 40             	and    $0x40,%eax
c0101432:	85 c0                	test   %eax,%eax
c0101434:	74 11                	je     c0101447 <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c0101436:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c010143a:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c010143f:	83 e0 bf             	and    $0xffffffbf,%eax
c0101442:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
    }

    shift |= shiftcode[data];
c0101447:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010144b:	0f b6 80 40 70 11 c0 	movzbl -0x3fee8fc0(%eax),%eax
c0101452:	0f b6 d0             	movzbl %al,%edx
c0101455:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c010145a:	09 d0                	or     %edx,%eax
c010145c:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
    shift ^= togglecode[data];
c0101461:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101465:	0f b6 80 40 71 11 c0 	movzbl -0x3fee8ec0(%eax),%eax
c010146c:	0f b6 d0             	movzbl %al,%edx
c010146f:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101474:	31 d0                	xor    %edx,%eax
c0101476:	a3 68 a6 11 c0       	mov    %eax,0xc011a668

    c = charcode[shift & (CTL | SHIFT)][data];
c010147b:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101480:	83 e0 03             	and    $0x3,%eax
c0101483:	8b 14 85 40 75 11 c0 	mov    -0x3fee8ac0(,%eax,4),%edx
c010148a:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010148e:	01 d0                	add    %edx,%eax
c0101490:	0f b6 00             	movzbl (%eax),%eax
c0101493:	0f b6 c0             	movzbl %al,%eax
c0101496:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101499:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c010149e:	83 e0 08             	and    $0x8,%eax
c01014a1:	85 c0                	test   %eax,%eax
c01014a3:	74 22                	je     c01014c7 <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
c01014a5:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c01014a9:	7e 0c                	jle    c01014b7 <kbd_proc_data+0x13e>
c01014ab:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c01014af:	7f 06                	jg     c01014b7 <kbd_proc_data+0x13e>
            c += 'A' - 'a';
c01014b1:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c01014b5:	eb 10                	jmp    c01014c7 <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
c01014b7:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c01014bb:	7e 0a                	jle    c01014c7 <kbd_proc_data+0x14e>
c01014bd:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c01014c1:	7f 04                	jg     c01014c7 <kbd_proc_data+0x14e>
            c += 'a' - 'A';
c01014c3:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c01014c7:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014cc:	f7 d0                	not    %eax
c01014ce:	83 e0 06             	and    $0x6,%eax
c01014d1:	85 c0                	test   %eax,%eax
c01014d3:	75 28                	jne    c01014fd <kbd_proc_data+0x184>
c01014d5:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c01014dc:	75 1f                	jne    c01014fd <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
c01014de:	c7 04 24 87 61 10 c0 	movl   $0xc0106187,(%esp)
c01014e5:	e8 5e ee ff ff       	call   c0100348 <cprintf>
c01014ea:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c01014f0:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01014f4:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c01014f8:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c01014fc:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c01014fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101500:	c9                   	leave  
c0101501:	c3                   	ret    

c0101502 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c0101502:	55                   	push   %ebp
c0101503:	89 e5                	mov    %esp,%ebp
c0101505:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c0101508:	c7 04 24 79 13 10 c0 	movl   $0xc0101379,(%esp)
c010150f:	e8 a6 fd ff ff       	call   c01012ba <cons_intr>
}
c0101514:	c9                   	leave  
c0101515:	c3                   	ret    

c0101516 <kbd_init>:

static void
kbd_init(void) {
c0101516:	55                   	push   %ebp
c0101517:	89 e5                	mov    %esp,%ebp
c0101519:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c010151c:	e8 e1 ff ff ff       	call   c0101502 <kbd_intr>
    pic_enable(IRQ_KBD);
c0101521:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0101528:	e8 3d 01 00 00       	call   c010166a <pic_enable>
}
c010152d:	c9                   	leave  
c010152e:	c3                   	ret    

c010152f <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c010152f:	55                   	push   %ebp
c0101530:	89 e5                	mov    %esp,%ebp
c0101532:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c0101535:	e8 93 f8 ff ff       	call   c0100dcd <cga_init>
    serial_init();
c010153a:	e8 74 f9 ff ff       	call   c0100eb3 <serial_init>
    kbd_init();
c010153f:	e8 d2 ff ff ff       	call   c0101516 <kbd_init>
    if (!serial_exists) {
c0101544:	a1 48 a4 11 c0       	mov    0xc011a448,%eax
c0101549:	85 c0                	test   %eax,%eax
c010154b:	75 0c                	jne    c0101559 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c010154d:	c7 04 24 93 61 10 c0 	movl   $0xc0106193,(%esp)
c0101554:	e8 ef ed ff ff       	call   c0100348 <cprintf>
    }
}
c0101559:	c9                   	leave  
c010155a:	c3                   	ret    

c010155b <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c010155b:	55                   	push   %ebp
c010155c:	89 e5                	mov    %esp,%ebp
c010155e:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0101561:	e8 e2 f7 ff ff       	call   c0100d48 <__intr_save>
c0101566:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0101569:	8b 45 08             	mov    0x8(%ebp),%eax
c010156c:	89 04 24             	mov    %eax,(%esp)
c010156f:	e8 9b fa ff ff       	call   c010100f <lpt_putc>
        cga_putc(c);
c0101574:	8b 45 08             	mov    0x8(%ebp),%eax
c0101577:	89 04 24             	mov    %eax,(%esp)
c010157a:	e8 cf fa ff ff       	call   c010104e <cga_putc>
        serial_putc(c);
c010157f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101582:	89 04 24             	mov    %eax,(%esp)
c0101585:	e8 f1 fc ff ff       	call   c010127b <serial_putc>
    }
    local_intr_restore(intr_flag);
c010158a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010158d:	89 04 24             	mov    %eax,(%esp)
c0101590:	e8 dd f7 ff ff       	call   c0100d72 <__intr_restore>
}
c0101595:	c9                   	leave  
c0101596:	c3                   	ret    

c0101597 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c0101597:	55                   	push   %ebp
c0101598:	89 e5                	mov    %esp,%ebp
c010159a:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c010159d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c01015a4:	e8 9f f7 ff ff       	call   c0100d48 <__intr_save>
c01015a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c01015ac:	e8 ab fd ff ff       	call   c010135c <serial_intr>
        kbd_intr();
c01015b1:	e8 4c ff ff ff       	call   c0101502 <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c01015b6:	8b 15 60 a6 11 c0    	mov    0xc011a660,%edx
c01015bc:	a1 64 a6 11 c0       	mov    0xc011a664,%eax
c01015c1:	39 c2                	cmp    %eax,%edx
c01015c3:	74 31                	je     c01015f6 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c01015c5:	a1 60 a6 11 c0       	mov    0xc011a660,%eax
c01015ca:	8d 50 01             	lea    0x1(%eax),%edx
c01015cd:	89 15 60 a6 11 c0    	mov    %edx,0xc011a660
c01015d3:	0f b6 80 60 a4 11 c0 	movzbl -0x3fee5ba0(%eax),%eax
c01015da:	0f b6 c0             	movzbl %al,%eax
c01015dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c01015e0:	a1 60 a6 11 c0       	mov    0xc011a660,%eax
c01015e5:	3d 00 02 00 00       	cmp    $0x200,%eax
c01015ea:	75 0a                	jne    c01015f6 <cons_getc+0x5f>
                cons.rpos = 0;
c01015ec:	c7 05 60 a6 11 c0 00 	movl   $0x0,0xc011a660
c01015f3:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c01015f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01015f9:	89 04 24             	mov    %eax,(%esp)
c01015fc:	e8 71 f7 ff ff       	call   c0100d72 <__intr_restore>
    return c;
c0101601:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101604:	c9                   	leave  
c0101605:	c3                   	ret    

c0101606 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c0101606:	55                   	push   %ebp
c0101607:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
c0101609:	fb                   	sti    
    sti();
}
c010160a:	5d                   	pop    %ebp
c010160b:	c3                   	ret    

c010160c <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c010160c:	55                   	push   %ebp
c010160d:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
c010160f:	fa                   	cli    
    cli();
}
c0101610:	5d                   	pop    %ebp
c0101611:	c3                   	ret    

c0101612 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c0101612:	55                   	push   %ebp
c0101613:	89 e5                	mov    %esp,%ebp
c0101615:	83 ec 14             	sub    $0x14,%esp
c0101618:	8b 45 08             	mov    0x8(%ebp),%eax
c010161b:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c010161f:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101623:	66 a3 50 75 11 c0    	mov    %ax,0xc0117550
    if (did_init) {
c0101629:	a1 6c a6 11 c0       	mov    0xc011a66c,%eax
c010162e:	85 c0                	test   %eax,%eax
c0101630:	74 36                	je     c0101668 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
c0101632:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101636:	0f b6 c0             	movzbl %al,%eax
c0101639:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c010163f:	88 45 fd             	mov    %al,-0x3(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101642:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0101646:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c010164a:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c010164b:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c010164f:	66 c1 e8 08          	shr    $0x8,%ax
c0101653:	0f b6 c0             	movzbl %al,%eax
c0101656:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c010165c:	88 45 f9             	mov    %al,-0x7(%ebp)
c010165f:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101663:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101667:	ee                   	out    %al,(%dx)
    }
}
c0101668:	c9                   	leave  
c0101669:	c3                   	ret    

c010166a <pic_enable>:

void
pic_enable(unsigned int irq) {
c010166a:	55                   	push   %ebp
c010166b:	89 e5                	mov    %esp,%ebp
c010166d:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c0101670:	8b 45 08             	mov    0x8(%ebp),%eax
c0101673:	ba 01 00 00 00       	mov    $0x1,%edx
c0101678:	89 c1                	mov    %eax,%ecx
c010167a:	d3 e2                	shl    %cl,%edx
c010167c:	89 d0                	mov    %edx,%eax
c010167e:	f7 d0                	not    %eax
c0101680:	89 c2                	mov    %eax,%edx
c0101682:	0f b7 05 50 75 11 c0 	movzwl 0xc0117550,%eax
c0101689:	21 d0                	and    %edx,%eax
c010168b:	0f b7 c0             	movzwl %ax,%eax
c010168e:	89 04 24             	mov    %eax,(%esp)
c0101691:	e8 7c ff ff ff       	call   c0101612 <pic_setmask>
}
c0101696:	c9                   	leave  
c0101697:	c3                   	ret    

c0101698 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c0101698:	55                   	push   %ebp
c0101699:	89 e5                	mov    %esp,%ebp
c010169b:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c010169e:	c7 05 6c a6 11 c0 01 	movl   $0x1,0xc011a66c
c01016a5:	00 00 00 
c01016a8:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c01016ae:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
c01016b2:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c01016b6:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c01016ba:	ee                   	out    %al,(%dx)
c01016bb:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c01016c1:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
c01016c5:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01016c9:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c01016cd:	ee                   	out    %al,(%dx)
c01016ce:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c01016d4:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
c01016d8:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01016dc:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01016e0:	ee                   	out    %al,(%dx)
c01016e1:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
c01016e7:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
c01016eb:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01016ef:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01016f3:	ee                   	out    %al,(%dx)
c01016f4:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
c01016fa:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
c01016fe:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101702:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101706:	ee                   	out    %al,(%dx)
c0101707:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
c010170d:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
c0101711:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101715:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101719:	ee                   	out    %al,(%dx)
c010171a:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
c0101720:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
c0101724:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101728:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010172c:	ee                   	out    %al,(%dx)
c010172d:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
c0101733:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
c0101737:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c010173b:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c010173f:	ee                   	out    %al,(%dx)
c0101740:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
c0101746:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
c010174a:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c010174e:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101752:	ee                   	out    %al,(%dx)
c0101753:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
c0101759:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
c010175d:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101761:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101765:	ee                   	out    %al,(%dx)
c0101766:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
c010176c:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
c0101770:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101774:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101778:	ee                   	out    %al,(%dx)
c0101779:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c010177f:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
c0101783:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0101787:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c010178b:	ee                   	out    %al,(%dx)
c010178c:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
c0101792:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
c0101796:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c010179a:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c010179e:	ee                   	out    %al,(%dx)
c010179f:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
c01017a5:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
c01017a9:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c01017ad:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c01017b1:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c01017b2:	0f b7 05 50 75 11 c0 	movzwl 0xc0117550,%eax
c01017b9:	66 83 f8 ff          	cmp    $0xffff,%ax
c01017bd:	74 12                	je     c01017d1 <pic_init+0x139>
        pic_setmask(irq_mask);
c01017bf:	0f b7 05 50 75 11 c0 	movzwl 0xc0117550,%eax
c01017c6:	0f b7 c0             	movzwl %ax,%eax
c01017c9:	89 04 24             	mov    %eax,(%esp)
c01017cc:	e8 41 fe ff ff       	call   c0101612 <pic_setmask>
    }
}
c01017d1:	c9                   	leave  
c01017d2:	c3                   	ret    

c01017d3 <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c01017d3:	55                   	push   %ebp
c01017d4:	89 e5                	mov    %esp,%ebp
c01017d6:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c01017d9:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c01017e0:	00 
c01017e1:	c7 04 24 c0 61 10 c0 	movl   $0xc01061c0,(%esp)
c01017e8:	e8 5b eb ff ff       	call   c0100348 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
c01017ed:	c9                   	leave  
c01017ee:	c3                   	ret    

c01017ef <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c01017ef:	55                   	push   %ebp
c01017f0:	89 e5                	mov    %esp,%ebp
      *     Can you see idt[256] in this file? Yes, it's IDT! you can use SETGATE macro to setup each item of IDT
      * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
}
c01017f2:	5d                   	pop    %ebp
c01017f3:	c3                   	ret    

c01017f4 <trapname>:

static const char *
trapname(int trapno) {
c01017f4:	55                   	push   %ebp
c01017f5:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c01017f7:	8b 45 08             	mov    0x8(%ebp),%eax
c01017fa:	83 f8 13             	cmp    $0x13,%eax
c01017fd:	77 0c                	ja     c010180b <trapname+0x17>
        return excnames[trapno];
c01017ff:	8b 45 08             	mov    0x8(%ebp),%eax
c0101802:	8b 04 85 20 65 10 c0 	mov    -0x3fef9ae0(,%eax,4),%eax
c0101809:	eb 18                	jmp    c0101823 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c010180b:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c010180f:	7e 0d                	jle    c010181e <trapname+0x2a>
c0101811:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c0101815:	7f 07                	jg     c010181e <trapname+0x2a>
        return "Hardware Interrupt";
c0101817:	b8 ca 61 10 c0       	mov    $0xc01061ca,%eax
c010181c:	eb 05                	jmp    c0101823 <trapname+0x2f>
    }
    return "(unknown trap)";
c010181e:	b8 dd 61 10 c0       	mov    $0xc01061dd,%eax
}
c0101823:	5d                   	pop    %ebp
c0101824:	c3                   	ret    

c0101825 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c0101825:	55                   	push   %ebp
c0101826:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c0101828:	8b 45 08             	mov    0x8(%ebp),%eax
c010182b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c010182f:	66 83 f8 08          	cmp    $0x8,%ax
c0101833:	0f 94 c0             	sete   %al
c0101836:	0f b6 c0             	movzbl %al,%eax
}
c0101839:	5d                   	pop    %ebp
c010183a:	c3                   	ret    

c010183b <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c010183b:	55                   	push   %ebp
c010183c:	89 e5                	mov    %esp,%ebp
c010183e:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c0101841:	8b 45 08             	mov    0x8(%ebp),%eax
c0101844:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101848:	c7 04 24 1e 62 10 c0 	movl   $0xc010621e,(%esp)
c010184f:	e8 f4 ea ff ff       	call   c0100348 <cprintf>
    print_regs(&tf->tf_regs);
c0101854:	8b 45 08             	mov    0x8(%ebp),%eax
c0101857:	89 04 24             	mov    %eax,(%esp)
c010185a:	e8 a1 01 00 00       	call   c0101a00 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c010185f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101862:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0101866:	0f b7 c0             	movzwl %ax,%eax
c0101869:	89 44 24 04          	mov    %eax,0x4(%esp)
c010186d:	c7 04 24 2f 62 10 c0 	movl   $0xc010622f,(%esp)
c0101874:	e8 cf ea ff ff       	call   c0100348 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0101879:	8b 45 08             	mov    0x8(%ebp),%eax
c010187c:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0101880:	0f b7 c0             	movzwl %ax,%eax
c0101883:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101887:	c7 04 24 42 62 10 c0 	movl   $0xc0106242,(%esp)
c010188e:	e8 b5 ea ff ff       	call   c0100348 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0101893:	8b 45 08             	mov    0x8(%ebp),%eax
c0101896:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c010189a:	0f b7 c0             	movzwl %ax,%eax
c010189d:	89 44 24 04          	mov    %eax,0x4(%esp)
c01018a1:	c7 04 24 55 62 10 c0 	movl   $0xc0106255,(%esp)
c01018a8:	e8 9b ea ff ff       	call   c0100348 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c01018ad:	8b 45 08             	mov    0x8(%ebp),%eax
c01018b0:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c01018b4:	0f b7 c0             	movzwl %ax,%eax
c01018b7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01018bb:	c7 04 24 68 62 10 c0 	movl   $0xc0106268,(%esp)
c01018c2:	e8 81 ea ff ff       	call   c0100348 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c01018c7:	8b 45 08             	mov    0x8(%ebp),%eax
c01018ca:	8b 40 30             	mov    0x30(%eax),%eax
c01018cd:	89 04 24             	mov    %eax,(%esp)
c01018d0:	e8 1f ff ff ff       	call   c01017f4 <trapname>
c01018d5:	8b 55 08             	mov    0x8(%ebp),%edx
c01018d8:	8b 52 30             	mov    0x30(%edx),%edx
c01018db:	89 44 24 08          	mov    %eax,0x8(%esp)
c01018df:	89 54 24 04          	mov    %edx,0x4(%esp)
c01018e3:	c7 04 24 7b 62 10 c0 	movl   $0xc010627b,(%esp)
c01018ea:	e8 59 ea ff ff       	call   c0100348 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c01018ef:	8b 45 08             	mov    0x8(%ebp),%eax
c01018f2:	8b 40 34             	mov    0x34(%eax),%eax
c01018f5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01018f9:	c7 04 24 8d 62 10 c0 	movl   $0xc010628d,(%esp)
c0101900:	e8 43 ea ff ff       	call   c0100348 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0101905:	8b 45 08             	mov    0x8(%ebp),%eax
c0101908:	8b 40 38             	mov    0x38(%eax),%eax
c010190b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010190f:	c7 04 24 9c 62 10 c0 	movl   $0xc010629c,(%esp)
c0101916:	e8 2d ea ff ff       	call   c0100348 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c010191b:	8b 45 08             	mov    0x8(%ebp),%eax
c010191e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101922:	0f b7 c0             	movzwl %ax,%eax
c0101925:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101929:	c7 04 24 ab 62 10 c0 	movl   $0xc01062ab,(%esp)
c0101930:	e8 13 ea ff ff       	call   c0100348 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0101935:	8b 45 08             	mov    0x8(%ebp),%eax
c0101938:	8b 40 40             	mov    0x40(%eax),%eax
c010193b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010193f:	c7 04 24 be 62 10 c0 	movl   $0xc01062be,(%esp)
c0101946:	e8 fd e9 ff ff       	call   c0100348 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c010194b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101952:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0101959:	eb 3e                	jmp    c0101999 <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c010195b:	8b 45 08             	mov    0x8(%ebp),%eax
c010195e:	8b 50 40             	mov    0x40(%eax),%edx
c0101961:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101964:	21 d0                	and    %edx,%eax
c0101966:	85 c0                	test   %eax,%eax
c0101968:	74 28                	je     c0101992 <print_trapframe+0x157>
c010196a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010196d:	8b 04 85 80 75 11 c0 	mov    -0x3fee8a80(,%eax,4),%eax
c0101974:	85 c0                	test   %eax,%eax
c0101976:	74 1a                	je     c0101992 <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
c0101978:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010197b:	8b 04 85 80 75 11 c0 	mov    -0x3fee8a80(,%eax,4),%eax
c0101982:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101986:	c7 04 24 cd 62 10 c0 	movl   $0xc01062cd,(%esp)
c010198d:	e8 b6 e9 ff ff       	call   c0100348 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101992:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101996:	d1 65 f0             	shll   -0x10(%ebp)
c0101999:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010199c:	83 f8 17             	cmp    $0x17,%eax
c010199f:	76 ba                	jbe    c010195b <print_trapframe+0x120>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c01019a1:	8b 45 08             	mov    0x8(%ebp),%eax
c01019a4:	8b 40 40             	mov    0x40(%eax),%eax
c01019a7:	25 00 30 00 00       	and    $0x3000,%eax
c01019ac:	c1 e8 0c             	shr    $0xc,%eax
c01019af:	89 44 24 04          	mov    %eax,0x4(%esp)
c01019b3:	c7 04 24 d1 62 10 c0 	movl   $0xc01062d1,(%esp)
c01019ba:	e8 89 e9 ff ff       	call   c0100348 <cprintf>

    if (!trap_in_kernel(tf)) {
c01019bf:	8b 45 08             	mov    0x8(%ebp),%eax
c01019c2:	89 04 24             	mov    %eax,(%esp)
c01019c5:	e8 5b fe ff ff       	call   c0101825 <trap_in_kernel>
c01019ca:	85 c0                	test   %eax,%eax
c01019cc:	75 30                	jne    c01019fe <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c01019ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01019d1:	8b 40 44             	mov    0x44(%eax),%eax
c01019d4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01019d8:	c7 04 24 da 62 10 c0 	movl   $0xc01062da,(%esp)
c01019df:	e8 64 e9 ff ff       	call   c0100348 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c01019e4:	8b 45 08             	mov    0x8(%ebp),%eax
c01019e7:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c01019eb:	0f b7 c0             	movzwl %ax,%eax
c01019ee:	89 44 24 04          	mov    %eax,0x4(%esp)
c01019f2:	c7 04 24 e9 62 10 c0 	movl   $0xc01062e9,(%esp)
c01019f9:	e8 4a e9 ff ff       	call   c0100348 <cprintf>
    }
}
c01019fe:	c9                   	leave  
c01019ff:	c3                   	ret    

c0101a00 <print_regs>:

void
print_regs(struct pushregs *regs) {
c0101a00:	55                   	push   %ebp
c0101a01:	89 e5                	mov    %esp,%ebp
c0101a03:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0101a06:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a09:	8b 00                	mov    (%eax),%eax
c0101a0b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a0f:	c7 04 24 fc 62 10 c0 	movl   $0xc01062fc,(%esp)
c0101a16:	e8 2d e9 ff ff       	call   c0100348 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0101a1b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a1e:	8b 40 04             	mov    0x4(%eax),%eax
c0101a21:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a25:	c7 04 24 0b 63 10 c0 	movl   $0xc010630b,(%esp)
c0101a2c:	e8 17 e9 ff ff       	call   c0100348 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0101a31:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a34:	8b 40 08             	mov    0x8(%eax),%eax
c0101a37:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a3b:	c7 04 24 1a 63 10 c0 	movl   $0xc010631a,(%esp)
c0101a42:	e8 01 e9 ff ff       	call   c0100348 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0101a47:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a4a:	8b 40 0c             	mov    0xc(%eax),%eax
c0101a4d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a51:	c7 04 24 29 63 10 c0 	movl   $0xc0106329,(%esp)
c0101a58:	e8 eb e8 ff ff       	call   c0100348 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0101a5d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a60:	8b 40 10             	mov    0x10(%eax),%eax
c0101a63:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a67:	c7 04 24 38 63 10 c0 	movl   $0xc0106338,(%esp)
c0101a6e:	e8 d5 e8 ff ff       	call   c0100348 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0101a73:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a76:	8b 40 14             	mov    0x14(%eax),%eax
c0101a79:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a7d:	c7 04 24 47 63 10 c0 	movl   $0xc0106347,(%esp)
c0101a84:	e8 bf e8 ff ff       	call   c0100348 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0101a89:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a8c:	8b 40 18             	mov    0x18(%eax),%eax
c0101a8f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a93:	c7 04 24 56 63 10 c0 	movl   $0xc0106356,(%esp)
c0101a9a:	e8 a9 e8 ff ff       	call   c0100348 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0101a9f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101aa2:	8b 40 1c             	mov    0x1c(%eax),%eax
c0101aa5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101aa9:	c7 04 24 65 63 10 c0 	movl   $0xc0106365,(%esp)
c0101ab0:	e8 93 e8 ff ff       	call   c0100348 <cprintf>
}
c0101ab5:	c9                   	leave  
c0101ab6:	c3                   	ret    

c0101ab7 <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
c0101ab7:	55                   	push   %ebp
c0101ab8:	89 e5                	mov    %esp,%ebp
c0101aba:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
c0101abd:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ac0:	8b 40 30             	mov    0x30(%eax),%eax
c0101ac3:	83 f8 2f             	cmp    $0x2f,%eax
c0101ac6:	77 1e                	ja     c0101ae6 <trap_dispatch+0x2f>
c0101ac8:	83 f8 2e             	cmp    $0x2e,%eax
c0101acb:	0f 83 bf 00 00 00    	jae    c0101b90 <trap_dispatch+0xd9>
c0101ad1:	83 f8 21             	cmp    $0x21,%eax
c0101ad4:	74 40                	je     c0101b16 <trap_dispatch+0x5f>
c0101ad6:	83 f8 24             	cmp    $0x24,%eax
c0101ad9:	74 15                	je     c0101af0 <trap_dispatch+0x39>
c0101adb:	83 f8 20             	cmp    $0x20,%eax
c0101ade:	0f 84 af 00 00 00    	je     c0101b93 <trap_dispatch+0xdc>
c0101ae4:	eb 72                	jmp    c0101b58 <trap_dispatch+0xa1>
c0101ae6:	83 e8 78             	sub    $0x78,%eax
c0101ae9:	83 f8 01             	cmp    $0x1,%eax
c0101aec:	77 6a                	ja     c0101b58 <trap_dispatch+0xa1>
c0101aee:	eb 4c                	jmp    c0101b3c <trap_dispatch+0x85>
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        break;
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0101af0:	e8 a2 fa ff ff       	call   c0101597 <cons_getc>
c0101af5:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0101af8:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101afc:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101b00:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101b04:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b08:	c7 04 24 74 63 10 c0 	movl   $0xc0106374,(%esp)
c0101b0f:	e8 34 e8 ff ff       	call   c0100348 <cprintf>
        break;
c0101b14:	eb 7e                	jmp    c0101b94 <trap_dispatch+0xdd>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0101b16:	e8 7c fa ff ff       	call   c0101597 <cons_getc>
c0101b1b:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0101b1e:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101b22:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101b26:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101b2a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b2e:	c7 04 24 86 63 10 c0 	movl   $0xc0106386,(%esp)
c0101b35:	e8 0e e8 ff ff       	call   c0100348 <cprintf>
        break;
c0101b3a:	eb 58                	jmp    c0101b94 <trap_dispatch+0xdd>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c0101b3c:	c7 44 24 08 95 63 10 	movl   $0xc0106395,0x8(%esp)
c0101b43:	c0 
c0101b44:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
c0101b4b:	00 
c0101b4c:	c7 04 24 a5 63 10 c0 	movl   $0xc01063a5,(%esp)
c0101b53:	e8 c0 f0 ff ff       	call   c0100c18 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0101b58:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b5b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101b5f:	0f b7 c0             	movzwl %ax,%eax
c0101b62:	83 e0 03             	and    $0x3,%eax
c0101b65:	85 c0                	test   %eax,%eax
c0101b67:	75 2b                	jne    c0101b94 <trap_dispatch+0xdd>
            print_trapframe(tf);
c0101b69:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b6c:	89 04 24             	mov    %eax,(%esp)
c0101b6f:	e8 c7 fc ff ff       	call   c010183b <print_trapframe>
            panic("unexpected trap in kernel.\n");
c0101b74:	c7 44 24 08 b6 63 10 	movl   $0xc01063b6,0x8(%esp)
c0101b7b:	c0 
c0101b7c:	c7 44 24 04 ac 00 00 	movl   $0xac,0x4(%esp)
c0101b83:	00 
c0101b84:	c7 04 24 a5 63 10 c0 	movl   $0xc01063a5,(%esp)
c0101b8b:	e8 88 f0 ff ff       	call   c0100c18 <__panic>
        panic("T_SWITCH_** ??\n");
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
c0101b90:	90                   	nop
c0101b91:	eb 01                	jmp    c0101b94 <trap_dispatch+0xdd>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        break;
c0101b93:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
c0101b94:	c9                   	leave  
c0101b95:	c3                   	ret    

c0101b96 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0101b96:	55                   	push   %ebp
c0101b97:	89 e5                	mov    %esp,%ebp
c0101b99:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c0101b9c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b9f:	89 04 24             	mov    %eax,(%esp)
c0101ba2:	e8 10 ff ff ff       	call   c0101ab7 <trap_dispatch>
}
c0101ba7:	c9                   	leave  
c0101ba8:	c3                   	ret    

c0101ba9 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0101ba9:	1e                   	push   %ds
    pushl %es
c0101baa:	06                   	push   %es
    pushl %fs
c0101bab:	0f a0                	push   %fs
    pushl %gs
c0101bad:	0f a8                	push   %gs
    pushal
c0101baf:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0101bb0:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0101bb5:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0101bb7:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0101bb9:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0101bba:	e8 d7 ff ff ff       	call   c0101b96 <trap>

    # pop the pushed stack pointer
    popl %esp
c0101bbf:	5c                   	pop    %esp

c0101bc0 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0101bc0:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0101bc1:	0f a9                	pop    %gs
    popl %fs
c0101bc3:	0f a1                	pop    %fs
    popl %es
c0101bc5:	07                   	pop    %es
    popl %ds
c0101bc6:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0101bc7:	83 c4 08             	add    $0x8,%esp
    iret
c0101bca:	cf                   	iret   

c0101bcb <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0101bcb:	6a 00                	push   $0x0
  pushl $0
c0101bcd:	6a 00                	push   $0x0
  jmp __alltraps
c0101bcf:	e9 d5 ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101bd4 <vector1>:
.globl vector1
vector1:
  pushl $0
c0101bd4:	6a 00                	push   $0x0
  pushl $1
c0101bd6:	6a 01                	push   $0x1
  jmp __alltraps
c0101bd8:	e9 cc ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101bdd <vector2>:
.globl vector2
vector2:
  pushl $0
c0101bdd:	6a 00                	push   $0x0
  pushl $2
c0101bdf:	6a 02                	push   $0x2
  jmp __alltraps
c0101be1:	e9 c3 ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101be6 <vector3>:
.globl vector3
vector3:
  pushl $0
c0101be6:	6a 00                	push   $0x0
  pushl $3
c0101be8:	6a 03                	push   $0x3
  jmp __alltraps
c0101bea:	e9 ba ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101bef <vector4>:
.globl vector4
vector4:
  pushl $0
c0101bef:	6a 00                	push   $0x0
  pushl $4
c0101bf1:	6a 04                	push   $0x4
  jmp __alltraps
c0101bf3:	e9 b1 ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101bf8 <vector5>:
.globl vector5
vector5:
  pushl $0
c0101bf8:	6a 00                	push   $0x0
  pushl $5
c0101bfa:	6a 05                	push   $0x5
  jmp __alltraps
c0101bfc:	e9 a8 ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101c01 <vector6>:
.globl vector6
vector6:
  pushl $0
c0101c01:	6a 00                	push   $0x0
  pushl $6
c0101c03:	6a 06                	push   $0x6
  jmp __alltraps
c0101c05:	e9 9f ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101c0a <vector7>:
.globl vector7
vector7:
  pushl $0
c0101c0a:	6a 00                	push   $0x0
  pushl $7
c0101c0c:	6a 07                	push   $0x7
  jmp __alltraps
c0101c0e:	e9 96 ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101c13 <vector8>:
.globl vector8
vector8:
  pushl $8
c0101c13:	6a 08                	push   $0x8
  jmp __alltraps
c0101c15:	e9 8f ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101c1a <vector9>:
.globl vector9
vector9:
  pushl $0
c0101c1a:	6a 00                	push   $0x0
  pushl $9
c0101c1c:	6a 09                	push   $0x9
  jmp __alltraps
c0101c1e:	e9 86 ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101c23 <vector10>:
.globl vector10
vector10:
  pushl $10
c0101c23:	6a 0a                	push   $0xa
  jmp __alltraps
c0101c25:	e9 7f ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101c2a <vector11>:
.globl vector11
vector11:
  pushl $11
c0101c2a:	6a 0b                	push   $0xb
  jmp __alltraps
c0101c2c:	e9 78 ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101c31 <vector12>:
.globl vector12
vector12:
  pushl $12
c0101c31:	6a 0c                	push   $0xc
  jmp __alltraps
c0101c33:	e9 71 ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101c38 <vector13>:
.globl vector13
vector13:
  pushl $13
c0101c38:	6a 0d                	push   $0xd
  jmp __alltraps
c0101c3a:	e9 6a ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101c3f <vector14>:
.globl vector14
vector14:
  pushl $14
c0101c3f:	6a 0e                	push   $0xe
  jmp __alltraps
c0101c41:	e9 63 ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101c46 <vector15>:
.globl vector15
vector15:
  pushl $0
c0101c46:	6a 00                	push   $0x0
  pushl $15
c0101c48:	6a 0f                	push   $0xf
  jmp __alltraps
c0101c4a:	e9 5a ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101c4f <vector16>:
.globl vector16
vector16:
  pushl $0
c0101c4f:	6a 00                	push   $0x0
  pushl $16
c0101c51:	6a 10                	push   $0x10
  jmp __alltraps
c0101c53:	e9 51 ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101c58 <vector17>:
.globl vector17
vector17:
  pushl $17
c0101c58:	6a 11                	push   $0x11
  jmp __alltraps
c0101c5a:	e9 4a ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101c5f <vector18>:
.globl vector18
vector18:
  pushl $0
c0101c5f:	6a 00                	push   $0x0
  pushl $18
c0101c61:	6a 12                	push   $0x12
  jmp __alltraps
c0101c63:	e9 41 ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101c68 <vector19>:
.globl vector19
vector19:
  pushl $0
c0101c68:	6a 00                	push   $0x0
  pushl $19
c0101c6a:	6a 13                	push   $0x13
  jmp __alltraps
c0101c6c:	e9 38 ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101c71 <vector20>:
.globl vector20
vector20:
  pushl $0
c0101c71:	6a 00                	push   $0x0
  pushl $20
c0101c73:	6a 14                	push   $0x14
  jmp __alltraps
c0101c75:	e9 2f ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101c7a <vector21>:
.globl vector21
vector21:
  pushl $0
c0101c7a:	6a 00                	push   $0x0
  pushl $21
c0101c7c:	6a 15                	push   $0x15
  jmp __alltraps
c0101c7e:	e9 26 ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101c83 <vector22>:
.globl vector22
vector22:
  pushl $0
c0101c83:	6a 00                	push   $0x0
  pushl $22
c0101c85:	6a 16                	push   $0x16
  jmp __alltraps
c0101c87:	e9 1d ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101c8c <vector23>:
.globl vector23
vector23:
  pushl $0
c0101c8c:	6a 00                	push   $0x0
  pushl $23
c0101c8e:	6a 17                	push   $0x17
  jmp __alltraps
c0101c90:	e9 14 ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101c95 <vector24>:
.globl vector24
vector24:
  pushl $0
c0101c95:	6a 00                	push   $0x0
  pushl $24
c0101c97:	6a 18                	push   $0x18
  jmp __alltraps
c0101c99:	e9 0b ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101c9e <vector25>:
.globl vector25
vector25:
  pushl $0
c0101c9e:	6a 00                	push   $0x0
  pushl $25
c0101ca0:	6a 19                	push   $0x19
  jmp __alltraps
c0101ca2:	e9 02 ff ff ff       	jmp    c0101ba9 <__alltraps>

c0101ca7 <vector26>:
.globl vector26
vector26:
  pushl $0
c0101ca7:	6a 00                	push   $0x0
  pushl $26
c0101ca9:	6a 1a                	push   $0x1a
  jmp __alltraps
c0101cab:	e9 f9 fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101cb0 <vector27>:
.globl vector27
vector27:
  pushl $0
c0101cb0:	6a 00                	push   $0x0
  pushl $27
c0101cb2:	6a 1b                	push   $0x1b
  jmp __alltraps
c0101cb4:	e9 f0 fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101cb9 <vector28>:
.globl vector28
vector28:
  pushl $0
c0101cb9:	6a 00                	push   $0x0
  pushl $28
c0101cbb:	6a 1c                	push   $0x1c
  jmp __alltraps
c0101cbd:	e9 e7 fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101cc2 <vector29>:
.globl vector29
vector29:
  pushl $0
c0101cc2:	6a 00                	push   $0x0
  pushl $29
c0101cc4:	6a 1d                	push   $0x1d
  jmp __alltraps
c0101cc6:	e9 de fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101ccb <vector30>:
.globl vector30
vector30:
  pushl $0
c0101ccb:	6a 00                	push   $0x0
  pushl $30
c0101ccd:	6a 1e                	push   $0x1e
  jmp __alltraps
c0101ccf:	e9 d5 fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101cd4 <vector31>:
.globl vector31
vector31:
  pushl $0
c0101cd4:	6a 00                	push   $0x0
  pushl $31
c0101cd6:	6a 1f                	push   $0x1f
  jmp __alltraps
c0101cd8:	e9 cc fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101cdd <vector32>:
.globl vector32
vector32:
  pushl $0
c0101cdd:	6a 00                	push   $0x0
  pushl $32
c0101cdf:	6a 20                	push   $0x20
  jmp __alltraps
c0101ce1:	e9 c3 fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101ce6 <vector33>:
.globl vector33
vector33:
  pushl $0
c0101ce6:	6a 00                	push   $0x0
  pushl $33
c0101ce8:	6a 21                	push   $0x21
  jmp __alltraps
c0101cea:	e9 ba fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101cef <vector34>:
.globl vector34
vector34:
  pushl $0
c0101cef:	6a 00                	push   $0x0
  pushl $34
c0101cf1:	6a 22                	push   $0x22
  jmp __alltraps
c0101cf3:	e9 b1 fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101cf8 <vector35>:
.globl vector35
vector35:
  pushl $0
c0101cf8:	6a 00                	push   $0x0
  pushl $35
c0101cfa:	6a 23                	push   $0x23
  jmp __alltraps
c0101cfc:	e9 a8 fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101d01 <vector36>:
.globl vector36
vector36:
  pushl $0
c0101d01:	6a 00                	push   $0x0
  pushl $36
c0101d03:	6a 24                	push   $0x24
  jmp __alltraps
c0101d05:	e9 9f fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101d0a <vector37>:
.globl vector37
vector37:
  pushl $0
c0101d0a:	6a 00                	push   $0x0
  pushl $37
c0101d0c:	6a 25                	push   $0x25
  jmp __alltraps
c0101d0e:	e9 96 fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101d13 <vector38>:
.globl vector38
vector38:
  pushl $0
c0101d13:	6a 00                	push   $0x0
  pushl $38
c0101d15:	6a 26                	push   $0x26
  jmp __alltraps
c0101d17:	e9 8d fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101d1c <vector39>:
.globl vector39
vector39:
  pushl $0
c0101d1c:	6a 00                	push   $0x0
  pushl $39
c0101d1e:	6a 27                	push   $0x27
  jmp __alltraps
c0101d20:	e9 84 fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101d25 <vector40>:
.globl vector40
vector40:
  pushl $0
c0101d25:	6a 00                	push   $0x0
  pushl $40
c0101d27:	6a 28                	push   $0x28
  jmp __alltraps
c0101d29:	e9 7b fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101d2e <vector41>:
.globl vector41
vector41:
  pushl $0
c0101d2e:	6a 00                	push   $0x0
  pushl $41
c0101d30:	6a 29                	push   $0x29
  jmp __alltraps
c0101d32:	e9 72 fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101d37 <vector42>:
.globl vector42
vector42:
  pushl $0
c0101d37:	6a 00                	push   $0x0
  pushl $42
c0101d39:	6a 2a                	push   $0x2a
  jmp __alltraps
c0101d3b:	e9 69 fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101d40 <vector43>:
.globl vector43
vector43:
  pushl $0
c0101d40:	6a 00                	push   $0x0
  pushl $43
c0101d42:	6a 2b                	push   $0x2b
  jmp __alltraps
c0101d44:	e9 60 fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101d49 <vector44>:
.globl vector44
vector44:
  pushl $0
c0101d49:	6a 00                	push   $0x0
  pushl $44
c0101d4b:	6a 2c                	push   $0x2c
  jmp __alltraps
c0101d4d:	e9 57 fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101d52 <vector45>:
.globl vector45
vector45:
  pushl $0
c0101d52:	6a 00                	push   $0x0
  pushl $45
c0101d54:	6a 2d                	push   $0x2d
  jmp __alltraps
c0101d56:	e9 4e fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101d5b <vector46>:
.globl vector46
vector46:
  pushl $0
c0101d5b:	6a 00                	push   $0x0
  pushl $46
c0101d5d:	6a 2e                	push   $0x2e
  jmp __alltraps
c0101d5f:	e9 45 fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101d64 <vector47>:
.globl vector47
vector47:
  pushl $0
c0101d64:	6a 00                	push   $0x0
  pushl $47
c0101d66:	6a 2f                	push   $0x2f
  jmp __alltraps
c0101d68:	e9 3c fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101d6d <vector48>:
.globl vector48
vector48:
  pushl $0
c0101d6d:	6a 00                	push   $0x0
  pushl $48
c0101d6f:	6a 30                	push   $0x30
  jmp __alltraps
c0101d71:	e9 33 fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101d76 <vector49>:
.globl vector49
vector49:
  pushl $0
c0101d76:	6a 00                	push   $0x0
  pushl $49
c0101d78:	6a 31                	push   $0x31
  jmp __alltraps
c0101d7a:	e9 2a fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101d7f <vector50>:
.globl vector50
vector50:
  pushl $0
c0101d7f:	6a 00                	push   $0x0
  pushl $50
c0101d81:	6a 32                	push   $0x32
  jmp __alltraps
c0101d83:	e9 21 fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101d88 <vector51>:
.globl vector51
vector51:
  pushl $0
c0101d88:	6a 00                	push   $0x0
  pushl $51
c0101d8a:	6a 33                	push   $0x33
  jmp __alltraps
c0101d8c:	e9 18 fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101d91 <vector52>:
.globl vector52
vector52:
  pushl $0
c0101d91:	6a 00                	push   $0x0
  pushl $52
c0101d93:	6a 34                	push   $0x34
  jmp __alltraps
c0101d95:	e9 0f fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101d9a <vector53>:
.globl vector53
vector53:
  pushl $0
c0101d9a:	6a 00                	push   $0x0
  pushl $53
c0101d9c:	6a 35                	push   $0x35
  jmp __alltraps
c0101d9e:	e9 06 fe ff ff       	jmp    c0101ba9 <__alltraps>

c0101da3 <vector54>:
.globl vector54
vector54:
  pushl $0
c0101da3:	6a 00                	push   $0x0
  pushl $54
c0101da5:	6a 36                	push   $0x36
  jmp __alltraps
c0101da7:	e9 fd fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101dac <vector55>:
.globl vector55
vector55:
  pushl $0
c0101dac:	6a 00                	push   $0x0
  pushl $55
c0101dae:	6a 37                	push   $0x37
  jmp __alltraps
c0101db0:	e9 f4 fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101db5 <vector56>:
.globl vector56
vector56:
  pushl $0
c0101db5:	6a 00                	push   $0x0
  pushl $56
c0101db7:	6a 38                	push   $0x38
  jmp __alltraps
c0101db9:	e9 eb fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101dbe <vector57>:
.globl vector57
vector57:
  pushl $0
c0101dbe:	6a 00                	push   $0x0
  pushl $57
c0101dc0:	6a 39                	push   $0x39
  jmp __alltraps
c0101dc2:	e9 e2 fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101dc7 <vector58>:
.globl vector58
vector58:
  pushl $0
c0101dc7:	6a 00                	push   $0x0
  pushl $58
c0101dc9:	6a 3a                	push   $0x3a
  jmp __alltraps
c0101dcb:	e9 d9 fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101dd0 <vector59>:
.globl vector59
vector59:
  pushl $0
c0101dd0:	6a 00                	push   $0x0
  pushl $59
c0101dd2:	6a 3b                	push   $0x3b
  jmp __alltraps
c0101dd4:	e9 d0 fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101dd9 <vector60>:
.globl vector60
vector60:
  pushl $0
c0101dd9:	6a 00                	push   $0x0
  pushl $60
c0101ddb:	6a 3c                	push   $0x3c
  jmp __alltraps
c0101ddd:	e9 c7 fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101de2 <vector61>:
.globl vector61
vector61:
  pushl $0
c0101de2:	6a 00                	push   $0x0
  pushl $61
c0101de4:	6a 3d                	push   $0x3d
  jmp __alltraps
c0101de6:	e9 be fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101deb <vector62>:
.globl vector62
vector62:
  pushl $0
c0101deb:	6a 00                	push   $0x0
  pushl $62
c0101ded:	6a 3e                	push   $0x3e
  jmp __alltraps
c0101def:	e9 b5 fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101df4 <vector63>:
.globl vector63
vector63:
  pushl $0
c0101df4:	6a 00                	push   $0x0
  pushl $63
c0101df6:	6a 3f                	push   $0x3f
  jmp __alltraps
c0101df8:	e9 ac fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101dfd <vector64>:
.globl vector64
vector64:
  pushl $0
c0101dfd:	6a 00                	push   $0x0
  pushl $64
c0101dff:	6a 40                	push   $0x40
  jmp __alltraps
c0101e01:	e9 a3 fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101e06 <vector65>:
.globl vector65
vector65:
  pushl $0
c0101e06:	6a 00                	push   $0x0
  pushl $65
c0101e08:	6a 41                	push   $0x41
  jmp __alltraps
c0101e0a:	e9 9a fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101e0f <vector66>:
.globl vector66
vector66:
  pushl $0
c0101e0f:	6a 00                	push   $0x0
  pushl $66
c0101e11:	6a 42                	push   $0x42
  jmp __alltraps
c0101e13:	e9 91 fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101e18 <vector67>:
.globl vector67
vector67:
  pushl $0
c0101e18:	6a 00                	push   $0x0
  pushl $67
c0101e1a:	6a 43                	push   $0x43
  jmp __alltraps
c0101e1c:	e9 88 fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101e21 <vector68>:
.globl vector68
vector68:
  pushl $0
c0101e21:	6a 00                	push   $0x0
  pushl $68
c0101e23:	6a 44                	push   $0x44
  jmp __alltraps
c0101e25:	e9 7f fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101e2a <vector69>:
.globl vector69
vector69:
  pushl $0
c0101e2a:	6a 00                	push   $0x0
  pushl $69
c0101e2c:	6a 45                	push   $0x45
  jmp __alltraps
c0101e2e:	e9 76 fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101e33 <vector70>:
.globl vector70
vector70:
  pushl $0
c0101e33:	6a 00                	push   $0x0
  pushl $70
c0101e35:	6a 46                	push   $0x46
  jmp __alltraps
c0101e37:	e9 6d fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101e3c <vector71>:
.globl vector71
vector71:
  pushl $0
c0101e3c:	6a 00                	push   $0x0
  pushl $71
c0101e3e:	6a 47                	push   $0x47
  jmp __alltraps
c0101e40:	e9 64 fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101e45 <vector72>:
.globl vector72
vector72:
  pushl $0
c0101e45:	6a 00                	push   $0x0
  pushl $72
c0101e47:	6a 48                	push   $0x48
  jmp __alltraps
c0101e49:	e9 5b fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101e4e <vector73>:
.globl vector73
vector73:
  pushl $0
c0101e4e:	6a 00                	push   $0x0
  pushl $73
c0101e50:	6a 49                	push   $0x49
  jmp __alltraps
c0101e52:	e9 52 fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101e57 <vector74>:
.globl vector74
vector74:
  pushl $0
c0101e57:	6a 00                	push   $0x0
  pushl $74
c0101e59:	6a 4a                	push   $0x4a
  jmp __alltraps
c0101e5b:	e9 49 fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101e60 <vector75>:
.globl vector75
vector75:
  pushl $0
c0101e60:	6a 00                	push   $0x0
  pushl $75
c0101e62:	6a 4b                	push   $0x4b
  jmp __alltraps
c0101e64:	e9 40 fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101e69 <vector76>:
.globl vector76
vector76:
  pushl $0
c0101e69:	6a 00                	push   $0x0
  pushl $76
c0101e6b:	6a 4c                	push   $0x4c
  jmp __alltraps
c0101e6d:	e9 37 fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101e72 <vector77>:
.globl vector77
vector77:
  pushl $0
c0101e72:	6a 00                	push   $0x0
  pushl $77
c0101e74:	6a 4d                	push   $0x4d
  jmp __alltraps
c0101e76:	e9 2e fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101e7b <vector78>:
.globl vector78
vector78:
  pushl $0
c0101e7b:	6a 00                	push   $0x0
  pushl $78
c0101e7d:	6a 4e                	push   $0x4e
  jmp __alltraps
c0101e7f:	e9 25 fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101e84 <vector79>:
.globl vector79
vector79:
  pushl $0
c0101e84:	6a 00                	push   $0x0
  pushl $79
c0101e86:	6a 4f                	push   $0x4f
  jmp __alltraps
c0101e88:	e9 1c fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101e8d <vector80>:
.globl vector80
vector80:
  pushl $0
c0101e8d:	6a 00                	push   $0x0
  pushl $80
c0101e8f:	6a 50                	push   $0x50
  jmp __alltraps
c0101e91:	e9 13 fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101e96 <vector81>:
.globl vector81
vector81:
  pushl $0
c0101e96:	6a 00                	push   $0x0
  pushl $81
c0101e98:	6a 51                	push   $0x51
  jmp __alltraps
c0101e9a:	e9 0a fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101e9f <vector82>:
.globl vector82
vector82:
  pushl $0
c0101e9f:	6a 00                	push   $0x0
  pushl $82
c0101ea1:	6a 52                	push   $0x52
  jmp __alltraps
c0101ea3:	e9 01 fd ff ff       	jmp    c0101ba9 <__alltraps>

c0101ea8 <vector83>:
.globl vector83
vector83:
  pushl $0
c0101ea8:	6a 00                	push   $0x0
  pushl $83
c0101eaa:	6a 53                	push   $0x53
  jmp __alltraps
c0101eac:	e9 f8 fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101eb1 <vector84>:
.globl vector84
vector84:
  pushl $0
c0101eb1:	6a 00                	push   $0x0
  pushl $84
c0101eb3:	6a 54                	push   $0x54
  jmp __alltraps
c0101eb5:	e9 ef fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101eba <vector85>:
.globl vector85
vector85:
  pushl $0
c0101eba:	6a 00                	push   $0x0
  pushl $85
c0101ebc:	6a 55                	push   $0x55
  jmp __alltraps
c0101ebe:	e9 e6 fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101ec3 <vector86>:
.globl vector86
vector86:
  pushl $0
c0101ec3:	6a 00                	push   $0x0
  pushl $86
c0101ec5:	6a 56                	push   $0x56
  jmp __alltraps
c0101ec7:	e9 dd fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101ecc <vector87>:
.globl vector87
vector87:
  pushl $0
c0101ecc:	6a 00                	push   $0x0
  pushl $87
c0101ece:	6a 57                	push   $0x57
  jmp __alltraps
c0101ed0:	e9 d4 fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101ed5 <vector88>:
.globl vector88
vector88:
  pushl $0
c0101ed5:	6a 00                	push   $0x0
  pushl $88
c0101ed7:	6a 58                	push   $0x58
  jmp __alltraps
c0101ed9:	e9 cb fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101ede <vector89>:
.globl vector89
vector89:
  pushl $0
c0101ede:	6a 00                	push   $0x0
  pushl $89
c0101ee0:	6a 59                	push   $0x59
  jmp __alltraps
c0101ee2:	e9 c2 fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101ee7 <vector90>:
.globl vector90
vector90:
  pushl $0
c0101ee7:	6a 00                	push   $0x0
  pushl $90
c0101ee9:	6a 5a                	push   $0x5a
  jmp __alltraps
c0101eeb:	e9 b9 fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101ef0 <vector91>:
.globl vector91
vector91:
  pushl $0
c0101ef0:	6a 00                	push   $0x0
  pushl $91
c0101ef2:	6a 5b                	push   $0x5b
  jmp __alltraps
c0101ef4:	e9 b0 fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101ef9 <vector92>:
.globl vector92
vector92:
  pushl $0
c0101ef9:	6a 00                	push   $0x0
  pushl $92
c0101efb:	6a 5c                	push   $0x5c
  jmp __alltraps
c0101efd:	e9 a7 fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101f02 <vector93>:
.globl vector93
vector93:
  pushl $0
c0101f02:	6a 00                	push   $0x0
  pushl $93
c0101f04:	6a 5d                	push   $0x5d
  jmp __alltraps
c0101f06:	e9 9e fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101f0b <vector94>:
.globl vector94
vector94:
  pushl $0
c0101f0b:	6a 00                	push   $0x0
  pushl $94
c0101f0d:	6a 5e                	push   $0x5e
  jmp __alltraps
c0101f0f:	e9 95 fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101f14 <vector95>:
.globl vector95
vector95:
  pushl $0
c0101f14:	6a 00                	push   $0x0
  pushl $95
c0101f16:	6a 5f                	push   $0x5f
  jmp __alltraps
c0101f18:	e9 8c fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101f1d <vector96>:
.globl vector96
vector96:
  pushl $0
c0101f1d:	6a 00                	push   $0x0
  pushl $96
c0101f1f:	6a 60                	push   $0x60
  jmp __alltraps
c0101f21:	e9 83 fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101f26 <vector97>:
.globl vector97
vector97:
  pushl $0
c0101f26:	6a 00                	push   $0x0
  pushl $97
c0101f28:	6a 61                	push   $0x61
  jmp __alltraps
c0101f2a:	e9 7a fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101f2f <vector98>:
.globl vector98
vector98:
  pushl $0
c0101f2f:	6a 00                	push   $0x0
  pushl $98
c0101f31:	6a 62                	push   $0x62
  jmp __alltraps
c0101f33:	e9 71 fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101f38 <vector99>:
.globl vector99
vector99:
  pushl $0
c0101f38:	6a 00                	push   $0x0
  pushl $99
c0101f3a:	6a 63                	push   $0x63
  jmp __alltraps
c0101f3c:	e9 68 fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101f41 <vector100>:
.globl vector100
vector100:
  pushl $0
c0101f41:	6a 00                	push   $0x0
  pushl $100
c0101f43:	6a 64                	push   $0x64
  jmp __alltraps
c0101f45:	e9 5f fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101f4a <vector101>:
.globl vector101
vector101:
  pushl $0
c0101f4a:	6a 00                	push   $0x0
  pushl $101
c0101f4c:	6a 65                	push   $0x65
  jmp __alltraps
c0101f4e:	e9 56 fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101f53 <vector102>:
.globl vector102
vector102:
  pushl $0
c0101f53:	6a 00                	push   $0x0
  pushl $102
c0101f55:	6a 66                	push   $0x66
  jmp __alltraps
c0101f57:	e9 4d fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101f5c <vector103>:
.globl vector103
vector103:
  pushl $0
c0101f5c:	6a 00                	push   $0x0
  pushl $103
c0101f5e:	6a 67                	push   $0x67
  jmp __alltraps
c0101f60:	e9 44 fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101f65 <vector104>:
.globl vector104
vector104:
  pushl $0
c0101f65:	6a 00                	push   $0x0
  pushl $104
c0101f67:	6a 68                	push   $0x68
  jmp __alltraps
c0101f69:	e9 3b fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101f6e <vector105>:
.globl vector105
vector105:
  pushl $0
c0101f6e:	6a 00                	push   $0x0
  pushl $105
c0101f70:	6a 69                	push   $0x69
  jmp __alltraps
c0101f72:	e9 32 fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101f77 <vector106>:
.globl vector106
vector106:
  pushl $0
c0101f77:	6a 00                	push   $0x0
  pushl $106
c0101f79:	6a 6a                	push   $0x6a
  jmp __alltraps
c0101f7b:	e9 29 fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101f80 <vector107>:
.globl vector107
vector107:
  pushl $0
c0101f80:	6a 00                	push   $0x0
  pushl $107
c0101f82:	6a 6b                	push   $0x6b
  jmp __alltraps
c0101f84:	e9 20 fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101f89 <vector108>:
.globl vector108
vector108:
  pushl $0
c0101f89:	6a 00                	push   $0x0
  pushl $108
c0101f8b:	6a 6c                	push   $0x6c
  jmp __alltraps
c0101f8d:	e9 17 fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101f92 <vector109>:
.globl vector109
vector109:
  pushl $0
c0101f92:	6a 00                	push   $0x0
  pushl $109
c0101f94:	6a 6d                	push   $0x6d
  jmp __alltraps
c0101f96:	e9 0e fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101f9b <vector110>:
.globl vector110
vector110:
  pushl $0
c0101f9b:	6a 00                	push   $0x0
  pushl $110
c0101f9d:	6a 6e                	push   $0x6e
  jmp __alltraps
c0101f9f:	e9 05 fc ff ff       	jmp    c0101ba9 <__alltraps>

c0101fa4 <vector111>:
.globl vector111
vector111:
  pushl $0
c0101fa4:	6a 00                	push   $0x0
  pushl $111
c0101fa6:	6a 6f                	push   $0x6f
  jmp __alltraps
c0101fa8:	e9 fc fb ff ff       	jmp    c0101ba9 <__alltraps>

c0101fad <vector112>:
.globl vector112
vector112:
  pushl $0
c0101fad:	6a 00                	push   $0x0
  pushl $112
c0101faf:	6a 70                	push   $0x70
  jmp __alltraps
c0101fb1:	e9 f3 fb ff ff       	jmp    c0101ba9 <__alltraps>

c0101fb6 <vector113>:
.globl vector113
vector113:
  pushl $0
c0101fb6:	6a 00                	push   $0x0
  pushl $113
c0101fb8:	6a 71                	push   $0x71
  jmp __alltraps
c0101fba:	e9 ea fb ff ff       	jmp    c0101ba9 <__alltraps>

c0101fbf <vector114>:
.globl vector114
vector114:
  pushl $0
c0101fbf:	6a 00                	push   $0x0
  pushl $114
c0101fc1:	6a 72                	push   $0x72
  jmp __alltraps
c0101fc3:	e9 e1 fb ff ff       	jmp    c0101ba9 <__alltraps>

c0101fc8 <vector115>:
.globl vector115
vector115:
  pushl $0
c0101fc8:	6a 00                	push   $0x0
  pushl $115
c0101fca:	6a 73                	push   $0x73
  jmp __alltraps
c0101fcc:	e9 d8 fb ff ff       	jmp    c0101ba9 <__alltraps>

c0101fd1 <vector116>:
.globl vector116
vector116:
  pushl $0
c0101fd1:	6a 00                	push   $0x0
  pushl $116
c0101fd3:	6a 74                	push   $0x74
  jmp __alltraps
c0101fd5:	e9 cf fb ff ff       	jmp    c0101ba9 <__alltraps>

c0101fda <vector117>:
.globl vector117
vector117:
  pushl $0
c0101fda:	6a 00                	push   $0x0
  pushl $117
c0101fdc:	6a 75                	push   $0x75
  jmp __alltraps
c0101fde:	e9 c6 fb ff ff       	jmp    c0101ba9 <__alltraps>

c0101fe3 <vector118>:
.globl vector118
vector118:
  pushl $0
c0101fe3:	6a 00                	push   $0x0
  pushl $118
c0101fe5:	6a 76                	push   $0x76
  jmp __alltraps
c0101fe7:	e9 bd fb ff ff       	jmp    c0101ba9 <__alltraps>

c0101fec <vector119>:
.globl vector119
vector119:
  pushl $0
c0101fec:	6a 00                	push   $0x0
  pushl $119
c0101fee:	6a 77                	push   $0x77
  jmp __alltraps
c0101ff0:	e9 b4 fb ff ff       	jmp    c0101ba9 <__alltraps>

c0101ff5 <vector120>:
.globl vector120
vector120:
  pushl $0
c0101ff5:	6a 00                	push   $0x0
  pushl $120
c0101ff7:	6a 78                	push   $0x78
  jmp __alltraps
c0101ff9:	e9 ab fb ff ff       	jmp    c0101ba9 <__alltraps>

c0101ffe <vector121>:
.globl vector121
vector121:
  pushl $0
c0101ffe:	6a 00                	push   $0x0
  pushl $121
c0102000:	6a 79                	push   $0x79
  jmp __alltraps
c0102002:	e9 a2 fb ff ff       	jmp    c0101ba9 <__alltraps>

c0102007 <vector122>:
.globl vector122
vector122:
  pushl $0
c0102007:	6a 00                	push   $0x0
  pushl $122
c0102009:	6a 7a                	push   $0x7a
  jmp __alltraps
c010200b:	e9 99 fb ff ff       	jmp    c0101ba9 <__alltraps>

c0102010 <vector123>:
.globl vector123
vector123:
  pushl $0
c0102010:	6a 00                	push   $0x0
  pushl $123
c0102012:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102014:	e9 90 fb ff ff       	jmp    c0101ba9 <__alltraps>

c0102019 <vector124>:
.globl vector124
vector124:
  pushl $0
c0102019:	6a 00                	push   $0x0
  pushl $124
c010201b:	6a 7c                	push   $0x7c
  jmp __alltraps
c010201d:	e9 87 fb ff ff       	jmp    c0101ba9 <__alltraps>

c0102022 <vector125>:
.globl vector125
vector125:
  pushl $0
c0102022:	6a 00                	push   $0x0
  pushl $125
c0102024:	6a 7d                	push   $0x7d
  jmp __alltraps
c0102026:	e9 7e fb ff ff       	jmp    c0101ba9 <__alltraps>

c010202b <vector126>:
.globl vector126
vector126:
  pushl $0
c010202b:	6a 00                	push   $0x0
  pushl $126
c010202d:	6a 7e                	push   $0x7e
  jmp __alltraps
c010202f:	e9 75 fb ff ff       	jmp    c0101ba9 <__alltraps>

c0102034 <vector127>:
.globl vector127
vector127:
  pushl $0
c0102034:	6a 00                	push   $0x0
  pushl $127
c0102036:	6a 7f                	push   $0x7f
  jmp __alltraps
c0102038:	e9 6c fb ff ff       	jmp    c0101ba9 <__alltraps>

c010203d <vector128>:
.globl vector128
vector128:
  pushl $0
c010203d:	6a 00                	push   $0x0
  pushl $128
c010203f:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102044:	e9 60 fb ff ff       	jmp    c0101ba9 <__alltraps>

c0102049 <vector129>:
.globl vector129
vector129:
  pushl $0
c0102049:	6a 00                	push   $0x0
  pushl $129
c010204b:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0102050:	e9 54 fb ff ff       	jmp    c0101ba9 <__alltraps>

c0102055 <vector130>:
.globl vector130
vector130:
  pushl $0
c0102055:	6a 00                	push   $0x0
  pushl $130
c0102057:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c010205c:	e9 48 fb ff ff       	jmp    c0101ba9 <__alltraps>

c0102061 <vector131>:
.globl vector131
vector131:
  pushl $0
c0102061:	6a 00                	push   $0x0
  pushl $131
c0102063:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0102068:	e9 3c fb ff ff       	jmp    c0101ba9 <__alltraps>

c010206d <vector132>:
.globl vector132
vector132:
  pushl $0
c010206d:	6a 00                	push   $0x0
  pushl $132
c010206f:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0102074:	e9 30 fb ff ff       	jmp    c0101ba9 <__alltraps>

c0102079 <vector133>:
.globl vector133
vector133:
  pushl $0
c0102079:	6a 00                	push   $0x0
  pushl $133
c010207b:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0102080:	e9 24 fb ff ff       	jmp    c0101ba9 <__alltraps>

c0102085 <vector134>:
.globl vector134
vector134:
  pushl $0
c0102085:	6a 00                	push   $0x0
  pushl $134
c0102087:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c010208c:	e9 18 fb ff ff       	jmp    c0101ba9 <__alltraps>

c0102091 <vector135>:
.globl vector135
vector135:
  pushl $0
c0102091:	6a 00                	push   $0x0
  pushl $135
c0102093:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102098:	e9 0c fb ff ff       	jmp    c0101ba9 <__alltraps>

c010209d <vector136>:
.globl vector136
vector136:
  pushl $0
c010209d:	6a 00                	push   $0x0
  pushl $136
c010209f:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c01020a4:	e9 00 fb ff ff       	jmp    c0101ba9 <__alltraps>

c01020a9 <vector137>:
.globl vector137
vector137:
  pushl $0
c01020a9:	6a 00                	push   $0x0
  pushl $137
c01020ab:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c01020b0:	e9 f4 fa ff ff       	jmp    c0101ba9 <__alltraps>

c01020b5 <vector138>:
.globl vector138
vector138:
  pushl $0
c01020b5:	6a 00                	push   $0x0
  pushl $138
c01020b7:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c01020bc:	e9 e8 fa ff ff       	jmp    c0101ba9 <__alltraps>

c01020c1 <vector139>:
.globl vector139
vector139:
  pushl $0
c01020c1:	6a 00                	push   $0x0
  pushl $139
c01020c3:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c01020c8:	e9 dc fa ff ff       	jmp    c0101ba9 <__alltraps>

c01020cd <vector140>:
.globl vector140
vector140:
  pushl $0
c01020cd:	6a 00                	push   $0x0
  pushl $140
c01020cf:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c01020d4:	e9 d0 fa ff ff       	jmp    c0101ba9 <__alltraps>

c01020d9 <vector141>:
.globl vector141
vector141:
  pushl $0
c01020d9:	6a 00                	push   $0x0
  pushl $141
c01020db:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c01020e0:	e9 c4 fa ff ff       	jmp    c0101ba9 <__alltraps>

c01020e5 <vector142>:
.globl vector142
vector142:
  pushl $0
c01020e5:	6a 00                	push   $0x0
  pushl $142
c01020e7:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c01020ec:	e9 b8 fa ff ff       	jmp    c0101ba9 <__alltraps>

c01020f1 <vector143>:
.globl vector143
vector143:
  pushl $0
c01020f1:	6a 00                	push   $0x0
  pushl $143
c01020f3:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c01020f8:	e9 ac fa ff ff       	jmp    c0101ba9 <__alltraps>

c01020fd <vector144>:
.globl vector144
vector144:
  pushl $0
c01020fd:	6a 00                	push   $0x0
  pushl $144
c01020ff:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0102104:	e9 a0 fa ff ff       	jmp    c0101ba9 <__alltraps>

c0102109 <vector145>:
.globl vector145
vector145:
  pushl $0
c0102109:	6a 00                	push   $0x0
  pushl $145
c010210b:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c0102110:	e9 94 fa ff ff       	jmp    c0101ba9 <__alltraps>

c0102115 <vector146>:
.globl vector146
vector146:
  pushl $0
c0102115:	6a 00                	push   $0x0
  pushl $146
c0102117:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c010211c:	e9 88 fa ff ff       	jmp    c0101ba9 <__alltraps>

c0102121 <vector147>:
.globl vector147
vector147:
  pushl $0
c0102121:	6a 00                	push   $0x0
  pushl $147
c0102123:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0102128:	e9 7c fa ff ff       	jmp    c0101ba9 <__alltraps>

c010212d <vector148>:
.globl vector148
vector148:
  pushl $0
c010212d:	6a 00                	push   $0x0
  pushl $148
c010212f:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0102134:	e9 70 fa ff ff       	jmp    c0101ba9 <__alltraps>

c0102139 <vector149>:
.globl vector149
vector149:
  pushl $0
c0102139:	6a 00                	push   $0x0
  pushl $149
c010213b:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0102140:	e9 64 fa ff ff       	jmp    c0101ba9 <__alltraps>

c0102145 <vector150>:
.globl vector150
vector150:
  pushl $0
c0102145:	6a 00                	push   $0x0
  pushl $150
c0102147:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c010214c:	e9 58 fa ff ff       	jmp    c0101ba9 <__alltraps>

c0102151 <vector151>:
.globl vector151
vector151:
  pushl $0
c0102151:	6a 00                	push   $0x0
  pushl $151
c0102153:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0102158:	e9 4c fa ff ff       	jmp    c0101ba9 <__alltraps>

c010215d <vector152>:
.globl vector152
vector152:
  pushl $0
c010215d:	6a 00                	push   $0x0
  pushl $152
c010215f:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c0102164:	e9 40 fa ff ff       	jmp    c0101ba9 <__alltraps>

c0102169 <vector153>:
.globl vector153
vector153:
  pushl $0
c0102169:	6a 00                	push   $0x0
  pushl $153
c010216b:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0102170:	e9 34 fa ff ff       	jmp    c0101ba9 <__alltraps>

c0102175 <vector154>:
.globl vector154
vector154:
  pushl $0
c0102175:	6a 00                	push   $0x0
  pushl $154
c0102177:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c010217c:	e9 28 fa ff ff       	jmp    c0101ba9 <__alltraps>

c0102181 <vector155>:
.globl vector155
vector155:
  pushl $0
c0102181:	6a 00                	push   $0x0
  pushl $155
c0102183:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0102188:	e9 1c fa ff ff       	jmp    c0101ba9 <__alltraps>

c010218d <vector156>:
.globl vector156
vector156:
  pushl $0
c010218d:	6a 00                	push   $0x0
  pushl $156
c010218f:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c0102194:	e9 10 fa ff ff       	jmp    c0101ba9 <__alltraps>

c0102199 <vector157>:
.globl vector157
vector157:
  pushl $0
c0102199:	6a 00                	push   $0x0
  pushl $157
c010219b:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c01021a0:	e9 04 fa ff ff       	jmp    c0101ba9 <__alltraps>

c01021a5 <vector158>:
.globl vector158
vector158:
  pushl $0
c01021a5:	6a 00                	push   $0x0
  pushl $158
c01021a7:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c01021ac:	e9 f8 f9 ff ff       	jmp    c0101ba9 <__alltraps>

c01021b1 <vector159>:
.globl vector159
vector159:
  pushl $0
c01021b1:	6a 00                	push   $0x0
  pushl $159
c01021b3:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c01021b8:	e9 ec f9 ff ff       	jmp    c0101ba9 <__alltraps>

c01021bd <vector160>:
.globl vector160
vector160:
  pushl $0
c01021bd:	6a 00                	push   $0x0
  pushl $160
c01021bf:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c01021c4:	e9 e0 f9 ff ff       	jmp    c0101ba9 <__alltraps>

c01021c9 <vector161>:
.globl vector161
vector161:
  pushl $0
c01021c9:	6a 00                	push   $0x0
  pushl $161
c01021cb:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c01021d0:	e9 d4 f9 ff ff       	jmp    c0101ba9 <__alltraps>

c01021d5 <vector162>:
.globl vector162
vector162:
  pushl $0
c01021d5:	6a 00                	push   $0x0
  pushl $162
c01021d7:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c01021dc:	e9 c8 f9 ff ff       	jmp    c0101ba9 <__alltraps>

c01021e1 <vector163>:
.globl vector163
vector163:
  pushl $0
c01021e1:	6a 00                	push   $0x0
  pushl $163
c01021e3:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c01021e8:	e9 bc f9 ff ff       	jmp    c0101ba9 <__alltraps>

c01021ed <vector164>:
.globl vector164
vector164:
  pushl $0
c01021ed:	6a 00                	push   $0x0
  pushl $164
c01021ef:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c01021f4:	e9 b0 f9 ff ff       	jmp    c0101ba9 <__alltraps>

c01021f9 <vector165>:
.globl vector165
vector165:
  pushl $0
c01021f9:	6a 00                	push   $0x0
  pushl $165
c01021fb:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c0102200:	e9 a4 f9 ff ff       	jmp    c0101ba9 <__alltraps>

c0102205 <vector166>:
.globl vector166
vector166:
  pushl $0
c0102205:	6a 00                	push   $0x0
  pushl $166
c0102207:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c010220c:	e9 98 f9 ff ff       	jmp    c0101ba9 <__alltraps>

c0102211 <vector167>:
.globl vector167
vector167:
  pushl $0
c0102211:	6a 00                	push   $0x0
  pushl $167
c0102213:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c0102218:	e9 8c f9 ff ff       	jmp    c0101ba9 <__alltraps>

c010221d <vector168>:
.globl vector168
vector168:
  pushl $0
c010221d:	6a 00                	push   $0x0
  pushl $168
c010221f:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c0102224:	e9 80 f9 ff ff       	jmp    c0101ba9 <__alltraps>

c0102229 <vector169>:
.globl vector169
vector169:
  pushl $0
c0102229:	6a 00                	push   $0x0
  pushl $169
c010222b:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c0102230:	e9 74 f9 ff ff       	jmp    c0101ba9 <__alltraps>

c0102235 <vector170>:
.globl vector170
vector170:
  pushl $0
c0102235:	6a 00                	push   $0x0
  pushl $170
c0102237:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c010223c:	e9 68 f9 ff ff       	jmp    c0101ba9 <__alltraps>

c0102241 <vector171>:
.globl vector171
vector171:
  pushl $0
c0102241:	6a 00                	push   $0x0
  pushl $171
c0102243:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c0102248:	e9 5c f9 ff ff       	jmp    c0101ba9 <__alltraps>

c010224d <vector172>:
.globl vector172
vector172:
  pushl $0
c010224d:	6a 00                	push   $0x0
  pushl $172
c010224f:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c0102254:	e9 50 f9 ff ff       	jmp    c0101ba9 <__alltraps>

c0102259 <vector173>:
.globl vector173
vector173:
  pushl $0
c0102259:	6a 00                	push   $0x0
  pushl $173
c010225b:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c0102260:	e9 44 f9 ff ff       	jmp    c0101ba9 <__alltraps>

c0102265 <vector174>:
.globl vector174
vector174:
  pushl $0
c0102265:	6a 00                	push   $0x0
  pushl $174
c0102267:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c010226c:	e9 38 f9 ff ff       	jmp    c0101ba9 <__alltraps>

c0102271 <vector175>:
.globl vector175
vector175:
  pushl $0
c0102271:	6a 00                	push   $0x0
  pushl $175
c0102273:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0102278:	e9 2c f9 ff ff       	jmp    c0101ba9 <__alltraps>

c010227d <vector176>:
.globl vector176
vector176:
  pushl $0
c010227d:	6a 00                	push   $0x0
  pushl $176
c010227f:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c0102284:	e9 20 f9 ff ff       	jmp    c0101ba9 <__alltraps>

c0102289 <vector177>:
.globl vector177
vector177:
  pushl $0
c0102289:	6a 00                	push   $0x0
  pushl $177
c010228b:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0102290:	e9 14 f9 ff ff       	jmp    c0101ba9 <__alltraps>

c0102295 <vector178>:
.globl vector178
vector178:
  pushl $0
c0102295:	6a 00                	push   $0x0
  pushl $178
c0102297:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c010229c:	e9 08 f9 ff ff       	jmp    c0101ba9 <__alltraps>

c01022a1 <vector179>:
.globl vector179
vector179:
  pushl $0
c01022a1:	6a 00                	push   $0x0
  pushl $179
c01022a3:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c01022a8:	e9 fc f8 ff ff       	jmp    c0101ba9 <__alltraps>

c01022ad <vector180>:
.globl vector180
vector180:
  pushl $0
c01022ad:	6a 00                	push   $0x0
  pushl $180
c01022af:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c01022b4:	e9 f0 f8 ff ff       	jmp    c0101ba9 <__alltraps>

c01022b9 <vector181>:
.globl vector181
vector181:
  pushl $0
c01022b9:	6a 00                	push   $0x0
  pushl $181
c01022bb:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c01022c0:	e9 e4 f8 ff ff       	jmp    c0101ba9 <__alltraps>

c01022c5 <vector182>:
.globl vector182
vector182:
  pushl $0
c01022c5:	6a 00                	push   $0x0
  pushl $182
c01022c7:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c01022cc:	e9 d8 f8 ff ff       	jmp    c0101ba9 <__alltraps>

c01022d1 <vector183>:
.globl vector183
vector183:
  pushl $0
c01022d1:	6a 00                	push   $0x0
  pushl $183
c01022d3:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c01022d8:	e9 cc f8 ff ff       	jmp    c0101ba9 <__alltraps>

c01022dd <vector184>:
.globl vector184
vector184:
  pushl $0
c01022dd:	6a 00                	push   $0x0
  pushl $184
c01022df:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c01022e4:	e9 c0 f8 ff ff       	jmp    c0101ba9 <__alltraps>

c01022e9 <vector185>:
.globl vector185
vector185:
  pushl $0
c01022e9:	6a 00                	push   $0x0
  pushl $185
c01022eb:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c01022f0:	e9 b4 f8 ff ff       	jmp    c0101ba9 <__alltraps>

c01022f5 <vector186>:
.globl vector186
vector186:
  pushl $0
c01022f5:	6a 00                	push   $0x0
  pushl $186
c01022f7:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c01022fc:	e9 a8 f8 ff ff       	jmp    c0101ba9 <__alltraps>

c0102301 <vector187>:
.globl vector187
vector187:
  pushl $0
c0102301:	6a 00                	push   $0x0
  pushl $187
c0102303:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c0102308:	e9 9c f8 ff ff       	jmp    c0101ba9 <__alltraps>

c010230d <vector188>:
.globl vector188
vector188:
  pushl $0
c010230d:	6a 00                	push   $0x0
  pushl $188
c010230f:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c0102314:	e9 90 f8 ff ff       	jmp    c0101ba9 <__alltraps>

c0102319 <vector189>:
.globl vector189
vector189:
  pushl $0
c0102319:	6a 00                	push   $0x0
  pushl $189
c010231b:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c0102320:	e9 84 f8 ff ff       	jmp    c0101ba9 <__alltraps>

c0102325 <vector190>:
.globl vector190
vector190:
  pushl $0
c0102325:	6a 00                	push   $0x0
  pushl $190
c0102327:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c010232c:	e9 78 f8 ff ff       	jmp    c0101ba9 <__alltraps>

c0102331 <vector191>:
.globl vector191
vector191:
  pushl $0
c0102331:	6a 00                	push   $0x0
  pushl $191
c0102333:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c0102338:	e9 6c f8 ff ff       	jmp    c0101ba9 <__alltraps>

c010233d <vector192>:
.globl vector192
vector192:
  pushl $0
c010233d:	6a 00                	push   $0x0
  pushl $192
c010233f:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c0102344:	e9 60 f8 ff ff       	jmp    c0101ba9 <__alltraps>

c0102349 <vector193>:
.globl vector193
vector193:
  pushl $0
c0102349:	6a 00                	push   $0x0
  pushl $193
c010234b:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c0102350:	e9 54 f8 ff ff       	jmp    c0101ba9 <__alltraps>

c0102355 <vector194>:
.globl vector194
vector194:
  pushl $0
c0102355:	6a 00                	push   $0x0
  pushl $194
c0102357:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c010235c:	e9 48 f8 ff ff       	jmp    c0101ba9 <__alltraps>

c0102361 <vector195>:
.globl vector195
vector195:
  pushl $0
c0102361:	6a 00                	push   $0x0
  pushl $195
c0102363:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c0102368:	e9 3c f8 ff ff       	jmp    c0101ba9 <__alltraps>

c010236d <vector196>:
.globl vector196
vector196:
  pushl $0
c010236d:	6a 00                	push   $0x0
  pushl $196
c010236f:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c0102374:	e9 30 f8 ff ff       	jmp    c0101ba9 <__alltraps>

c0102379 <vector197>:
.globl vector197
vector197:
  pushl $0
c0102379:	6a 00                	push   $0x0
  pushl $197
c010237b:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c0102380:	e9 24 f8 ff ff       	jmp    c0101ba9 <__alltraps>

c0102385 <vector198>:
.globl vector198
vector198:
  pushl $0
c0102385:	6a 00                	push   $0x0
  pushl $198
c0102387:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c010238c:	e9 18 f8 ff ff       	jmp    c0101ba9 <__alltraps>

c0102391 <vector199>:
.globl vector199
vector199:
  pushl $0
c0102391:	6a 00                	push   $0x0
  pushl $199
c0102393:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0102398:	e9 0c f8 ff ff       	jmp    c0101ba9 <__alltraps>

c010239d <vector200>:
.globl vector200
vector200:
  pushl $0
c010239d:	6a 00                	push   $0x0
  pushl $200
c010239f:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c01023a4:	e9 00 f8 ff ff       	jmp    c0101ba9 <__alltraps>

c01023a9 <vector201>:
.globl vector201
vector201:
  pushl $0
c01023a9:	6a 00                	push   $0x0
  pushl $201
c01023ab:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c01023b0:	e9 f4 f7 ff ff       	jmp    c0101ba9 <__alltraps>

c01023b5 <vector202>:
.globl vector202
vector202:
  pushl $0
c01023b5:	6a 00                	push   $0x0
  pushl $202
c01023b7:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c01023bc:	e9 e8 f7 ff ff       	jmp    c0101ba9 <__alltraps>

c01023c1 <vector203>:
.globl vector203
vector203:
  pushl $0
c01023c1:	6a 00                	push   $0x0
  pushl $203
c01023c3:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c01023c8:	e9 dc f7 ff ff       	jmp    c0101ba9 <__alltraps>

c01023cd <vector204>:
.globl vector204
vector204:
  pushl $0
c01023cd:	6a 00                	push   $0x0
  pushl $204
c01023cf:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c01023d4:	e9 d0 f7 ff ff       	jmp    c0101ba9 <__alltraps>

c01023d9 <vector205>:
.globl vector205
vector205:
  pushl $0
c01023d9:	6a 00                	push   $0x0
  pushl $205
c01023db:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c01023e0:	e9 c4 f7 ff ff       	jmp    c0101ba9 <__alltraps>

c01023e5 <vector206>:
.globl vector206
vector206:
  pushl $0
c01023e5:	6a 00                	push   $0x0
  pushl $206
c01023e7:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c01023ec:	e9 b8 f7 ff ff       	jmp    c0101ba9 <__alltraps>

c01023f1 <vector207>:
.globl vector207
vector207:
  pushl $0
c01023f1:	6a 00                	push   $0x0
  pushl $207
c01023f3:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c01023f8:	e9 ac f7 ff ff       	jmp    c0101ba9 <__alltraps>

c01023fd <vector208>:
.globl vector208
vector208:
  pushl $0
c01023fd:	6a 00                	push   $0x0
  pushl $208
c01023ff:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c0102404:	e9 a0 f7 ff ff       	jmp    c0101ba9 <__alltraps>

c0102409 <vector209>:
.globl vector209
vector209:
  pushl $0
c0102409:	6a 00                	push   $0x0
  pushl $209
c010240b:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c0102410:	e9 94 f7 ff ff       	jmp    c0101ba9 <__alltraps>

c0102415 <vector210>:
.globl vector210
vector210:
  pushl $0
c0102415:	6a 00                	push   $0x0
  pushl $210
c0102417:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c010241c:	e9 88 f7 ff ff       	jmp    c0101ba9 <__alltraps>

c0102421 <vector211>:
.globl vector211
vector211:
  pushl $0
c0102421:	6a 00                	push   $0x0
  pushl $211
c0102423:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c0102428:	e9 7c f7 ff ff       	jmp    c0101ba9 <__alltraps>

c010242d <vector212>:
.globl vector212
vector212:
  pushl $0
c010242d:	6a 00                	push   $0x0
  pushl $212
c010242f:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c0102434:	e9 70 f7 ff ff       	jmp    c0101ba9 <__alltraps>

c0102439 <vector213>:
.globl vector213
vector213:
  pushl $0
c0102439:	6a 00                	push   $0x0
  pushl $213
c010243b:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c0102440:	e9 64 f7 ff ff       	jmp    c0101ba9 <__alltraps>

c0102445 <vector214>:
.globl vector214
vector214:
  pushl $0
c0102445:	6a 00                	push   $0x0
  pushl $214
c0102447:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c010244c:	e9 58 f7 ff ff       	jmp    c0101ba9 <__alltraps>

c0102451 <vector215>:
.globl vector215
vector215:
  pushl $0
c0102451:	6a 00                	push   $0x0
  pushl $215
c0102453:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c0102458:	e9 4c f7 ff ff       	jmp    c0101ba9 <__alltraps>

c010245d <vector216>:
.globl vector216
vector216:
  pushl $0
c010245d:	6a 00                	push   $0x0
  pushl $216
c010245f:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c0102464:	e9 40 f7 ff ff       	jmp    c0101ba9 <__alltraps>

c0102469 <vector217>:
.globl vector217
vector217:
  pushl $0
c0102469:	6a 00                	push   $0x0
  pushl $217
c010246b:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c0102470:	e9 34 f7 ff ff       	jmp    c0101ba9 <__alltraps>

c0102475 <vector218>:
.globl vector218
vector218:
  pushl $0
c0102475:	6a 00                	push   $0x0
  pushl $218
c0102477:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c010247c:	e9 28 f7 ff ff       	jmp    c0101ba9 <__alltraps>

c0102481 <vector219>:
.globl vector219
vector219:
  pushl $0
c0102481:	6a 00                	push   $0x0
  pushl $219
c0102483:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c0102488:	e9 1c f7 ff ff       	jmp    c0101ba9 <__alltraps>

c010248d <vector220>:
.globl vector220
vector220:
  pushl $0
c010248d:	6a 00                	push   $0x0
  pushl $220
c010248f:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c0102494:	e9 10 f7 ff ff       	jmp    c0101ba9 <__alltraps>

c0102499 <vector221>:
.globl vector221
vector221:
  pushl $0
c0102499:	6a 00                	push   $0x0
  pushl $221
c010249b:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c01024a0:	e9 04 f7 ff ff       	jmp    c0101ba9 <__alltraps>

c01024a5 <vector222>:
.globl vector222
vector222:
  pushl $0
c01024a5:	6a 00                	push   $0x0
  pushl $222
c01024a7:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c01024ac:	e9 f8 f6 ff ff       	jmp    c0101ba9 <__alltraps>

c01024b1 <vector223>:
.globl vector223
vector223:
  pushl $0
c01024b1:	6a 00                	push   $0x0
  pushl $223
c01024b3:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c01024b8:	e9 ec f6 ff ff       	jmp    c0101ba9 <__alltraps>

c01024bd <vector224>:
.globl vector224
vector224:
  pushl $0
c01024bd:	6a 00                	push   $0x0
  pushl $224
c01024bf:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c01024c4:	e9 e0 f6 ff ff       	jmp    c0101ba9 <__alltraps>

c01024c9 <vector225>:
.globl vector225
vector225:
  pushl $0
c01024c9:	6a 00                	push   $0x0
  pushl $225
c01024cb:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c01024d0:	e9 d4 f6 ff ff       	jmp    c0101ba9 <__alltraps>

c01024d5 <vector226>:
.globl vector226
vector226:
  pushl $0
c01024d5:	6a 00                	push   $0x0
  pushl $226
c01024d7:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c01024dc:	e9 c8 f6 ff ff       	jmp    c0101ba9 <__alltraps>

c01024e1 <vector227>:
.globl vector227
vector227:
  pushl $0
c01024e1:	6a 00                	push   $0x0
  pushl $227
c01024e3:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c01024e8:	e9 bc f6 ff ff       	jmp    c0101ba9 <__alltraps>

c01024ed <vector228>:
.globl vector228
vector228:
  pushl $0
c01024ed:	6a 00                	push   $0x0
  pushl $228
c01024ef:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c01024f4:	e9 b0 f6 ff ff       	jmp    c0101ba9 <__alltraps>

c01024f9 <vector229>:
.globl vector229
vector229:
  pushl $0
c01024f9:	6a 00                	push   $0x0
  pushl $229
c01024fb:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c0102500:	e9 a4 f6 ff ff       	jmp    c0101ba9 <__alltraps>

c0102505 <vector230>:
.globl vector230
vector230:
  pushl $0
c0102505:	6a 00                	push   $0x0
  pushl $230
c0102507:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c010250c:	e9 98 f6 ff ff       	jmp    c0101ba9 <__alltraps>

c0102511 <vector231>:
.globl vector231
vector231:
  pushl $0
c0102511:	6a 00                	push   $0x0
  pushl $231
c0102513:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c0102518:	e9 8c f6 ff ff       	jmp    c0101ba9 <__alltraps>

c010251d <vector232>:
.globl vector232
vector232:
  pushl $0
c010251d:	6a 00                	push   $0x0
  pushl $232
c010251f:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c0102524:	e9 80 f6 ff ff       	jmp    c0101ba9 <__alltraps>

c0102529 <vector233>:
.globl vector233
vector233:
  pushl $0
c0102529:	6a 00                	push   $0x0
  pushl $233
c010252b:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c0102530:	e9 74 f6 ff ff       	jmp    c0101ba9 <__alltraps>

c0102535 <vector234>:
.globl vector234
vector234:
  pushl $0
c0102535:	6a 00                	push   $0x0
  pushl $234
c0102537:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c010253c:	e9 68 f6 ff ff       	jmp    c0101ba9 <__alltraps>

c0102541 <vector235>:
.globl vector235
vector235:
  pushl $0
c0102541:	6a 00                	push   $0x0
  pushl $235
c0102543:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c0102548:	e9 5c f6 ff ff       	jmp    c0101ba9 <__alltraps>

c010254d <vector236>:
.globl vector236
vector236:
  pushl $0
c010254d:	6a 00                	push   $0x0
  pushl $236
c010254f:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c0102554:	e9 50 f6 ff ff       	jmp    c0101ba9 <__alltraps>

c0102559 <vector237>:
.globl vector237
vector237:
  pushl $0
c0102559:	6a 00                	push   $0x0
  pushl $237
c010255b:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c0102560:	e9 44 f6 ff ff       	jmp    c0101ba9 <__alltraps>

c0102565 <vector238>:
.globl vector238
vector238:
  pushl $0
c0102565:	6a 00                	push   $0x0
  pushl $238
c0102567:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c010256c:	e9 38 f6 ff ff       	jmp    c0101ba9 <__alltraps>

c0102571 <vector239>:
.globl vector239
vector239:
  pushl $0
c0102571:	6a 00                	push   $0x0
  pushl $239
c0102573:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c0102578:	e9 2c f6 ff ff       	jmp    c0101ba9 <__alltraps>

c010257d <vector240>:
.globl vector240
vector240:
  pushl $0
c010257d:	6a 00                	push   $0x0
  pushl $240
c010257f:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c0102584:	e9 20 f6 ff ff       	jmp    c0101ba9 <__alltraps>

c0102589 <vector241>:
.globl vector241
vector241:
  pushl $0
c0102589:	6a 00                	push   $0x0
  pushl $241
c010258b:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c0102590:	e9 14 f6 ff ff       	jmp    c0101ba9 <__alltraps>

c0102595 <vector242>:
.globl vector242
vector242:
  pushl $0
c0102595:	6a 00                	push   $0x0
  pushl $242
c0102597:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c010259c:	e9 08 f6 ff ff       	jmp    c0101ba9 <__alltraps>

c01025a1 <vector243>:
.globl vector243
vector243:
  pushl $0
c01025a1:	6a 00                	push   $0x0
  pushl $243
c01025a3:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c01025a8:	e9 fc f5 ff ff       	jmp    c0101ba9 <__alltraps>

c01025ad <vector244>:
.globl vector244
vector244:
  pushl $0
c01025ad:	6a 00                	push   $0x0
  pushl $244
c01025af:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c01025b4:	e9 f0 f5 ff ff       	jmp    c0101ba9 <__alltraps>

c01025b9 <vector245>:
.globl vector245
vector245:
  pushl $0
c01025b9:	6a 00                	push   $0x0
  pushl $245
c01025bb:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c01025c0:	e9 e4 f5 ff ff       	jmp    c0101ba9 <__alltraps>

c01025c5 <vector246>:
.globl vector246
vector246:
  pushl $0
c01025c5:	6a 00                	push   $0x0
  pushl $246
c01025c7:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c01025cc:	e9 d8 f5 ff ff       	jmp    c0101ba9 <__alltraps>

c01025d1 <vector247>:
.globl vector247
vector247:
  pushl $0
c01025d1:	6a 00                	push   $0x0
  pushl $247
c01025d3:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c01025d8:	e9 cc f5 ff ff       	jmp    c0101ba9 <__alltraps>

c01025dd <vector248>:
.globl vector248
vector248:
  pushl $0
c01025dd:	6a 00                	push   $0x0
  pushl $248
c01025df:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c01025e4:	e9 c0 f5 ff ff       	jmp    c0101ba9 <__alltraps>

c01025e9 <vector249>:
.globl vector249
vector249:
  pushl $0
c01025e9:	6a 00                	push   $0x0
  pushl $249
c01025eb:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c01025f0:	e9 b4 f5 ff ff       	jmp    c0101ba9 <__alltraps>

c01025f5 <vector250>:
.globl vector250
vector250:
  pushl $0
c01025f5:	6a 00                	push   $0x0
  pushl $250
c01025f7:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c01025fc:	e9 a8 f5 ff ff       	jmp    c0101ba9 <__alltraps>

c0102601 <vector251>:
.globl vector251
vector251:
  pushl $0
c0102601:	6a 00                	push   $0x0
  pushl $251
c0102603:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c0102608:	e9 9c f5 ff ff       	jmp    c0101ba9 <__alltraps>

c010260d <vector252>:
.globl vector252
vector252:
  pushl $0
c010260d:	6a 00                	push   $0x0
  pushl $252
c010260f:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c0102614:	e9 90 f5 ff ff       	jmp    c0101ba9 <__alltraps>

c0102619 <vector253>:
.globl vector253
vector253:
  pushl $0
c0102619:	6a 00                	push   $0x0
  pushl $253
c010261b:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c0102620:	e9 84 f5 ff ff       	jmp    c0101ba9 <__alltraps>

c0102625 <vector254>:
.globl vector254
vector254:
  pushl $0
c0102625:	6a 00                	push   $0x0
  pushl $254
c0102627:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c010262c:	e9 78 f5 ff ff       	jmp    c0101ba9 <__alltraps>

c0102631 <vector255>:
.globl vector255
vector255:
  pushl $0
c0102631:	6a 00                	push   $0x0
  pushl $255
c0102633:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c0102638:	e9 6c f5 ff ff       	jmp    c0101ba9 <__alltraps>

c010263d <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c010263d:	55                   	push   %ebp
c010263e:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0102640:	8b 55 08             	mov    0x8(%ebp),%edx
c0102643:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c0102648:	29 c2                	sub    %eax,%edx
c010264a:	89 d0                	mov    %edx,%eax
c010264c:	c1 f8 02             	sar    $0x2,%eax
c010264f:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c0102655:	5d                   	pop    %ebp
c0102656:	c3                   	ret    

c0102657 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0102657:	55                   	push   %ebp
c0102658:	89 e5                	mov    %esp,%ebp
c010265a:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c010265d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102660:	89 04 24             	mov    %eax,(%esp)
c0102663:	e8 d5 ff ff ff       	call   c010263d <page2ppn>
c0102668:	c1 e0 0c             	shl    $0xc,%eax
}
c010266b:	c9                   	leave  
c010266c:	c3                   	ret    

c010266d <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c010266d:	55                   	push   %ebp
c010266e:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0102670:	8b 45 08             	mov    0x8(%ebp),%eax
c0102673:	8b 00                	mov    (%eax),%eax
}
c0102675:	5d                   	pop    %ebp
c0102676:	c3                   	ret    

c0102677 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0102677:	55                   	push   %ebp
c0102678:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c010267a:	8b 45 08             	mov    0x8(%ebp),%eax
c010267d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102680:	89 10                	mov    %edx,(%eax)
}
c0102682:	5d                   	pop    %ebp
c0102683:	c3                   	ret    

c0102684 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c0102684:	55                   	push   %ebp
c0102685:	89 e5                	mov    %esp,%ebp
c0102687:	83 ec 10             	sub    $0x10,%esp
c010268a:	c7 45 fc 10 af 11 c0 	movl   $0xc011af10,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0102691:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102694:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0102697:	89 50 04             	mov    %edx,0x4(%eax)
c010269a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010269d:	8b 50 04             	mov    0x4(%eax),%edx
c01026a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01026a3:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c01026a5:	c7 05 18 af 11 c0 00 	movl   $0x0,0xc011af18
c01026ac:	00 00 00 
}
c01026af:	c9                   	leave  
c01026b0:	c3                   	ret    

c01026b1 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c01026b1:	55                   	push   %ebp
c01026b2:	89 e5                	mov    %esp,%ebp
c01026b4:	83 ec 58             	sub    $0x58,%esp
    assert(n > 0);
c01026b7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01026bb:	75 24                	jne    c01026e1 <default_init_memmap+0x30>
c01026bd:	c7 44 24 0c 70 65 10 	movl   $0xc0106570,0xc(%esp)
c01026c4:	c0 
c01026c5:	c7 44 24 08 76 65 10 	movl   $0xc0106576,0x8(%esp)
c01026cc:	c0 
c01026cd:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c01026d4:	00 
c01026d5:	c7 04 24 8b 65 10 c0 	movl   $0xc010658b,(%esp)
c01026dc:	e8 37 e5 ff ff       	call   c0100c18 <__panic>
    struct Page *p = base;
c01026e1:	8b 45 08             	mov    0x8(%ebp),%eax
c01026e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c01026e7:	eb 7d                	jmp    c0102766 <default_init_memmap+0xb5>
        assert(PageReserved(p));
c01026e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01026ec:	83 c0 04             	add    $0x4,%eax
c01026ef:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c01026f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01026f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01026fc:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01026ff:	0f a3 10             	bt     %edx,(%eax)
c0102702:	19 c0                	sbb    %eax,%eax
c0102704:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c0102707:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010270b:	0f 95 c0             	setne  %al
c010270e:	0f b6 c0             	movzbl %al,%eax
c0102711:	85 c0                	test   %eax,%eax
c0102713:	75 24                	jne    c0102739 <default_init_memmap+0x88>
c0102715:	c7 44 24 0c a1 65 10 	movl   $0xc01065a1,0xc(%esp)
c010271c:	c0 
c010271d:	c7 44 24 08 76 65 10 	movl   $0xc0106576,0x8(%esp)
c0102724:	c0 
c0102725:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c010272c:	00 
c010272d:	c7 04 24 8b 65 10 c0 	movl   $0xc010658b,(%esp)
c0102734:	e8 df e4 ff ff       	call   c0100c18 <__panic>
        p->flags = p->property = 0;
c0102739:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010273c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c0102743:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102746:	8b 50 08             	mov    0x8(%eax),%edx
c0102749:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010274c:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c010274f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0102756:	00 
c0102757:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010275a:	89 04 24             	mov    %eax,(%esp)
c010275d:	e8 15 ff ff ff       	call   c0102677 <set_page_ref>

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c0102762:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0102766:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102769:	89 d0                	mov    %edx,%eax
c010276b:	c1 e0 02             	shl    $0x2,%eax
c010276e:	01 d0                	add    %edx,%eax
c0102770:	c1 e0 02             	shl    $0x2,%eax
c0102773:	89 c2                	mov    %eax,%edx
c0102775:	8b 45 08             	mov    0x8(%ebp),%eax
c0102778:	01 d0                	add    %edx,%eax
c010277a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010277d:	0f 85 66 ff ff ff    	jne    c01026e9 <default_init_memmap+0x38>
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
        
    }
    base->property = n;
c0102783:	8b 45 08             	mov    0x8(%ebp),%eax
c0102786:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102789:	89 50 08             	mov    %edx,0x8(%eax)
    nr_free += n;
c010278c:	8b 15 18 af 11 c0    	mov    0xc011af18,%edx
c0102792:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102795:	01 d0                	add    %edx,%eax
c0102797:	a3 18 af 11 c0       	mov    %eax,0xc011af18
    SetPageProperty(base);
c010279c:	8b 45 08             	mov    0x8(%ebp),%eax
c010279f:	83 c0 04             	add    $0x4,%eax
c01027a2:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c01027a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01027ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01027af:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01027b2:	0f ab 10             	bts    %edx,(%eax)
    list_add(&free_list, &(base->page_link));
c01027b5:	8b 45 08             	mov    0x8(%ebp),%eax
c01027b8:	83 c0 0c             	add    $0xc,%eax
c01027bb:	c7 45 dc 10 af 11 c0 	movl   $0xc011af10,-0x24(%ebp)
c01027c2:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01027c5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01027c8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c01027cb:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01027ce:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c01027d1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01027d4:	8b 40 04             	mov    0x4(%eax),%eax
c01027d7:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01027da:	89 55 cc             	mov    %edx,-0x34(%ebp)
c01027dd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01027e0:	89 55 c8             	mov    %edx,-0x38(%ebp)
c01027e3:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01027e6:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01027e9:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01027ec:	89 10                	mov    %edx,(%eax)
c01027ee:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01027f1:	8b 10                	mov    (%eax),%edx
c01027f3:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01027f6:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01027f9:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01027fc:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c01027ff:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0102802:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102805:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0102808:	89 10                	mov    %edx,(%eax)
}
c010280a:	c9                   	leave  
c010280b:	c3                   	ret    

c010280c <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c010280c:	55                   	push   %ebp
c010280d:	89 e5                	mov    %esp,%ebp
c010280f:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
c0102815:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0102819:	75 24                	jne    c010283f <default_alloc_pages+0x33>
c010281b:	c7 44 24 0c 70 65 10 	movl   $0xc0106570,0xc(%esp)
c0102822:	c0 
c0102823:	c7 44 24 08 76 65 10 	movl   $0xc0106576,0x8(%esp)
c010282a:	c0 
c010282b:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c0102832:	00 
c0102833:	c7 04 24 8b 65 10 c0 	movl   $0xc010658b,(%esp)
c010283a:	e8 d9 e3 ff ff       	call   c0100c18 <__panic>
    if (n > nr_free) {
c010283f:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c0102844:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102847:	73 0a                	jae    c0102853 <default_alloc_pages+0x47>
        return NULL;
c0102849:	b8 00 00 00 00       	mov    $0x0,%eax
c010284e:	e9 bd 01 00 00       	jmp    c0102a10 <default_alloc_pages+0x204>
    }
    struct Page *page = NULL;
c0102853:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c010285a:	c7 45 f0 10 af 11 c0 	movl   $0xc011af10,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0102861:	eb 1c                	jmp    c010287f <default_alloc_pages+0x73>
        struct Page *p = le2page(le, page_link);
c0102863:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102866:	83 e8 0c             	sub    $0xc,%eax
c0102869:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
c010286c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010286f:	8b 40 08             	mov    0x8(%eax),%eax
c0102872:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102875:	72 08                	jb     c010287f <default_alloc_pages+0x73>
            page = p;
c0102877:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010287a:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c010287d:	eb 18                	jmp    c0102897 <default_alloc_pages+0x8b>
c010287f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102882:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0102885:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102888:	8b 40 04             	mov    0x4(%eax),%eax
    if (n > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c010288b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010288e:	81 7d f0 10 af 11 c0 	cmpl   $0xc011af10,-0x10(%ebp)
c0102895:	75 cc                	jne    c0102863 <default_alloc_pages+0x57>
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    if (page != NULL) {
c0102897:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010289b:	0f 84 6c 01 00 00    	je     c0102a0d <default_alloc_pages+0x201>
        list_entry_t *p1=list_next(&(page->page_link));       
c01028a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01028a4:	83 c0 0c             	add    $0xc,%eax
c01028a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01028aa:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01028ad:	8b 40 04             	mov    0x4(%eax),%eax
c01028b0:	89 45 e8             	mov    %eax,-0x18(%ebp)
        list_entry_t *p2=list_prev(&(page->page_link)); 
c01028b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01028b6:	83 c0 0c             	add    $0xc,%eax
c01028b9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
c01028bc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01028bf:	8b 00                	mov    (%eax),%eax
c01028c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        //SetPageReserved(page);                   
        if (page->property > n) {
c01028c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01028c7:	8b 40 08             	mov    0x8(%eax),%eax
c01028ca:	3b 45 08             	cmp    0x8(%ebp),%eax
c01028cd:	0f 86 e9 00 00 00    	jbe    c01029bc <default_alloc_pages+0x1b0>
            struct Page *p = page + n;
c01028d3:	8b 55 08             	mov    0x8(%ebp),%edx
c01028d6:	89 d0                	mov    %edx,%eax
c01028d8:	c1 e0 02             	shl    $0x2,%eax
c01028db:	01 d0                	add    %edx,%eax
c01028dd:	c1 e0 02             	shl    $0x2,%eax
c01028e0:	89 c2                	mov    %eax,%edx
c01028e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01028e5:	01 d0                	add    %edx,%eax
c01028e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
            p->property = page->property - n;
c01028ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01028ed:	8b 40 08             	mov    0x8(%eax),%eax
c01028f0:	2b 45 08             	sub    0x8(%ebp),%eax
c01028f3:	89 c2                	mov    %eax,%edx
c01028f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01028f8:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);                 
c01028fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01028fe:	83 c0 04             	add    $0x4,%eax
c0102901:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0102908:	89 45 cc             	mov    %eax,-0x34(%ebp)
c010290b:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010290e:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102911:	0f ab 10             	bts    %edx,(%eax)
            list_add(&(p->page_link),p1);
c0102914:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102917:	83 c0 0c             	add    $0xc,%eax
c010291a:	89 45 c8             	mov    %eax,-0x38(%ebp)
c010291d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102920:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c0102923:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102926:	89 45 c0             	mov    %eax,-0x40(%ebp)
c0102929:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010292c:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c010292f:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0102932:	8b 40 04             	mov    0x4(%eax),%eax
c0102935:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0102938:	89 55 b8             	mov    %edx,-0x48(%ebp)
c010293b:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010293e:	89 55 b4             	mov    %edx,-0x4c(%ebp)
c0102941:	89 45 b0             	mov    %eax,-0x50(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0102944:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0102947:	8b 55 b8             	mov    -0x48(%ebp),%edx
c010294a:	89 10                	mov    %edx,(%eax)
c010294c:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010294f:	8b 10                	mov    (%eax),%edx
c0102951:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0102954:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0102957:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010295a:	8b 55 b0             	mov    -0x50(%ebp),%edx
c010295d:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0102960:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0102963:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0102966:	89 10                	mov    %edx,(%eax)
            list_add(p2,&(p->page_link));                                   
c0102968:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010296b:	8d 50 0c             	lea    0xc(%eax),%edx
c010296e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102971:	89 45 ac             	mov    %eax,-0x54(%ebp)
c0102974:	89 55 a8             	mov    %edx,-0x58(%ebp)
c0102977:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010297a:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c010297d:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0102980:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0102983:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0102986:	8b 40 04             	mov    0x4(%eax),%eax
c0102989:	8b 55 a0             	mov    -0x60(%ebp),%edx
c010298c:	89 55 9c             	mov    %edx,-0x64(%ebp)
c010298f:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0102992:	89 55 98             	mov    %edx,-0x68(%ebp)
c0102995:	89 45 94             	mov    %eax,-0x6c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0102998:	8b 45 94             	mov    -0x6c(%ebp),%eax
c010299b:	8b 55 9c             	mov    -0x64(%ebp),%edx
c010299e:	89 10                	mov    %edx,(%eax)
c01029a0:	8b 45 94             	mov    -0x6c(%ebp),%eax
c01029a3:	8b 10                	mov    (%eax),%edx
c01029a5:	8b 45 98             	mov    -0x68(%ebp),%eax
c01029a8:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01029ab:	8b 45 9c             	mov    -0x64(%ebp),%eax
c01029ae:	8b 55 94             	mov    -0x6c(%ebp),%edx
c01029b1:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01029b4:	8b 45 9c             	mov    -0x64(%ebp),%eax
c01029b7:	8b 55 98             	mov    -0x68(%ebp),%edx
c01029ba:	89 10                	mov    %edx,(%eax)
    }
        nr_free -= n;
c01029bc:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c01029c1:	2b 45 08             	sub    0x8(%ebp),%eax
c01029c4:	a3 18 af 11 c0       	mov    %eax,0xc011af18
        list_del(&(page->page_link));
c01029c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01029cc:	83 c0 0c             	add    $0xc,%eax
c01029cf:	89 45 90             	mov    %eax,-0x70(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c01029d2:	8b 45 90             	mov    -0x70(%ebp),%eax
c01029d5:	8b 40 04             	mov    0x4(%eax),%eax
c01029d8:	8b 55 90             	mov    -0x70(%ebp),%edx
c01029db:	8b 12                	mov    (%edx),%edx
c01029dd:	89 55 8c             	mov    %edx,-0x74(%ebp)
c01029e0:	89 45 88             	mov    %eax,-0x78(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c01029e3:	8b 45 8c             	mov    -0x74(%ebp),%eax
c01029e6:	8b 55 88             	mov    -0x78(%ebp),%edx
c01029e9:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01029ec:	8b 45 88             	mov    -0x78(%ebp),%eax
c01029ef:	8b 55 8c             	mov    -0x74(%ebp),%edx
c01029f2:	89 10                	mov    %edx,(%eax)
        ClearPageProperty(page);
c01029f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01029f7:	83 c0 04             	add    $0x4,%eax
c01029fa:	c7 45 84 01 00 00 00 	movl   $0x1,-0x7c(%ebp)
c0102a01:	89 45 80             	mov    %eax,-0x80(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102a04:	8b 45 80             	mov    -0x80(%ebp),%eax
c0102a07:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0102a0a:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
c0102a0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102a10:	c9                   	leave  
c0102a11:	c3                   	ret    

c0102a12 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c0102a12:	55                   	push   %ebp
c0102a13:	89 e5                	mov    %esp,%ebp
c0102a15:	81 ec b8 00 00 00    	sub    $0xb8,%esp
    assert(n > 0);
c0102a1b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0102a1f:	75 24                	jne    c0102a45 <default_free_pages+0x33>
c0102a21:	c7 44 24 0c 70 65 10 	movl   $0xc0106570,0xc(%esp)
c0102a28:	c0 
c0102a29:	c7 44 24 08 76 65 10 	movl   $0xc0106576,0x8(%esp)
c0102a30:	c0 
c0102a31:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
c0102a38:	00 
c0102a39:	c7 04 24 8b 65 10 c0 	movl   $0xc010658b,(%esp)
c0102a40:	e8 d3 e1 ff ff       	call   c0100c18 <__panic>
    struct Page *p = base;
c0102a45:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a48:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0102a4b:	e9 9d 00 00 00       	jmp    c0102aed <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
c0102a50:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102a53:	83 c0 04             	add    $0x4,%eax
c0102a56:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c0102a5d:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0102a60:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102a63:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102a66:	0f a3 10             	bt     %edx,(%eax)
c0102a69:	19 c0                	sbb    %eax,%eax
c0102a6b:	89 45 dc             	mov    %eax,-0x24(%ebp)
    return oldbit != 0;
c0102a6e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0102a72:	0f 95 c0             	setne  %al
c0102a75:	0f b6 c0             	movzbl %al,%eax
c0102a78:	85 c0                	test   %eax,%eax
c0102a7a:	75 2c                	jne    c0102aa8 <default_free_pages+0x96>
c0102a7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102a7f:	83 c0 04             	add    $0x4,%eax
c0102a82:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
c0102a89:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0102a8c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102a8f:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0102a92:	0f a3 10             	bt     %edx,(%eax)
c0102a95:	19 c0                	sbb    %eax,%eax
c0102a97:	89 45 d0             	mov    %eax,-0x30(%ebp)
    return oldbit != 0;
c0102a9a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c0102a9e:	0f 95 c0             	setne  %al
c0102aa1:	0f b6 c0             	movzbl %al,%eax
c0102aa4:	85 c0                	test   %eax,%eax
c0102aa6:	74 24                	je     c0102acc <default_free_pages+0xba>
c0102aa8:	c7 44 24 0c b4 65 10 	movl   $0xc01065b4,0xc(%esp)
c0102aaf:	c0 
c0102ab0:	c7 44 24 08 76 65 10 	movl   $0xc0106576,0x8(%esp)
c0102ab7:	c0 
c0102ab8:	c7 44 24 04 a1 00 00 	movl   $0xa1,0x4(%esp)
c0102abf:	00 
c0102ac0:	c7 04 24 8b 65 10 c0 	movl   $0xc010658b,(%esp)
c0102ac7:	e8 4c e1 ff ff       	call   c0100c18 <__panic>
        p->flags = 0;
c0102acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102acf:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c0102ad6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0102add:	00 
c0102ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102ae1:	89 04 24             	mov    %eax,(%esp)
c0102ae4:	e8 8e fb ff ff       	call   c0102677 <set_page_ref>

static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c0102ae9:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0102aed:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102af0:	89 d0                	mov    %edx,%eax
c0102af2:	c1 e0 02             	shl    $0x2,%eax
c0102af5:	01 d0                	add    %edx,%eax
c0102af7:	c1 e0 02             	shl    $0x2,%eax
c0102afa:	89 c2                	mov    %eax,%edx
c0102afc:	8b 45 08             	mov    0x8(%ebp),%eax
c0102aff:	01 d0                	add    %edx,%eax
c0102b01:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102b04:	0f 85 46 ff ff ff    	jne    c0102a50 <default_free_pages+0x3e>
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
c0102b0a:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b0d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102b10:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0102b13:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b16:	83 c0 04             	add    $0x4,%eax
c0102b19:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
c0102b20:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102b23:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102b26:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0102b29:	0f ab 10             	bts    %edx,(%eax)
c0102b2c:	c7 45 c4 10 af 11 c0 	movl   $0xc011af10,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0102b33:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102b36:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c0102b39:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c0102b3c:	e9 08 01 00 00       	jmp    c0102c49 <default_free_pages+0x237>
        p = le2page(le, page_link);
c0102b41:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102b44:	83 e8 0c             	sub    $0xc,%eax
c0102b47:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102b4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102b4d:	89 45 c0             	mov    %eax,-0x40(%ebp)
c0102b50:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0102b53:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0102b56:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) {
c0102b59:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b5c:	8b 50 08             	mov    0x8(%eax),%edx
c0102b5f:	89 d0                	mov    %edx,%eax
c0102b61:	c1 e0 02             	shl    $0x2,%eax
c0102b64:	01 d0                	add    %edx,%eax
c0102b66:	c1 e0 02             	shl    $0x2,%eax
c0102b69:	89 c2                	mov    %eax,%edx
c0102b6b:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b6e:	01 d0                	add    %edx,%eax
c0102b70:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102b73:	75 5a                	jne    c0102bcf <default_free_pages+0x1bd>
            base->property += p->property;
c0102b75:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b78:	8b 50 08             	mov    0x8(%eax),%edx
c0102b7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102b7e:	8b 40 08             	mov    0x8(%eax),%eax
c0102b81:	01 c2                	add    %eax,%edx
c0102b83:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b86:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c0102b89:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102b8c:	83 c0 04             	add    $0x4,%eax
c0102b8f:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
c0102b96:	89 45 b8             	mov    %eax,-0x48(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102b99:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0102b9c:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0102b9f:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
c0102ba2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102ba5:	83 c0 0c             	add    $0xc,%eax
c0102ba8:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0102bab:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0102bae:	8b 40 04             	mov    0x4(%eax),%eax
c0102bb1:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0102bb4:	8b 12                	mov    (%edx),%edx
c0102bb6:	89 55 b0             	mov    %edx,-0x50(%ebp)
c0102bb9:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0102bbc:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0102bbf:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0102bc2:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0102bc5:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0102bc8:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0102bcb:	89 10                	mov    %edx,(%eax)
c0102bcd:	eb 7a                	jmp    c0102c49 <default_free_pages+0x237>
        }
        else if (p + p->property == base) {
c0102bcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102bd2:	8b 50 08             	mov    0x8(%eax),%edx
c0102bd5:	89 d0                	mov    %edx,%eax
c0102bd7:	c1 e0 02             	shl    $0x2,%eax
c0102bda:	01 d0                	add    %edx,%eax
c0102bdc:	c1 e0 02             	shl    $0x2,%eax
c0102bdf:	89 c2                	mov    %eax,%edx
c0102be1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102be4:	01 d0                	add    %edx,%eax
c0102be6:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102be9:	75 5e                	jne    c0102c49 <default_free_pages+0x237>
            p->property += base->property;
c0102beb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102bee:	8b 50 08             	mov    0x8(%eax),%edx
c0102bf1:	8b 45 08             	mov    0x8(%ebp),%eax
c0102bf4:	8b 40 08             	mov    0x8(%eax),%eax
c0102bf7:	01 c2                	add    %eax,%edx
c0102bf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102bfc:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c0102bff:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c02:	83 c0 04             	add    $0x4,%eax
c0102c05:	c7 45 a8 01 00 00 00 	movl   $0x1,-0x58(%ebp)
c0102c0c:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c0102c0f:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0102c12:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0102c15:	0f b3 10             	btr    %edx,(%eax)
            base = p;
c0102c18:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c1b:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c0102c1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c21:	83 c0 0c             	add    $0xc,%eax
c0102c24:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0102c27:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0102c2a:	8b 40 04             	mov    0x4(%eax),%eax
c0102c2d:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0102c30:	8b 12                	mov    (%edx),%edx
c0102c32:	89 55 9c             	mov    %edx,-0x64(%ebp)
c0102c35:	89 45 98             	mov    %eax,-0x68(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0102c38:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0102c3b:	8b 55 98             	mov    -0x68(%ebp),%edx
c0102c3e:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0102c41:	8b 45 98             	mov    -0x68(%ebp),%eax
c0102c44:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0102c47:	89 10                	mov    %edx,(%eax)
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
    while (le != &free_list) {
c0102c49:	81 7d f0 10 af 11 c0 	cmpl   $0xc011af10,-0x10(%ebp)
c0102c50:	0f 85 eb fe ff ff    	jne    c0102b41 <default_free_pages+0x12f>
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
c0102c56:	8b 15 18 af 11 c0    	mov    0xc011af18,%edx
c0102c5c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102c5f:	01 d0                	add    %edx,%eax
c0102c61:	a3 18 af 11 c0       	mov    %eax,0xc011af18
    if(base->property>n)
c0102c66:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c69:	8b 40 08             	mov    0x8(%eax),%eax
c0102c6c:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0102c6f:	76 66                	jbe    c0102cd7 <default_free_pages+0x2c5>
    list_add(&free_list, &(base->page_link));
c0102c71:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c74:	83 c0 0c             	add    $0xc,%eax
c0102c77:	c7 45 94 10 af 11 c0 	movl   $0xc011af10,-0x6c(%ebp)
c0102c7e:	89 45 90             	mov    %eax,-0x70(%ebp)
c0102c81:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0102c84:	89 45 8c             	mov    %eax,-0x74(%ebp)
c0102c87:	8b 45 90             	mov    -0x70(%ebp),%eax
c0102c8a:	89 45 88             	mov    %eax,-0x78(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0102c8d:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0102c90:	8b 40 04             	mov    0x4(%eax),%eax
c0102c93:	8b 55 88             	mov    -0x78(%ebp),%edx
c0102c96:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0102c99:	8b 55 8c             	mov    -0x74(%ebp),%edx
c0102c9c:	89 55 80             	mov    %edx,-0x80(%ebp)
c0102c9f:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0102ca5:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c0102cab:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0102cae:	89 10                	mov    %edx,(%eax)
c0102cb0:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c0102cb6:	8b 10                	mov    (%eax),%edx
c0102cb8:	8b 45 80             	mov    -0x80(%ebp),%eax
c0102cbb:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0102cbe:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0102cc1:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
c0102cc7:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0102cca:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0102ccd:	8b 55 80             	mov    -0x80(%ebp),%edx
c0102cd0:	89 10                	mov    %edx,(%eax)
c0102cd2:	e9 fe 00 00 00       	jmp    c0102dd5 <default_free_pages+0x3c3>
c0102cd7:	c7 85 78 ff ff ff 10 	movl   $0xc011af10,-0x88(%ebp)
c0102cde:	af 11 c0 
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0102ce1:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
c0102ce7:	8b 40 04             	mov    0x4(%eax),%eax
    else
    {
	    list_entry_t *le1 = list_next(&free_list);
c0102cea:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0102ced:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102cf0:	89 85 74 ff ff ff    	mov    %eax,-0x8c(%ebp)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
c0102cf6:	8b 85 74 ff ff ff    	mov    -0x8c(%ebp),%eax
c0102cfc:	8b 00                	mov    (%eax),%eax
	    list_entry_t *le0 = list_prev(le1);
c0102cfe:	89 45 e8             	mov    %eax,-0x18(%ebp)
	    while (le1 != &free_list) {
c0102d01:	eb 39                	jmp    c0102d3c <default_free_pages+0x32a>
		p = le2page(le1, page_link);
c0102d03:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102d06:	83 e8 0c             	sub    $0xc,%eax
c0102d09:	89 45 f4             	mov    %eax,-0xc(%ebp)
		if(base+base->property<le1)break;
c0102d0c:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d0f:	8b 50 08             	mov    0x8(%eax),%edx
c0102d12:	89 d0                	mov    %edx,%eax
c0102d14:	c1 e0 02             	shl    $0x2,%eax
c0102d17:	01 d0                	add    %edx,%eax
c0102d19:	c1 e0 02             	shl    $0x2,%eax
c0102d1c:	89 c2                	mov    %eax,%edx
c0102d1e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d21:	01 d0                	add    %edx,%eax
c0102d23:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0102d26:	73 02                	jae    c0102d2a <default_free_pages+0x318>
c0102d28:	eb 1b                	jmp    c0102d45 <default_free_pages+0x333>
		le0=le0->next;
c0102d2a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102d2d:	8b 40 04             	mov    0x4(%eax),%eax
c0102d30:	89 45 e8             	mov    %eax,-0x18(%ebp)
		le1=le1->next;
c0102d33:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102d36:	8b 40 04             	mov    0x4(%eax),%eax
c0102d39:	89 45 ec             	mov    %eax,-0x14(%ebp)
    list_add(&free_list, &(base->page_link));
    else
    {
	    list_entry_t *le1 = list_next(&free_list);
	    list_entry_t *le0 = list_prev(le1);
	    while (le1 != &free_list) {
c0102d3c:	81 7d ec 10 af 11 c0 	cmpl   $0xc011af10,-0x14(%ebp)
c0102d43:	75 be                	jne    c0102d03 <default_free_pages+0x2f1>
		p = le2page(le1, page_link);
		if(base+base->property<le1)break;
		le0=le0->next;
		le1=le1->next;
	    }
	    list_add(le0, &(base->page_link));
c0102d45:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d48:	8d 50 0c             	lea    0xc(%eax),%edx
c0102d4b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102d4e:	89 85 70 ff ff ff    	mov    %eax,-0x90(%ebp)
c0102d54:	89 95 6c ff ff ff    	mov    %edx,-0x94(%ebp)
c0102d5a:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
c0102d60:	89 85 68 ff ff ff    	mov    %eax,-0x98(%ebp)
c0102d66:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
c0102d6c:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0102d72:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
c0102d78:	8b 40 04             	mov    0x4(%eax),%eax
c0102d7b:	8b 95 64 ff ff ff    	mov    -0x9c(%ebp),%edx
c0102d81:	89 95 60 ff ff ff    	mov    %edx,-0xa0(%ebp)
c0102d87:	8b 95 68 ff ff ff    	mov    -0x98(%ebp),%edx
c0102d8d:	89 95 5c ff ff ff    	mov    %edx,-0xa4(%ebp)
c0102d93:	89 85 58 ff ff ff    	mov    %eax,-0xa8(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0102d99:	8b 85 58 ff ff ff    	mov    -0xa8(%ebp),%eax
c0102d9f:	8b 95 60 ff ff ff    	mov    -0xa0(%ebp),%edx
c0102da5:	89 10                	mov    %edx,(%eax)
c0102da7:	8b 85 58 ff ff ff    	mov    -0xa8(%ebp),%eax
c0102dad:	8b 10                	mov    (%eax),%edx
c0102daf:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
c0102db5:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0102db8:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
c0102dbe:	8b 95 58 ff ff ff    	mov    -0xa8(%ebp),%edx
c0102dc4:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0102dc7:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
c0102dcd:	8b 95 5c ff ff ff    	mov    -0xa4(%ebp),%edx
c0102dd3:	89 10                	mov    %edx,(%eax)
    }
}
c0102dd5:	c9                   	leave  
c0102dd6:	c3                   	ret    

c0102dd7 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0102dd7:	55                   	push   %ebp
c0102dd8:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0102dda:	a1 18 af 11 c0       	mov    0xc011af18,%eax
}
c0102ddf:	5d                   	pop    %ebp
c0102de0:	c3                   	ret    

c0102de1 <basic_check>:

static void
basic_check(void) {
c0102de1:	55                   	push   %ebp
c0102de2:	89 e5                	mov    %esp,%ebp
c0102de4:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0102de7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0102dee:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102df1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102df4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102df7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0102dfa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0102e01:	e8 db 0e 00 00       	call   c0103ce1 <alloc_pages>
c0102e06:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0102e09:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0102e0d:	75 24                	jne    c0102e33 <basic_check+0x52>
c0102e0f:	c7 44 24 0c d9 65 10 	movl   $0xc01065d9,0xc(%esp)
c0102e16:	c0 
c0102e17:	c7 44 24 08 76 65 10 	movl   $0xc0106576,0x8(%esp)
c0102e1e:	c0 
c0102e1f:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
c0102e26:	00 
c0102e27:	c7 04 24 8b 65 10 c0 	movl   $0xc010658b,(%esp)
c0102e2e:	e8 e5 dd ff ff       	call   c0100c18 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0102e33:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0102e3a:	e8 a2 0e 00 00       	call   c0103ce1 <alloc_pages>
c0102e3f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102e42:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0102e46:	75 24                	jne    c0102e6c <basic_check+0x8b>
c0102e48:	c7 44 24 0c f5 65 10 	movl   $0xc01065f5,0xc(%esp)
c0102e4f:	c0 
c0102e50:	c7 44 24 08 76 65 10 	movl   $0xc0106576,0x8(%esp)
c0102e57:	c0 
c0102e58:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
c0102e5f:	00 
c0102e60:	c7 04 24 8b 65 10 c0 	movl   $0xc010658b,(%esp)
c0102e67:	e8 ac dd ff ff       	call   c0100c18 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0102e6c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0102e73:	e8 69 0e 00 00       	call   c0103ce1 <alloc_pages>
c0102e78:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102e7b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0102e7f:	75 24                	jne    c0102ea5 <basic_check+0xc4>
c0102e81:	c7 44 24 0c 11 66 10 	movl   $0xc0106611,0xc(%esp)
c0102e88:	c0 
c0102e89:	c7 44 24 08 76 65 10 	movl   $0xc0106576,0x8(%esp)
c0102e90:	c0 
c0102e91:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
c0102e98:	00 
c0102e99:	c7 04 24 8b 65 10 c0 	movl   $0xc010658b,(%esp)
c0102ea0:	e8 73 dd ff ff       	call   c0100c18 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0102ea5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102ea8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0102eab:	74 10                	je     c0102ebd <basic_check+0xdc>
c0102ead:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102eb0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102eb3:	74 08                	je     c0102ebd <basic_check+0xdc>
c0102eb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102eb8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102ebb:	75 24                	jne    c0102ee1 <basic_check+0x100>
c0102ebd:	c7 44 24 0c 30 66 10 	movl   $0xc0106630,0xc(%esp)
c0102ec4:	c0 
c0102ec5:	c7 44 24 08 76 65 10 	movl   $0xc0106576,0x8(%esp)
c0102ecc:	c0 
c0102ecd:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
c0102ed4:	00 
c0102ed5:	c7 04 24 8b 65 10 c0 	movl   $0xc010658b,(%esp)
c0102edc:	e8 37 dd ff ff       	call   c0100c18 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0102ee1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102ee4:	89 04 24             	mov    %eax,(%esp)
c0102ee7:	e8 81 f7 ff ff       	call   c010266d <page_ref>
c0102eec:	85 c0                	test   %eax,%eax
c0102eee:	75 1e                	jne    c0102f0e <basic_check+0x12d>
c0102ef0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102ef3:	89 04 24             	mov    %eax,(%esp)
c0102ef6:	e8 72 f7 ff ff       	call   c010266d <page_ref>
c0102efb:	85 c0                	test   %eax,%eax
c0102efd:	75 0f                	jne    c0102f0e <basic_check+0x12d>
c0102eff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102f02:	89 04 24             	mov    %eax,(%esp)
c0102f05:	e8 63 f7 ff ff       	call   c010266d <page_ref>
c0102f0a:	85 c0                	test   %eax,%eax
c0102f0c:	74 24                	je     c0102f32 <basic_check+0x151>
c0102f0e:	c7 44 24 0c 54 66 10 	movl   $0xc0106654,0xc(%esp)
c0102f15:	c0 
c0102f16:	c7 44 24 08 76 65 10 	movl   $0xc0106576,0x8(%esp)
c0102f1d:	c0 
c0102f1e:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c0102f25:	00 
c0102f26:	c7 04 24 8b 65 10 c0 	movl   $0xc010658b,(%esp)
c0102f2d:	e8 e6 dc ff ff       	call   c0100c18 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0102f32:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102f35:	89 04 24             	mov    %eax,(%esp)
c0102f38:	e8 1a f7 ff ff       	call   c0102657 <page2pa>
c0102f3d:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c0102f43:	c1 e2 0c             	shl    $0xc,%edx
c0102f46:	39 d0                	cmp    %edx,%eax
c0102f48:	72 24                	jb     c0102f6e <basic_check+0x18d>
c0102f4a:	c7 44 24 0c 90 66 10 	movl   $0xc0106690,0xc(%esp)
c0102f51:	c0 
c0102f52:	c7 44 24 08 76 65 10 	movl   $0xc0106576,0x8(%esp)
c0102f59:	c0 
c0102f5a:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
c0102f61:	00 
c0102f62:	c7 04 24 8b 65 10 c0 	movl   $0xc010658b,(%esp)
c0102f69:	e8 aa dc ff ff       	call   c0100c18 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0102f6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102f71:	89 04 24             	mov    %eax,(%esp)
c0102f74:	e8 de f6 ff ff       	call   c0102657 <page2pa>
c0102f79:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c0102f7f:	c1 e2 0c             	shl    $0xc,%edx
c0102f82:	39 d0                	cmp    %edx,%eax
c0102f84:	72 24                	jb     c0102faa <basic_check+0x1c9>
c0102f86:	c7 44 24 0c ad 66 10 	movl   $0xc01066ad,0xc(%esp)
c0102f8d:	c0 
c0102f8e:	c7 44 24 08 76 65 10 	movl   $0xc0106576,0x8(%esp)
c0102f95:	c0 
c0102f96:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
c0102f9d:	00 
c0102f9e:	c7 04 24 8b 65 10 c0 	movl   $0xc010658b,(%esp)
c0102fa5:	e8 6e dc ff ff       	call   c0100c18 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0102faa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102fad:	89 04 24             	mov    %eax,(%esp)
c0102fb0:	e8 a2 f6 ff ff       	call   c0102657 <page2pa>
c0102fb5:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c0102fbb:	c1 e2 0c             	shl    $0xc,%edx
c0102fbe:	39 d0                	cmp    %edx,%eax
c0102fc0:	72 24                	jb     c0102fe6 <basic_check+0x205>
c0102fc2:	c7 44 24 0c ca 66 10 	movl   $0xc01066ca,0xc(%esp)
c0102fc9:	c0 
c0102fca:	c7 44 24 08 76 65 10 	movl   $0xc0106576,0x8(%esp)
c0102fd1:	c0 
c0102fd2:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c0102fd9:	00 
c0102fda:	c7 04 24 8b 65 10 c0 	movl   $0xc010658b,(%esp)
c0102fe1:	e8 32 dc ff ff       	call   c0100c18 <__panic>

    list_entry_t free_list_store = free_list;
c0102fe6:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c0102feb:	8b 15 14 af 11 c0    	mov    0xc011af14,%edx
c0102ff1:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102ff4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0102ff7:	c7 45 e0 10 af 11 c0 	movl   $0xc011af10,-0x20(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0102ffe:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103001:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103004:	89 50 04             	mov    %edx,0x4(%eax)
c0103007:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010300a:	8b 50 04             	mov    0x4(%eax),%edx
c010300d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103010:	89 10                	mov    %edx,(%eax)
c0103012:	c7 45 dc 10 af 11 c0 	movl   $0xc011af10,-0x24(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0103019:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010301c:	8b 40 04             	mov    0x4(%eax),%eax
c010301f:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0103022:	0f 94 c0             	sete   %al
c0103025:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0103028:	85 c0                	test   %eax,%eax
c010302a:	75 24                	jne    c0103050 <basic_check+0x26f>
c010302c:	c7 44 24 0c e7 66 10 	movl   $0xc01066e7,0xc(%esp)
c0103033:	c0 
c0103034:	c7 44 24 08 76 65 10 	movl   $0xc0106576,0x8(%esp)
c010303b:	c0 
c010303c:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
c0103043:	00 
c0103044:	c7 04 24 8b 65 10 c0 	movl   $0xc010658b,(%esp)
c010304b:	e8 c8 db ff ff       	call   c0100c18 <__panic>

    unsigned int nr_free_store = nr_free;
c0103050:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c0103055:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0103058:	c7 05 18 af 11 c0 00 	movl   $0x0,0xc011af18
c010305f:	00 00 00 

    assert(alloc_page() == NULL);
c0103062:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103069:	e8 73 0c 00 00       	call   c0103ce1 <alloc_pages>
c010306e:	85 c0                	test   %eax,%eax
c0103070:	74 24                	je     c0103096 <basic_check+0x2b5>
c0103072:	c7 44 24 0c fe 66 10 	movl   $0xc01066fe,0xc(%esp)
c0103079:	c0 
c010307a:	c7 44 24 08 76 65 10 	movl   $0xc0106576,0x8(%esp)
c0103081:	c0 
c0103082:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
c0103089:	00 
c010308a:	c7 04 24 8b 65 10 c0 	movl   $0xc010658b,(%esp)
c0103091:	e8 82 db ff ff       	call   c0100c18 <__panic>

    free_page(p0);
c0103096:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010309d:	00 
c010309e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01030a1:	89 04 24             	mov    %eax,(%esp)
c01030a4:	e8 70 0c 00 00       	call   c0103d19 <free_pages>
    free_page(p1);
c01030a9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01030b0:	00 
c01030b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01030b4:	89 04 24             	mov    %eax,(%esp)
c01030b7:	e8 5d 0c 00 00       	call   c0103d19 <free_pages>
    free_page(p2);
c01030bc:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01030c3:	00 
c01030c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01030c7:	89 04 24             	mov    %eax,(%esp)
c01030ca:	e8 4a 0c 00 00       	call   c0103d19 <free_pages>
    assert(nr_free == 3);
c01030cf:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c01030d4:	83 f8 03             	cmp    $0x3,%eax
c01030d7:	74 24                	je     c01030fd <basic_check+0x31c>
c01030d9:	c7 44 24 0c 13 67 10 	movl   $0xc0106713,0xc(%esp)
c01030e0:	c0 
c01030e1:	c7 44 24 08 76 65 10 	movl   $0xc0106576,0x8(%esp)
c01030e8:	c0 
c01030e9:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
c01030f0:	00 
c01030f1:	c7 04 24 8b 65 10 c0 	movl   $0xc010658b,(%esp)
c01030f8:	e8 1b db ff ff       	call   c0100c18 <__panic>

    assert((p0 = alloc_page()) != NULL);
c01030fd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103104:	e8 d8 0b 00 00       	call   c0103ce1 <alloc_pages>
c0103109:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010310c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103110:	75 24                	jne    c0103136 <basic_check+0x355>
c0103112:	c7 44 24 0c d9 65 10 	movl   $0xc01065d9,0xc(%esp)
c0103119:	c0 
c010311a:	c7 44 24 08 76 65 10 	movl   $0xc0106576,0x8(%esp)
c0103121:	c0 
c0103122:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
c0103129:	00 
c010312a:	c7 04 24 8b 65 10 c0 	movl   $0xc010658b,(%esp)
c0103131:	e8 e2 da ff ff       	call   c0100c18 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0103136:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010313d:	e8 9f 0b 00 00       	call   c0103ce1 <alloc_pages>
c0103142:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103145:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103149:	75 24                	jne    c010316f <basic_check+0x38e>
c010314b:	c7 44 24 0c f5 65 10 	movl   $0xc01065f5,0xc(%esp)
c0103152:	c0 
c0103153:	c7 44 24 08 76 65 10 	movl   $0xc0106576,0x8(%esp)
c010315a:	c0 
c010315b:	c7 44 24 04 eb 00 00 	movl   $0xeb,0x4(%esp)
c0103162:	00 
c0103163:	c7 04 24 8b 65 10 c0 	movl   $0xc010658b,(%esp)
c010316a:	e8 a9 da ff ff       	call   c0100c18 <__panic>
    assert((p2 = alloc_page()) != NULL);
c010316f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103176:	e8 66 0b 00 00       	call   c0103ce1 <alloc_pages>
c010317b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010317e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103182:	75 24                	jne    c01031a8 <basic_check+0x3c7>
c0103184:	c7 44 24 0c 11 66 10 	movl   $0xc0106611,0xc(%esp)
c010318b:	c0 
c010318c:	c7 44 24 08 76 65 10 	movl   $0xc0106576,0x8(%esp)
c0103193:	c0 
c0103194:	c7 44 24 04 ec 00 00 	movl   $0xec,0x4(%esp)
c010319b:	00 
c010319c:	c7 04 24 8b 65 10 c0 	movl   $0xc010658b,(%esp)
c01031a3:	e8 70 da ff ff       	call   c0100c18 <__panic>

    assert(alloc_page() == NULL);
c01031a8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01031af:	e8 2d 0b 00 00       	call   c0103ce1 <alloc_pages>
c01031b4:	85 c0                	test   %eax,%eax
c01031b6:	74 24                	je     c01031dc <basic_check+0x3fb>
c01031b8:	c7 44 24 0c fe 66 10 	movl   $0xc01066fe,0xc(%esp)
c01031bf:	c0 
c01031c0:	c7 44 24 08 76 65 10 	movl   $0xc0106576,0x8(%esp)
c01031c7:	c0 
c01031c8:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
c01031cf:	00 
c01031d0:	c7 04 24 8b 65 10 c0 	movl   $0xc010658b,(%esp)
c01031d7:	e8 3c da ff ff       	call   c0100c18 <__panic>

    free_page(p0);
c01031dc:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01031e3:	00 
c01031e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01031e7:	89 04 24             	mov    %eax,(%esp)
c01031ea:	e8 2a 0b 00 00       	call   c0103d19 <free_pages>
c01031ef:	c7 45 d8 10 af 11 c0 	movl   $0xc011af10,-0x28(%ebp)
c01031f6:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01031f9:	8b 40 04             	mov    0x4(%eax),%eax
c01031fc:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c01031ff:	0f 94 c0             	sete   %al
c0103202:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0103205:	85 c0                	test   %eax,%eax
c0103207:	74 24                	je     c010322d <basic_check+0x44c>
c0103209:	c7 44 24 0c 20 67 10 	movl   $0xc0106720,0xc(%esp)
c0103210:	c0 
c0103211:	c7 44 24 08 76 65 10 	movl   $0xc0106576,0x8(%esp)
c0103218:	c0 
c0103219:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
c0103220:	00 
c0103221:	c7 04 24 8b 65 10 c0 	movl   $0xc010658b,(%esp)
c0103228:	e8 eb d9 ff ff       	call   c0100c18 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c010322d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103234:	e8 a8 0a 00 00       	call   c0103ce1 <alloc_pages>
c0103239:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010323c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010323f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103242:	74 24                	je     c0103268 <basic_check+0x487>
c0103244:	c7 44 24 0c 38 67 10 	movl   $0xc0106738,0xc(%esp)
c010324b:	c0 
c010324c:	c7 44 24 08 76 65 10 	movl   $0xc0106576,0x8(%esp)
c0103253:	c0 
c0103254:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
c010325b:	00 
c010325c:	c7 04 24 8b 65 10 c0 	movl   $0xc010658b,(%esp)
c0103263:	e8 b0 d9 ff ff       	call   c0100c18 <__panic>
    assert(alloc_page() == NULL);
c0103268:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010326f:	e8 6d 0a 00 00       	call   c0103ce1 <alloc_pages>
c0103274:	85 c0                	test   %eax,%eax
c0103276:	74 24                	je     c010329c <basic_check+0x4bb>
c0103278:	c7 44 24 0c fe 66 10 	movl   $0xc01066fe,0xc(%esp)
c010327f:	c0 
c0103280:	c7 44 24 08 76 65 10 	movl   $0xc0106576,0x8(%esp)
c0103287:	c0 
c0103288:	c7 44 24 04 f5 00 00 	movl   $0xf5,0x4(%esp)
c010328f:	00 
c0103290:	c7 04 24 8b 65 10 c0 	movl   $0xc010658b,(%esp)
c0103297:	e8 7c d9 ff ff       	call   c0100c18 <__panic>

    assert(nr_free == 0);
c010329c:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c01032a1:	85 c0                	test   %eax,%eax
c01032a3:	74 24                	je     c01032c9 <basic_check+0x4e8>
c01032a5:	c7 44 24 0c 51 67 10 	movl   $0xc0106751,0xc(%esp)
c01032ac:	c0 
c01032ad:	c7 44 24 08 76 65 10 	movl   $0xc0106576,0x8(%esp)
c01032b4:	c0 
c01032b5:	c7 44 24 04 f7 00 00 	movl   $0xf7,0x4(%esp)
c01032bc:	00 
c01032bd:	c7 04 24 8b 65 10 c0 	movl   $0xc010658b,(%esp)
c01032c4:	e8 4f d9 ff ff       	call   c0100c18 <__panic>
    free_list = free_list_store;
c01032c9:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01032cc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01032cf:	a3 10 af 11 c0       	mov    %eax,0xc011af10
c01032d4:	89 15 14 af 11 c0    	mov    %edx,0xc011af14
    nr_free = nr_free_store;
c01032da:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01032dd:	a3 18 af 11 c0       	mov    %eax,0xc011af18

    free_page(p);
c01032e2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01032e9:	00 
c01032ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01032ed:	89 04 24             	mov    %eax,(%esp)
c01032f0:	e8 24 0a 00 00       	call   c0103d19 <free_pages>
    free_page(p1);
c01032f5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01032fc:	00 
c01032fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103300:	89 04 24             	mov    %eax,(%esp)
c0103303:	e8 11 0a 00 00       	call   c0103d19 <free_pages>
    free_page(p2);
c0103308:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010330f:	00 
c0103310:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103313:	89 04 24             	mov    %eax,(%esp)
c0103316:	e8 fe 09 00 00       	call   c0103d19 <free_pages>
}
c010331b:	c9                   	leave  
c010331c:	c3                   	ret    

c010331d <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c010331d:	55                   	push   %ebp
c010331e:	89 e5                	mov    %esp,%ebp
c0103320:	53                   	push   %ebx
c0103321:	81 ec 94 00 00 00    	sub    $0x94,%esp
    int count = 0, total = 0;
c0103327:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010332e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0103335:	c7 45 ec 10 af 11 c0 	movl   $0xc011af10,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c010333c:	eb 6b                	jmp    c01033a9 <default_check+0x8c>
        struct Page *p = le2page(le, page_link);
c010333e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103341:	83 e8 0c             	sub    $0xc,%eax
c0103344:	89 45 e8             	mov    %eax,-0x18(%ebp)
        assert(PageProperty(p));
c0103347:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010334a:	83 c0 04             	add    $0x4,%eax
c010334d:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0103354:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103357:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010335a:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010335d:	0f a3 10             	bt     %edx,(%eax)
c0103360:	19 c0                	sbb    %eax,%eax
c0103362:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c0103365:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0103369:	0f 95 c0             	setne  %al
c010336c:	0f b6 c0             	movzbl %al,%eax
c010336f:	85 c0                	test   %eax,%eax
c0103371:	75 24                	jne    c0103397 <default_check+0x7a>
c0103373:	c7 44 24 0c 5e 67 10 	movl   $0xc010675e,0xc(%esp)
c010337a:	c0 
c010337b:	c7 44 24 08 76 65 10 	movl   $0xc0106576,0x8(%esp)
c0103382:	c0 
c0103383:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
c010338a:	00 
c010338b:	c7 04 24 8b 65 10 c0 	movl   $0xc010658b,(%esp)
c0103392:	e8 81 d8 ff ff       	call   c0100c18 <__panic>
        count ++, total += p->property;
c0103397:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010339b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010339e:	8b 50 08             	mov    0x8(%eax),%edx
c01033a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01033a4:	01 d0                	add    %edx,%eax
c01033a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01033a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01033ac:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01033af:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01033b2:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c01033b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01033b8:	81 7d ec 10 af 11 c0 	cmpl   $0xc011af10,-0x14(%ebp)
c01033bf:	0f 85 79 ff ff ff    	jne    c010333e <default_check+0x21>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
c01033c5:	8b 5d f0             	mov    -0x10(%ebp),%ebx
c01033c8:	e8 7e 09 00 00       	call   c0103d4b <nr_free_pages>
c01033cd:	39 c3                	cmp    %eax,%ebx
c01033cf:	74 24                	je     c01033f5 <default_check+0xd8>
c01033d1:	c7 44 24 0c 6e 67 10 	movl   $0xc010676e,0xc(%esp)
c01033d8:	c0 
c01033d9:	c7 44 24 08 76 65 10 	movl   $0xc0106576,0x8(%esp)
c01033e0:	c0 
c01033e1:	c7 44 24 04 0b 01 00 	movl   $0x10b,0x4(%esp)
c01033e8:	00 
c01033e9:	c7 04 24 8b 65 10 c0 	movl   $0xc010658b,(%esp)
c01033f0:	e8 23 d8 ff ff       	call   c0100c18 <__panic>

    basic_check();
c01033f5:	e8 e7 f9 ff ff       	call   c0102de1 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c01033fa:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0103401:	e8 db 08 00 00       	call   c0103ce1 <alloc_pages>
c0103406:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(p0 != NULL);
c0103409:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010340d:	75 24                	jne    c0103433 <default_check+0x116>
c010340f:	c7 44 24 0c 87 67 10 	movl   $0xc0106787,0xc(%esp)
c0103416:	c0 
c0103417:	c7 44 24 08 76 65 10 	movl   $0xc0106576,0x8(%esp)
c010341e:	c0 
c010341f:	c7 44 24 04 10 01 00 	movl   $0x110,0x4(%esp)
c0103426:	00 
c0103427:	c7 04 24 8b 65 10 c0 	movl   $0xc010658b,(%esp)
c010342e:	e8 e5 d7 ff ff       	call   c0100c18 <__panic>
    assert(!PageProperty(p0));
c0103433:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103436:	83 c0 04             	add    $0x4,%eax
c0103439:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0103440:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103443:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0103446:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0103449:	0f a3 10             	bt     %edx,(%eax)
c010344c:	19 c0                	sbb    %eax,%eax
c010344e:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c0103451:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0103455:	0f 95 c0             	setne  %al
c0103458:	0f b6 c0             	movzbl %al,%eax
c010345b:	85 c0                	test   %eax,%eax
c010345d:	74 24                	je     c0103483 <default_check+0x166>
c010345f:	c7 44 24 0c 92 67 10 	movl   $0xc0106792,0xc(%esp)
c0103466:	c0 
c0103467:	c7 44 24 08 76 65 10 	movl   $0xc0106576,0x8(%esp)
c010346e:	c0 
c010346f:	c7 44 24 04 11 01 00 	movl   $0x111,0x4(%esp)
c0103476:	00 
c0103477:	c7 04 24 8b 65 10 c0 	movl   $0xc010658b,(%esp)
c010347e:	e8 95 d7 ff ff       	call   c0100c18 <__panic>

    list_entry_t free_list_store = free_list;
c0103483:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c0103488:	8b 15 14 af 11 c0    	mov    0xc011af14,%edx
c010348e:	89 45 80             	mov    %eax,-0x80(%ebp)
c0103491:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0103494:	c7 45 b4 10 af 11 c0 	movl   $0xc011af10,-0x4c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010349b:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010349e:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01034a1:	89 50 04             	mov    %edx,0x4(%eax)
c01034a4:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01034a7:	8b 50 04             	mov    0x4(%eax),%edx
c01034aa:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01034ad:	89 10                	mov    %edx,(%eax)
c01034af:	c7 45 b0 10 af 11 c0 	movl   $0xc011af10,-0x50(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c01034b6:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01034b9:	8b 40 04             	mov    0x4(%eax),%eax
c01034bc:	39 45 b0             	cmp    %eax,-0x50(%ebp)
c01034bf:	0f 94 c0             	sete   %al
c01034c2:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c01034c5:	85 c0                	test   %eax,%eax
c01034c7:	75 24                	jne    c01034ed <default_check+0x1d0>
c01034c9:	c7 44 24 0c e7 66 10 	movl   $0xc01066e7,0xc(%esp)
c01034d0:	c0 
c01034d1:	c7 44 24 08 76 65 10 	movl   $0xc0106576,0x8(%esp)
c01034d8:	c0 
c01034d9:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c01034e0:	00 
c01034e1:	c7 04 24 8b 65 10 c0 	movl   $0xc010658b,(%esp)
c01034e8:	e8 2b d7 ff ff       	call   c0100c18 <__panic>
    assert(alloc_page() == NULL);
c01034ed:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01034f4:	e8 e8 07 00 00       	call   c0103ce1 <alloc_pages>
c01034f9:	85 c0                	test   %eax,%eax
c01034fb:	74 24                	je     c0103521 <default_check+0x204>
c01034fd:	c7 44 24 0c fe 66 10 	movl   $0xc01066fe,0xc(%esp)
c0103504:	c0 
c0103505:	c7 44 24 08 76 65 10 	movl   $0xc0106576,0x8(%esp)
c010350c:	c0 
c010350d:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c0103514:	00 
c0103515:	c7 04 24 8b 65 10 c0 	movl   $0xc010658b,(%esp)
c010351c:	e8 f7 d6 ff ff       	call   c0100c18 <__panic>

    unsigned int nr_free_store = nr_free;
c0103521:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c0103526:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
c0103529:	c7 05 18 af 11 c0 00 	movl   $0x0,0xc011af18
c0103530:	00 00 00 

    free_pages(p0 + 2, 3);
c0103533:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103536:	83 c0 28             	add    $0x28,%eax
c0103539:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0103540:	00 
c0103541:	89 04 24             	mov    %eax,(%esp)
c0103544:	e8 d0 07 00 00       	call   c0103d19 <free_pages>
    assert(alloc_pages(4) == NULL);
c0103549:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0103550:	e8 8c 07 00 00       	call   c0103ce1 <alloc_pages>
c0103555:	85 c0                	test   %eax,%eax
c0103557:	74 24                	je     c010357d <default_check+0x260>
c0103559:	c7 44 24 0c a4 67 10 	movl   $0xc01067a4,0xc(%esp)
c0103560:	c0 
c0103561:	c7 44 24 08 76 65 10 	movl   $0xc0106576,0x8(%esp)
c0103568:	c0 
c0103569:	c7 44 24 04 1c 01 00 	movl   $0x11c,0x4(%esp)
c0103570:	00 
c0103571:	c7 04 24 8b 65 10 c0 	movl   $0xc010658b,(%esp)
c0103578:	e8 9b d6 ff ff       	call   c0100c18 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c010357d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103580:	83 c0 28             	add    $0x28,%eax
c0103583:	83 c0 04             	add    $0x4,%eax
c0103586:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c010358d:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103590:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0103593:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0103596:	0f a3 10             	bt     %edx,(%eax)
c0103599:	19 c0                	sbb    %eax,%eax
c010359b:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c010359e:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c01035a2:	0f 95 c0             	setne  %al
c01035a5:	0f b6 c0             	movzbl %al,%eax
c01035a8:	85 c0                	test   %eax,%eax
c01035aa:	74 0e                	je     c01035ba <default_check+0x29d>
c01035ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01035af:	83 c0 28             	add    $0x28,%eax
c01035b2:	8b 40 08             	mov    0x8(%eax),%eax
c01035b5:	83 f8 03             	cmp    $0x3,%eax
c01035b8:	74 24                	je     c01035de <default_check+0x2c1>
c01035ba:	c7 44 24 0c bc 67 10 	movl   $0xc01067bc,0xc(%esp)
c01035c1:	c0 
c01035c2:	c7 44 24 08 76 65 10 	movl   $0xc0106576,0x8(%esp)
c01035c9:	c0 
c01035ca:	c7 44 24 04 1d 01 00 	movl   $0x11d,0x4(%esp)
c01035d1:	00 
c01035d2:	c7 04 24 8b 65 10 c0 	movl   $0xc010658b,(%esp)
c01035d9:	e8 3a d6 ff ff       	call   c0100c18 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c01035de:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c01035e5:	e8 f7 06 00 00       	call   c0103ce1 <alloc_pages>
c01035ea:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01035ed:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01035f1:	75 24                	jne    c0103617 <default_check+0x2fa>
c01035f3:	c7 44 24 0c e8 67 10 	movl   $0xc01067e8,0xc(%esp)
c01035fa:	c0 
c01035fb:	c7 44 24 08 76 65 10 	movl   $0xc0106576,0x8(%esp)
c0103602:	c0 
c0103603:	c7 44 24 04 1e 01 00 	movl   $0x11e,0x4(%esp)
c010360a:	00 
c010360b:	c7 04 24 8b 65 10 c0 	movl   $0xc010658b,(%esp)
c0103612:	e8 01 d6 ff ff       	call   c0100c18 <__panic>
    assert(alloc_page() == NULL);
c0103617:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010361e:	e8 be 06 00 00       	call   c0103ce1 <alloc_pages>
c0103623:	85 c0                	test   %eax,%eax
c0103625:	74 24                	je     c010364b <default_check+0x32e>
c0103627:	c7 44 24 0c fe 66 10 	movl   $0xc01066fe,0xc(%esp)
c010362e:	c0 
c010362f:	c7 44 24 08 76 65 10 	movl   $0xc0106576,0x8(%esp)
c0103636:	c0 
c0103637:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
c010363e:	00 
c010363f:	c7 04 24 8b 65 10 c0 	movl   $0xc010658b,(%esp)
c0103646:	e8 cd d5 ff ff       	call   c0100c18 <__panic>
    assert(p0 + 2 == p1);
c010364b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010364e:	83 c0 28             	add    $0x28,%eax
c0103651:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0103654:	74 24                	je     c010367a <default_check+0x35d>
c0103656:	c7 44 24 0c 06 68 10 	movl   $0xc0106806,0xc(%esp)
c010365d:	c0 
c010365e:	c7 44 24 08 76 65 10 	movl   $0xc0106576,0x8(%esp)
c0103665:	c0 
c0103666:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
c010366d:	00 
c010366e:	c7 04 24 8b 65 10 c0 	movl   $0xc010658b,(%esp)
c0103675:	e8 9e d5 ff ff       	call   c0100c18 <__panic>

    p2 = p0 + 1;
c010367a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010367d:	83 c0 14             	add    $0x14,%eax
c0103680:	89 45 d8             	mov    %eax,-0x28(%ebp)
    free_page(p0);
c0103683:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010368a:	00 
c010368b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010368e:	89 04 24             	mov    %eax,(%esp)
c0103691:	e8 83 06 00 00       	call   c0103d19 <free_pages>
    free_pages(p1, 3);
c0103696:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c010369d:	00 
c010369e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01036a1:	89 04 24             	mov    %eax,(%esp)
c01036a4:	e8 70 06 00 00       	call   c0103d19 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c01036a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01036ac:	83 c0 04             	add    $0x4,%eax
c01036af:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c01036b6:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01036b9:	8b 45 9c             	mov    -0x64(%ebp),%eax
c01036bc:	8b 55 a0             	mov    -0x60(%ebp),%edx
c01036bf:	0f a3 10             	bt     %edx,(%eax)
c01036c2:	19 c0                	sbb    %eax,%eax
c01036c4:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c01036c7:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c01036cb:	0f 95 c0             	setne  %al
c01036ce:	0f b6 c0             	movzbl %al,%eax
c01036d1:	85 c0                	test   %eax,%eax
c01036d3:	74 0b                	je     c01036e0 <default_check+0x3c3>
c01036d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01036d8:	8b 40 08             	mov    0x8(%eax),%eax
c01036db:	83 f8 01             	cmp    $0x1,%eax
c01036de:	74 24                	je     c0103704 <default_check+0x3e7>
c01036e0:	c7 44 24 0c 14 68 10 	movl   $0xc0106814,0xc(%esp)
c01036e7:	c0 
c01036e8:	c7 44 24 08 76 65 10 	movl   $0xc0106576,0x8(%esp)
c01036ef:	c0 
c01036f0:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
c01036f7:	00 
c01036f8:	c7 04 24 8b 65 10 c0 	movl   $0xc010658b,(%esp)
c01036ff:	e8 14 d5 ff ff       	call   c0100c18 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c0103704:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103707:	83 c0 04             	add    $0x4,%eax
c010370a:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c0103711:	89 45 90             	mov    %eax,-0x70(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103714:	8b 45 90             	mov    -0x70(%ebp),%eax
c0103717:	8b 55 94             	mov    -0x6c(%ebp),%edx
c010371a:	0f a3 10             	bt     %edx,(%eax)
c010371d:	19 c0                	sbb    %eax,%eax
c010371f:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c0103722:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c0103726:	0f 95 c0             	setne  %al
c0103729:	0f b6 c0             	movzbl %al,%eax
c010372c:	85 c0                	test   %eax,%eax
c010372e:	74 0b                	je     c010373b <default_check+0x41e>
c0103730:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103733:	8b 40 08             	mov    0x8(%eax),%eax
c0103736:	83 f8 03             	cmp    $0x3,%eax
c0103739:	74 24                	je     c010375f <default_check+0x442>
c010373b:	c7 44 24 0c 3c 68 10 	movl   $0xc010683c,0xc(%esp)
c0103742:	c0 
c0103743:	c7 44 24 08 76 65 10 	movl   $0xc0106576,0x8(%esp)
c010374a:	c0 
c010374b:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
c0103752:	00 
c0103753:	c7 04 24 8b 65 10 c0 	movl   $0xc010658b,(%esp)
c010375a:	e8 b9 d4 ff ff       	call   c0100c18 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c010375f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103766:	e8 76 05 00 00       	call   c0103ce1 <alloc_pages>
c010376b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010376e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103771:	83 e8 14             	sub    $0x14,%eax
c0103774:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0103777:	74 24                	je     c010379d <default_check+0x480>
c0103779:	c7 44 24 0c 62 68 10 	movl   $0xc0106862,0xc(%esp)
c0103780:	c0 
c0103781:	c7 44 24 08 76 65 10 	movl   $0xc0106576,0x8(%esp)
c0103788:	c0 
c0103789:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
c0103790:	00 
c0103791:	c7 04 24 8b 65 10 c0 	movl   $0xc010658b,(%esp)
c0103798:	e8 7b d4 ff ff       	call   c0100c18 <__panic>
    free_page(p0);
c010379d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01037a4:	00 
c01037a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01037a8:	89 04 24             	mov    %eax,(%esp)
c01037ab:	e8 69 05 00 00       	call   c0103d19 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c01037b0:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c01037b7:	e8 25 05 00 00       	call   c0103ce1 <alloc_pages>
c01037bc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01037bf:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01037c2:	83 c0 14             	add    $0x14,%eax
c01037c5:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c01037c8:	74 24                	je     c01037ee <default_check+0x4d1>
c01037ca:	c7 44 24 0c 80 68 10 	movl   $0xc0106880,0xc(%esp)
c01037d1:	c0 
c01037d2:	c7 44 24 08 76 65 10 	movl   $0xc0106576,0x8(%esp)
c01037d9:	c0 
c01037da:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
c01037e1:	00 
c01037e2:	c7 04 24 8b 65 10 c0 	movl   $0xc010658b,(%esp)
c01037e9:	e8 2a d4 ff ff       	call   c0100c18 <__panic>

    free_pages(p0, 2);
c01037ee:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c01037f5:	00 
c01037f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01037f9:	89 04 24             	mov    %eax,(%esp)
c01037fc:	e8 18 05 00 00       	call   c0103d19 <free_pages>
    free_page(p2);
c0103801:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103808:	00 
c0103809:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010380c:	89 04 24             	mov    %eax,(%esp)
c010380f:	e8 05 05 00 00       	call   c0103d19 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c0103814:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c010381b:	e8 c1 04 00 00       	call   c0103ce1 <alloc_pages>
c0103820:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103823:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103827:	75 24                	jne    c010384d <default_check+0x530>
c0103829:	c7 44 24 0c a0 68 10 	movl   $0xc01068a0,0xc(%esp)
c0103830:	c0 
c0103831:	c7 44 24 08 76 65 10 	movl   $0xc0106576,0x8(%esp)
c0103838:	c0 
c0103839:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
c0103840:	00 
c0103841:	c7 04 24 8b 65 10 c0 	movl   $0xc010658b,(%esp)
c0103848:	e8 cb d3 ff ff       	call   c0100c18 <__panic>
    assert(alloc_page() == NULL);
c010384d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103854:	e8 88 04 00 00       	call   c0103ce1 <alloc_pages>
c0103859:	85 c0                	test   %eax,%eax
c010385b:	74 24                	je     c0103881 <default_check+0x564>
c010385d:	c7 44 24 0c fe 66 10 	movl   $0xc01066fe,0xc(%esp)
c0103864:	c0 
c0103865:	c7 44 24 08 76 65 10 	movl   $0xc0106576,0x8(%esp)
c010386c:	c0 
c010386d:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
c0103874:	00 
c0103875:	c7 04 24 8b 65 10 c0 	movl   $0xc010658b,(%esp)
c010387c:	e8 97 d3 ff ff       	call   c0100c18 <__panic>

    assert(nr_free == 0);
c0103881:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c0103886:	85 c0                	test   %eax,%eax
c0103888:	74 24                	je     c01038ae <default_check+0x591>
c010388a:	c7 44 24 0c 51 67 10 	movl   $0xc0106751,0xc(%esp)
c0103891:	c0 
c0103892:	c7 44 24 08 76 65 10 	movl   $0xc0106576,0x8(%esp)
c0103899:	c0 
c010389a:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
c01038a1:	00 
c01038a2:	c7 04 24 8b 65 10 c0 	movl   $0xc010658b,(%esp)
c01038a9:	e8 6a d3 ff ff       	call   c0100c18 <__panic>
    nr_free = nr_free_store;
c01038ae:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01038b1:	a3 18 af 11 c0       	mov    %eax,0xc011af18

    free_list = free_list_store;
c01038b6:	8b 45 80             	mov    -0x80(%ebp),%eax
c01038b9:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01038bc:	a3 10 af 11 c0       	mov    %eax,0xc011af10
c01038c1:	89 15 14 af 11 c0    	mov    %edx,0xc011af14
    free_pages(p0, 5);
c01038c7:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c01038ce:	00 
c01038cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01038d2:	89 04 24             	mov    %eax,(%esp)
c01038d5:	e8 3f 04 00 00       	call   c0103d19 <free_pages>

    le = &free_list;
c01038da:	c7 45 ec 10 af 11 c0 	movl   $0xc011af10,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c01038e1:	eb 5b                	jmp    c010393e <default_check+0x621>
        assert(le->next->prev == le && le->prev->next == le);
c01038e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01038e6:	8b 40 04             	mov    0x4(%eax),%eax
c01038e9:	8b 00                	mov    (%eax),%eax
c01038eb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01038ee:	75 0d                	jne    c01038fd <default_check+0x5e0>
c01038f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01038f3:	8b 00                	mov    (%eax),%eax
c01038f5:	8b 40 04             	mov    0x4(%eax),%eax
c01038f8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01038fb:	74 24                	je     c0103921 <default_check+0x604>
c01038fd:	c7 44 24 0c c0 68 10 	movl   $0xc01068c0,0xc(%esp)
c0103904:	c0 
c0103905:	c7 44 24 08 76 65 10 	movl   $0xc0106576,0x8(%esp)
c010390c:	c0 
c010390d:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
c0103914:	00 
c0103915:	c7 04 24 8b 65 10 c0 	movl   $0xc010658b,(%esp)
c010391c:	e8 f7 d2 ff ff       	call   c0100c18 <__panic>
        struct Page *p = le2page(le, page_link);
c0103921:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103924:	83 e8 0c             	sub    $0xc,%eax
c0103927:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        count --, total -= p->property;
c010392a:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c010392e:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0103931:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103934:	8b 40 08             	mov    0x8(%eax),%eax
c0103937:	29 c2                	sub    %eax,%edx
c0103939:	89 d0                	mov    %edx,%eax
c010393b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010393e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103941:	89 45 88             	mov    %eax,-0x78(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0103944:	8b 45 88             	mov    -0x78(%ebp),%eax
c0103947:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c010394a:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010394d:	81 7d ec 10 af 11 c0 	cmpl   $0xc011af10,-0x14(%ebp)
c0103954:	75 8d                	jne    c01038e3 <default_check+0x5c6>
        assert(le->next->prev == le && le->prev->next == le);
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
c0103956:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010395a:	74 24                	je     c0103980 <default_check+0x663>
c010395c:	c7 44 24 0c ed 68 10 	movl   $0xc01068ed,0xc(%esp)
c0103963:	c0 
c0103964:	c7 44 24 08 76 65 10 	movl   $0xc0106576,0x8(%esp)
c010396b:	c0 
c010396c:	c7 44 24 04 3e 01 00 	movl   $0x13e,0x4(%esp)
c0103973:	00 
c0103974:	c7 04 24 8b 65 10 c0 	movl   $0xc010658b,(%esp)
c010397b:	e8 98 d2 ff ff       	call   c0100c18 <__panic>
    assert(total == 0);
c0103980:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103984:	74 24                	je     c01039aa <default_check+0x68d>
c0103986:	c7 44 24 0c f8 68 10 	movl   $0xc01068f8,0xc(%esp)
c010398d:	c0 
c010398e:	c7 44 24 08 76 65 10 	movl   $0xc0106576,0x8(%esp)
c0103995:	c0 
c0103996:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
c010399d:	00 
c010399e:	c7 04 24 8b 65 10 c0 	movl   $0xc010658b,(%esp)
c01039a5:	e8 6e d2 ff ff       	call   c0100c18 <__panic>
}
c01039aa:	81 c4 94 00 00 00    	add    $0x94,%esp
c01039b0:	5b                   	pop    %ebx
c01039b1:	5d                   	pop    %ebp
c01039b2:	c3                   	ret    

c01039b3 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c01039b3:	55                   	push   %ebp
c01039b4:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01039b6:	8b 55 08             	mov    0x8(%ebp),%edx
c01039b9:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c01039be:	29 c2                	sub    %eax,%edx
c01039c0:	89 d0                	mov    %edx,%eax
c01039c2:	c1 f8 02             	sar    $0x2,%eax
c01039c5:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c01039cb:	5d                   	pop    %ebp
c01039cc:	c3                   	ret    

c01039cd <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c01039cd:	55                   	push   %ebp
c01039ce:	89 e5                	mov    %esp,%ebp
c01039d0:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01039d3:	8b 45 08             	mov    0x8(%ebp),%eax
c01039d6:	89 04 24             	mov    %eax,(%esp)
c01039d9:	e8 d5 ff ff ff       	call   c01039b3 <page2ppn>
c01039de:	c1 e0 0c             	shl    $0xc,%eax
}
c01039e1:	c9                   	leave  
c01039e2:	c3                   	ret    

c01039e3 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c01039e3:	55                   	push   %ebp
c01039e4:	89 e5                	mov    %esp,%ebp
c01039e6:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c01039e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01039ec:	c1 e8 0c             	shr    $0xc,%eax
c01039ef:	89 c2                	mov    %eax,%edx
c01039f1:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c01039f6:	39 c2                	cmp    %eax,%edx
c01039f8:	72 1c                	jb     c0103a16 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c01039fa:	c7 44 24 08 34 69 10 	movl   $0xc0106934,0x8(%esp)
c0103a01:	c0 
c0103a02:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
c0103a09:	00 
c0103a0a:	c7 04 24 53 69 10 c0 	movl   $0xc0106953,(%esp)
c0103a11:	e8 02 d2 ff ff       	call   c0100c18 <__panic>
    }
    return &pages[PPN(pa)];
c0103a16:	8b 0d 24 af 11 c0    	mov    0xc011af24,%ecx
c0103a1c:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a1f:	c1 e8 0c             	shr    $0xc,%eax
c0103a22:	89 c2                	mov    %eax,%edx
c0103a24:	89 d0                	mov    %edx,%eax
c0103a26:	c1 e0 02             	shl    $0x2,%eax
c0103a29:	01 d0                	add    %edx,%eax
c0103a2b:	c1 e0 02             	shl    $0x2,%eax
c0103a2e:	01 c8                	add    %ecx,%eax
}
c0103a30:	c9                   	leave  
c0103a31:	c3                   	ret    

c0103a32 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0103a32:	55                   	push   %ebp
c0103a33:	89 e5                	mov    %esp,%ebp
c0103a35:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0103a38:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a3b:	89 04 24             	mov    %eax,(%esp)
c0103a3e:	e8 8a ff ff ff       	call   c01039cd <page2pa>
c0103a43:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103a46:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a49:	c1 e8 0c             	shr    $0xc,%eax
c0103a4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103a4f:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0103a54:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0103a57:	72 23                	jb     c0103a7c <page2kva+0x4a>
c0103a59:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a5c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103a60:	c7 44 24 08 64 69 10 	movl   $0xc0106964,0x8(%esp)
c0103a67:	c0 
c0103a68:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
c0103a6f:	00 
c0103a70:	c7 04 24 53 69 10 c0 	movl   $0xc0106953,(%esp)
c0103a77:	e8 9c d1 ff ff       	call   c0100c18 <__panic>
c0103a7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a7f:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0103a84:	c9                   	leave  
c0103a85:	c3                   	ret    

c0103a86 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c0103a86:	55                   	push   %ebp
c0103a87:	89 e5                	mov    %esp,%ebp
c0103a89:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0103a8c:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a8f:	83 e0 01             	and    $0x1,%eax
c0103a92:	85 c0                	test   %eax,%eax
c0103a94:	75 1c                	jne    c0103ab2 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0103a96:	c7 44 24 08 88 69 10 	movl   $0xc0106988,0x8(%esp)
c0103a9d:	c0 
c0103a9e:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c0103aa5:	00 
c0103aa6:	c7 04 24 53 69 10 c0 	movl   $0xc0106953,(%esp)
c0103aad:	e8 66 d1 ff ff       	call   c0100c18 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0103ab2:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ab5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103aba:	89 04 24             	mov    %eax,(%esp)
c0103abd:	e8 21 ff ff ff       	call   c01039e3 <pa2page>
}
c0103ac2:	c9                   	leave  
c0103ac3:	c3                   	ret    

c0103ac4 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c0103ac4:	55                   	push   %ebp
c0103ac5:	89 e5                	mov    %esp,%ebp
c0103ac7:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0103aca:	8b 45 08             	mov    0x8(%ebp),%eax
c0103acd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103ad2:	89 04 24             	mov    %eax,(%esp)
c0103ad5:	e8 09 ff ff ff       	call   c01039e3 <pa2page>
}
c0103ada:	c9                   	leave  
c0103adb:	c3                   	ret    

c0103adc <page_ref>:

static inline int
page_ref(struct Page *page) {
c0103adc:	55                   	push   %ebp
c0103add:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0103adf:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ae2:	8b 00                	mov    (%eax),%eax
}
c0103ae4:	5d                   	pop    %ebp
c0103ae5:	c3                   	ret    

c0103ae6 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0103ae6:	55                   	push   %ebp
c0103ae7:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0103ae9:	8b 45 08             	mov    0x8(%ebp),%eax
c0103aec:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103aef:	89 10                	mov    %edx,(%eax)
}
c0103af1:	5d                   	pop    %ebp
c0103af2:	c3                   	ret    

c0103af3 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0103af3:	55                   	push   %ebp
c0103af4:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0103af6:	8b 45 08             	mov    0x8(%ebp),%eax
c0103af9:	8b 00                	mov    (%eax),%eax
c0103afb:	8d 50 01             	lea    0x1(%eax),%edx
c0103afe:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b01:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0103b03:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b06:	8b 00                	mov    (%eax),%eax
}
c0103b08:	5d                   	pop    %ebp
c0103b09:	c3                   	ret    

c0103b0a <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0103b0a:	55                   	push   %ebp
c0103b0b:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0103b0d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b10:	8b 00                	mov    (%eax),%eax
c0103b12:	8d 50 ff             	lea    -0x1(%eax),%edx
c0103b15:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b18:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0103b1a:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b1d:	8b 00                	mov    (%eax),%eax
}
c0103b1f:	5d                   	pop    %ebp
c0103b20:	c3                   	ret    

c0103b21 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0103b21:	55                   	push   %ebp
c0103b22:	89 e5                	mov    %esp,%ebp
c0103b24:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0103b27:	9c                   	pushf  
c0103b28:	58                   	pop    %eax
c0103b29:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0103b2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0103b2f:	25 00 02 00 00       	and    $0x200,%eax
c0103b34:	85 c0                	test   %eax,%eax
c0103b36:	74 0c                	je     c0103b44 <__intr_save+0x23>
        intr_disable();
c0103b38:	e8 cf da ff ff       	call   c010160c <intr_disable>
        return 1;
c0103b3d:	b8 01 00 00 00       	mov    $0x1,%eax
c0103b42:	eb 05                	jmp    c0103b49 <__intr_save+0x28>
    }
    return 0;
c0103b44:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103b49:	c9                   	leave  
c0103b4a:	c3                   	ret    

c0103b4b <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0103b4b:	55                   	push   %ebp
c0103b4c:	89 e5                	mov    %esp,%ebp
c0103b4e:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0103b51:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0103b55:	74 05                	je     c0103b5c <__intr_restore+0x11>
        intr_enable();
c0103b57:	e8 aa da ff ff       	call   c0101606 <intr_enable>
    }
}
c0103b5c:	c9                   	leave  
c0103b5d:	c3                   	ret    

c0103b5e <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0103b5e:	55                   	push   %ebp
c0103b5f:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0103b61:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b64:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0103b67:	b8 23 00 00 00       	mov    $0x23,%eax
c0103b6c:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0103b6e:	b8 23 00 00 00       	mov    $0x23,%eax
c0103b73:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0103b75:	b8 10 00 00 00       	mov    $0x10,%eax
c0103b7a:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0103b7c:	b8 10 00 00 00       	mov    $0x10,%eax
c0103b81:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0103b83:	b8 10 00 00 00       	mov    $0x10,%eax
c0103b88:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0103b8a:	ea 91 3b 10 c0 08 00 	ljmp   $0x8,$0xc0103b91
}
c0103b91:	5d                   	pop    %ebp
c0103b92:	c3                   	ret    

c0103b93 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0103b93:	55                   	push   %ebp
c0103b94:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0103b96:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b99:	a3 a4 ae 11 c0       	mov    %eax,0xc011aea4
}
c0103b9e:	5d                   	pop    %ebp
c0103b9f:	c3                   	ret    

c0103ba0 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0103ba0:	55                   	push   %ebp
c0103ba1:	89 e5                	mov    %esp,%ebp
c0103ba3:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0103ba6:	b8 00 70 11 c0       	mov    $0xc0117000,%eax
c0103bab:	89 04 24             	mov    %eax,(%esp)
c0103bae:	e8 e0 ff ff ff       	call   c0103b93 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0103bb3:	66 c7 05 a8 ae 11 c0 	movw   $0x10,0xc011aea8
c0103bba:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0103bbc:	66 c7 05 28 7a 11 c0 	movw   $0x68,0xc0117a28
c0103bc3:	68 00 
c0103bc5:	b8 a0 ae 11 c0       	mov    $0xc011aea0,%eax
c0103bca:	66 a3 2a 7a 11 c0    	mov    %ax,0xc0117a2a
c0103bd0:	b8 a0 ae 11 c0       	mov    $0xc011aea0,%eax
c0103bd5:	c1 e8 10             	shr    $0x10,%eax
c0103bd8:	a2 2c 7a 11 c0       	mov    %al,0xc0117a2c
c0103bdd:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0103be4:	83 e0 f0             	and    $0xfffffff0,%eax
c0103be7:	83 c8 09             	or     $0x9,%eax
c0103bea:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0103bef:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0103bf6:	83 e0 ef             	and    $0xffffffef,%eax
c0103bf9:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0103bfe:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0103c05:	83 e0 9f             	and    $0xffffff9f,%eax
c0103c08:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0103c0d:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0103c14:	83 c8 80             	or     $0xffffff80,%eax
c0103c17:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0103c1c:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103c23:	83 e0 f0             	and    $0xfffffff0,%eax
c0103c26:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103c2b:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103c32:	83 e0 ef             	and    $0xffffffef,%eax
c0103c35:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103c3a:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103c41:	83 e0 df             	and    $0xffffffdf,%eax
c0103c44:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103c49:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103c50:	83 c8 40             	or     $0x40,%eax
c0103c53:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103c58:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103c5f:	83 e0 7f             	and    $0x7f,%eax
c0103c62:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103c67:	b8 a0 ae 11 c0       	mov    $0xc011aea0,%eax
c0103c6c:	c1 e8 18             	shr    $0x18,%eax
c0103c6f:	a2 2f 7a 11 c0       	mov    %al,0xc0117a2f

    // reload all segment registers
    lgdt(&gdt_pd);
c0103c74:	c7 04 24 30 7a 11 c0 	movl   $0xc0117a30,(%esp)
c0103c7b:	e8 de fe ff ff       	call   c0103b5e <lgdt>
c0103c80:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0103c86:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0103c8a:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c0103c8d:	c9                   	leave  
c0103c8e:	c3                   	ret    

c0103c8f <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0103c8f:	55                   	push   %ebp
c0103c90:	89 e5                	mov    %esp,%ebp
c0103c92:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c0103c95:	c7 05 1c af 11 c0 18 	movl   $0xc0106918,0xc011af1c
c0103c9c:	69 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0103c9f:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0103ca4:	8b 00                	mov    (%eax),%eax
c0103ca6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103caa:	c7 04 24 b4 69 10 c0 	movl   $0xc01069b4,(%esp)
c0103cb1:	e8 92 c6 ff ff       	call   c0100348 <cprintf>
    pmm_manager->init();
c0103cb6:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0103cbb:	8b 40 04             	mov    0x4(%eax),%eax
c0103cbe:	ff d0                	call   *%eax
}
c0103cc0:	c9                   	leave  
c0103cc1:	c3                   	ret    

c0103cc2 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0103cc2:	55                   	push   %ebp
c0103cc3:	89 e5                	mov    %esp,%ebp
c0103cc5:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0103cc8:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0103ccd:	8b 40 08             	mov    0x8(%eax),%eax
c0103cd0:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103cd3:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103cd7:	8b 55 08             	mov    0x8(%ebp),%edx
c0103cda:	89 14 24             	mov    %edx,(%esp)
c0103cdd:	ff d0                	call   *%eax
}
c0103cdf:	c9                   	leave  
c0103ce0:	c3                   	ret    

c0103ce1 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0103ce1:	55                   	push   %ebp
c0103ce2:	89 e5                	mov    %esp,%ebp
c0103ce4:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0103ce7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0103cee:	e8 2e fe ff ff       	call   c0103b21 <__intr_save>
c0103cf3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
c0103cf6:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0103cfb:	8b 40 0c             	mov    0xc(%eax),%eax
c0103cfe:	8b 55 08             	mov    0x8(%ebp),%edx
c0103d01:	89 14 24             	mov    %edx,(%esp)
c0103d04:	ff d0                	call   *%eax
c0103d06:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
c0103d09:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103d0c:	89 04 24             	mov    %eax,(%esp)
c0103d0f:	e8 37 fe ff ff       	call   c0103b4b <__intr_restore>
    return page;
c0103d14:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0103d17:	c9                   	leave  
c0103d18:	c3                   	ret    

c0103d19 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0103d19:	55                   	push   %ebp
c0103d1a:	89 e5                	mov    %esp,%ebp
c0103d1c:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0103d1f:	e8 fd fd ff ff       	call   c0103b21 <__intr_save>
c0103d24:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0103d27:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0103d2c:	8b 40 10             	mov    0x10(%eax),%eax
c0103d2f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103d32:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103d36:	8b 55 08             	mov    0x8(%ebp),%edx
c0103d39:	89 14 24             	mov    %edx,(%esp)
c0103d3c:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c0103d3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103d41:	89 04 24             	mov    %eax,(%esp)
c0103d44:	e8 02 fe ff ff       	call   c0103b4b <__intr_restore>
}
c0103d49:	c9                   	leave  
c0103d4a:	c3                   	ret    

c0103d4b <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0103d4b:	55                   	push   %ebp
c0103d4c:	89 e5                	mov    %esp,%ebp
c0103d4e:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0103d51:	e8 cb fd ff ff       	call   c0103b21 <__intr_save>
c0103d56:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0103d59:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0103d5e:	8b 40 14             	mov    0x14(%eax),%eax
c0103d61:	ff d0                	call   *%eax
c0103d63:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0103d66:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103d69:	89 04 24             	mov    %eax,(%esp)
c0103d6c:	e8 da fd ff ff       	call   c0103b4b <__intr_restore>
    return ret;
c0103d71:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0103d74:	c9                   	leave  
c0103d75:	c3                   	ret    

c0103d76 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0103d76:	55                   	push   %ebp
c0103d77:	89 e5                	mov    %esp,%ebp
c0103d79:	57                   	push   %edi
c0103d7a:	56                   	push   %esi
c0103d7b:	53                   	push   %ebx
c0103d7c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0103d82:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0103d89:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0103d90:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0103d97:	c7 04 24 cb 69 10 c0 	movl   $0xc01069cb,(%esp)
c0103d9e:	e8 a5 c5 ff ff       	call   c0100348 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0103da3:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0103daa:	e9 15 01 00 00       	jmp    c0103ec4 <page_init+0x14e>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0103daf:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103db2:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103db5:	89 d0                	mov    %edx,%eax
c0103db7:	c1 e0 02             	shl    $0x2,%eax
c0103dba:	01 d0                	add    %edx,%eax
c0103dbc:	c1 e0 02             	shl    $0x2,%eax
c0103dbf:	01 c8                	add    %ecx,%eax
c0103dc1:	8b 50 08             	mov    0x8(%eax),%edx
c0103dc4:	8b 40 04             	mov    0x4(%eax),%eax
c0103dc7:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0103dca:	89 55 bc             	mov    %edx,-0x44(%ebp)
c0103dcd:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103dd0:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103dd3:	89 d0                	mov    %edx,%eax
c0103dd5:	c1 e0 02             	shl    $0x2,%eax
c0103dd8:	01 d0                	add    %edx,%eax
c0103dda:	c1 e0 02             	shl    $0x2,%eax
c0103ddd:	01 c8                	add    %ecx,%eax
c0103ddf:	8b 48 0c             	mov    0xc(%eax),%ecx
c0103de2:	8b 58 10             	mov    0x10(%eax),%ebx
c0103de5:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103de8:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0103deb:	01 c8                	add    %ecx,%eax
c0103ded:	11 da                	adc    %ebx,%edx
c0103def:	89 45 b0             	mov    %eax,-0x50(%ebp)
c0103df2:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0103df5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103df8:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103dfb:	89 d0                	mov    %edx,%eax
c0103dfd:	c1 e0 02             	shl    $0x2,%eax
c0103e00:	01 d0                	add    %edx,%eax
c0103e02:	c1 e0 02             	shl    $0x2,%eax
c0103e05:	01 c8                	add    %ecx,%eax
c0103e07:	83 c0 14             	add    $0x14,%eax
c0103e0a:	8b 00                	mov    (%eax),%eax
c0103e0c:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
c0103e12:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103e15:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0103e18:	83 c0 ff             	add    $0xffffffff,%eax
c0103e1b:	83 d2 ff             	adc    $0xffffffff,%edx
c0103e1e:	89 c6                	mov    %eax,%esi
c0103e20:	89 d7                	mov    %edx,%edi
c0103e22:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103e25:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103e28:	89 d0                	mov    %edx,%eax
c0103e2a:	c1 e0 02             	shl    $0x2,%eax
c0103e2d:	01 d0                	add    %edx,%eax
c0103e2f:	c1 e0 02             	shl    $0x2,%eax
c0103e32:	01 c8                	add    %ecx,%eax
c0103e34:	8b 48 0c             	mov    0xc(%eax),%ecx
c0103e37:	8b 58 10             	mov    0x10(%eax),%ebx
c0103e3a:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c0103e40:	89 44 24 1c          	mov    %eax,0x1c(%esp)
c0103e44:	89 74 24 14          	mov    %esi,0x14(%esp)
c0103e48:	89 7c 24 18          	mov    %edi,0x18(%esp)
c0103e4c:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103e4f:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0103e52:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103e56:	89 54 24 10          	mov    %edx,0x10(%esp)
c0103e5a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0103e5e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0103e62:	c7 04 24 d8 69 10 c0 	movl   $0xc01069d8,(%esp)
c0103e69:	e8 da c4 ff ff       	call   c0100348 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0103e6e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103e71:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103e74:	89 d0                	mov    %edx,%eax
c0103e76:	c1 e0 02             	shl    $0x2,%eax
c0103e79:	01 d0                	add    %edx,%eax
c0103e7b:	c1 e0 02             	shl    $0x2,%eax
c0103e7e:	01 c8                	add    %ecx,%eax
c0103e80:	83 c0 14             	add    $0x14,%eax
c0103e83:	8b 00                	mov    (%eax),%eax
c0103e85:	83 f8 01             	cmp    $0x1,%eax
c0103e88:	75 36                	jne    c0103ec0 <page_init+0x14a>
            if (maxpa < end && begin < KMEMSIZE) {
c0103e8a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103e8d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103e90:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0103e93:	77 2b                	ja     c0103ec0 <page_init+0x14a>
c0103e95:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0103e98:	72 05                	jb     c0103e9f <page_init+0x129>
c0103e9a:	3b 45 b0             	cmp    -0x50(%ebp),%eax
c0103e9d:	73 21                	jae    c0103ec0 <page_init+0x14a>
c0103e9f:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0103ea3:	77 1b                	ja     c0103ec0 <page_init+0x14a>
c0103ea5:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0103ea9:	72 09                	jb     c0103eb4 <page_init+0x13e>
c0103eab:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
c0103eb2:	77 0c                	ja     c0103ec0 <page_init+0x14a>
                maxpa = end;
c0103eb4:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103eb7:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0103eba:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0103ebd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0103ec0:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0103ec4:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103ec7:	8b 00                	mov    (%eax),%eax
c0103ec9:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0103ecc:	0f 8f dd fe ff ff    	jg     c0103daf <page_init+0x39>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0103ed2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103ed6:	72 1d                	jb     c0103ef5 <page_init+0x17f>
c0103ed8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103edc:	77 09                	ja     c0103ee7 <page_init+0x171>
c0103ede:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c0103ee5:	76 0e                	jbe    c0103ef5 <page_init+0x17f>
        maxpa = KMEMSIZE;
c0103ee7:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0103eee:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0103ef5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103ef8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103efb:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0103eff:	c1 ea 0c             	shr    $0xc,%edx
c0103f02:	a3 80 ae 11 c0       	mov    %eax,0xc011ae80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0103f07:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
c0103f0e:	b8 28 af 11 c0       	mov    $0xc011af28,%eax
c0103f13:	8d 50 ff             	lea    -0x1(%eax),%edx
c0103f16:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0103f19:	01 d0                	add    %edx,%eax
c0103f1b:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0103f1e:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0103f21:	ba 00 00 00 00       	mov    $0x0,%edx
c0103f26:	f7 75 ac             	divl   -0x54(%ebp)
c0103f29:	89 d0                	mov    %edx,%eax
c0103f2b:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0103f2e:	29 c2                	sub    %eax,%edx
c0103f30:	89 d0                	mov    %edx,%eax
c0103f32:	a3 24 af 11 c0       	mov    %eax,0xc011af24

    for (i = 0; i < npage; i ++) {
c0103f37:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0103f3e:	eb 2f                	jmp    c0103f6f <page_init+0x1f9>
        SetPageReserved(pages + i);
c0103f40:	8b 0d 24 af 11 c0    	mov    0xc011af24,%ecx
c0103f46:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103f49:	89 d0                	mov    %edx,%eax
c0103f4b:	c1 e0 02             	shl    $0x2,%eax
c0103f4e:	01 d0                	add    %edx,%eax
c0103f50:	c1 e0 02             	shl    $0x2,%eax
c0103f53:	01 c8                	add    %ecx,%eax
c0103f55:	83 c0 04             	add    $0x4,%eax
c0103f58:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
c0103f5f:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103f62:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0103f65:	8b 55 90             	mov    -0x70(%ebp),%edx
c0103f68:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
c0103f6b:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0103f6f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103f72:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0103f77:	39 c2                	cmp    %eax,%edx
c0103f79:	72 c5                	jb     c0103f40 <page_init+0x1ca>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0103f7b:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c0103f81:	89 d0                	mov    %edx,%eax
c0103f83:	c1 e0 02             	shl    $0x2,%eax
c0103f86:	01 d0                	add    %edx,%eax
c0103f88:	c1 e0 02             	shl    $0x2,%eax
c0103f8b:	89 c2                	mov    %eax,%edx
c0103f8d:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c0103f92:	01 d0                	add    %edx,%eax
c0103f94:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c0103f97:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
c0103f9e:	77 23                	ja     c0103fc3 <page_init+0x24d>
c0103fa0:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0103fa3:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103fa7:	c7 44 24 08 08 6a 10 	movl   $0xc0106a08,0x8(%esp)
c0103fae:	c0 
c0103faf:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c0103fb6:	00 
c0103fb7:	c7 04 24 2c 6a 10 c0 	movl   $0xc0106a2c,(%esp)
c0103fbe:	e8 55 cc ff ff       	call   c0100c18 <__panic>
c0103fc3:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0103fc6:	05 00 00 00 40       	add    $0x40000000,%eax
c0103fcb:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c0103fce:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0103fd5:	e9 74 01 00 00       	jmp    c010414e <page_init+0x3d8>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0103fda:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103fdd:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103fe0:	89 d0                	mov    %edx,%eax
c0103fe2:	c1 e0 02             	shl    $0x2,%eax
c0103fe5:	01 d0                	add    %edx,%eax
c0103fe7:	c1 e0 02             	shl    $0x2,%eax
c0103fea:	01 c8                	add    %ecx,%eax
c0103fec:	8b 50 08             	mov    0x8(%eax),%edx
c0103fef:	8b 40 04             	mov    0x4(%eax),%eax
c0103ff2:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103ff5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0103ff8:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103ffb:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103ffe:	89 d0                	mov    %edx,%eax
c0104000:	c1 e0 02             	shl    $0x2,%eax
c0104003:	01 d0                	add    %edx,%eax
c0104005:	c1 e0 02             	shl    $0x2,%eax
c0104008:	01 c8                	add    %ecx,%eax
c010400a:	8b 48 0c             	mov    0xc(%eax),%ecx
c010400d:	8b 58 10             	mov    0x10(%eax),%ebx
c0104010:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104013:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104016:	01 c8                	add    %ecx,%eax
c0104018:	11 da                	adc    %ebx,%edx
c010401a:	89 45 c8             	mov    %eax,-0x38(%ebp)
c010401d:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c0104020:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104023:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104026:	89 d0                	mov    %edx,%eax
c0104028:	c1 e0 02             	shl    $0x2,%eax
c010402b:	01 d0                	add    %edx,%eax
c010402d:	c1 e0 02             	shl    $0x2,%eax
c0104030:	01 c8                	add    %ecx,%eax
c0104032:	83 c0 14             	add    $0x14,%eax
c0104035:	8b 00                	mov    (%eax),%eax
c0104037:	83 f8 01             	cmp    $0x1,%eax
c010403a:	0f 85 0a 01 00 00    	jne    c010414a <page_init+0x3d4>
            if (begin < freemem) {
c0104040:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0104043:	ba 00 00 00 00       	mov    $0x0,%edx
c0104048:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010404b:	72 17                	jb     c0104064 <page_init+0x2ee>
c010404d:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0104050:	77 05                	ja     c0104057 <page_init+0x2e1>
c0104052:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0104055:	76 0d                	jbe    c0104064 <page_init+0x2ee>
                begin = freemem;
c0104057:	8b 45 a0             	mov    -0x60(%ebp),%eax
c010405a:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010405d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c0104064:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0104068:	72 1d                	jb     c0104087 <page_init+0x311>
c010406a:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c010406e:	77 09                	ja     c0104079 <page_init+0x303>
c0104070:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c0104077:	76 0e                	jbe    c0104087 <page_init+0x311>
                end = KMEMSIZE;
c0104079:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0104080:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0104087:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010408a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010408d:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0104090:	0f 87 b4 00 00 00    	ja     c010414a <page_init+0x3d4>
c0104096:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0104099:	72 09                	jb     c01040a4 <page_init+0x32e>
c010409b:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c010409e:	0f 83 a6 00 00 00    	jae    c010414a <page_init+0x3d4>
                begin = ROUNDUP(begin, PGSIZE);
c01040a4:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
c01040ab:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01040ae:	8b 45 9c             	mov    -0x64(%ebp),%eax
c01040b1:	01 d0                	add    %edx,%eax
c01040b3:	83 e8 01             	sub    $0x1,%eax
c01040b6:	89 45 98             	mov    %eax,-0x68(%ebp)
c01040b9:	8b 45 98             	mov    -0x68(%ebp),%eax
c01040bc:	ba 00 00 00 00       	mov    $0x0,%edx
c01040c1:	f7 75 9c             	divl   -0x64(%ebp)
c01040c4:	89 d0                	mov    %edx,%eax
c01040c6:	8b 55 98             	mov    -0x68(%ebp),%edx
c01040c9:	29 c2                	sub    %eax,%edx
c01040cb:	89 d0                	mov    %edx,%eax
c01040cd:	ba 00 00 00 00       	mov    $0x0,%edx
c01040d2:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01040d5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c01040d8:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01040db:	89 45 94             	mov    %eax,-0x6c(%ebp)
c01040de:	8b 45 94             	mov    -0x6c(%ebp),%eax
c01040e1:	ba 00 00 00 00       	mov    $0x0,%edx
c01040e6:	89 c7                	mov    %eax,%edi
c01040e8:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
c01040ee:	89 7d 80             	mov    %edi,-0x80(%ebp)
c01040f1:	89 d0                	mov    %edx,%eax
c01040f3:	83 e0 00             	and    $0x0,%eax
c01040f6:	89 45 84             	mov    %eax,-0x7c(%ebp)
c01040f9:	8b 45 80             	mov    -0x80(%ebp),%eax
c01040fc:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01040ff:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0104102:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
c0104105:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104108:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010410b:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c010410e:	77 3a                	ja     c010414a <page_init+0x3d4>
c0104110:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0104113:	72 05                	jb     c010411a <page_init+0x3a4>
c0104115:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0104118:	73 30                	jae    c010414a <page_init+0x3d4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c010411a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c010411d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
c0104120:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104123:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0104126:	29 c8                	sub    %ecx,%eax
c0104128:	19 da                	sbb    %ebx,%edx
c010412a:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c010412e:	c1 ea 0c             	shr    $0xc,%edx
c0104131:	89 c3                	mov    %eax,%ebx
c0104133:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104136:	89 04 24             	mov    %eax,(%esp)
c0104139:	e8 a5 f8 ff ff       	call   c01039e3 <pa2page>
c010413e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0104142:	89 04 24             	mov    %eax,(%esp)
c0104145:	e8 78 fb ff ff       	call   c0103cc2 <init_memmap>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
c010414a:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c010414e:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104151:	8b 00                	mov    (%eax),%eax
c0104153:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0104156:	0f 8f 7e fe ff ff    	jg     c0103fda <page_init+0x264>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
c010415c:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c0104162:	5b                   	pop    %ebx
c0104163:	5e                   	pop    %esi
c0104164:	5f                   	pop    %edi
c0104165:	5d                   	pop    %ebp
c0104166:	c3                   	ret    

c0104167 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c0104167:	55                   	push   %ebp
c0104168:	89 e5                	mov    %esp,%ebp
c010416a:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c010416d:	8b 45 14             	mov    0x14(%ebp),%eax
c0104170:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104173:	31 d0                	xor    %edx,%eax
c0104175:	25 ff 0f 00 00       	and    $0xfff,%eax
c010417a:	85 c0                	test   %eax,%eax
c010417c:	74 24                	je     c01041a2 <boot_map_segment+0x3b>
c010417e:	c7 44 24 0c 3a 6a 10 	movl   $0xc0106a3a,0xc(%esp)
c0104185:	c0 
c0104186:	c7 44 24 08 51 6a 10 	movl   $0xc0106a51,0x8(%esp)
c010418d:	c0 
c010418e:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c0104195:	00 
c0104196:	c7 04 24 2c 6a 10 c0 	movl   $0xc0106a2c,(%esp)
c010419d:	e8 76 ca ff ff       	call   c0100c18 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c01041a2:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c01041a9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01041ac:	25 ff 0f 00 00       	and    $0xfff,%eax
c01041b1:	89 c2                	mov    %eax,%edx
c01041b3:	8b 45 10             	mov    0x10(%ebp),%eax
c01041b6:	01 c2                	add    %eax,%edx
c01041b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01041bb:	01 d0                	add    %edx,%eax
c01041bd:	83 e8 01             	sub    $0x1,%eax
c01041c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01041c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01041c6:	ba 00 00 00 00       	mov    $0x0,%edx
c01041cb:	f7 75 f0             	divl   -0x10(%ebp)
c01041ce:	89 d0                	mov    %edx,%eax
c01041d0:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01041d3:	29 c2                	sub    %eax,%edx
c01041d5:	89 d0                	mov    %edx,%eax
c01041d7:	c1 e8 0c             	shr    $0xc,%eax
c01041da:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c01041dd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01041e0:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01041e3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01041e6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01041eb:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c01041ee:	8b 45 14             	mov    0x14(%ebp),%eax
c01041f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01041f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01041f7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01041fc:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c01041ff:	eb 6b                	jmp    c010426c <boot_map_segment+0x105>
        pte_t *ptep = get_pte(pgdir, la, 1);
c0104201:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0104208:	00 
c0104209:	8b 45 0c             	mov    0xc(%ebp),%eax
c010420c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104210:	8b 45 08             	mov    0x8(%ebp),%eax
c0104213:	89 04 24             	mov    %eax,(%esp)
c0104216:	e8 82 01 00 00       	call   c010439d <get_pte>
c010421b:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c010421e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0104222:	75 24                	jne    c0104248 <boot_map_segment+0xe1>
c0104224:	c7 44 24 0c 66 6a 10 	movl   $0xc0106a66,0xc(%esp)
c010422b:	c0 
c010422c:	c7 44 24 08 51 6a 10 	movl   $0xc0106a51,0x8(%esp)
c0104233:	c0 
c0104234:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c010423b:	00 
c010423c:	c7 04 24 2c 6a 10 c0 	movl   $0xc0106a2c,(%esp)
c0104243:	e8 d0 c9 ff ff       	call   c0100c18 <__panic>
        *ptep = pa | PTE_P | perm;
c0104248:	8b 45 18             	mov    0x18(%ebp),%eax
c010424b:	8b 55 14             	mov    0x14(%ebp),%edx
c010424e:	09 d0                	or     %edx,%eax
c0104250:	83 c8 01             	or     $0x1,%eax
c0104253:	89 c2                	mov    %eax,%edx
c0104255:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104258:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c010425a:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c010425e:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c0104265:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c010426c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104270:	75 8f                	jne    c0104201 <boot_map_segment+0x9a>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
c0104272:	c9                   	leave  
c0104273:	c3                   	ret    

c0104274 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c0104274:	55                   	push   %ebp
c0104275:	89 e5                	mov    %esp,%ebp
c0104277:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c010427a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104281:	e8 5b fa ff ff       	call   c0103ce1 <alloc_pages>
c0104286:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c0104289:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010428d:	75 1c                	jne    c01042ab <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c010428f:	c7 44 24 08 73 6a 10 	movl   $0xc0106a73,0x8(%esp)
c0104296:	c0 
c0104297:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c010429e:	00 
c010429f:	c7 04 24 2c 6a 10 c0 	movl   $0xc0106a2c,(%esp)
c01042a6:	e8 6d c9 ff ff       	call   c0100c18 <__panic>
    }
    return page2kva(p);
c01042ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01042ae:	89 04 24             	mov    %eax,(%esp)
c01042b1:	e8 7c f7 ff ff       	call   c0103a32 <page2kva>
}
c01042b6:	c9                   	leave  
c01042b7:	c3                   	ret    

c01042b8 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c01042b8:	55                   	push   %ebp
c01042b9:	89 e5                	mov    %esp,%ebp
c01042bb:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c01042be:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01042c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01042c6:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01042cd:	77 23                	ja     c01042f2 <pmm_init+0x3a>
c01042cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01042d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01042d6:	c7 44 24 08 08 6a 10 	movl   $0xc0106a08,0x8(%esp)
c01042dd:	c0 
c01042de:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c01042e5:	00 
c01042e6:	c7 04 24 2c 6a 10 c0 	movl   $0xc0106a2c,(%esp)
c01042ed:	e8 26 c9 ff ff       	call   c0100c18 <__panic>
c01042f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01042f5:	05 00 00 00 40       	add    $0x40000000,%eax
c01042fa:	a3 20 af 11 c0       	mov    %eax,0xc011af20
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c01042ff:	e8 8b f9 ff ff       	call   c0103c8f <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c0104304:	e8 6d fa ff ff       	call   c0103d76 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c0104309:	e8 7b 03 00 00       	call   c0104689 <check_alloc_page>

    check_pgdir();
c010430e:	e8 94 03 00 00       	call   c01046a7 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c0104313:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104318:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c010431e:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104323:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104326:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c010432d:	77 23                	ja     c0104352 <pmm_init+0x9a>
c010432f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104332:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104336:	c7 44 24 08 08 6a 10 	movl   $0xc0106a08,0x8(%esp)
c010433d:	c0 
c010433e:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
c0104345:	00 
c0104346:	c7 04 24 2c 6a 10 c0 	movl   $0xc0106a2c,(%esp)
c010434d:	e8 c6 c8 ff ff       	call   c0100c18 <__panic>
c0104352:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104355:	05 00 00 00 40       	add    $0x40000000,%eax
c010435a:	83 c8 03             	or     $0x3,%eax
c010435d:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c010435f:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104364:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c010436b:	00 
c010436c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0104373:	00 
c0104374:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c010437b:	38 
c010437c:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c0104383:	c0 
c0104384:	89 04 24             	mov    %eax,(%esp)
c0104387:	e8 db fd ff ff       	call   c0104167 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c010438c:	e8 0f f8 ff ff       	call   c0103ba0 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c0104391:	e8 ac 09 00 00       	call   c0104d42 <check_boot_pgdir>

    print_pgdir();
c0104396:	e8 34 0e 00 00       	call   c01051cf <print_pgdir>

}
c010439b:	c9                   	leave  
c010439c:	c3                   	ret    

c010439d <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c010439d:	55                   	push   %ebp
c010439e:	89 e5                	mov    %esp,%ebp
c01043a0:	83 ec 38             	sub    $0x38,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    pde_t *pdep = &pgdir[PDX(la)];
c01043a3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01043a6:	c1 e8 16             	shr    $0x16,%eax
c01043a9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01043b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01043b3:	01 d0                	add    %edx,%eax
c01043b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if((*pdep & PTE_P)==0)
c01043b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01043bb:	8b 00                	mov    (%eax),%eax
c01043bd:	83 e0 01             	and    $0x1,%eax
c01043c0:	85 c0                	test   %eax,%eax
c01043c2:	0f 85 ab 00 00 00    	jne    c0104473 <get_pte+0xd6>
     {
      struct Page *page;
      if(create==1)
c01043c8:	83 7d 10 01          	cmpl   $0x1,0x10(%ebp)
c01043cc:	75 4b                	jne    c0104419 <get_pte+0x7c>
      {
       page=alloc_pages(1);
c01043ce:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01043d5:	e8 07 f9 ff ff       	call   c0103ce1 <alloc_pages>
c01043da:	89 45 f0             	mov    %eax,-0x10(%ebp)
      }
      else return NULL;
      set_page_ref(page,1);
c01043dd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01043e4:	00 
c01043e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01043e8:	89 04 24             	mov    %eax,(%esp)
c01043eb:	e8 f6 f6 ff ff       	call   c0103ae6 <set_page_ref>
      uintptr_t pa=page2pa(page);
c01043f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01043f3:	89 04 24             	mov    %eax,(%esp)
c01043f6:	e8 d2 f5 ff ff       	call   c01039cd <page2pa>
c01043fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
      memset(KADDR(pa),0,sizeof(struct Page));
c01043fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104401:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104404:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104407:	c1 e8 0c             	shr    $0xc,%eax
c010440a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010440d:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0104412:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0104415:	72 2f                	jb     c0104446 <get_pte+0xa9>
c0104417:	eb 0a                	jmp    c0104423 <get_pte+0x86>
      struct Page *page;
      if(create==1)
      {
       page=alloc_pages(1);
      }
      else return NULL;
c0104419:	b8 00 00 00 00       	mov    $0x0,%eax
c010441e:	e9 ac 00 00 00       	jmp    c01044cf <get_pte+0x132>
      set_page_ref(page,1);
      uintptr_t pa=page2pa(page);
      memset(KADDR(pa),0,sizeof(struct Page));
c0104423:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104426:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010442a:	c7 44 24 08 64 69 10 	movl   $0xc0106964,0x8(%esp)
c0104431:	c0 
c0104432:	c7 44 24 04 75 01 00 	movl   $0x175,0x4(%esp)
c0104439:	00 
c010443a:	c7 04 24 2c 6a 10 c0 	movl   $0xc0106a2c,(%esp)
c0104441:	e8 d2 c7 ff ff       	call   c0100c18 <__panic>
c0104446:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104449:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010444e:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
c0104455:	00 
c0104456:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010445d:	00 
c010445e:	89 04 24             	mov    %eax,(%esp)
c0104461:	e8 87 18 00 00       	call   c0105ced <memset>
      *pdep=pa|PTE_P|PTE_W|PTE_U;
c0104466:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104469:	83 c8 07             	or     $0x7,%eax
c010446c:	89 c2                	mov    %eax,%edx
c010446e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104471:	89 10                	mov    %edx,(%eax)
 
      }
      return (pte_t*)KADDR((PDE_ADDR(*pdep)))+PTX(la);
c0104473:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104476:	8b 00                	mov    (%eax),%eax
c0104478:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010447d:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0104480:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104483:	c1 e8 0c             	shr    $0xc,%eax
c0104486:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0104489:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c010448e:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0104491:	72 23                	jb     c01044b6 <get_pte+0x119>
c0104493:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104496:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010449a:	c7 44 24 08 64 69 10 	movl   $0xc0106964,0x8(%esp)
c01044a1:	c0 
c01044a2:	c7 44 24 04 79 01 00 	movl   $0x179,0x4(%esp)
c01044a9:	00 
c01044aa:	c7 04 24 2c 6a 10 c0 	movl   $0xc0106a2c,(%esp)
c01044b1:	e8 62 c7 ff ff       	call   c0100c18 <__panic>
c01044b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01044b9:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01044be:	8b 55 0c             	mov    0xc(%ebp),%edx
c01044c1:	c1 ea 0c             	shr    $0xc,%edx
c01044c4:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
c01044ca:	c1 e2 02             	shl    $0x2,%edx
c01044cd:	01 d0                	add    %edx,%eax
}
c01044cf:	c9                   	leave  
c01044d0:	c3                   	ret    

c01044d1 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c01044d1:	55                   	push   %ebp
c01044d2:	89 e5                	mov    %esp,%ebp
c01044d4:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c01044d7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01044de:	00 
c01044df:	8b 45 0c             	mov    0xc(%ebp),%eax
c01044e2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01044e6:	8b 45 08             	mov    0x8(%ebp),%eax
c01044e9:	89 04 24             	mov    %eax,(%esp)
c01044ec:	e8 ac fe ff ff       	call   c010439d <get_pte>
c01044f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c01044f4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01044f8:	74 08                	je     c0104502 <get_page+0x31>
        *ptep_store = ptep;
c01044fa:	8b 45 10             	mov    0x10(%ebp),%eax
c01044fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104500:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c0104502:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104506:	74 1b                	je     c0104523 <get_page+0x52>
c0104508:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010450b:	8b 00                	mov    (%eax),%eax
c010450d:	83 e0 01             	and    $0x1,%eax
c0104510:	85 c0                	test   %eax,%eax
c0104512:	74 0f                	je     c0104523 <get_page+0x52>
        return pte2page(*ptep);
c0104514:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104517:	8b 00                	mov    (%eax),%eax
c0104519:	89 04 24             	mov    %eax,(%esp)
c010451c:	e8 65 f5 ff ff       	call   c0103a86 <pte2page>
c0104521:	eb 05                	jmp    c0104528 <get_page+0x57>
    }
    return NULL;
c0104523:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104528:	c9                   	leave  
c0104529:	c3                   	ret    

c010452a <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c010452a:	55                   	push   %ebp
c010452b:	89 e5                	mov    %esp,%ebp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
}
c010452d:	5d                   	pop    %ebp
c010452e:	c3                   	ret    

c010452f <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c010452f:	55                   	push   %ebp
c0104530:	89 e5                	mov    %esp,%ebp
c0104532:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0104535:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010453c:	00 
c010453d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104540:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104544:	8b 45 08             	mov    0x8(%ebp),%eax
c0104547:	89 04 24             	mov    %eax,(%esp)
c010454a:	e8 4e fe ff ff       	call   c010439d <get_pte>
c010454f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c0104552:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104556:	74 19                	je     c0104571 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c0104558:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010455b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010455f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104562:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104566:	8b 45 08             	mov    0x8(%ebp),%eax
c0104569:	89 04 24             	mov    %eax,(%esp)
c010456c:	e8 b9 ff ff ff       	call   c010452a <page_remove_pte>
    }
}
c0104571:	c9                   	leave  
c0104572:	c3                   	ret    

c0104573 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c0104573:	55                   	push   %ebp
c0104574:	89 e5                	mov    %esp,%ebp
c0104576:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c0104579:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0104580:	00 
c0104581:	8b 45 10             	mov    0x10(%ebp),%eax
c0104584:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104588:	8b 45 08             	mov    0x8(%ebp),%eax
c010458b:	89 04 24             	mov    %eax,(%esp)
c010458e:	e8 0a fe ff ff       	call   c010439d <get_pte>
c0104593:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c0104596:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010459a:	75 0a                	jne    c01045a6 <page_insert+0x33>
        return -E_NO_MEM;
c010459c:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c01045a1:	e9 84 00 00 00       	jmp    c010462a <page_insert+0xb7>
    }
    page_ref_inc(page);
c01045a6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01045a9:	89 04 24             	mov    %eax,(%esp)
c01045ac:	e8 42 f5 ff ff       	call   c0103af3 <page_ref_inc>
    if (*ptep & PTE_P) {
c01045b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045b4:	8b 00                	mov    (%eax),%eax
c01045b6:	83 e0 01             	and    $0x1,%eax
c01045b9:	85 c0                	test   %eax,%eax
c01045bb:	74 3e                	je     c01045fb <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c01045bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045c0:	8b 00                	mov    (%eax),%eax
c01045c2:	89 04 24             	mov    %eax,(%esp)
c01045c5:	e8 bc f4 ff ff       	call   c0103a86 <pte2page>
c01045ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c01045cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01045d0:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01045d3:	75 0d                	jne    c01045e2 <page_insert+0x6f>
            page_ref_dec(page);
c01045d5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01045d8:	89 04 24             	mov    %eax,(%esp)
c01045db:	e8 2a f5 ff ff       	call   c0103b0a <page_ref_dec>
c01045e0:	eb 19                	jmp    c01045fb <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c01045e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045e5:	89 44 24 08          	mov    %eax,0x8(%esp)
c01045e9:	8b 45 10             	mov    0x10(%ebp),%eax
c01045ec:	89 44 24 04          	mov    %eax,0x4(%esp)
c01045f0:	8b 45 08             	mov    0x8(%ebp),%eax
c01045f3:	89 04 24             	mov    %eax,(%esp)
c01045f6:	e8 2f ff ff ff       	call   c010452a <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c01045fb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01045fe:	89 04 24             	mov    %eax,(%esp)
c0104601:	e8 c7 f3 ff ff       	call   c01039cd <page2pa>
c0104606:	0b 45 14             	or     0x14(%ebp),%eax
c0104609:	83 c8 01             	or     $0x1,%eax
c010460c:	89 c2                	mov    %eax,%edx
c010460e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104611:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c0104613:	8b 45 10             	mov    0x10(%ebp),%eax
c0104616:	89 44 24 04          	mov    %eax,0x4(%esp)
c010461a:	8b 45 08             	mov    0x8(%ebp),%eax
c010461d:	89 04 24             	mov    %eax,(%esp)
c0104620:	e8 07 00 00 00       	call   c010462c <tlb_invalidate>
    return 0;
c0104625:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010462a:	c9                   	leave  
c010462b:	c3                   	ret    

c010462c <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c010462c:	55                   	push   %ebp
c010462d:	89 e5                	mov    %esp,%ebp
c010462f:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c0104632:	0f 20 d8             	mov    %cr3,%eax
c0104635:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c0104638:	8b 45 f0             	mov    -0x10(%ebp),%eax
    if (rcr3() == PADDR(pgdir)) {
c010463b:	89 c2                	mov    %eax,%edx
c010463d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104640:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104643:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c010464a:	77 23                	ja     c010466f <tlb_invalidate+0x43>
c010464c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010464f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104653:	c7 44 24 08 08 6a 10 	movl   $0xc0106a08,0x8(%esp)
c010465a:	c0 
c010465b:	c7 44 24 04 d3 01 00 	movl   $0x1d3,0x4(%esp)
c0104662:	00 
c0104663:	c7 04 24 2c 6a 10 c0 	movl   $0xc0106a2c,(%esp)
c010466a:	e8 a9 c5 ff ff       	call   c0100c18 <__panic>
c010466f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104672:	05 00 00 00 40       	add    $0x40000000,%eax
c0104677:	39 c2                	cmp    %eax,%edx
c0104679:	75 0c                	jne    c0104687 <tlb_invalidate+0x5b>
        invlpg((void *)la);
c010467b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010467e:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c0104681:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104684:	0f 01 38             	invlpg (%eax)
    }
}
c0104687:	c9                   	leave  
c0104688:	c3                   	ret    

c0104689 <check_alloc_page>:

static void
check_alloc_page(void) {
c0104689:	55                   	push   %ebp
c010468a:	89 e5                	mov    %esp,%ebp
c010468c:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c010468f:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0104694:	8b 40 18             	mov    0x18(%eax),%eax
c0104697:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c0104699:	c7 04 24 8c 6a 10 c0 	movl   $0xc0106a8c,(%esp)
c01046a0:	e8 a3 bc ff ff       	call   c0100348 <cprintf>
}
c01046a5:	c9                   	leave  
c01046a6:	c3                   	ret    

c01046a7 <check_pgdir>:

static void
check_pgdir(void) {
c01046a7:	55                   	push   %ebp
c01046a8:	89 e5                	mov    %esp,%ebp
c01046aa:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c01046ad:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c01046b2:	3d 00 80 03 00       	cmp    $0x38000,%eax
c01046b7:	76 24                	jbe    c01046dd <check_pgdir+0x36>
c01046b9:	c7 44 24 0c ab 6a 10 	movl   $0xc0106aab,0xc(%esp)
c01046c0:	c0 
c01046c1:	c7 44 24 08 51 6a 10 	movl   $0xc0106a51,0x8(%esp)
c01046c8:	c0 
c01046c9:	c7 44 24 04 e0 01 00 	movl   $0x1e0,0x4(%esp)
c01046d0:	00 
c01046d1:	c7 04 24 2c 6a 10 c0 	movl   $0xc0106a2c,(%esp)
c01046d8:	e8 3b c5 ff ff       	call   c0100c18 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c01046dd:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01046e2:	85 c0                	test   %eax,%eax
c01046e4:	74 0e                	je     c01046f4 <check_pgdir+0x4d>
c01046e6:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01046eb:	25 ff 0f 00 00       	and    $0xfff,%eax
c01046f0:	85 c0                	test   %eax,%eax
c01046f2:	74 24                	je     c0104718 <check_pgdir+0x71>
c01046f4:	c7 44 24 0c c8 6a 10 	movl   $0xc0106ac8,0xc(%esp)
c01046fb:	c0 
c01046fc:	c7 44 24 08 51 6a 10 	movl   $0xc0106a51,0x8(%esp)
c0104703:	c0 
c0104704:	c7 44 24 04 e1 01 00 	movl   $0x1e1,0x4(%esp)
c010470b:	00 
c010470c:	c7 04 24 2c 6a 10 c0 	movl   $0xc0106a2c,(%esp)
c0104713:	e8 00 c5 ff ff       	call   c0100c18 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c0104718:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c010471d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104724:	00 
c0104725:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010472c:	00 
c010472d:	89 04 24             	mov    %eax,(%esp)
c0104730:	e8 9c fd ff ff       	call   c01044d1 <get_page>
c0104735:	85 c0                	test   %eax,%eax
c0104737:	74 24                	je     c010475d <check_pgdir+0xb6>
c0104739:	c7 44 24 0c 00 6b 10 	movl   $0xc0106b00,0xc(%esp)
c0104740:	c0 
c0104741:	c7 44 24 08 51 6a 10 	movl   $0xc0106a51,0x8(%esp)
c0104748:	c0 
c0104749:	c7 44 24 04 e2 01 00 	movl   $0x1e2,0x4(%esp)
c0104750:	00 
c0104751:	c7 04 24 2c 6a 10 c0 	movl   $0xc0106a2c,(%esp)
c0104758:	e8 bb c4 ff ff       	call   c0100c18 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c010475d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104764:	e8 78 f5 ff ff       	call   c0103ce1 <alloc_pages>
c0104769:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c010476c:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104771:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0104778:	00 
c0104779:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104780:	00 
c0104781:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104784:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104788:	89 04 24             	mov    %eax,(%esp)
c010478b:	e8 e3 fd ff ff       	call   c0104573 <page_insert>
c0104790:	85 c0                	test   %eax,%eax
c0104792:	74 24                	je     c01047b8 <check_pgdir+0x111>
c0104794:	c7 44 24 0c 28 6b 10 	movl   $0xc0106b28,0xc(%esp)
c010479b:	c0 
c010479c:	c7 44 24 08 51 6a 10 	movl   $0xc0106a51,0x8(%esp)
c01047a3:	c0 
c01047a4:	c7 44 24 04 e6 01 00 	movl   $0x1e6,0x4(%esp)
c01047ab:	00 
c01047ac:	c7 04 24 2c 6a 10 c0 	movl   $0xc0106a2c,(%esp)
c01047b3:	e8 60 c4 ff ff       	call   c0100c18 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c01047b8:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01047bd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01047c4:	00 
c01047c5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01047cc:	00 
c01047cd:	89 04 24             	mov    %eax,(%esp)
c01047d0:	e8 c8 fb ff ff       	call   c010439d <get_pte>
c01047d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01047d8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01047dc:	75 24                	jne    c0104802 <check_pgdir+0x15b>
c01047de:	c7 44 24 0c 54 6b 10 	movl   $0xc0106b54,0xc(%esp)
c01047e5:	c0 
c01047e6:	c7 44 24 08 51 6a 10 	movl   $0xc0106a51,0x8(%esp)
c01047ed:	c0 
c01047ee:	c7 44 24 04 e9 01 00 	movl   $0x1e9,0x4(%esp)
c01047f5:	00 
c01047f6:	c7 04 24 2c 6a 10 c0 	movl   $0xc0106a2c,(%esp)
c01047fd:	e8 16 c4 ff ff       	call   c0100c18 <__panic>
    assert(pte2page(*ptep) == p1);
c0104802:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104805:	8b 00                	mov    (%eax),%eax
c0104807:	89 04 24             	mov    %eax,(%esp)
c010480a:	e8 77 f2 ff ff       	call   c0103a86 <pte2page>
c010480f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104812:	74 24                	je     c0104838 <check_pgdir+0x191>
c0104814:	c7 44 24 0c 81 6b 10 	movl   $0xc0106b81,0xc(%esp)
c010481b:	c0 
c010481c:	c7 44 24 08 51 6a 10 	movl   $0xc0106a51,0x8(%esp)
c0104823:	c0 
c0104824:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
c010482b:	00 
c010482c:	c7 04 24 2c 6a 10 c0 	movl   $0xc0106a2c,(%esp)
c0104833:	e8 e0 c3 ff ff       	call   c0100c18 <__panic>
    assert(page_ref(p1) == 1);
c0104838:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010483b:	89 04 24             	mov    %eax,(%esp)
c010483e:	e8 99 f2 ff ff       	call   c0103adc <page_ref>
c0104843:	83 f8 01             	cmp    $0x1,%eax
c0104846:	74 24                	je     c010486c <check_pgdir+0x1c5>
c0104848:	c7 44 24 0c 97 6b 10 	movl   $0xc0106b97,0xc(%esp)
c010484f:	c0 
c0104850:	c7 44 24 08 51 6a 10 	movl   $0xc0106a51,0x8(%esp)
c0104857:	c0 
c0104858:	c7 44 24 04 eb 01 00 	movl   $0x1eb,0x4(%esp)
c010485f:	00 
c0104860:	c7 04 24 2c 6a 10 c0 	movl   $0xc0106a2c,(%esp)
c0104867:	e8 ac c3 ff ff       	call   c0100c18 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c010486c:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104871:	8b 00                	mov    (%eax),%eax
c0104873:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104878:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010487b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010487e:	c1 e8 0c             	shr    $0xc,%eax
c0104881:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104884:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0104889:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c010488c:	72 23                	jb     c01048b1 <check_pgdir+0x20a>
c010488e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104891:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104895:	c7 44 24 08 64 69 10 	movl   $0xc0106964,0x8(%esp)
c010489c:	c0 
c010489d:	c7 44 24 04 ed 01 00 	movl   $0x1ed,0x4(%esp)
c01048a4:	00 
c01048a5:	c7 04 24 2c 6a 10 c0 	movl   $0xc0106a2c,(%esp)
c01048ac:	e8 67 c3 ff ff       	call   c0100c18 <__panic>
c01048b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01048b4:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01048b9:	83 c0 04             	add    $0x4,%eax
c01048bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c01048bf:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01048c4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01048cb:	00 
c01048cc:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01048d3:	00 
c01048d4:	89 04 24             	mov    %eax,(%esp)
c01048d7:	e8 c1 fa ff ff       	call   c010439d <get_pte>
c01048dc:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01048df:	74 24                	je     c0104905 <check_pgdir+0x25e>
c01048e1:	c7 44 24 0c ac 6b 10 	movl   $0xc0106bac,0xc(%esp)
c01048e8:	c0 
c01048e9:	c7 44 24 08 51 6a 10 	movl   $0xc0106a51,0x8(%esp)
c01048f0:	c0 
c01048f1:	c7 44 24 04 ee 01 00 	movl   $0x1ee,0x4(%esp)
c01048f8:	00 
c01048f9:	c7 04 24 2c 6a 10 c0 	movl   $0xc0106a2c,(%esp)
c0104900:	e8 13 c3 ff ff       	call   c0100c18 <__panic>

    p2 = alloc_page();
c0104905:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010490c:	e8 d0 f3 ff ff       	call   c0103ce1 <alloc_pages>
c0104911:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c0104914:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104919:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c0104920:	00 
c0104921:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0104928:	00 
c0104929:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010492c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104930:	89 04 24             	mov    %eax,(%esp)
c0104933:	e8 3b fc ff ff       	call   c0104573 <page_insert>
c0104938:	85 c0                	test   %eax,%eax
c010493a:	74 24                	je     c0104960 <check_pgdir+0x2b9>
c010493c:	c7 44 24 0c d4 6b 10 	movl   $0xc0106bd4,0xc(%esp)
c0104943:	c0 
c0104944:	c7 44 24 08 51 6a 10 	movl   $0xc0106a51,0x8(%esp)
c010494b:	c0 
c010494c:	c7 44 24 04 f1 01 00 	movl   $0x1f1,0x4(%esp)
c0104953:	00 
c0104954:	c7 04 24 2c 6a 10 c0 	movl   $0xc0106a2c,(%esp)
c010495b:	e8 b8 c2 ff ff       	call   c0100c18 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0104960:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104965:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010496c:	00 
c010496d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104974:	00 
c0104975:	89 04 24             	mov    %eax,(%esp)
c0104978:	e8 20 fa ff ff       	call   c010439d <get_pte>
c010497d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104980:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104984:	75 24                	jne    c01049aa <check_pgdir+0x303>
c0104986:	c7 44 24 0c 0c 6c 10 	movl   $0xc0106c0c,0xc(%esp)
c010498d:	c0 
c010498e:	c7 44 24 08 51 6a 10 	movl   $0xc0106a51,0x8(%esp)
c0104995:	c0 
c0104996:	c7 44 24 04 f2 01 00 	movl   $0x1f2,0x4(%esp)
c010499d:	00 
c010499e:	c7 04 24 2c 6a 10 c0 	movl   $0xc0106a2c,(%esp)
c01049a5:	e8 6e c2 ff ff       	call   c0100c18 <__panic>
    assert(*ptep & PTE_U);
c01049aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01049ad:	8b 00                	mov    (%eax),%eax
c01049af:	83 e0 04             	and    $0x4,%eax
c01049b2:	85 c0                	test   %eax,%eax
c01049b4:	75 24                	jne    c01049da <check_pgdir+0x333>
c01049b6:	c7 44 24 0c 3c 6c 10 	movl   $0xc0106c3c,0xc(%esp)
c01049bd:	c0 
c01049be:	c7 44 24 08 51 6a 10 	movl   $0xc0106a51,0x8(%esp)
c01049c5:	c0 
c01049c6:	c7 44 24 04 f3 01 00 	movl   $0x1f3,0x4(%esp)
c01049cd:	00 
c01049ce:	c7 04 24 2c 6a 10 c0 	movl   $0xc0106a2c,(%esp)
c01049d5:	e8 3e c2 ff ff       	call   c0100c18 <__panic>
    assert(*ptep & PTE_W);
c01049da:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01049dd:	8b 00                	mov    (%eax),%eax
c01049df:	83 e0 02             	and    $0x2,%eax
c01049e2:	85 c0                	test   %eax,%eax
c01049e4:	75 24                	jne    c0104a0a <check_pgdir+0x363>
c01049e6:	c7 44 24 0c 4a 6c 10 	movl   $0xc0106c4a,0xc(%esp)
c01049ed:	c0 
c01049ee:	c7 44 24 08 51 6a 10 	movl   $0xc0106a51,0x8(%esp)
c01049f5:	c0 
c01049f6:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
c01049fd:	00 
c01049fe:	c7 04 24 2c 6a 10 c0 	movl   $0xc0106a2c,(%esp)
c0104a05:	e8 0e c2 ff ff       	call   c0100c18 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0104a0a:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104a0f:	8b 00                	mov    (%eax),%eax
c0104a11:	83 e0 04             	and    $0x4,%eax
c0104a14:	85 c0                	test   %eax,%eax
c0104a16:	75 24                	jne    c0104a3c <check_pgdir+0x395>
c0104a18:	c7 44 24 0c 58 6c 10 	movl   $0xc0106c58,0xc(%esp)
c0104a1f:	c0 
c0104a20:	c7 44 24 08 51 6a 10 	movl   $0xc0106a51,0x8(%esp)
c0104a27:	c0 
c0104a28:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
c0104a2f:	00 
c0104a30:	c7 04 24 2c 6a 10 c0 	movl   $0xc0106a2c,(%esp)
c0104a37:	e8 dc c1 ff ff       	call   c0100c18 <__panic>
    assert(page_ref(p2) == 1);
c0104a3c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104a3f:	89 04 24             	mov    %eax,(%esp)
c0104a42:	e8 95 f0 ff ff       	call   c0103adc <page_ref>
c0104a47:	83 f8 01             	cmp    $0x1,%eax
c0104a4a:	74 24                	je     c0104a70 <check_pgdir+0x3c9>
c0104a4c:	c7 44 24 0c 6e 6c 10 	movl   $0xc0106c6e,0xc(%esp)
c0104a53:	c0 
c0104a54:	c7 44 24 08 51 6a 10 	movl   $0xc0106a51,0x8(%esp)
c0104a5b:	c0 
c0104a5c:	c7 44 24 04 f6 01 00 	movl   $0x1f6,0x4(%esp)
c0104a63:	00 
c0104a64:	c7 04 24 2c 6a 10 c0 	movl   $0xc0106a2c,(%esp)
c0104a6b:	e8 a8 c1 ff ff       	call   c0100c18 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0104a70:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104a75:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0104a7c:	00 
c0104a7d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0104a84:	00 
c0104a85:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104a88:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104a8c:	89 04 24             	mov    %eax,(%esp)
c0104a8f:	e8 df fa ff ff       	call   c0104573 <page_insert>
c0104a94:	85 c0                	test   %eax,%eax
c0104a96:	74 24                	je     c0104abc <check_pgdir+0x415>
c0104a98:	c7 44 24 0c 80 6c 10 	movl   $0xc0106c80,0xc(%esp)
c0104a9f:	c0 
c0104aa0:	c7 44 24 08 51 6a 10 	movl   $0xc0106a51,0x8(%esp)
c0104aa7:	c0 
c0104aa8:	c7 44 24 04 f8 01 00 	movl   $0x1f8,0x4(%esp)
c0104aaf:	00 
c0104ab0:	c7 04 24 2c 6a 10 c0 	movl   $0xc0106a2c,(%esp)
c0104ab7:	e8 5c c1 ff ff       	call   c0100c18 <__panic>
    assert(page_ref(p1) == 2);
c0104abc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104abf:	89 04 24             	mov    %eax,(%esp)
c0104ac2:	e8 15 f0 ff ff       	call   c0103adc <page_ref>
c0104ac7:	83 f8 02             	cmp    $0x2,%eax
c0104aca:	74 24                	je     c0104af0 <check_pgdir+0x449>
c0104acc:	c7 44 24 0c ac 6c 10 	movl   $0xc0106cac,0xc(%esp)
c0104ad3:	c0 
c0104ad4:	c7 44 24 08 51 6a 10 	movl   $0xc0106a51,0x8(%esp)
c0104adb:	c0 
c0104adc:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
c0104ae3:	00 
c0104ae4:	c7 04 24 2c 6a 10 c0 	movl   $0xc0106a2c,(%esp)
c0104aeb:	e8 28 c1 ff ff       	call   c0100c18 <__panic>
    assert(page_ref(p2) == 0);
c0104af0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104af3:	89 04 24             	mov    %eax,(%esp)
c0104af6:	e8 e1 ef ff ff       	call   c0103adc <page_ref>
c0104afb:	85 c0                	test   %eax,%eax
c0104afd:	74 24                	je     c0104b23 <check_pgdir+0x47c>
c0104aff:	c7 44 24 0c be 6c 10 	movl   $0xc0106cbe,0xc(%esp)
c0104b06:	c0 
c0104b07:	c7 44 24 08 51 6a 10 	movl   $0xc0106a51,0x8(%esp)
c0104b0e:	c0 
c0104b0f:	c7 44 24 04 fa 01 00 	movl   $0x1fa,0x4(%esp)
c0104b16:	00 
c0104b17:	c7 04 24 2c 6a 10 c0 	movl   $0xc0106a2c,(%esp)
c0104b1e:	e8 f5 c0 ff ff       	call   c0100c18 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0104b23:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104b28:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104b2f:	00 
c0104b30:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104b37:	00 
c0104b38:	89 04 24             	mov    %eax,(%esp)
c0104b3b:	e8 5d f8 ff ff       	call   c010439d <get_pte>
c0104b40:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104b43:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104b47:	75 24                	jne    c0104b6d <check_pgdir+0x4c6>
c0104b49:	c7 44 24 0c 0c 6c 10 	movl   $0xc0106c0c,0xc(%esp)
c0104b50:	c0 
c0104b51:	c7 44 24 08 51 6a 10 	movl   $0xc0106a51,0x8(%esp)
c0104b58:	c0 
c0104b59:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
c0104b60:	00 
c0104b61:	c7 04 24 2c 6a 10 c0 	movl   $0xc0106a2c,(%esp)
c0104b68:	e8 ab c0 ff ff       	call   c0100c18 <__panic>
    assert(pte2page(*ptep) == p1);
c0104b6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b70:	8b 00                	mov    (%eax),%eax
c0104b72:	89 04 24             	mov    %eax,(%esp)
c0104b75:	e8 0c ef ff ff       	call   c0103a86 <pte2page>
c0104b7a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104b7d:	74 24                	je     c0104ba3 <check_pgdir+0x4fc>
c0104b7f:	c7 44 24 0c 81 6b 10 	movl   $0xc0106b81,0xc(%esp)
c0104b86:	c0 
c0104b87:	c7 44 24 08 51 6a 10 	movl   $0xc0106a51,0x8(%esp)
c0104b8e:	c0 
c0104b8f:	c7 44 24 04 fc 01 00 	movl   $0x1fc,0x4(%esp)
c0104b96:	00 
c0104b97:	c7 04 24 2c 6a 10 c0 	movl   $0xc0106a2c,(%esp)
c0104b9e:	e8 75 c0 ff ff       	call   c0100c18 <__panic>
    assert((*ptep & PTE_U) == 0);
c0104ba3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ba6:	8b 00                	mov    (%eax),%eax
c0104ba8:	83 e0 04             	and    $0x4,%eax
c0104bab:	85 c0                	test   %eax,%eax
c0104bad:	74 24                	je     c0104bd3 <check_pgdir+0x52c>
c0104baf:	c7 44 24 0c d0 6c 10 	movl   $0xc0106cd0,0xc(%esp)
c0104bb6:	c0 
c0104bb7:	c7 44 24 08 51 6a 10 	movl   $0xc0106a51,0x8(%esp)
c0104bbe:	c0 
c0104bbf:	c7 44 24 04 fd 01 00 	movl   $0x1fd,0x4(%esp)
c0104bc6:	00 
c0104bc7:	c7 04 24 2c 6a 10 c0 	movl   $0xc0106a2c,(%esp)
c0104bce:	e8 45 c0 ff ff       	call   c0100c18 <__panic>

    page_remove(boot_pgdir, 0x0);
c0104bd3:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104bd8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104bdf:	00 
c0104be0:	89 04 24             	mov    %eax,(%esp)
c0104be3:	e8 47 f9 ff ff       	call   c010452f <page_remove>
    assert(page_ref(p1) == 1);
c0104be8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104beb:	89 04 24             	mov    %eax,(%esp)
c0104bee:	e8 e9 ee ff ff       	call   c0103adc <page_ref>
c0104bf3:	83 f8 01             	cmp    $0x1,%eax
c0104bf6:	74 24                	je     c0104c1c <check_pgdir+0x575>
c0104bf8:	c7 44 24 0c 97 6b 10 	movl   $0xc0106b97,0xc(%esp)
c0104bff:	c0 
c0104c00:	c7 44 24 08 51 6a 10 	movl   $0xc0106a51,0x8(%esp)
c0104c07:	c0 
c0104c08:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
c0104c0f:	00 
c0104c10:	c7 04 24 2c 6a 10 c0 	movl   $0xc0106a2c,(%esp)
c0104c17:	e8 fc bf ff ff       	call   c0100c18 <__panic>
    assert(page_ref(p2) == 0);
c0104c1c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104c1f:	89 04 24             	mov    %eax,(%esp)
c0104c22:	e8 b5 ee ff ff       	call   c0103adc <page_ref>
c0104c27:	85 c0                	test   %eax,%eax
c0104c29:	74 24                	je     c0104c4f <check_pgdir+0x5a8>
c0104c2b:	c7 44 24 0c be 6c 10 	movl   $0xc0106cbe,0xc(%esp)
c0104c32:	c0 
c0104c33:	c7 44 24 08 51 6a 10 	movl   $0xc0106a51,0x8(%esp)
c0104c3a:	c0 
c0104c3b:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
c0104c42:	00 
c0104c43:	c7 04 24 2c 6a 10 c0 	movl   $0xc0106a2c,(%esp)
c0104c4a:	e8 c9 bf ff ff       	call   c0100c18 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0104c4f:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104c54:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104c5b:	00 
c0104c5c:	89 04 24             	mov    %eax,(%esp)
c0104c5f:	e8 cb f8 ff ff       	call   c010452f <page_remove>
    assert(page_ref(p1) == 0);
c0104c64:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c67:	89 04 24             	mov    %eax,(%esp)
c0104c6a:	e8 6d ee ff ff       	call   c0103adc <page_ref>
c0104c6f:	85 c0                	test   %eax,%eax
c0104c71:	74 24                	je     c0104c97 <check_pgdir+0x5f0>
c0104c73:	c7 44 24 0c e5 6c 10 	movl   $0xc0106ce5,0xc(%esp)
c0104c7a:	c0 
c0104c7b:	c7 44 24 08 51 6a 10 	movl   $0xc0106a51,0x8(%esp)
c0104c82:	c0 
c0104c83:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
c0104c8a:	00 
c0104c8b:	c7 04 24 2c 6a 10 c0 	movl   $0xc0106a2c,(%esp)
c0104c92:	e8 81 bf ff ff       	call   c0100c18 <__panic>
    assert(page_ref(p2) == 0);
c0104c97:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104c9a:	89 04 24             	mov    %eax,(%esp)
c0104c9d:	e8 3a ee ff ff       	call   c0103adc <page_ref>
c0104ca2:	85 c0                	test   %eax,%eax
c0104ca4:	74 24                	je     c0104cca <check_pgdir+0x623>
c0104ca6:	c7 44 24 0c be 6c 10 	movl   $0xc0106cbe,0xc(%esp)
c0104cad:	c0 
c0104cae:	c7 44 24 08 51 6a 10 	movl   $0xc0106a51,0x8(%esp)
c0104cb5:	c0 
c0104cb6:	c7 44 24 04 05 02 00 	movl   $0x205,0x4(%esp)
c0104cbd:	00 
c0104cbe:	c7 04 24 2c 6a 10 c0 	movl   $0xc0106a2c,(%esp)
c0104cc5:	e8 4e bf ff ff       	call   c0100c18 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0104cca:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104ccf:	8b 00                	mov    (%eax),%eax
c0104cd1:	89 04 24             	mov    %eax,(%esp)
c0104cd4:	e8 eb ed ff ff       	call   c0103ac4 <pde2page>
c0104cd9:	89 04 24             	mov    %eax,(%esp)
c0104cdc:	e8 fb ed ff ff       	call   c0103adc <page_ref>
c0104ce1:	83 f8 01             	cmp    $0x1,%eax
c0104ce4:	74 24                	je     c0104d0a <check_pgdir+0x663>
c0104ce6:	c7 44 24 0c f8 6c 10 	movl   $0xc0106cf8,0xc(%esp)
c0104ced:	c0 
c0104cee:	c7 44 24 08 51 6a 10 	movl   $0xc0106a51,0x8(%esp)
c0104cf5:	c0 
c0104cf6:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
c0104cfd:	00 
c0104cfe:	c7 04 24 2c 6a 10 c0 	movl   $0xc0106a2c,(%esp)
c0104d05:	e8 0e bf ff ff       	call   c0100c18 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0104d0a:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104d0f:	8b 00                	mov    (%eax),%eax
c0104d11:	89 04 24             	mov    %eax,(%esp)
c0104d14:	e8 ab ed ff ff       	call   c0103ac4 <pde2page>
c0104d19:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104d20:	00 
c0104d21:	89 04 24             	mov    %eax,(%esp)
c0104d24:	e8 f0 ef ff ff       	call   c0103d19 <free_pages>
    boot_pgdir[0] = 0;
c0104d29:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104d2e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0104d34:	c7 04 24 1f 6d 10 c0 	movl   $0xc0106d1f,(%esp)
c0104d3b:	e8 08 b6 ff ff       	call   c0100348 <cprintf>
}
c0104d40:	c9                   	leave  
c0104d41:	c3                   	ret    

c0104d42 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0104d42:	55                   	push   %ebp
c0104d43:	89 e5                	mov    %esp,%ebp
c0104d45:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0104d48:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104d4f:	e9 ca 00 00 00       	jmp    c0104e1e <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0104d54:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d57:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104d5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d5d:	c1 e8 0c             	shr    $0xc,%eax
c0104d60:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104d63:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0104d68:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0104d6b:	72 23                	jb     c0104d90 <check_boot_pgdir+0x4e>
c0104d6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d70:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104d74:	c7 44 24 08 64 69 10 	movl   $0xc0106964,0x8(%esp)
c0104d7b:	c0 
c0104d7c:	c7 44 24 04 13 02 00 	movl   $0x213,0x4(%esp)
c0104d83:	00 
c0104d84:	c7 04 24 2c 6a 10 c0 	movl   $0xc0106a2c,(%esp)
c0104d8b:	e8 88 be ff ff       	call   c0100c18 <__panic>
c0104d90:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d93:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0104d98:	89 c2                	mov    %eax,%edx
c0104d9a:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104d9f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104da6:	00 
c0104da7:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104dab:	89 04 24             	mov    %eax,(%esp)
c0104dae:	e8 ea f5 ff ff       	call   c010439d <get_pte>
c0104db3:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104db6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104dba:	75 24                	jne    c0104de0 <check_boot_pgdir+0x9e>
c0104dbc:	c7 44 24 0c 3c 6d 10 	movl   $0xc0106d3c,0xc(%esp)
c0104dc3:	c0 
c0104dc4:	c7 44 24 08 51 6a 10 	movl   $0xc0106a51,0x8(%esp)
c0104dcb:	c0 
c0104dcc:	c7 44 24 04 13 02 00 	movl   $0x213,0x4(%esp)
c0104dd3:	00 
c0104dd4:	c7 04 24 2c 6a 10 c0 	movl   $0xc0106a2c,(%esp)
c0104ddb:	e8 38 be ff ff       	call   c0100c18 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0104de0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104de3:	8b 00                	mov    (%eax),%eax
c0104de5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104dea:	89 c2                	mov    %eax,%edx
c0104dec:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104def:	39 c2                	cmp    %eax,%edx
c0104df1:	74 24                	je     c0104e17 <check_boot_pgdir+0xd5>
c0104df3:	c7 44 24 0c 79 6d 10 	movl   $0xc0106d79,0xc(%esp)
c0104dfa:	c0 
c0104dfb:	c7 44 24 08 51 6a 10 	movl   $0xc0106a51,0x8(%esp)
c0104e02:	c0 
c0104e03:	c7 44 24 04 14 02 00 	movl   $0x214,0x4(%esp)
c0104e0a:	00 
c0104e0b:	c7 04 24 2c 6a 10 c0 	movl   $0xc0106a2c,(%esp)
c0104e12:	e8 01 be ff ff       	call   c0100c18 <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0104e17:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0104e1e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104e21:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0104e26:	39 c2                	cmp    %eax,%edx
c0104e28:	0f 82 26 ff ff ff    	jb     c0104d54 <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0104e2e:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104e33:	05 ac 0f 00 00       	add    $0xfac,%eax
c0104e38:	8b 00                	mov    (%eax),%eax
c0104e3a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104e3f:	89 c2                	mov    %eax,%edx
c0104e41:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104e46:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104e49:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
c0104e50:	77 23                	ja     c0104e75 <check_boot_pgdir+0x133>
c0104e52:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104e55:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104e59:	c7 44 24 08 08 6a 10 	movl   $0xc0106a08,0x8(%esp)
c0104e60:	c0 
c0104e61:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
c0104e68:	00 
c0104e69:	c7 04 24 2c 6a 10 c0 	movl   $0xc0106a2c,(%esp)
c0104e70:	e8 a3 bd ff ff       	call   c0100c18 <__panic>
c0104e75:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104e78:	05 00 00 00 40       	add    $0x40000000,%eax
c0104e7d:	39 c2                	cmp    %eax,%edx
c0104e7f:	74 24                	je     c0104ea5 <check_boot_pgdir+0x163>
c0104e81:	c7 44 24 0c 90 6d 10 	movl   $0xc0106d90,0xc(%esp)
c0104e88:	c0 
c0104e89:	c7 44 24 08 51 6a 10 	movl   $0xc0106a51,0x8(%esp)
c0104e90:	c0 
c0104e91:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
c0104e98:	00 
c0104e99:	c7 04 24 2c 6a 10 c0 	movl   $0xc0106a2c,(%esp)
c0104ea0:	e8 73 bd ff ff       	call   c0100c18 <__panic>

    assert(boot_pgdir[0] == 0);
c0104ea5:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104eaa:	8b 00                	mov    (%eax),%eax
c0104eac:	85 c0                	test   %eax,%eax
c0104eae:	74 24                	je     c0104ed4 <check_boot_pgdir+0x192>
c0104eb0:	c7 44 24 0c c4 6d 10 	movl   $0xc0106dc4,0xc(%esp)
c0104eb7:	c0 
c0104eb8:	c7 44 24 08 51 6a 10 	movl   $0xc0106a51,0x8(%esp)
c0104ebf:	c0 
c0104ec0:	c7 44 24 04 19 02 00 	movl   $0x219,0x4(%esp)
c0104ec7:	00 
c0104ec8:	c7 04 24 2c 6a 10 c0 	movl   $0xc0106a2c,(%esp)
c0104ecf:	e8 44 bd ff ff       	call   c0100c18 <__panic>

    struct Page *p;
    p = alloc_page();
c0104ed4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104edb:	e8 01 ee ff ff       	call   c0103ce1 <alloc_pages>
c0104ee0:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0104ee3:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104ee8:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0104eef:	00 
c0104ef0:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0104ef7:	00 
c0104ef8:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104efb:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104eff:	89 04 24             	mov    %eax,(%esp)
c0104f02:	e8 6c f6 ff ff       	call   c0104573 <page_insert>
c0104f07:	85 c0                	test   %eax,%eax
c0104f09:	74 24                	je     c0104f2f <check_boot_pgdir+0x1ed>
c0104f0b:	c7 44 24 0c d8 6d 10 	movl   $0xc0106dd8,0xc(%esp)
c0104f12:	c0 
c0104f13:	c7 44 24 08 51 6a 10 	movl   $0xc0106a51,0x8(%esp)
c0104f1a:	c0 
c0104f1b:	c7 44 24 04 1d 02 00 	movl   $0x21d,0x4(%esp)
c0104f22:	00 
c0104f23:	c7 04 24 2c 6a 10 c0 	movl   $0xc0106a2c,(%esp)
c0104f2a:	e8 e9 bc ff ff       	call   c0100c18 <__panic>
    assert(page_ref(p) == 1);
c0104f2f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104f32:	89 04 24             	mov    %eax,(%esp)
c0104f35:	e8 a2 eb ff ff       	call   c0103adc <page_ref>
c0104f3a:	83 f8 01             	cmp    $0x1,%eax
c0104f3d:	74 24                	je     c0104f63 <check_boot_pgdir+0x221>
c0104f3f:	c7 44 24 0c 06 6e 10 	movl   $0xc0106e06,0xc(%esp)
c0104f46:	c0 
c0104f47:	c7 44 24 08 51 6a 10 	movl   $0xc0106a51,0x8(%esp)
c0104f4e:	c0 
c0104f4f:	c7 44 24 04 1e 02 00 	movl   $0x21e,0x4(%esp)
c0104f56:	00 
c0104f57:	c7 04 24 2c 6a 10 c0 	movl   $0xc0106a2c,(%esp)
c0104f5e:	e8 b5 bc ff ff       	call   c0100c18 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0104f63:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104f68:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0104f6f:	00 
c0104f70:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0104f77:	00 
c0104f78:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104f7b:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104f7f:	89 04 24             	mov    %eax,(%esp)
c0104f82:	e8 ec f5 ff ff       	call   c0104573 <page_insert>
c0104f87:	85 c0                	test   %eax,%eax
c0104f89:	74 24                	je     c0104faf <check_boot_pgdir+0x26d>
c0104f8b:	c7 44 24 0c 18 6e 10 	movl   $0xc0106e18,0xc(%esp)
c0104f92:	c0 
c0104f93:	c7 44 24 08 51 6a 10 	movl   $0xc0106a51,0x8(%esp)
c0104f9a:	c0 
c0104f9b:	c7 44 24 04 1f 02 00 	movl   $0x21f,0x4(%esp)
c0104fa2:	00 
c0104fa3:	c7 04 24 2c 6a 10 c0 	movl   $0xc0106a2c,(%esp)
c0104faa:	e8 69 bc ff ff       	call   c0100c18 <__panic>
    assert(page_ref(p) == 2);
c0104faf:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104fb2:	89 04 24             	mov    %eax,(%esp)
c0104fb5:	e8 22 eb ff ff       	call   c0103adc <page_ref>
c0104fba:	83 f8 02             	cmp    $0x2,%eax
c0104fbd:	74 24                	je     c0104fe3 <check_boot_pgdir+0x2a1>
c0104fbf:	c7 44 24 0c 4f 6e 10 	movl   $0xc0106e4f,0xc(%esp)
c0104fc6:	c0 
c0104fc7:	c7 44 24 08 51 6a 10 	movl   $0xc0106a51,0x8(%esp)
c0104fce:	c0 
c0104fcf:	c7 44 24 04 20 02 00 	movl   $0x220,0x4(%esp)
c0104fd6:	00 
c0104fd7:	c7 04 24 2c 6a 10 c0 	movl   $0xc0106a2c,(%esp)
c0104fde:	e8 35 bc ff ff       	call   c0100c18 <__panic>

    const char *str = "ucore: Hello world!!";
c0104fe3:	c7 45 dc 60 6e 10 c0 	movl   $0xc0106e60,-0x24(%ebp)
    strcpy((void *)0x100, str);
c0104fea:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104fed:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104ff1:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0104ff8:	e8 19 0a 00 00       	call   c0105a16 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0104ffd:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c0105004:	00 
c0105005:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c010500c:	e8 7e 0a 00 00       	call   c0105a8f <strcmp>
c0105011:	85 c0                	test   %eax,%eax
c0105013:	74 24                	je     c0105039 <check_boot_pgdir+0x2f7>
c0105015:	c7 44 24 0c 78 6e 10 	movl   $0xc0106e78,0xc(%esp)
c010501c:	c0 
c010501d:	c7 44 24 08 51 6a 10 	movl   $0xc0106a51,0x8(%esp)
c0105024:	c0 
c0105025:	c7 44 24 04 24 02 00 	movl   $0x224,0x4(%esp)
c010502c:	00 
c010502d:	c7 04 24 2c 6a 10 c0 	movl   $0xc0106a2c,(%esp)
c0105034:	e8 df bb ff ff       	call   c0100c18 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0105039:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010503c:	89 04 24             	mov    %eax,(%esp)
c010503f:	e8 ee e9 ff ff       	call   c0103a32 <page2kva>
c0105044:	05 00 01 00 00       	add    $0x100,%eax
c0105049:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c010504c:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0105053:	e8 66 09 00 00       	call   c01059be <strlen>
c0105058:	85 c0                	test   %eax,%eax
c010505a:	74 24                	je     c0105080 <check_boot_pgdir+0x33e>
c010505c:	c7 44 24 0c b0 6e 10 	movl   $0xc0106eb0,0xc(%esp)
c0105063:	c0 
c0105064:	c7 44 24 08 51 6a 10 	movl   $0xc0106a51,0x8(%esp)
c010506b:	c0 
c010506c:	c7 44 24 04 27 02 00 	movl   $0x227,0x4(%esp)
c0105073:	00 
c0105074:	c7 04 24 2c 6a 10 c0 	movl   $0xc0106a2c,(%esp)
c010507b:	e8 98 bb ff ff       	call   c0100c18 <__panic>

    free_page(p);
c0105080:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105087:	00 
c0105088:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010508b:	89 04 24             	mov    %eax,(%esp)
c010508e:	e8 86 ec ff ff       	call   c0103d19 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c0105093:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0105098:	8b 00                	mov    (%eax),%eax
c010509a:	89 04 24             	mov    %eax,(%esp)
c010509d:	e8 22 ea ff ff       	call   c0103ac4 <pde2page>
c01050a2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01050a9:	00 
c01050aa:	89 04 24             	mov    %eax,(%esp)
c01050ad:	e8 67 ec ff ff       	call   c0103d19 <free_pages>
    boot_pgdir[0] = 0;
c01050b2:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01050b7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c01050bd:	c7 04 24 d4 6e 10 c0 	movl   $0xc0106ed4,(%esp)
c01050c4:	e8 7f b2 ff ff       	call   c0100348 <cprintf>
}
c01050c9:	c9                   	leave  
c01050ca:	c3                   	ret    

c01050cb <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c01050cb:	55                   	push   %ebp
c01050cc:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c01050ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01050d1:	83 e0 04             	and    $0x4,%eax
c01050d4:	85 c0                	test   %eax,%eax
c01050d6:	74 07                	je     c01050df <perm2str+0x14>
c01050d8:	b8 75 00 00 00       	mov    $0x75,%eax
c01050dd:	eb 05                	jmp    c01050e4 <perm2str+0x19>
c01050df:	b8 2d 00 00 00       	mov    $0x2d,%eax
c01050e4:	a2 08 af 11 c0       	mov    %al,0xc011af08
    str[1] = 'r';
c01050e9:	c6 05 09 af 11 c0 72 	movb   $0x72,0xc011af09
    str[2] = (perm & PTE_W) ? 'w' : '-';
c01050f0:	8b 45 08             	mov    0x8(%ebp),%eax
c01050f3:	83 e0 02             	and    $0x2,%eax
c01050f6:	85 c0                	test   %eax,%eax
c01050f8:	74 07                	je     c0105101 <perm2str+0x36>
c01050fa:	b8 77 00 00 00       	mov    $0x77,%eax
c01050ff:	eb 05                	jmp    c0105106 <perm2str+0x3b>
c0105101:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0105106:	a2 0a af 11 c0       	mov    %al,0xc011af0a
    str[3] = '\0';
c010510b:	c6 05 0b af 11 c0 00 	movb   $0x0,0xc011af0b
    return str;
c0105112:	b8 08 af 11 c0       	mov    $0xc011af08,%eax
}
c0105117:	5d                   	pop    %ebp
c0105118:	c3                   	ret    

c0105119 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0105119:	55                   	push   %ebp
c010511a:	89 e5                	mov    %esp,%ebp
c010511c:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c010511f:	8b 45 10             	mov    0x10(%ebp),%eax
c0105122:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105125:	72 0a                	jb     c0105131 <get_pgtable_items+0x18>
        return 0;
c0105127:	b8 00 00 00 00       	mov    $0x0,%eax
c010512c:	e9 9c 00 00 00       	jmp    c01051cd <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
c0105131:	eb 04                	jmp    c0105137 <get_pgtable_items+0x1e>
        start ++;
c0105133:	83 45 10 01          	addl   $0x1,0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
c0105137:	8b 45 10             	mov    0x10(%ebp),%eax
c010513a:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010513d:	73 18                	jae    c0105157 <get_pgtable_items+0x3e>
c010513f:	8b 45 10             	mov    0x10(%ebp),%eax
c0105142:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105149:	8b 45 14             	mov    0x14(%ebp),%eax
c010514c:	01 d0                	add    %edx,%eax
c010514e:	8b 00                	mov    (%eax),%eax
c0105150:	83 e0 01             	and    $0x1,%eax
c0105153:	85 c0                	test   %eax,%eax
c0105155:	74 dc                	je     c0105133 <get_pgtable_items+0x1a>
        start ++;
    }
    if (start < right) {
c0105157:	8b 45 10             	mov    0x10(%ebp),%eax
c010515a:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010515d:	73 69                	jae    c01051c8 <get_pgtable_items+0xaf>
        if (left_store != NULL) {
c010515f:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0105163:	74 08                	je     c010516d <get_pgtable_items+0x54>
            *left_store = start;
c0105165:	8b 45 18             	mov    0x18(%ebp),%eax
c0105168:	8b 55 10             	mov    0x10(%ebp),%edx
c010516b:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c010516d:	8b 45 10             	mov    0x10(%ebp),%eax
c0105170:	8d 50 01             	lea    0x1(%eax),%edx
c0105173:	89 55 10             	mov    %edx,0x10(%ebp)
c0105176:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010517d:	8b 45 14             	mov    0x14(%ebp),%eax
c0105180:	01 d0                	add    %edx,%eax
c0105182:	8b 00                	mov    (%eax),%eax
c0105184:	83 e0 07             	and    $0x7,%eax
c0105187:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c010518a:	eb 04                	jmp    c0105190 <get_pgtable_items+0x77>
            start ++;
c010518c:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
c0105190:	8b 45 10             	mov    0x10(%ebp),%eax
c0105193:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105196:	73 1d                	jae    c01051b5 <get_pgtable_items+0x9c>
c0105198:	8b 45 10             	mov    0x10(%ebp),%eax
c010519b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01051a2:	8b 45 14             	mov    0x14(%ebp),%eax
c01051a5:	01 d0                	add    %edx,%eax
c01051a7:	8b 00                	mov    (%eax),%eax
c01051a9:	83 e0 07             	and    $0x7,%eax
c01051ac:	89 c2                	mov    %eax,%edx
c01051ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01051b1:	39 c2                	cmp    %eax,%edx
c01051b3:	74 d7                	je     c010518c <get_pgtable_items+0x73>
            start ++;
        }
        if (right_store != NULL) {
c01051b5:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c01051b9:	74 08                	je     c01051c3 <get_pgtable_items+0xaa>
            *right_store = start;
c01051bb:	8b 45 1c             	mov    0x1c(%ebp),%eax
c01051be:	8b 55 10             	mov    0x10(%ebp),%edx
c01051c1:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c01051c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01051c6:	eb 05                	jmp    c01051cd <get_pgtable_items+0xb4>
    }
    return 0;
c01051c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01051cd:	c9                   	leave  
c01051ce:	c3                   	ret    

c01051cf <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c01051cf:	55                   	push   %ebp
c01051d0:	89 e5                	mov    %esp,%ebp
c01051d2:	57                   	push   %edi
c01051d3:	56                   	push   %esi
c01051d4:	53                   	push   %ebx
c01051d5:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c01051d8:	c7 04 24 f4 6e 10 c0 	movl   $0xc0106ef4,(%esp)
c01051df:	e8 64 b1 ff ff       	call   c0100348 <cprintf>
    size_t left, right = 0, perm;
c01051e4:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c01051eb:	e9 fa 00 00 00       	jmp    c01052ea <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c01051f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01051f3:	89 04 24             	mov    %eax,(%esp)
c01051f6:	e8 d0 fe ff ff       	call   c01050cb <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c01051fb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c01051fe:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105201:	29 d1                	sub    %edx,%ecx
c0105203:	89 ca                	mov    %ecx,%edx
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0105205:	89 d6                	mov    %edx,%esi
c0105207:	c1 e6 16             	shl    $0x16,%esi
c010520a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010520d:	89 d3                	mov    %edx,%ebx
c010520f:	c1 e3 16             	shl    $0x16,%ebx
c0105212:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105215:	89 d1                	mov    %edx,%ecx
c0105217:	c1 e1 16             	shl    $0x16,%ecx
c010521a:	8b 7d dc             	mov    -0x24(%ebp),%edi
c010521d:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105220:	29 d7                	sub    %edx,%edi
c0105222:	89 fa                	mov    %edi,%edx
c0105224:	89 44 24 14          	mov    %eax,0x14(%esp)
c0105228:	89 74 24 10          	mov    %esi,0x10(%esp)
c010522c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0105230:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0105234:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105238:	c7 04 24 25 6f 10 c0 	movl   $0xc0106f25,(%esp)
c010523f:	e8 04 b1 ff ff       	call   c0100348 <cprintf>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
c0105244:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105247:	c1 e0 0a             	shl    $0xa,%eax
c010524a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c010524d:	eb 54                	jmp    c01052a3 <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c010524f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105252:	89 04 24             	mov    %eax,(%esp)
c0105255:	e8 71 fe ff ff       	call   c01050cb <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c010525a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c010525d:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105260:	29 d1                	sub    %edx,%ecx
c0105262:	89 ca                	mov    %ecx,%edx
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0105264:	89 d6                	mov    %edx,%esi
c0105266:	c1 e6 0c             	shl    $0xc,%esi
c0105269:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010526c:	89 d3                	mov    %edx,%ebx
c010526e:	c1 e3 0c             	shl    $0xc,%ebx
c0105271:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105274:	c1 e2 0c             	shl    $0xc,%edx
c0105277:	89 d1                	mov    %edx,%ecx
c0105279:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c010527c:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010527f:	29 d7                	sub    %edx,%edi
c0105281:	89 fa                	mov    %edi,%edx
c0105283:	89 44 24 14          	mov    %eax,0x14(%esp)
c0105287:	89 74 24 10          	mov    %esi,0x10(%esp)
c010528b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c010528f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0105293:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105297:	c7 04 24 44 6f 10 c0 	movl   $0xc0106f44,(%esp)
c010529e:	e8 a5 b0 ff ff       	call   c0100348 <cprintf>
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c01052a3:	ba 00 00 c0 fa       	mov    $0xfac00000,%edx
c01052a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01052ab:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c01052ae:	89 ce                	mov    %ecx,%esi
c01052b0:	c1 e6 0a             	shl    $0xa,%esi
c01052b3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c01052b6:	89 cb                	mov    %ecx,%ebx
c01052b8:	c1 e3 0a             	shl    $0xa,%ebx
c01052bb:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
c01052be:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c01052c2:	8d 4d d8             	lea    -0x28(%ebp),%ecx
c01052c5:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c01052c9:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01052cd:	89 44 24 08          	mov    %eax,0x8(%esp)
c01052d1:	89 74 24 04          	mov    %esi,0x4(%esp)
c01052d5:	89 1c 24             	mov    %ebx,(%esp)
c01052d8:	e8 3c fe ff ff       	call   c0105119 <get_pgtable_items>
c01052dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01052e0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01052e4:	0f 85 65 ff ff ff    	jne    c010524f <print_pgdir+0x80>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c01052ea:	ba 00 b0 fe fa       	mov    $0xfafeb000,%edx
c01052ef:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01052f2:	8d 4d dc             	lea    -0x24(%ebp),%ecx
c01052f5:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c01052f9:	8d 4d e0             	lea    -0x20(%ebp),%ecx
c01052fc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0105300:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105304:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105308:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c010530f:	00 
c0105310:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0105317:	e8 fd fd ff ff       	call   c0105119 <get_pgtable_items>
c010531c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010531f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105323:	0f 85 c7 fe ff ff    	jne    c01051f0 <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0105329:	c7 04 24 68 6f 10 c0 	movl   $0xc0106f68,(%esp)
c0105330:	e8 13 b0 ff ff       	call   c0100348 <cprintf>
}
c0105335:	83 c4 4c             	add    $0x4c,%esp
c0105338:	5b                   	pop    %ebx
c0105339:	5e                   	pop    %esi
c010533a:	5f                   	pop    %edi
c010533b:	5d                   	pop    %ebp
c010533c:	c3                   	ret    

c010533d <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c010533d:	55                   	push   %ebp
c010533e:	89 e5                	mov    %esp,%ebp
c0105340:	83 ec 58             	sub    $0x58,%esp
c0105343:	8b 45 10             	mov    0x10(%ebp),%eax
c0105346:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0105349:	8b 45 14             	mov    0x14(%ebp),%eax
c010534c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c010534f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105352:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105355:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105358:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c010535b:	8b 45 18             	mov    0x18(%ebp),%eax
c010535e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105361:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105364:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105367:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010536a:	89 55 f0             	mov    %edx,-0x10(%ebp)
c010536d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105370:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105373:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105377:	74 1c                	je     c0105395 <printnum+0x58>
c0105379:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010537c:	ba 00 00 00 00       	mov    $0x0,%edx
c0105381:	f7 75 e4             	divl   -0x1c(%ebp)
c0105384:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0105387:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010538a:	ba 00 00 00 00       	mov    $0x0,%edx
c010538f:	f7 75 e4             	divl   -0x1c(%ebp)
c0105392:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105395:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105398:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010539b:	f7 75 e4             	divl   -0x1c(%ebp)
c010539e:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01053a1:	89 55 dc             	mov    %edx,-0x24(%ebp)
c01053a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01053a7:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01053aa:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01053ad:	89 55 ec             	mov    %edx,-0x14(%ebp)
c01053b0:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01053b3:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c01053b6:	8b 45 18             	mov    0x18(%ebp),%eax
c01053b9:	ba 00 00 00 00       	mov    $0x0,%edx
c01053be:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01053c1:	77 56                	ja     c0105419 <printnum+0xdc>
c01053c3:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01053c6:	72 05                	jb     c01053cd <printnum+0x90>
c01053c8:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c01053cb:	77 4c                	ja     c0105419 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c01053cd:	8b 45 1c             	mov    0x1c(%ebp),%eax
c01053d0:	8d 50 ff             	lea    -0x1(%eax),%edx
c01053d3:	8b 45 20             	mov    0x20(%ebp),%eax
c01053d6:	89 44 24 18          	mov    %eax,0x18(%esp)
c01053da:	89 54 24 14          	mov    %edx,0x14(%esp)
c01053de:	8b 45 18             	mov    0x18(%ebp),%eax
c01053e1:	89 44 24 10          	mov    %eax,0x10(%esp)
c01053e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01053e8:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01053eb:	89 44 24 08          	mov    %eax,0x8(%esp)
c01053ef:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01053f3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01053f6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01053fa:	8b 45 08             	mov    0x8(%ebp),%eax
c01053fd:	89 04 24             	mov    %eax,(%esp)
c0105400:	e8 38 ff ff ff       	call   c010533d <printnum>
c0105405:	eb 1c                	jmp    c0105423 <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c0105407:	8b 45 0c             	mov    0xc(%ebp),%eax
c010540a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010540e:	8b 45 20             	mov    0x20(%ebp),%eax
c0105411:	89 04 24             	mov    %eax,(%esp)
c0105414:	8b 45 08             	mov    0x8(%ebp),%eax
c0105417:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
c0105419:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
c010541d:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0105421:	7f e4                	jg     c0105407 <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c0105423:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105426:	05 1c 70 10 c0       	add    $0xc010701c,%eax
c010542b:	0f b6 00             	movzbl (%eax),%eax
c010542e:	0f be c0             	movsbl %al,%eax
c0105431:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105434:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105438:	89 04 24             	mov    %eax,(%esp)
c010543b:	8b 45 08             	mov    0x8(%ebp),%eax
c010543e:	ff d0                	call   *%eax
}
c0105440:	c9                   	leave  
c0105441:	c3                   	ret    

c0105442 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c0105442:	55                   	push   %ebp
c0105443:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0105445:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0105449:	7e 14                	jle    c010545f <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c010544b:	8b 45 08             	mov    0x8(%ebp),%eax
c010544e:	8b 00                	mov    (%eax),%eax
c0105450:	8d 48 08             	lea    0x8(%eax),%ecx
c0105453:	8b 55 08             	mov    0x8(%ebp),%edx
c0105456:	89 0a                	mov    %ecx,(%edx)
c0105458:	8b 50 04             	mov    0x4(%eax),%edx
c010545b:	8b 00                	mov    (%eax),%eax
c010545d:	eb 30                	jmp    c010548f <getuint+0x4d>
    }
    else if (lflag) {
c010545f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105463:	74 16                	je     c010547b <getuint+0x39>
        return va_arg(*ap, unsigned long);
c0105465:	8b 45 08             	mov    0x8(%ebp),%eax
c0105468:	8b 00                	mov    (%eax),%eax
c010546a:	8d 48 04             	lea    0x4(%eax),%ecx
c010546d:	8b 55 08             	mov    0x8(%ebp),%edx
c0105470:	89 0a                	mov    %ecx,(%edx)
c0105472:	8b 00                	mov    (%eax),%eax
c0105474:	ba 00 00 00 00       	mov    $0x0,%edx
c0105479:	eb 14                	jmp    c010548f <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c010547b:	8b 45 08             	mov    0x8(%ebp),%eax
c010547e:	8b 00                	mov    (%eax),%eax
c0105480:	8d 48 04             	lea    0x4(%eax),%ecx
c0105483:	8b 55 08             	mov    0x8(%ebp),%edx
c0105486:	89 0a                	mov    %ecx,(%edx)
c0105488:	8b 00                	mov    (%eax),%eax
c010548a:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c010548f:	5d                   	pop    %ebp
c0105490:	c3                   	ret    

c0105491 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c0105491:	55                   	push   %ebp
c0105492:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0105494:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0105498:	7e 14                	jle    c01054ae <getint+0x1d>
        return va_arg(*ap, long long);
c010549a:	8b 45 08             	mov    0x8(%ebp),%eax
c010549d:	8b 00                	mov    (%eax),%eax
c010549f:	8d 48 08             	lea    0x8(%eax),%ecx
c01054a2:	8b 55 08             	mov    0x8(%ebp),%edx
c01054a5:	89 0a                	mov    %ecx,(%edx)
c01054a7:	8b 50 04             	mov    0x4(%eax),%edx
c01054aa:	8b 00                	mov    (%eax),%eax
c01054ac:	eb 28                	jmp    c01054d6 <getint+0x45>
    }
    else if (lflag) {
c01054ae:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01054b2:	74 12                	je     c01054c6 <getint+0x35>
        return va_arg(*ap, long);
c01054b4:	8b 45 08             	mov    0x8(%ebp),%eax
c01054b7:	8b 00                	mov    (%eax),%eax
c01054b9:	8d 48 04             	lea    0x4(%eax),%ecx
c01054bc:	8b 55 08             	mov    0x8(%ebp),%edx
c01054bf:	89 0a                	mov    %ecx,(%edx)
c01054c1:	8b 00                	mov    (%eax),%eax
c01054c3:	99                   	cltd   
c01054c4:	eb 10                	jmp    c01054d6 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c01054c6:	8b 45 08             	mov    0x8(%ebp),%eax
c01054c9:	8b 00                	mov    (%eax),%eax
c01054cb:	8d 48 04             	lea    0x4(%eax),%ecx
c01054ce:	8b 55 08             	mov    0x8(%ebp),%edx
c01054d1:	89 0a                	mov    %ecx,(%edx)
c01054d3:	8b 00                	mov    (%eax),%eax
c01054d5:	99                   	cltd   
    }
}
c01054d6:	5d                   	pop    %ebp
c01054d7:	c3                   	ret    

c01054d8 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c01054d8:	55                   	push   %ebp
c01054d9:	89 e5                	mov    %esp,%ebp
c01054db:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c01054de:	8d 45 14             	lea    0x14(%ebp),%eax
c01054e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c01054e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01054e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01054eb:	8b 45 10             	mov    0x10(%ebp),%eax
c01054ee:	89 44 24 08          	mov    %eax,0x8(%esp)
c01054f2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01054f5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01054f9:	8b 45 08             	mov    0x8(%ebp),%eax
c01054fc:	89 04 24             	mov    %eax,(%esp)
c01054ff:	e8 02 00 00 00       	call   c0105506 <vprintfmt>
    va_end(ap);
}
c0105504:	c9                   	leave  
c0105505:	c3                   	ret    

c0105506 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c0105506:	55                   	push   %ebp
c0105507:	89 e5                	mov    %esp,%ebp
c0105509:	56                   	push   %esi
c010550a:	53                   	push   %ebx
c010550b:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010550e:	eb 18                	jmp    c0105528 <vprintfmt+0x22>
            if (ch == '\0') {
c0105510:	85 db                	test   %ebx,%ebx
c0105512:	75 05                	jne    c0105519 <vprintfmt+0x13>
                return;
c0105514:	e9 d1 03 00 00       	jmp    c01058ea <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
c0105519:	8b 45 0c             	mov    0xc(%ebp),%eax
c010551c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105520:	89 1c 24             	mov    %ebx,(%esp)
c0105523:	8b 45 08             	mov    0x8(%ebp),%eax
c0105526:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0105528:	8b 45 10             	mov    0x10(%ebp),%eax
c010552b:	8d 50 01             	lea    0x1(%eax),%edx
c010552e:	89 55 10             	mov    %edx,0x10(%ebp)
c0105531:	0f b6 00             	movzbl (%eax),%eax
c0105534:	0f b6 d8             	movzbl %al,%ebx
c0105537:	83 fb 25             	cmp    $0x25,%ebx
c010553a:	75 d4                	jne    c0105510 <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
c010553c:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c0105540:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c0105547:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010554a:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c010554d:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0105554:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105557:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c010555a:	8b 45 10             	mov    0x10(%ebp),%eax
c010555d:	8d 50 01             	lea    0x1(%eax),%edx
c0105560:	89 55 10             	mov    %edx,0x10(%ebp)
c0105563:	0f b6 00             	movzbl (%eax),%eax
c0105566:	0f b6 d8             	movzbl %al,%ebx
c0105569:	8d 43 dd             	lea    -0x23(%ebx),%eax
c010556c:	83 f8 55             	cmp    $0x55,%eax
c010556f:	0f 87 44 03 00 00    	ja     c01058b9 <vprintfmt+0x3b3>
c0105575:	8b 04 85 40 70 10 c0 	mov    -0x3fef8fc0(,%eax,4),%eax
c010557c:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c010557e:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c0105582:	eb d6                	jmp    c010555a <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c0105584:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c0105588:	eb d0                	jmp    c010555a <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c010558a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c0105591:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105594:	89 d0                	mov    %edx,%eax
c0105596:	c1 e0 02             	shl    $0x2,%eax
c0105599:	01 d0                	add    %edx,%eax
c010559b:	01 c0                	add    %eax,%eax
c010559d:	01 d8                	add    %ebx,%eax
c010559f:	83 e8 30             	sub    $0x30,%eax
c01055a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c01055a5:	8b 45 10             	mov    0x10(%ebp),%eax
c01055a8:	0f b6 00             	movzbl (%eax),%eax
c01055ab:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c01055ae:	83 fb 2f             	cmp    $0x2f,%ebx
c01055b1:	7e 0b                	jle    c01055be <vprintfmt+0xb8>
c01055b3:	83 fb 39             	cmp    $0x39,%ebx
c01055b6:	7f 06                	jg     c01055be <vprintfmt+0xb8>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c01055b8:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
c01055bc:	eb d3                	jmp    c0105591 <vprintfmt+0x8b>
            goto process_precision;
c01055be:	eb 33                	jmp    c01055f3 <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
c01055c0:	8b 45 14             	mov    0x14(%ebp),%eax
c01055c3:	8d 50 04             	lea    0x4(%eax),%edx
c01055c6:	89 55 14             	mov    %edx,0x14(%ebp)
c01055c9:	8b 00                	mov    (%eax),%eax
c01055cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c01055ce:	eb 23                	jmp    c01055f3 <vprintfmt+0xed>

        case '.':
            if (width < 0)
c01055d0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01055d4:	79 0c                	jns    c01055e2 <vprintfmt+0xdc>
                width = 0;
c01055d6:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c01055dd:	e9 78 ff ff ff       	jmp    c010555a <vprintfmt+0x54>
c01055e2:	e9 73 ff ff ff       	jmp    c010555a <vprintfmt+0x54>

        case '#':
            altflag = 1;
c01055e7:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c01055ee:	e9 67 ff ff ff       	jmp    c010555a <vprintfmt+0x54>

        process_precision:
            if (width < 0)
c01055f3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01055f7:	79 12                	jns    c010560b <vprintfmt+0x105>
                width = precision, precision = -1;
c01055f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01055fc:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01055ff:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c0105606:	e9 4f ff ff ff       	jmp    c010555a <vprintfmt+0x54>
c010560b:	e9 4a ff ff ff       	jmp    c010555a <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c0105610:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
c0105614:	e9 41 ff ff ff       	jmp    c010555a <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c0105619:	8b 45 14             	mov    0x14(%ebp),%eax
c010561c:	8d 50 04             	lea    0x4(%eax),%edx
c010561f:	89 55 14             	mov    %edx,0x14(%ebp)
c0105622:	8b 00                	mov    (%eax),%eax
c0105624:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105627:	89 54 24 04          	mov    %edx,0x4(%esp)
c010562b:	89 04 24             	mov    %eax,(%esp)
c010562e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105631:	ff d0                	call   *%eax
            break;
c0105633:	e9 ac 02 00 00       	jmp    c01058e4 <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
c0105638:	8b 45 14             	mov    0x14(%ebp),%eax
c010563b:	8d 50 04             	lea    0x4(%eax),%edx
c010563e:	89 55 14             	mov    %edx,0x14(%ebp)
c0105641:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c0105643:	85 db                	test   %ebx,%ebx
c0105645:	79 02                	jns    c0105649 <vprintfmt+0x143>
                err = -err;
c0105647:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c0105649:	83 fb 06             	cmp    $0x6,%ebx
c010564c:	7f 0b                	jg     c0105659 <vprintfmt+0x153>
c010564e:	8b 34 9d 00 70 10 c0 	mov    -0x3fef9000(,%ebx,4),%esi
c0105655:	85 f6                	test   %esi,%esi
c0105657:	75 23                	jne    c010567c <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
c0105659:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c010565d:	c7 44 24 08 2d 70 10 	movl   $0xc010702d,0x8(%esp)
c0105664:	c0 
c0105665:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105668:	89 44 24 04          	mov    %eax,0x4(%esp)
c010566c:	8b 45 08             	mov    0x8(%ebp),%eax
c010566f:	89 04 24             	mov    %eax,(%esp)
c0105672:	e8 61 fe ff ff       	call   c01054d8 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c0105677:	e9 68 02 00 00       	jmp    c01058e4 <vprintfmt+0x3de>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
c010567c:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0105680:	c7 44 24 08 36 70 10 	movl   $0xc0107036,0x8(%esp)
c0105687:	c0 
c0105688:	8b 45 0c             	mov    0xc(%ebp),%eax
c010568b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010568f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105692:	89 04 24             	mov    %eax,(%esp)
c0105695:	e8 3e fe ff ff       	call   c01054d8 <printfmt>
            }
            break;
c010569a:	e9 45 02 00 00       	jmp    c01058e4 <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c010569f:	8b 45 14             	mov    0x14(%ebp),%eax
c01056a2:	8d 50 04             	lea    0x4(%eax),%edx
c01056a5:	89 55 14             	mov    %edx,0x14(%ebp)
c01056a8:	8b 30                	mov    (%eax),%esi
c01056aa:	85 f6                	test   %esi,%esi
c01056ac:	75 05                	jne    c01056b3 <vprintfmt+0x1ad>
                p = "(null)";
c01056ae:	be 39 70 10 c0       	mov    $0xc0107039,%esi
            }
            if (width > 0 && padc != '-') {
c01056b3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01056b7:	7e 3e                	jle    c01056f7 <vprintfmt+0x1f1>
c01056b9:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c01056bd:	74 38                	je     c01056f7 <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
c01056bf:	8b 5d e8             	mov    -0x18(%ebp),%ebx
c01056c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01056c5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01056c9:	89 34 24             	mov    %esi,(%esp)
c01056cc:	e8 15 03 00 00       	call   c01059e6 <strnlen>
c01056d1:	29 c3                	sub    %eax,%ebx
c01056d3:	89 d8                	mov    %ebx,%eax
c01056d5:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01056d8:	eb 17                	jmp    c01056f1 <vprintfmt+0x1eb>
                    putch(padc, putdat);
c01056da:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c01056de:	8b 55 0c             	mov    0xc(%ebp),%edx
c01056e1:	89 54 24 04          	mov    %edx,0x4(%esp)
c01056e5:	89 04 24             	mov    %eax,(%esp)
c01056e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01056eb:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
c01056ed:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c01056f1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01056f5:	7f e3                	jg     c01056da <vprintfmt+0x1d4>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c01056f7:	eb 38                	jmp    c0105731 <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
c01056f9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01056fd:	74 1f                	je     c010571e <vprintfmt+0x218>
c01056ff:	83 fb 1f             	cmp    $0x1f,%ebx
c0105702:	7e 05                	jle    c0105709 <vprintfmt+0x203>
c0105704:	83 fb 7e             	cmp    $0x7e,%ebx
c0105707:	7e 15                	jle    c010571e <vprintfmt+0x218>
                    putch('?', putdat);
c0105709:	8b 45 0c             	mov    0xc(%ebp),%eax
c010570c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105710:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c0105717:	8b 45 08             	mov    0x8(%ebp),%eax
c010571a:	ff d0                	call   *%eax
c010571c:	eb 0f                	jmp    c010572d <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
c010571e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105721:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105725:	89 1c 24             	mov    %ebx,(%esp)
c0105728:	8b 45 08             	mov    0x8(%ebp),%eax
c010572b:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010572d:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c0105731:	89 f0                	mov    %esi,%eax
c0105733:	8d 70 01             	lea    0x1(%eax),%esi
c0105736:	0f b6 00             	movzbl (%eax),%eax
c0105739:	0f be d8             	movsbl %al,%ebx
c010573c:	85 db                	test   %ebx,%ebx
c010573e:	74 10                	je     c0105750 <vprintfmt+0x24a>
c0105740:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105744:	78 b3                	js     c01056f9 <vprintfmt+0x1f3>
c0105746:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
c010574a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010574e:	79 a9                	jns    c01056f9 <vprintfmt+0x1f3>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c0105750:	eb 17                	jmp    c0105769 <vprintfmt+0x263>
                putch(' ', putdat);
c0105752:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105755:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105759:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0105760:	8b 45 08             	mov    0x8(%ebp),%eax
c0105763:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c0105765:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c0105769:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010576d:	7f e3                	jg     c0105752 <vprintfmt+0x24c>
                putch(' ', putdat);
            }
            break;
c010576f:	e9 70 01 00 00       	jmp    c01058e4 <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c0105774:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105777:	89 44 24 04          	mov    %eax,0x4(%esp)
c010577b:	8d 45 14             	lea    0x14(%ebp),%eax
c010577e:	89 04 24             	mov    %eax,(%esp)
c0105781:	e8 0b fd ff ff       	call   c0105491 <getint>
c0105786:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105789:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c010578c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010578f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105792:	85 d2                	test   %edx,%edx
c0105794:	79 26                	jns    c01057bc <vprintfmt+0x2b6>
                putch('-', putdat);
c0105796:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105799:	89 44 24 04          	mov    %eax,0x4(%esp)
c010579d:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c01057a4:	8b 45 08             	mov    0x8(%ebp),%eax
c01057a7:	ff d0                	call   *%eax
                num = -(long long)num;
c01057a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01057ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01057af:	f7 d8                	neg    %eax
c01057b1:	83 d2 00             	adc    $0x0,%edx
c01057b4:	f7 da                	neg    %edx
c01057b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01057b9:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c01057bc:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c01057c3:	e9 a8 00 00 00       	jmp    c0105870 <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c01057c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01057cb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01057cf:	8d 45 14             	lea    0x14(%ebp),%eax
c01057d2:	89 04 24             	mov    %eax,(%esp)
c01057d5:	e8 68 fc ff ff       	call   c0105442 <getuint>
c01057da:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01057dd:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c01057e0:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c01057e7:	e9 84 00 00 00       	jmp    c0105870 <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c01057ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01057ef:	89 44 24 04          	mov    %eax,0x4(%esp)
c01057f3:	8d 45 14             	lea    0x14(%ebp),%eax
c01057f6:	89 04 24             	mov    %eax,(%esp)
c01057f9:	e8 44 fc ff ff       	call   c0105442 <getuint>
c01057fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105801:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c0105804:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c010580b:	eb 63                	jmp    c0105870 <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
c010580d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105810:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105814:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c010581b:	8b 45 08             	mov    0x8(%ebp),%eax
c010581e:	ff d0                	call   *%eax
            putch('x', putdat);
c0105820:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105823:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105827:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c010582e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105831:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c0105833:	8b 45 14             	mov    0x14(%ebp),%eax
c0105836:	8d 50 04             	lea    0x4(%eax),%edx
c0105839:	89 55 14             	mov    %edx,0x14(%ebp)
c010583c:	8b 00                	mov    (%eax),%eax
c010583e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105841:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c0105848:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c010584f:	eb 1f                	jmp    c0105870 <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c0105851:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105854:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105858:	8d 45 14             	lea    0x14(%ebp),%eax
c010585b:	89 04 24             	mov    %eax,(%esp)
c010585e:	e8 df fb ff ff       	call   c0105442 <getuint>
c0105863:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105866:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c0105869:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c0105870:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c0105874:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105877:	89 54 24 18          	mov    %edx,0x18(%esp)
c010587b:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010587e:	89 54 24 14          	mov    %edx,0x14(%esp)
c0105882:	89 44 24 10          	mov    %eax,0x10(%esp)
c0105886:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105889:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010588c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105890:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105894:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105897:	89 44 24 04          	mov    %eax,0x4(%esp)
c010589b:	8b 45 08             	mov    0x8(%ebp),%eax
c010589e:	89 04 24             	mov    %eax,(%esp)
c01058a1:	e8 97 fa ff ff       	call   c010533d <printnum>
            break;
c01058a6:	eb 3c                	jmp    c01058e4 <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c01058a8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01058ab:	89 44 24 04          	mov    %eax,0x4(%esp)
c01058af:	89 1c 24             	mov    %ebx,(%esp)
c01058b2:	8b 45 08             	mov    0x8(%ebp),%eax
c01058b5:	ff d0                	call   *%eax
            break;
c01058b7:	eb 2b                	jmp    c01058e4 <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c01058b9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01058bc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01058c0:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c01058c7:	8b 45 08             	mov    0x8(%ebp),%eax
c01058ca:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c01058cc:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c01058d0:	eb 04                	jmp    c01058d6 <vprintfmt+0x3d0>
c01058d2:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c01058d6:	8b 45 10             	mov    0x10(%ebp),%eax
c01058d9:	83 e8 01             	sub    $0x1,%eax
c01058dc:	0f b6 00             	movzbl (%eax),%eax
c01058df:	3c 25                	cmp    $0x25,%al
c01058e1:	75 ef                	jne    c01058d2 <vprintfmt+0x3cc>
                /* do nothing */;
            break;
c01058e3:	90                   	nop
        }
    }
c01058e4:	90                   	nop
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c01058e5:	e9 3e fc ff ff       	jmp    c0105528 <vprintfmt+0x22>
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
c01058ea:	83 c4 40             	add    $0x40,%esp
c01058ed:	5b                   	pop    %ebx
c01058ee:	5e                   	pop    %esi
c01058ef:	5d                   	pop    %ebp
c01058f0:	c3                   	ret    

c01058f1 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c01058f1:	55                   	push   %ebp
c01058f2:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c01058f4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01058f7:	8b 40 08             	mov    0x8(%eax),%eax
c01058fa:	8d 50 01             	lea    0x1(%eax),%edx
c01058fd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105900:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c0105903:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105906:	8b 10                	mov    (%eax),%edx
c0105908:	8b 45 0c             	mov    0xc(%ebp),%eax
c010590b:	8b 40 04             	mov    0x4(%eax),%eax
c010590e:	39 c2                	cmp    %eax,%edx
c0105910:	73 12                	jae    c0105924 <sprintputch+0x33>
        *b->buf ++ = ch;
c0105912:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105915:	8b 00                	mov    (%eax),%eax
c0105917:	8d 48 01             	lea    0x1(%eax),%ecx
c010591a:	8b 55 0c             	mov    0xc(%ebp),%edx
c010591d:	89 0a                	mov    %ecx,(%edx)
c010591f:	8b 55 08             	mov    0x8(%ebp),%edx
c0105922:	88 10                	mov    %dl,(%eax)
    }
}
c0105924:	5d                   	pop    %ebp
c0105925:	c3                   	ret    

c0105926 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c0105926:	55                   	push   %ebp
c0105927:	89 e5                	mov    %esp,%ebp
c0105929:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010592c:	8d 45 14             	lea    0x14(%ebp),%eax
c010592f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0105932:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105935:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105939:	8b 45 10             	mov    0x10(%ebp),%eax
c010593c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105940:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105943:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105947:	8b 45 08             	mov    0x8(%ebp),%eax
c010594a:	89 04 24             	mov    %eax,(%esp)
c010594d:	e8 08 00 00 00       	call   c010595a <vsnprintf>
c0105952:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0105955:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105958:	c9                   	leave  
c0105959:	c3                   	ret    

c010595a <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c010595a:	55                   	push   %ebp
c010595b:	89 e5                	mov    %esp,%ebp
c010595d:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0105960:	8b 45 08             	mov    0x8(%ebp),%eax
c0105963:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105966:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105969:	8d 50 ff             	lea    -0x1(%eax),%edx
c010596c:	8b 45 08             	mov    0x8(%ebp),%eax
c010596f:	01 d0                	add    %edx,%eax
c0105971:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105974:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c010597b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010597f:	74 0a                	je     c010598b <vsnprintf+0x31>
c0105981:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105984:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105987:	39 c2                	cmp    %eax,%edx
c0105989:	76 07                	jbe    c0105992 <vsnprintf+0x38>
        return -E_INVAL;
c010598b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0105990:	eb 2a                	jmp    c01059bc <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c0105992:	8b 45 14             	mov    0x14(%ebp),%eax
c0105995:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105999:	8b 45 10             	mov    0x10(%ebp),%eax
c010599c:	89 44 24 08          	mov    %eax,0x8(%esp)
c01059a0:	8d 45 ec             	lea    -0x14(%ebp),%eax
c01059a3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01059a7:	c7 04 24 f1 58 10 c0 	movl   $0xc01058f1,(%esp)
c01059ae:	e8 53 fb ff ff       	call   c0105506 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c01059b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01059b6:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c01059b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01059bc:	c9                   	leave  
c01059bd:	c3                   	ret    

c01059be <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c01059be:	55                   	push   %ebp
c01059bf:	89 e5                	mov    %esp,%ebp
c01059c1:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c01059c4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c01059cb:	eb 04                	jmp    c01059d1 <strlen+0x13>
        cnt ++;
c01059cd:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
c01059d1:	8b 45 08             	mov    0x8(%ebp),%eax
c01059d4:	8d 50 01             	lea    0x1(%eax),%edx
c01059d7:	89 55 08             	mov    %edx,0x8(%ebp)
c01059da:	0f b6 00             	movzbl (%eax),%eax
c01059dd:	84 c0                	test   %al,%al
c01059df:	75 ec                	jne    c01059cd <strlen+0xf>
        cnt ++;
    }
    return cnt;
c01059e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01059e4:	c9                   	leave  
c01059e5:	c3                   	ret    

c01059e6 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c01059e6:	55                   	push   %ebp
c01059e7:	89 e5                	mov    %esp,%ebp
c01059e9:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c01059ec:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c01059f3:	eb 04                	jmp    c01059f9 <strnlen+0x13>
        cnt ++;
c01059f5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
c01059f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01059fc:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01059ff:	73 10                	jae    c0105a11 <strnlen+0x2b>
c0105a01:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a04:	8d 50 01             	lea    0x1(%eax),%edx
c0105a07:	89 55 08             	mov    %edx,0x8(%ebp)
c0105a0a:	0f b6 00             	movzbl (%eax),%eax
c0105a0d:	84 c0                	test   %al,%al
c0105a0f:	75 e4                	jne    c01059f5 <strnlen+0xf>
        cnt ++;
    }
    return cnt;
c0105a11:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0105a14:	c9                   	leave  
c0105a15:	c3                   	ret    

c0105a16 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c0105a16:	55                   	push   %ebp
c0105a17:	89 e5                	mov    %esp,%ebp
c0105a19:	57                   	push   %edi
c0105a1a:	56                   	push   %esi
c0105a1b:	83 ec 20             	sub    $0x20,%esp
c0105a1e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a21:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105a24:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a27:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c0105a2a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105a2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a30:	89 d1                	mov    %edx,%ecx
c0105a32:	89 c2                	mov    %eax,%edx
c0105a34:	89 ce                	mov    %ecx,%esi
c0105a36:	89 d7                	mov    %edx,%edi
c0105a38:	ac                   	lods   %ds:(%esi),%al
c0105a39:	aa                   	stos   %al,%es:(%edi)
c0105a3a:	84 c0                	test   %al,%al
c0105a3c:	75 fa                	jne    c0105a38 <strcpy+0x22>
c0105a3e:	89 fa                	mov    %edi,%edx
c0105a40:	89 f1                	mov    %esi,%ecx
c0105a42:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0105a45:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0105a48:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c0105a4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c0105a4e:	83 c4 20             	add    $0x20,%esp
c0105a51:	5e                   	pop    %esi
c0105a52:	5f                   	pop    %edi
c0105a53:	5d                   	pop    %ebp
c0105a54:	c3                   	ret    

c0105a55 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c0105a55:	55                   	push   %ebp
c0105a56:	89 e5                	mov    %esp,%ebp
c0105a58:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c0105a5b:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a5e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c0105a61:	eb 21                	jmp    c0105a84 <strncpy+0x2f>
        if ((*p = *src) != '\0') {
c0105a63:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a66:	0f b6 10             	movzbl (%eax),%edx
c0105a69:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105a6c:	88 10                	mov    %dl,(%eax)
c0105a6e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105a71:	0f b6 00             	movzbl (%eax),%eax
c0105a74:	84 c0                	test   %al,%al
c0105a76:	74 04                	je     c0105a7c <strncpy+0x27>
            src ++;
c0105a78:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
c0105a7c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0105a80:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
c0105a84:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105a88:	75 d9                	jne    c0105a63 <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
c0105a8a:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0105a8d:	c9                   	leave  
c0105a8e:	c3                   	ret    

c0105a8f <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c0105a8f:	55                   	push   %ebp
c0105a90:	89 e5                	mov    %esp,%ebp
c0105a92:	57                   	push   %edi
c0105a93:	56                   	push   %esi
c0105a94:	83 ec 20             	sub    $0x20,%esp
c0105a97:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a9a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105a9d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105aa0:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
c0105aa3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105aa6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105aa9:	89 d1                	mov    %edx,%ecx
c0105aab:	89 c2                	mov    %eax,%edx
c0105aad:	89 ce                	mov    %ecx,%esi
c0105aaf:	89 d7                	mov    %edx,%edi
c0105ab1:	ac                   	lods   %ds:(%esi),%al
c0105ab2:	ae                   	scas   %es:(%edi),%al
c0105ab3:	75 08                	jne    c0105abd <strcmp+0x2e>
c0105ab5:	84 c0                	test   %al,%al
c0105ab7:	75 f8                	jne    c0105ab1 <strcmp+0x22>
c0105ab9:	31 c0                	xor    %eax,%eax
c0105abb:	eb 04                	jmp    c0105ac1 <strcmp+0x32>
c0105abd:	19 c0                	sbb    %eax,%eax
c0105abf:	0c 01                	or     $0x1,%al
c0105ac1:	89 fa                	mov    %edi,%edx
c0105ac3:	89 f1                	mov    %esi,%ecx
c0105ac5:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105ac8:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0105acb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
c0105ace:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c0105ad1:	83 c4 20             	add    $0x20,%esp
c0105ad4:	5e                   	pop    %esi
c0105ad5:	5f                   	pop    %edi
c0105ad6:	5d                   	pop    %ebp
c0105ad7:	c3                   	ret    

c0105ad8 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c0105ad8:	55                   	push   %ebp
c0105ad9:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0105adb:	eb 0c                	jmp    c0105ae9 <strncmp+0x11>
        n --, s1 ++, s2 ++;
c0105add:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0105ae1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105ae5:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0105ae9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105aed:	74 1a                	je     c0105b09 <strncmp+0x31>
c0105aef:	8b 45 08             	mov    0x8(%ebp),%eax
c0105af2:	0f b6 00             	movzbl (%eax),%eax
c0105af5:	84 c0                	test   %al,%al
c0105af7:	74 10                	je     c0105b09 <strncmp+0x31>
c0105af9:	8b 45 08             	mov    0x8(%ebp),%eax
c0105afc:	0f b6 10             	movzbl (%eax),%edx
c0105aff:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b02:	0f b6 00             	movzbl (%eax),%eax
c0105b05:	38 c2                	cmp    %al,%dl
c0105b07:	74 d4                	je     c0105add <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c0105b09:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105b0d:	74 18                	je     c0105b27 <strncmp+0x4f>
c0105b0f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b12:	0f b6 00             	movzbl (%eax),%eax
c0105b15:	0f b6 d0             	movzbl %al,%edx
c0105b18:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b1b:	0f b6 00             	movzbl (%eax),%eax
c0105b1e:	0f b6 c0             	movzbl %al,%eax
c0105b21:	29 c2                	sub    %eax,%edx
c0105b23:	89 d0                	mov    %edx,%eax
c0105b25:	eb 05                	jmp    c0105b2c <strncmp+0x54>
c0105b27:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105b2c:	5d                   	pop    %ebp
c0105b2d:	c3                   	ret    

c0105b2e <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0105b2e:	55                   	push   %ebp
c0105b2f:	89 e5                	mov    %esp,%ebp
c0105b31:	83 ec 04             	sub    $0x4,%esp
c0105b34:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b37:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0105b3a:	eb 14                	jmp    c0105b50 <strchr+0x22>
        if (*s == c) {
c0105b3c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b3f:	0f b6 00             	movzbl (%eax),%eax
c0105b42:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0105b45:	75 05                	jne    c0105b4c <strchr+0x1e>
            return (char *)s;
c0105b47:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b4a:	eb 13                	jmp    c0105b5f <strchr+0x31>
        }
        s ++;
c0105b4c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
c0105b50:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b53:	0f b6 00             	movzbl (%eax),%eax
c0105b56:	84 c0                	test   %al,%al
c0105b58:	75 e2                	jne    c0105b3c <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
c0105b5a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105b5f:	c9                   	leave  
c0105b60:	c3                   	ret    

c0105b61 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0105b61:	55                   	push   %ebp
c0105b62:	89 e5                	mov    %esp,%ebp
c0105b64:	83 ec 04             	sub    $0x4,%esp
c0105b67:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b6a:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0105b6d:	eb 11                	jmp    c0105b80 <strfind+0x1f>
        if (*s == c) {
c0105b6f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b72:	0f b6 00             	movzbl (%eax),%eax
c0105b75:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0105b78:	75 02                	jne    c0105b7c <strfind+0x1b>
            break;
c0105b7a:	eb 0e                	jmp    c0105b8a <strfind+0x29>
        }
        s ++;
c0105b7c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
c0105b80:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b83:	0f b6 00             	movzbl (%eax),%eax
c0105b86:	84 c0                	test   %al,%al
c0105b88:	75 e5                	jne    c0105b6f <strfind+0xe>
        if (*s == c) {
            break;
        }
        s ++;
    }
    return (char *)s;
c0105b8a:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0105b8d:	c9                   	leave  
c0105b8e:	c3                   	ret    

c0105b8f <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0105b8f:	55                   	push   %ebp
c0105b90:	89 e5                	mov    %esp,%ebp
c0105b92:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c0105b95:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0105b9c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0105ba3:	eb 04                	jmp    c0105ba9 <strtol+0x1a>
        s ++;
c0105ba5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0105ba9:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bac:	0f b6 00             	movzbl (%eax),%eax
c0105baf:	3c 20                	cmp    $0x20,%al
c0105bb1:	74 f2                	je     c0105ba5 <strtol+0x16>
c0105bb3:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bb6:	0f b6 00             	movzbl (%eax),%eax
c0105bb9:	3c 09                	cmp    $0x9,%al
c0105bbb:	74 e8                	je     c0105ba5 <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
c0105bbd:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bc0:	0f b6 00             	movzbl (%eax),%eax
c0105bc3:	3c 2b                	cmp    $0x2b,%al
c0105bc5:	75 06                	jne    c0105bcd <strtol+0x3e>
        s ++;
c0105bc7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105bcb:	eb 15                	jmp    c0105be2 <strtol+0x53>
    }
    else if (*s == '-') {
c0105bcd:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bd0:	0f b6 00             	movzbl (%eax),%eax
c0105bd3:	3c 2d                	cmp    $0x2d,%al
c0105bd5:	75 0b                	jne    c0105be2 <strtol+0x53>
        s ++, neg = 1;
c0105bd7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105bdb:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c0105be2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105be6:	74 06                	je     c0105bee <strtol+0x5f>
c0105be8:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c0105bec:	75 24                	jne    c0105c12 <strtol+0x83>
c0105bee:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bf1:	0f b6 00             	movzbl (%eax),%eax
c0105bf4:	3c 30                	cmp    $0x30,%al
c0105bf6:	75 1a                	jne    c0105c12 <strtol+0x83>
c0105bf8:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bfb:	83 c0 01             	add    $0x1,%eax
c0105bfe:	0f b6 00             	movzbl (%eax),%eax
c0105c01:	3c 78                	cmp    $0x78,%al
c0105c03:	75 0d                	jne    c0105c12 <strtol+0x83>
        s += 2, base = 16;
c0105c05:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c0105c09:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c0105c10:	eb 2a                	jmp    c0105c3c <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
c0105c12:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105c16:	75 17                	jne    c0105c2f <strtol+0xa0>
c0105c18:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c1b:	0f b6 00             	movzbl (%eax),%eax
c0105c1e:	3c 30                	cmp    $0x30,%al
c0105c20:	75 0d                	jne    c0105c2f <strtol+0xa0>
        s ++, base = 8;
c0105c22:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105c26:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c0105c2d:	eb 0d                	jmp    c0105c3c <strtol+0xad>
    }
    else if (base == 0) {
c0105c2f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105c33:	75 07                	jne    c0105c3c <strtol+0xad>
        base = 10;
c0105c35:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c0105c3c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c3f:	0f b6 00             	movzbl (%eax),%eax
c0105c42:	3c 2f                	cmp    $0x2f,%al
c0105c44:	7e 1b                	jle    c0105c61 <strtol+0xd2>
c0105c46:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c49:	0f b6 00             	movzbl (%eax),%eax
c0105c4c:	3c 39                	cmp    $0x39,%al
c0105c4e:	7f 11                	jg     c0105c61 <strtol+0xd2>
            dig = *s - '0';
c0105c50:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c53:	0f b6 00             	movzbl (%eax),%eax
c0105c56:	0f be c0             	movsbl %al,%eax
c0105c59:	83 e8 30             	sub    $0x30,%eax
c0105c5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105c5f:	eb 48                	jmp    c0105ca9 <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0105c61:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c64:	0f b6 00             	movzbl (%eax),%eax
c0105c67:	3c 60                	cmp    $0x60,%al
c0105c69:	7e 1b                	jle    c0105c86 <strtol+0xf7>
c0105c6b:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c6e:	0f b6 00             	movzbl (%eax),%eax
c0105c71:	3c 7a                	cmp    $0x7a,%al
c0105c73:	7f 11                	jg     c0105c86 <strtol+0xf7>
            dig = *s - 'a' + 10;
c0105c75:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c78:	0f b6 00             	movzbl (%eax),%eax
c0105c7b:	0f be c0             	movsbl %al,%eax
c0105c7e:	83 e8 57             	sub    $0x57,%eax
c0105c81:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105c84:	eb 23                	jmp    c0105ca9 <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c0105c86:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c89:	0f b6 00             	movzbl (%eax),%eax
c0105c8c:	3c 40                	cmp    $0x40,%al
c0105c8e:	7e 3d                	jle    c0105ccd <strtol+0x13e>
c0105c90:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c93:	0f b6 00             	movzbl (%eax),%eax
c0105c96:	3c 5a                	cmp    $0x5a,%al
c0105c98:	7f 33                	jg     c0105ccd <strtol+0x13e>
            dig = *s - 'A' + 10;
c0105c9a:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c9d:	0f b6 00             	movzbl (%eax),%eax
c0105ca0:	0f be c0             	movsbl %al,%eax
c0105ca3:	83 e8 37             	sub    $0x37,%eax
c0105ca6:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c0105ca9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105cac:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105caf:	7c 02                	jl     c0105cb3 <strtol+0x124>
            break;
c0105cb1:	eb 1a                	jmp    c0105ccd <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
c0105cb3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105cb7:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105cba:	0f af 45 10          	imul   0x10(%ebp),%eax
c0105cbe:	89 c2                	mov    %eax,%edx
c0105cc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105cc3:	01 d0                	add    %edx,%eax
c0105cc5:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
c0105cc8:	e9 6f ff ff ff       	jmp    c0105c3c <strtol+0xad>

    if (endptr) {
c0105ccd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105cd1:	74 08                	je     c0105cdb <strtol+0x14c>
        *endptr = (char *) s;
c0105cd3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105cd6:	8b 55 08             	mov    0x8(%ebp),%edx
c0105cd9:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c0105cdb:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0105cdf:	74 07                	je     c0105ce8 <strtol+0x159>
c0105ce1:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105ce4:	f7 d8                	neg    %eax
c0105ce6:	eb 03                	jmp    c0105ceb <strtol+0x15c>
c0105ce8:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c0105ceb:	c9                   	leave  
c0105cec:	c3                   	ret    

c0105ced <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c0105ced:	55                   	push   %ebp
c0105cee:	89 e5                	mov    %esp,%ebp
c0105cf0:	57                   	push   %edi
c0105cf1:	83 ec 24             	sub    $0x24,%esp
c0105cf4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105cf7:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c0105cfa:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c0105cfe:	8b 55 08             	mov    0x8(%ebp),%edx
c0105d01:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0105d04:	88 45 f7             	mov    %al,-0x9(%ebp)
c0105d07:	8b 45 10             	mov    0x10(%ebp),%eax
c0105d0a:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c0105d0d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0105d10:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0105d14:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0105d17:	89 d7                	mov    %edx,%edi
c0105d19:	f3 aa                	rep stos %al,%es:(%edi)
c0105d1b:	89 fa                	mov    %edi,%edx
c0105d1d:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0105d20:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c0105d23:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0105d26:	83 c4 24             	add    $0x24,%esp
c0105d29:	5f                   	pop    %edi
c0105d2a:	5d                   	pop    %ebp
c0105d2b:	c3                   	ret    

c0105d2c <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c0105d2c:	55                   	push   %ebp
c0105d2d:	89 e5                	mov    %esp,%ebp
c0105d2f:	57                   	push   %edi
c0105d30:	56                   	push   %esi
c0105d31:	53                   	push   %ebx
c0105d32:	83 ec 30             	sub    $0x30,%esp
c0105d35:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d38:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105d3b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d3e:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105d41:	8b 45 10             	mov    0x10(%ebp),%eax
c0105d44:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c0105d47:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d4a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0105d4d:	73 42                	jae    c0105d91 <memmove+0x65>
c0105d4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d52:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105d55:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105d58:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105d5b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105d5e:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0105d61:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105d64:	c1 e8 02             	shr    $0x2,%eax
c0105d67:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c0105d69:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105d6c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105d6f:	89 d7                	mov    %edx,%edi
c0105d71:	89 c6                	mov    %eax,%esi
c0105d73:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0105d75:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0105d78:	83 e1 03             	and    $0x3,%ecx
c0105d7b:	74 02                	je     c0105d7f <memmove+0x53>
c0105d7d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105d7f:	89 f0                	mov    %esi,%eax
c0105d81:	89 fa                	mov    %edi,%edx
c0105d83:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c0105d86:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0105d89:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c0105d8c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105d8f:	eb 36                	jmp    c0105dc7 <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c0105d91:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105d94:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105d97:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105d9a:	01 c2                	add    %eax,%edx
c0105d9c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105d9f:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0105da2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105da5:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
c0105da8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105dab:	89 c1                	mov    %eax,%ecx
c0105dad:	89 d8                	mov    %ebx,%eax
c0105daf:	89 d6                	mov    %edx,%esi
c0105db1:	89 c7                	mov    %eax,%edi
c0105db3:	fd                   	std    
c0105db4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105db6:	fc                   	cld    
c0105db7:	89 f8                	mov    %edi,%eax
c0105db9:	89 f2                	mov    %esi,%edx
c0105dbb:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c0105dbe:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0105dc1:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
c0105dc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c0105dc7:	83 c4 30             	add    $0x30,%esp
c0105dca:	5b                   	pop    %ebx
c0105dcb:	5e                   	pop    %esi
c0105dcc:	5f                   	pop    %edi
c0105dcd:	5d                   	pop    %ebp
c0105dce:	c3                   	ret    

c0105dcf <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c0105dcf:	55                   	push   %ebp
c0105dd0:	89 e5                	mov    %esp,%ebp
c0105dd2:	57                   	push   %edi
c0105dd3:	56                   	push   %esi
c0105dd4:	83 ec 20             	sub    $0x20,%esp
c0105dd7:	8b 45 08             	mov    0x8(%ebp),%eax
c0105dda:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105ddd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105de0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105de3:	8b 45 10             	mov    0x10(%ebp),%eax
c0105de6:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0105de9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105dec:	c1 e8 02             	shr    $0x2,%eax
c0105def:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c0105df1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105df4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105df7:	89 d7                	mov    %edx,%edi
c0105df9:	89 c6                	mov    %eax,%esi
c0105dfb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0105dfd:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c0105e00:	83 e1 03             	and    $0x3,%ecx
c0105e03:	74 02                	je     c0105e07 <memcpy+0x38>
c0105e05:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105e07:	89 f0                	mov    %esi,%eax
c0105e09:	89 fa                	mov    %edi,%edx
c0105e0b:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0105e0e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0105e11:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c0105e14:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c0105e17:	83 c4 20             	add    $0x20,%esp
c0105e1a:	5e                   	pop    %esi
c0105e1b:	5f                   	pop    %edi
c0105e1c:	5d                   	pop    %ebp
c0105e1d:	c3                   	ret    

c0105e1e <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c0105e1e:	55                   	push   %ebp
c0105e1f:	89 e5                	mov    %esp,%ebp
c0105e21:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c0105e24:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e27:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c0105e2a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e2d:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c0105e30:	eb 30                	jmp    c0105e62 <memcmp+0x44>
        if (*s1 != *s2) {
c0105e32:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105e35:	0f b6 10             	movzbl (%eax),%edx
c0105e38:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105e3b:	0f b6 00             	movzbl (%eax),%eax
c0105e3e:	38 c2                	cmp    %al,%dl
c0105e40:	74 18                	je     c0105e5a <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c0105e42:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105e45:	0f b6 00             	movzbl (%eax),%eax
c0105e48:	0f b6 d0             	movzbl %al,%edx
c0105e4b:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105e4e:	0f b6 00             	movzbl (%eax),%eax
c0105e51:	0f b6 c0             	movzbl %al,%eax
c0105e54:	29 c2                	sub    %eax,%edx
c0105e56:	89 d0                	mov    %edx,%eax
c0105e58:	eb 1a                	jmp    c0105e74 <memcmp+0x56>
        }
        s1 ++, s2 ++;
c0105e5a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0105e5e:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
c0105e62:	8b 45 10             	mov    0x10(%ebp),%eax
c0105e65:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105e68:	89 55 10             	mov    %edx,0x10(%ebp)
c0105e6b:	85 c0                	test   %eax,%eax
c0105e6d:	75 c3                	jne    c0105e32 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
c0105e6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105e74:	c9                   	leave  
c0105e75:	c3                   	ret    
