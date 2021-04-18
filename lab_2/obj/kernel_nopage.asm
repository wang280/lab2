
bin/kernel_nopage：     文件格式 elf32-i386


Disassembly of section .text:

00100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
  100000:	b8 00 80 11 40       	mov    $0x40118000,%eax
    movl %eax, %cr3
  100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
  100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
  10000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
  100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
  100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
  100016:	8d 05 1e 00 10 00    	lea    0x10001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
  10001c:	ff e0                	jmp    *%eax

0010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
  10001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
  100020:	a3 00 80 11 00       	mov    %eax,0x118000

    # set ebp, esp
    movl $0x0, %ebp
  100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
  10002a:	bc 00 70 11 00       	mov    $0x117000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
  10002f:	e8 02 00 00 00       	call   100036 <kern_init>

00100034 <spin>:

# should never get here
spin:
    jmp spin
  100034:	eb fe                	jmp    100034 <spin>

00100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
  100036:	55                   	push   %ebp
  100037:	89 e5                	mov    %esp,%ebp
  100039:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
  10003c:	ba 28 af 11 00       	mov    $0x11af28,%edx
  100041:	b8 36 7a 11 00       	mov    $0x117a36,%eax
  100046:	29 c2                	sub    %eax,%edx
  100048:	89 d0                	mov    %edx,%eax
  10004a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  100055:	00 
  100056:	c7 04 24 36 7a 11 00 	movl   $0x117a36,(%esp)
  10005d:	e8 8b 5c 00 00       	call   105ced <memset>

    cons_init();                // init the console
  100062:	e8 c8 14 00 00       	call   10152f <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  100067:	c7 45 f4 80 5e 10 00 	movl   $0x105e80,-0xc(%ebp)
    cprintf("%s\n\n", message);
  10006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100071:	89 44 24 04          	mov    %eax,0x4(%esp)
  100075:	c7 04 24 9c 5e 10 00 	movl   $0x105e9c,(%esp)
  10007c:	e8 c7 02 00 00       	call   100348 <cprintf>

    print_kerninfo();
  100081:	e8 f6 07 00 00       	call   10087c <print_kerninfo>

    grade_backtrace();
  100086:	e8 86 00 00 00       	call   100111 <grade_backtrace>

    pmm_init();                 // init physical memory management
  10008b:	e8 28 42 00 00       	call   1042b8 <pmm_init>

    pic_init();                 // init interrupt controller
  100090:	e8 03 16 00 00       	call   101698 <pic_init>
    idt_init();                 // init interrupt descriptor table
  100095:	e8 55 17 00 00       	call   1017ef <idt_init>

    clock_init();               // init clock interrupt
  10009a:	e8 46 0c 00 00       	call   100ce5 <clock_init>
    intr_enable();              // enable irq interrupt
  10009f:	e8 62 15 00 00       	call   101606 <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
  1000a4:	eb fe                	jmp    1000a4 <kern_init+0x6e>

001000a6 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
  1000a6:	55                   	push   %ebp
  1000a7:	89 e5                	mov    %esp,%ebp
  1000a9:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
  1000ac:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1000b3:	00 
  1000b4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1000bb:	00 
  1000bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1000c3:	e8 3e 0b 00 00       	call   100c06 <mon_backtrace>
}
  1000c8:	c9                   	leave  
  1000c9:	c3                   	ret    

001000ca <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
  1000ca:	55                   	push   %ebp
  1000cb:	89 e5                	mov    %esp,%ebp
  1000cd:	53                   	push   %ebx
  1000ce:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
  1000d1:	8d 5d 0c             	lea    0xc(%ebp),%ebx
  1000d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  1000d7:	8d 55 08             	lea    0x8(%ebp),%edx
  1000da:	8b 45 08             	mov    0x8(%ebp),%eax
  1000dd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1000e1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  1000e5:	89 54 24 04          	mov    %edx,0x4(%esp)
  1000e9:	89 04 24             	mov    %eax,(%esp)
  1000ec:	e8 b5 ff ff ff       	call   1000a6 <grade_backtrace2>
}
  1000f1:	83 c4 14             	add    $0x14,%esp
  1000f4:	5b                   	pop    %ebx
  1000f5:	5d                   	pop    %ebp
  1000f6:	c3                   	ret    

001000f7 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
  1000f7:	55                   	push   %ebp
  1000f8:	89 e5                	mov    %esp,%ebp
  1000fa:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
  1000fd:	8b 45 10             	mov    0x10(%ebp),%eax
  100100:	89 44 24 04          	mov    %eax,0x4(%esp)
  100104:	8b 45 08             	mov    0x8(%ebp),%eax
  100107:	89 04 24             	mov    %eax,(%esp)
  10010a:	e8 bb ff ff ff       	call   1000ca <grade_backtrace1>
}
  10010f:	c9                   	leave  
  100110:	c3                   	ret    

00100111 <grade_backtrace>:

void
grade_backtrace(void) {
  100111:	55                   	push   %ebp
  100112:	89 e5                	mov    %esp,%ebp
  100114:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
  100117:	b8 36 00 10 00       	mov    $0x100036,%eax
  10011c:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
  100123:	ff 
  100124:	89 44 24 04          	mov    %eax,0x4(%esp)
  100128:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  10012f:	e8 c3 ff ff ff       	call   1000f7 <grade_backtrace0>
}
  100134:	c9                   	leave  
  100135:	c3                   	ret    

00100136 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
  100136:	55                   	push   %ebp
  100137:	89 e5                	mov    %esp,%ebp
  100139:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
  10013c:	8c 4d f6             	mov    %cs,-0xa(%ebp)
  10013f:	8c 5d f4             	mov    %ds,-0xc(%ebp)
  100142:	8c 45 f2             	mov    %es,-0xe(%ebp)
  100145:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
  100148:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  10014c:	0f b7 c0             	movzwl %ax,%eax
  10014f:	83 e0 03             	and    $0x3,%eax
  100152:	89 c2                	mov    %eax,%edx
  100154:	a1 00 a0 11 00       	mov    0x11a000,%eax
  100159:	89 54 24 08          	mov    %edx,0x8(%esp)
  10015d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100161:	c7 04 24 a1 5e 10 00 	movl   $0x105ea1,(%esp)
  100168:	e8 db 01 00 00       	call   100348 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  10016d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100171:	0f b7 d0             	movzwl %ax,%edx
  100174:	a1 00 a0 11 00       	mov    0x11a000,%eax
  100179:	89 54 24 08          	mov    %edx,0x8(%esp)
  10017d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100181:	c7 04 24 af 5e 10 00 	movl   $0x105eaf,(%esp)
  100188:	e8 bb 01 00 00       	call   100348 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  10018d:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100191:	0f b7 d0             	movzwl %ax,%edx
  100194:	a1 00 a0 11 00       	mov    0x11a000,%eax
  100199:	89 54 24 08          	mov    %edx,0x8(%esp)
  10019d:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001a1:	c7 04 24 bd 5e 10 00 	movl   $0x105ebd,(%esp)
  1001a8:	e8 9b 01 00 00       	call   100348 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  1001ad:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  1001b1:	0f b7 d0             	movzwl %ax,%edx
  1001b4:	a1 00 a0 11 00       	mov    0x11a000,%eax
  1001b9:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001c1:	c7 04 24 cb 5e 10 00 	movl   $0x105ecb,(%esp)
  1001c8:	e8 7b 01 00 00       	call   100348 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  1001cd:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1001d1:	0f b7 d0             	movzwl %ax,%edx
  1001d4:	a1 00 a0 11 00       	mov    0x11a000,%eax
  1001d9:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001e1:	c7 04 24 d9 5e 10 00 	movl   $0x105ed9,(%esp)
  1001e8:	e8 5b 01 00 00       	call   100348 <cprintf>
    round ++;
  1001ed:	a1 00 a0 11 00       	mov    0x11a000,%eax
  1001f2:	83 c0 01             	add    $0x1,%eax
  1001f5:	a3 00 a0 11 00       	mov    %eax,0x11a000
}
  1001fa:	c9                   	leave  
  1001fb:	c3                   	ret    

001001fc <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
  1001fc:	55                   	push   %ebp
  1001fd:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
  1001ff:	5d                   	pop    %ebp
  100200:	c3                   	ret    

00100201 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
  100201:	55                   	push   %ebp
  100202:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
  100204:	5d                   	pop    %ebp
  100205:	c3                   	ret    

00100206 <lab1_switch_test>:

static void
lab1_switch_test(void) {
  100206:	55                   	push   %ebp
  100207:	89 e5                	mov    %esp,%ebp
  100209:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
  10020c:	e8 25 ff ff ff       	call   100136 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
  100211:	c7 04 24 e8 5e 10 00 	movl   $0x105ee8,(%esp)
  100218:	e8 2b 01 00 00       	call   100348 <cprintf>
    lab1_switch_to_user();
  10021d:	e8 da ff ff ff       	call   1001fc <lab1_switch_to_user>
    lab1_print_cur_status();
  100222:	e8 0f ff ff ff       	call   100136 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  100227:	c7 04 24 08 5f 10 00 	movl   $0x105f08,(%esp)
  10022e:	e8 15 01 00 00       	call   100348 <cprintf>
    lab1_switch_to_kernel();
  100233:	e8 c9 ff ff ff       	call   100201 <lab1_switch_to_kernel>
    lab1_print_cur_status();
  100238:	e8 f9 fe ff ff       	call   100136 <lab1_print_cur_status>
}
  10023d:	c9                   	leave  
  10023e:	c3                   	ret    

0010023f <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
  10023f:	55                   	push   %ebp
  100240:	89 e5                	mov    %esp,%ebp
  100242:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
  100245:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100249:	74 13                	je     10025e <readline+0x1f>
        cprintf("%s", prompt);
  10024b:	8b 45 08             	mov    0x8(%ebp),%eax
  10024e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100252:	c7 04 24 27 5f 10 00 	movl   $0x105f27,(%esp)
  100259:	e8 ea 00 00 00       	call   100348 <cprintf>
    }
    int i = 0, c;
  10025e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
  100265:	e8 66 01 00 00       	call   1003d0 <getchar>
  10026a:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
  10026d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100271:	79 07                	jns    10027a <readline+0x3b>
            return NULL;
  100273:	b8 00 00 00 00       	mov    $0x0,%eax
  100278:	eb 79                	jmp    1002f3 <readline+0xb4>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
  10027a:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
  10027e:	7e 28                	jle    1002a8 <readline+0x69>
  100280:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  100287:	7f 1f                	jg     1002a8 <readline+0x69>
            cputchar(c);
  100289:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10028c:	89 04 24             	mov    %eax,(%esp)
  10028f:	e8 da 00 00 00       	call   10036e <cputchar>
            buf[i ++] = c;
  100294:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100297:	8d 50 01             	lea    0x1(%eax),%edx
  10029a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  10029d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1002a0:	88 90 20 a0 11 00    	mov    %dl,0x11a020(%eax)
  1002a6:	eb 46                	jmp    1002ee <readline+0xaf>
        }
        else if (c == '\b' && i > 0) {
  1002a8:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
  1002ac:	75 17                	jne    1002c5 <readline+0x86>
  1002ae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1002b2:	7e 11                	jle    1002c5 <readline+0x86>
            cputchar(c);
  1002b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002b7:	89 04 24             	mov    %eax,(%esp)
  1002ba:	e8 af 00 00 00       	call   10036e <cputchar>
            i --;
  1002bf:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  1002c3:	eb 29                	jmp    1002ee <readline+0xaf>
        }
        else if (c == '\n' || c == '\r') {
  1002c5:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
  1002c9:	74 06                	je     1002d1 <readline+0x92>
  1002cb:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
  1002cf:	75 1d                	jne    1002ee <readline+0xaf>
            cputchar(c);
  1002d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002d4:	89 04 24             	mov    %eax,(%esp)
  1002d7:	e8 92 00 00 00       	call   10036e <cputchar>
            buf[i] = '\0';
  1002dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1002df:	05 20 a0 11 00       	add    $0x11a020,%eax
  1002e4:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  1002e7:	b8 20 a0 11 00       	mov    $0x11a020,%eax
  1002ec:	eb 05                	jmp    1002f3 <readline+0xb4>
        }
    }
  1002ee:	e9 72 ff ff ff       	jmp    100265 <readline+0x26>
}
  1002f3:	c9                   	leave  
  1002f4:	c3                   	ret    

001002f5 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  1002f5:	55                   	push   %ebp
  1002f6:	89 e5                	mov    %esp,%ebp
  1002f8:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  1002fb:	8b 45 08             	mov    0x8(%ebp),%eax
  1002fe:	89 04 24             	mov    %eax,(%esp)
  100301:	e8 55 12 00 00       	call   10155b <cons_putc>
    (*cnt) ++;
  100306:	8b 45 0c             	mov    0xc(%ebp),%eax
  100309:	8b 00                	mov    (%eax),%eax
  10030b:	8d 50 01             	lea    0x1(%eax),%edx
  10030e:	8b 45 0c             	mov    0xc(%ebp),%eax
  100311:	89 10                	mov    %edx,(%eax)
}
  100313:	c9                   	leave  
  100314:	c3                   	ret    

00100315 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  100315:	55                   	push   %ebp
  100316:	89 e5                	mov    %esp,%ebp
  100318:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  10031b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  100322:	8b 45 0c             	mov    0xc(%ebp),%eax
  100325:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100329:	8b 45 08             	mov    0x8(%ebp),%eax
  10032c:	89 44 24 08          	mov    %eax,0x8(%esp)
  100330:	8d 45 f4             	lea    -0xc(%ebp),%eax
  100333:	89 44 24 04          	mov    %eax,0x4(%esp)
  100337:	c7 04 24 f5 02 10 00 	movl   $0x1002f5,(%esp)
  10033e:	e8 c3 51 00 00       	call   105506 <vprintfmt>
    return cnt;
  100343:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100346:	c9                   	leave  
  100347:	c3                   	ret    

00100348 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  100348:	55                   	push   %ebp
  100349:	89 e5                	mov    %esp,%ebp
  10034b:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  10034e:	8d 45 0c             	lea    0xc(%ebp),%eax
  100351:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
  100354:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100357:	89 44 24 04          	mov    %eax,0x4(%esp)
  10035b:	8b 45 08             	mov    0x8(%ebp),%eax
  10035e:	89 04 24             	mov    %eax,(%esp)
  100361:	e8 af ff ff ff       	call   100315 <vcprintf>
  100366:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  100369:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10036c:	c9                   	leave  
  10036d:	c3                   	ret    

0010036e <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
  10036e:	55                   	push   %ebp
  10036f:	89 e5                	mov    %esp,%ebp
  100371:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  100374:	8b 45 08             	mov    0x8(%ebp),%eax
  100377:	89 04 24             	mov    %eax,(%esp)
  10037a:	e8 dc 11 00 00       	call   10155b <cons_putc>
}
  10037f:	c9                   	leave  
  100380:	c3                   	ret    

00100381 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  100381:	55                   	push   %ebp
  100382:	89 e5                	mov    %esp,%ebp
  100384:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  100387:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  10038e:	eb 13                	jmp    1003a3 <cputs+0x22>
        cputch(c, &cnt);
  100390:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  100394:	8d 55 f0             	lea    -0x10(%ebp),%edx
  100397:	89 54 24 04          	mov    %edx,0x4(%esp)
  10039b:	89 04 24             	mov    %eax,(%esp)
  10039e:	e8 52 ff ff ff       	call   1002f5 <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
  1003a3:	8b 45 08             	mov    0x8(%ebp),%eax
  1003a6:	8d 50 01             	lea    0x1(%eax),%edx
  1003a9:	89 55 08             	mov    %edx,0x8(%ebp)
  1003ac:	0f b6 00             	movzbl (%eax),%eax
  1003af:	88 45 f7             	mov    %al,-0x9(%ebp)
  1003b2:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  1003b6:	75 d8                	jne    100390 <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
  1003b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  1003bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1003bf:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  1003c6:	e8 2a ff ff ff       	call   1002f5 <cputch>
    return cnt;
  1003cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  1003ce:	c9                   	leave  
  1003cf:	c3                   	ret    

001003d0 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
  1003d0:	55                   	push   %ebp
  1003d1:	89 e5                	mov    %esp,%ebp
  1003d3:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
  1003d6:	e8 bc 11 00 00       	call   101597 <cons_getc>
  1003db:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1003de:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1003e2:	74 f2                	je     1003d6 <getchar+0x6>
        /* do nothing */;
    return c;
  1003e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1003e7:	c9                   	leave  
  1003e8:	c3                   	ret    

001003e9 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
  1003e9:	55                   	push   %ebp
  1003ea:	89 e5                	mov    %esp,%ebp
  1003ec:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
  1003ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  1003f2:	8b 00                	mov    (%eax),%eax
  1003f4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  1003f7:	8b 45 10             	mov    0x10(%ebp),%eax
  1003fa:	8b 00                	mov    (%eax),%eax
  1003fc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1003ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
  100406:	e9 d2 00 00 00       	jmp    1004dd <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
  10040b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10040e:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100411:	01 d0                	add    %edx,%eax
  100413:	89 c2                	mov    %eax,%edx
  100415:	c1 ea 1f             	shr    $0x1f,%edx
  100418:	01 d0                	add    %edx,%eax
  10041a:	d1 f8                	sar    %eax
  10041c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10041f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100422:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  100425:	eb 04                	jmp    10042b <stab_binsearch+0x42>
            m --;
  100427:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  10042b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10042e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100431:	7c 1f                	jl     100452 <stab_binsearch+0x69>
  100433:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100436:	89 d0                	mov    %edx,%eax
  100438:	01 c0                	add    %eax,%eax
  10043a:	01 d0                	add    %edx,%eax
  10043c:	c1 e0 02             	shl    $0x2,%eax
  10043f:	89 c2                	mov    %eax,%edx
  100441:	8b 45 08             	mov    0x8(%ebp),%eax
  100444:	01 d0                	add    %edx,%eax
  100446:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10044a:	0f b6 c0             	movzbl %al,%eax
  10044d:	3b 45 14             	cmp    0x14(%ebp),%eax
  100450:	75 d5                	jne    100427 <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
  100452:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100455:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100458:	7d 0b                	jge    100465 <stab_binsearch+0x7c>
            l = true_m + 1;
  10045a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10045d:	83 c0 01             	add    $0x1,%eax
  100460:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
  100463:	eb 78                	jmp    1004dd <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
  100465:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
  10046c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10046f:	89 d0                	mov    %edx,%eax
  100471:	01 c0                	add    %eax,%eax
  100473:	01 d0                	add    %edx,%eax
  100475:	c1 e0 02             	shl    $0x2,%eax
  100478:	89 c2                	mov    %eax,%edx
  10047a:	8b 45 08             	mov    0x8(%ebp),%eax
  10047d:	01 d0                	add    %edx,%eax
  10047f:	8b 40 08             	mov    0x8(%eax),%eax
  100482:	3b 45 18             	cmp    0x18(%ebp),%eax
  100485:	73 13                	jae    10049a <stab_binsearch+0xb1>
            *region_left = m;
  100487:	8b 45 0c             	mov    0xc(%ebp),%eax
  10048a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10048d:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
  10048f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100492:	83 c0 01             	add    $0x1,%eax
  100495:	89 45 fc             	mov    %eax,-0x4(%ebp)
  100498:	eb 43                	jmp    1004dd <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
  10049a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10049d:	89 d0                	mov    %edx,%eax
  10049f:	01 c0                	add    %eax,%eax
  1004a1:	01 d0                	add    %edx,%eax
  1004a3:	c1 e0 02             	shl    $0x2,%eax
  1004a6:	89 c2                	mov    %eax,%edx
  1004a8:	8b 45 08             	mov    0x8(%ebp),%eax
  1004ab:	01 d0                	add    %edx,%eax
  1004ad:	8b 40 08             	mov    0x8(%eax),%eax
  1004b0:	3b 45 18             	cmp    0x18(%ebp),%eax
  1004b3:	76 16                	jbe    1004cb <stab_binsearch+0xe2>
            *region_right = m - 1;
  1004b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004b8:	8d 50 ff             	lea    -0x1(%eax),%edx
  1004bb:	8b 45 10             	mov    0x10(%ebp),%eax
  1004be:	89 10                	mov    %edx,(%eax)
            r = m - 1;
  1004c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004c3:	83 e8 01             	sub    $0x1,%eax
  1004c6:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1004c9:	eb 12                	jmp    1004dd <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
  1004cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004ce:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004d1:	89 10                	mov    %edx,(%eax)
            l = m;
  1004d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004d6:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
  1004d9:	83 45 18 01          	addl   $0x1,0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
  1004dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1004e0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  1004e3:	0f 8e 22 ff ff ff    	jle    10040b <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
  1004e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1004ed:	75 0f                	jne    1004fe <stab_binsearch+0x115>
        *region_right = *region_left - 1;
  1004ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004f2:	8b 00                	mov    (%eax),%eax
  1004f4:	8d 50 ff             	lea    -0x1(%eax),%edx
  1004f7:	8b 45 10             	mov    0x10(%ebp),%eax
  1004fa:	89 10                	mov    %edx,(%eax)
  1004fc:	eb 3f                	jmp    10053d <stab_binsearch+0x154>
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
  1004fe:	8b 45 10             	mov    0x10(%ebp),%eax
  100501:	8b 00                	mov    (%eax),%eax
  100503:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
  100506:	eb 04                	jmp    10050c <stab_binsearch+0x123>
  100508:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
  10050c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10050f:	8b 00                	mov    (%eax),%eax
  100511:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100514:	7d 1f                	jge    100535 <stab_binsearch+0x14c>
  100516:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100519:	89 d0                	mov    %edx,%eax
  10051b:	01 c0                	add    %eax,%eax
  10051d:	01 d0                	add    %edx,%eax
  10051f:	c1 e0 02             	shl    $0x2,%eax
  100522:	89 c2                	mov    %eax,%edx
  100524:	8b 45 08             	mov    0x8(%ebp),%eax
  100527:	01 d0                	add    %edx,%eax
  100529:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10052d:	0f b6 c0             	movzbl %al,%eax
  100530:	3b 45 14             	cmp    0x14(%ebp),%eax
  100533:	75 d3                	jne    100508 <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
  100535:	8b 45 0c             	mov    0xc(%ebp),%eax
  100538:	8b 55 fc             	mov    -0x4(%ebp),%edx
  10053b:	89 10                	mov    %edx,(%eax)
    }
}
  10053d:	c9                   	leave  
  10053e:	c3                   	ret    

0010053f <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
  10053f:	55                   	push   %ebp
  100540:	89 e5                	mov    %esp,%ebp
  100542:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
  100545:	8b 45 0c             	mov    0xc(%ebp),%eax
  100548:	c7 00 2c 5f 10 00    	movl   $0x105f2c,(%eax)
    info->eip_line = 0;
  10054e:	8b 45 0c             	mov    0xc(%ebp),%eax
  100551:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  100558:	8b 45 0c             	mov    0xc(%ebp),%eax
  10055b:	c7 40 08 2c 5f 10 00 	movl   $0x105f2c,0x8(%eax)
    info->eip_fn_namelen = 9;
  100562:	8b 45 0c             	mov    0xc(%ebp),%eax
  100565:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
  10056c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10056f:	8b 55 08             	mov    0x8(%ebp),%edx
  100572:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
  100575:	8b 45 0c             	mov    0xc(%ebp),%eax
  100578:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
  10057f:	c7 45 f4 98 71 10 00 	movl   $0x107198,-0xc(%ebp)
    stab_end = __STAB_END__;
  100586:	c7 45 f0 ec 1c 11 00 	movl   $0x111cec,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  10058d:	c7 45 ec ed 1c 11 00 	movl   $0x111ced,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  100594:	c7 45 e8 22 47 11 00 	movl   $0x114722,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
  10059b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10059e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  1005a1:	76 0d                	jbe    1005b0 <debuginfo_eip+0x71>
  1005a3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1005a6:	83 e8 01             	sub    $0x1,%eax
  1005a9:	0f b6 00             	movzbl (%eax),%eax
  1005ac:	84 c0                	test   %al,%al
  1005ae:	74 0a                	je     1005ba <debuginfo_eip+0x7b>
        return -1;
  1005b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1005b5:	e9 c0 02 00 00       	jmp    10087a <debuginfo_eip+0x33b>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
  1005ba:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  1005c1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1005c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1005c7:	29 c2                	sub    %eax,%edx
  1005c9:	89 d0                	mov    %edx,%eax
  1005cb:	c1 f8 02             	sar    $0x2,%eax
  1005ce:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
  1005d4:	83 e8 01             	sub    $0x1,%eax
  1005d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  1005da:	8b 45 08             	mov    0x8(%ebp),%eax
  1005dd:	89 44 24 10          	mov    %eax,0x10(%esp)
  1005e1:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
  1005e8:	00 
  1005e9:	8d 45 e0             	lea    -0x20(%ebp),%eax
  1005ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  1005f0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  1005f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  1005f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1005fa:	89 04 24             	mov    %eax,(%esp)
  1005fd:	e8 e7 fd ff ff       	call   1003e9 <stab_binsearch>
    if (lfile == 0)
  100602:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100605:	85 c0                	test   %eax,%eax
  100607:	75 0a                	jne    100613 <debuginfo_eip+0xd4>
        return -1;
  100609:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10060e:	e9 67 02 00 00       	jmp    10087a <debuginfo_eip+0x33b>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
  100613:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100616:	89 45 dc             	mov    %eax,-0x24(%ebp)
  100619:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10061c:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  10061f:	8b 45 08             	mov    0x8(%ebp),%eax
  100622:	89 44 24 10          	mov    %eax,0x10(%esp)
  100626:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
  10062d:	00 
  10062e:	8d 45 d8             	lea    -0x28(%ebp),%eax
  100631:	89 44 24 08          	mov    %eax,0x8(%esp)
  100635:	8d 45 dc             	lea    -0x24(%ebp),%eax
  100638:	89 44 24 04          	mov    %eax,0x4(%esp)
  10063c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10063f:	89 04 24             	mov    %eax,(%esp)
  100642:	e8 a2 fd ff ff       	call   1003e9 <stab_binsearch>

    if (lfun <= rfun) {
  100647:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10064a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10064d:	39 c2                	cmp    %eax,%edx
  10064f:	7f 7c                	jg     1006cd <debuginfo_eip+0x18e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
  100651:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100654:	89 c2                	mov    %eax,%edx
  100656:	89 d0                	mov    %edx,%eax
  100658:	01 c0                	add    %eax,%eax
  10065a:	01 d0                	add    %edx,%eax
  10065c:	c1 e0 02             	shl    $0x2,%eax
  10065f:	89 c2                	mov    %eax,%edx
  100661:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100664:	01 d0                	add    %edx,%eax
  100666:	8b 10                	mov    (%eax),%edx
  100668:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  10066b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10066e:	29 c1                	sub    %eax,%ecx
  100670:	89 c8                	mov    %ecx,%eax
  100672:	39 c2                	cmp    %eax,%edx
  100674:	73 22                	jae    100698 <debuginfo_eip+0x159>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  100676:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100679:	89 c2                	mov    %eax,%edx
  10067b:	89 d0                	mov    %edx,%eax
  10067d:	01 c0                	add    %eax,%eax
  10067f:	01 d0                	add    %edx,%eax
  100681:	c1 e0 02             	shl    $0x2,%eax
  100684:	89 c2                	mov    %eax,%edx
  100686:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100689:	01 d0                	add    %edx,%eax
  10068b:	8b 10                	mov    (%eax),%edx
  10068d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100690:	01 c2                	add    %eax,%edx
  100692:	8b 45 0c             	mov    0xc(%ebp),%eax
  100695:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
  100698:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10069b:	89 c2                	mov    %eax,%edx
  10069d:	89 d0                	mov    %edx,%eax
  10069f:	01 c0                	add    %eax,%eax
  1006a1:	01 d0                	add    %edx,%eax
  1006a3:	c1 e0 02             	shl    $0x2,%eax
  1006a6:	89 c2                	mov    %eax,%edx
  1006a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1006ab:	01 d0                	add    %edx,%eax
  1006ad:	8b 50 08             	mov    0x8(%eax),%edx
  1006b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006b3:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
  1006b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006b9:	8b 40 10             	mov    0x10(%eax),%eax
  1006bc:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
  1006bf:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1006c2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
  1006c5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1006c8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1006cb:	eb 15                	jmp    1006e2 <debuginfo_eip+0x1a3>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
  1006cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006d0:	8b 55 08             	mov    0x8(%ebp),%edx
  1006d3:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
  1006d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
  1006dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1006df:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  1006e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006e5:	8b 40 08             	mov    0x8(%eax),%eax
  1006e8:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  1006ef:	00 
  1006f0:	89 04 24             	mov    %eax,(%esp)
  1006f3:	e8 69 54 00 00       	call   105b61 <strfind>
  1006f8:	89 c2                	mov    %eax,%edx
  1006fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006fd:	8b 40 08             	mov    0x8(%eax),%eax
  100700:	29 c2                	sub    %eax,%edx
  100702:	8b 45 0c             	mov    0xc(%ebp),%eax
  100705:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  100708:	8b 45 08             	mov    0x8(%ebp),%eax
  10070b:	89 44 24 10          	mov    %eax,0x10(%esp)
  10070f:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
  100716:	00 
  100717:	8d 45 d0             	lea    -0x30(%ebp),%eax
  10071a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10071e:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  100721:	89 44 24 04          	mov    %eax,0x4(%esp)
  100725:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100728:	89 04 24             	mov    %eax,(%esp)
  10072b:	e8 b9 fc ff ff       	call   1003e9 <stab_binsearch>
    if (lline <= rline) {
  100730:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100733:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100736:	39 c2                	cmp    %eax,%edx
  100738:	7f 24                	jg     10075e <debuginfo_eip+0x21f>
        info->eip_line = stabs[rline].n_desc;
  10073a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10073d:	89 c2                	mov    %eax,%edx
  10073f:	89 d0                	mov    %edx,%eax
  100741:	01 c0                	add    %eax,%eax
  100743:	01 d0                	add    %edx,%eax
  100745:	c1 e0 02             	shl    $0x2,%eax
  100748:	89 c2                	mov    %eax,%edx
  10074a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10074d:	01 d0                	add    %edx,%eax
  10074f:	0f b7 40 06          	movzwl 0x6(%eax),%eax
  100753:	0f b7 d0             	movzwl %ax,%edx
  100756:	8b 45 0c             	mov    0xc(%ebp),%eax
  100759:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  10075c:	eb 13                	jmp    100771 <debuginfo_eip+0x232>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
  10075e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100763:	e9 12 01 00 00       	jmp    10087a <debuginfo_eip+0x33b>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
  100768:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10076b:	83 e8 01             	sub    $0x1,%eax
  10076e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  100771:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100774:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100777:	39 c2                	cmp    %eax,%edx
  100779:	7c 56                	jl     1007d1 <debuginfo_eip+0x292>
           && stabs[lline].n_type != N_SOL
  10077b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10077e:	89 c2                	mov    %eax,%edx
  100780:	89 d0                	mov    %edx,%eax
  100782:	01 c0                	add    %eax,%eax
  100784:	01 d0                	add    %edx,%eax
  100786:	c1 e0 02             	shl    $0x2,%eax
  100789:	89 c2                	mov    %eax,%edx
  10078b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10078e:	01 d0                	add    %edx,%eax
  100790:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100794:	3c 84                	cmp    $0x84,%al
  100796:	74 39                	je     1007d1 <debuginfo_eip+0x292>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  100798:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10079b:	89 c2                	mov    %eax,%edx
  10079d:	89 d0                	mov    %edx,%eax
  10079f:	01 c0                	add    %eax,%eax
  1007a1:	01 d0                	add    %edx,%eax
  1007a3:	c1 e0 02             	shl    $0x2,%eax
  1007a6:	89 c2                	mov    %eax,%edx
  1007a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007ab:	01 d0                	add    %edx,%eax
  1007ad:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1007b1:	3c 64                	cmp    $0x64,%al
  1007b3:	75 b3                	jne    100768 <debuginfo_eip+0x229>
  1007b5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007b8:	89 c2                	mov    %eax,%edx
  1007ba:	89 d0                	mov    %edx,%eax
  1007bc:	01 c0                	add    %eax,%eax
  1007be:	01 d0                	add    %edx,%eax
  1007c0:	c1 e0 02             	shl    $0x2,%eax
  1007c3:	89 c2                	mov    %eax,%edx
  1007c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007c8:	01 d0                	add    %edx,%eax
  1007ca:	8b 40 08             	mov    0x8(%eax),%eax
  1007cd:	85 c0                	test   %eax,%eax
  1007cf:	74 97                	je     100768 <debuginfo_eip+0x229>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
  1007d1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1007d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1007d7:	39 c2                	cmp    %eax,%edx
  1007d9:	7c 46                	jl     100821 <debuginfo_eip+0x2e2>
  1007db:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007de:	89 c2                	mov    %eax,%edx
  1007e0:	89 d0                	mov    %edx,%eax
  1007e2:	01 c0                	add    %eax,%eax
  1007e4:	01 d0                	add    %edx,%eax
  1007e6:	c1 e0 02             	shl    $0x2,%eax
  1007e9:	89 c2                	mov    %eax,%edx
  1007eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007ee:	01 d0                	add    %edx,%eax
  1007f0:	8b 10                	mov    (%eax),%edx
  1007f2:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  1007f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1007f8:	29 c1                	sub    %eax,%ecx
  1007fa:	89 c8                	mov    %ecx,%eax
  1007fc:	39 c2                	cmp    %eax,%edx
  1007fe:	73 21                	jae    100821 <debuginfo_eip+0x2e2>
        info->eip_file = stabstr + stabs[lline].n_strx;
  100800:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100803:	89 c2                	mov    %eax,%edx
  100805:	89 d0                	mov    %edx,%eax
  100807:	01 c0                	add    %eax,%eax
  100809:	01 d0                	add    %edx,%eax
  10080b:	c1 e0 02             	shl    $0x2,%eax
  10080e:	89 c2                	mov    %eax,%edx
  100810:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100813:	01 d0                	add    %edx,%eax
  100815:	8b 10                	mov    (%eax),%edx
  100817:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10081a:	01 c2                	add    %eax,%edx
  10081c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10081f:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
  100821:	8b 55 dc             	mov    -0x24(%ebp),%edx
  100824:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100827:	39 c2                	cmp    %eax,%edx
  100829:	7d 4a                	jge    100875 <debuginfo_eip+0x336>
        for (lline = lfun + 1;
  10082b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10082e:	83 c0 01             	add    $0x1,%eax
  100831:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  100834:	eb 18                	jmp    10084e <debuginfo_eip+0x30f>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
  100836:	8b 45 0c             	mov    0xc(%ebp),%eax
  100839:	8b 40 14             	mov    0x14(%eax),%eax
  10083c:	8d 50 01             	lea    0x1(%eax),%edx
  10083f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100842:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
  100845:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100848:	83 c0 01             	add    $0x1,%eax
  10084b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
  10084e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100851:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
  100854:	39 c2                	cmp    %eax,%edx
  100856:	7d 1d                	jge    100875 <debuginfo_eip+0x336>
             lline < rfun && stabs[lline].n_type == N_PSYM;
  100858:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10085b:	89 c2                	mov    %eax,%edx
  10085d:	89 d0                	mov    %edx,%eax
  10085f:	01 c0                	add    %eax,%eax
  100861:	01 d0                	add    %edx,%eax
  100863:	c1 e0 02             	shl    $0x2,%eax
  100866:	89 c2                	mov    %eax,%edx
  100868:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10086b:	01 d0                	add    %edx,%eax
  10086d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100871:	3c a0                	cmp    $0xa0,%al
  100873:	74 c1                	je     100836 <debuginfo_eip+0x2f7>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
  100875:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10087a:	c9                   	leave  
  10087b:	c3                   	ret    

0010087c <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
  10087c:	55                   	push   %ebp
  10087d:	89 e5                	mov    %esp,%ebp
  10087f:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
  100882:	c7 04 24 36 5f 10 00 	movl   $0x105f36,(%esp)
  100889:	e8 ba fa ff ff       	call   100348 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  10088e:	c7 44 24 04 36 00 10 	movl   $0x100036,0x4(%esp)
  100895:	00 
  100896:	c7 04 24 4f 5f 10 00 	movl   $0x105f4f,(%esp)
  10089d:	e8 a6 fa ff ff       	call   100348 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  1008a2:	c7 44 24 04 76 5e 10 	movl   $0x105e76,0x4(%esp)
  1008a9:	00 
  1008aa:	c7 04 24 67 5f 10 00 	movl   $0x105f67,(%esp)
  1008b1:	e8 92 fa ff ff       	call   100348 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  1008b6:	c7 44 24 04 36 7a 11 	movl   $0x117a36,0x4(%esp)
  1008bd:	00 
  1008be:	c7 04 24 7f 5f 10 00 	movl   $0x105f7f,(%esp)
  1008c5:	e8 7e fa ff ff       	call   100348 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  1008ca:	c7 44 24 04 28 af 11 	movl   $0x11af28,0x4(%esp)
  1008d1:	00 
  1008d2:	c7 04 24 97 5f 10 00 	movl   $0x105f97,(%esp)
  1008d9:	e8 6a fa ff ff       	call   100348 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  1008de:	b8 28 af 11 00       	mov    $0x11af28,%eax
  1008e3:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1008e9:	b8 36 00 10 00       	mov    $0x100036,%eax
  1008ee:	29 c2                	sub    %eax,%edx
  1008f0:	89 d0                	mov    %edx,%eax
  1008f2:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1008f8:	85 c0                	test   %eax,%eax
  1008fa:	0f 48 c2             	cmovs  %edx,%eax
  1008fd:	c1 f8 0a             	sar    $0xa,%eax
  100900:	89 44 24 04          	mov    %eax,0x4(%esp)
  100904:	c7 04 24 b0 5f 10 00 	movl   $0x105fb0,(%esp)
  10090b:	e8 38 fa ff ff       	call   100348 <cprintf>
}
  100910:	c9                   	leave  
  100911:	c3                   	ret    

00100912 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
  100912:	55                   	push   %ebp
  100913:	89 e5                	mov    %esp,%ebp
  100915:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
  10091b:	8d 45 dc             	lea    -0x24(%ebp),%eax
  10091e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100922:	8b 45 08             	mov    0x8(%ebp),%eax
  100925:	89 04 24             	mov    %eax,(%esp)
  100928:	e8 12 fc ff ff       	call   10053f <debuginfo_eip>
  10092d:	85 c0                	test   %eax,%eax
  10092f:	74 15                	je     100946 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
  100931:	8b 45 08             	mov    0x8(%ebp),%eax
  100934:	89 44 24 04          	mov    %eax,0x4(%esp)
  100938:	c7 04 24 da 5f 10 00 	movl   $0x105fda,(%esp)
  10093f:	e8 04 fa ff ff       	call   100348 <cprintf>
  100944:	eb 6d                	jmp    1009b3 <print_debuginfo+0xa1>
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100946:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  10094d:	eb 1c                	jmp    10096b <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
  10094f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  100952:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100955:	01 d0                	add    %edx,%eax
  100957:	0f b6 00             	movzbl (%eax),%eax
  10095a:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100960:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100963:	01 ca                	add    %ecx,%edx
  100965:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100967:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  10096b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10096e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  100971:	7f dc                	jg     10094f <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
  100973:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
  100979:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10097c:	01 d0                	add    %edx,%eax
  10097e:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
  100981:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
  100984:	8b 55 08             	mov    0x8(%ebp),%edx
  100987:	89 d1                	mov    %edx,%ecx
  100989:	29 c1                	sub    %eax,%ecx
  10098b:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10098e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100991:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  100995:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  10099b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  10099f:	89 54 24 08          	mov    %edx,0x8(%esp)
  1009a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009a7:	c7 04 24 f6 5f 10 00 	movl   $0x105ff6,(%esp)
  1009ae:	e8 95 f9 ff ff       	call   100348 <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
  1009b3:	c9                   	leave  
  1009b4:	c3                   	ret    

001009b5 <read_eip>:

static __noinline uint32_t
read_eip(void) {
  1009b5:	55                   	push   %ebp
  1009b6:	89 e5                	mov    %esp,%ebp
  1009b8:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
  1009bb:	8b 45 04             	mov    0x4(%ebp),%eax
  1009be:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
  1009c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1009c4:	c9                   	leave  
  1009c5:	c3                   	ret    

001009c6 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
  1009c6:	55                   	push   %ebp
  1009c7:	89 e5                	mov    %esp,%ebp
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
}
  1009c9:	5d                   	pop    %ebp
  1009ca:	c3                   	ret    

001009cb <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  1009cb:	55                   	push   %ebp
  1009cc:	89 e5                	mov    %esp,%ebp
  1009ce:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
  1009d1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  1009d8:	eb 0c                	jmp    1009e6 <parse+0x1b>
            *buf ++ = '\0';
  1009da:	8b 45 08             	mov    0x8(%ebp),%eax
  1009dd:	8d 50 01             	lea    0x1(%eax),%edx
  1009e0:	89 55 08             	mov    %edx,0x8(%ebp)
  1009e3:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  1009e6:	8b 45 08             	mov    0x8(%ebp),%eax
  1009e9:	0f b6 00             	movzbl (%eax),%eax
  1009ec:	84 c0                	test   %al,%al
  1009ee:	74 1d                	je     100a0d <parse+0x42>
  1009f0:	8b 45 08             	mov    0x8(%ebp),%eax
  1009f3:	0f b6 00             	movzbl (%eax),%eax
  1009f6:	0f be c0             	movsbl %al,%eax
  1009f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009fd:	c7 04 24 88 60 10 00 	movl   $0x106088,(%esp)
  100a04:	e8 25 51 00 00       	call   105b2e <strchr>
  100a09:	85 c0                	test   %eax,%eax
  100a0b:	75 cd                	jne    1009da <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
  100a0d:	8b 45 08             	mov    0x8(%ebp),%eax
  100a10:	0f b6 00             	movzbl (%eax),%eax
  100a13:	84 c0                	test   %al,%al
  100a15:	75 02                	jne    100a19 <parse+0x4e>
            break;
  100a17:	eb 67                	jmp    100a80 <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100a19:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100a1d:	75 14                	jne    100a33 <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100a1f:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  100a26:	00 
  100a27:	c7 04 24 8d 60 10 00 	movl   $0x10608d,(%esp)
  100a2e:	e8 15 f9 ff ff       	call   100348 <cprintf>
        }
        argv[argc ++] = buf;
  100a33:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a36:	8d 50 01             	lea    0x1(%eax),%edx
  100a39:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100a3c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100a43:	8b 45 0c             	mov    0xc(%ebp),%eax
  100a46:	01 c2                	add    %eax,%edx
  100a48:	8b 45 08             	mov    0x8(%ebp),%eax
  100a4b:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100a4d:	eb 04                	jmp    100a53 <parse+0x88>
            buf ++;
  100a4f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100a53:	8b 45 08             	mov    0x8(%ebp),%eax
  100a56:	0f b6 00             	movzbl (%eax),%eax
  100a59:	84 c0                	test   %al,%al
  100a5b:	74 1d                	je     100a7a <parse+0xaf>
  100a5d:	8b 45 08             	mov    0x8(%ebp),%eax
  100a60:	0f b6 00             	movzbl (%eax),%eax
  100a63:	0f be c0             	movsbl %al,%eax
  100a66:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a6a:	c7 04 24 88 60 10 00 	movl   $0x106088,(%esp)
  100a71:	e8 b8 50 00 00       	call   105b2e <strchr>
  100a76:	85 c0                	test   %eax,%eax
  100a78:	74 d5                	je     100a4f <parse+0x84>
            buf ++;
        }
    }
  100a7a:	90                   	nop
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100a7b:	e9 66 ff ff ff       	jmp    1009e6 <parse+0x1b>
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
  100a80:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100a83:	c9                   	leave  
  100a84:	c3                   	ret    

00100a85 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100a85:	55                   	push   %ebp
  100a86:	89 e5                	mov    %esp,%ebp
  100a88:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100a8b:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100a8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a92:	8b 45 08             	mov    0x8(%ebp),%eax
  100a95:	89 04 24             	mov    %eax,(%esp)
  100a98:	e8 2e ff ff ff       	call   1009cb <parse>
  100a9d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100aa0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100aa4:	75 0a                	jne    100ab0 <runcmd+0x2b>
        return 0;
  100aa6:	b8 00 00 00 00       	mov    $0x0,%eax
  100aab:	e9 85 00 00 00       	jmp    100b35 <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100ab0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100ab7:	eb 5c                	jmp    100b15 <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100ab9:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  100abc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100abf:	89 d0                	mov    %edx,%eax
  100ac1:	01 c0                	add    %eax,%eax
  100ac3:	01 d0                	add    %edx,%eax
  100ac5:	c1 e0 02             	shl    $0x2,%eax
  100ac8:	05 00 70 11 00       	add    $0x117000,%eax
  100acd:	8b 00                	mov    (%eax),%eax
  100acf:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  100ad3:	89 04 24             	mov    %eax,(%esp)
  100ad6:	e8 b4 4f 00 00       	call   105a8f <strcmp>
  100adb:	85 c0                	test   %eax,%eax
  100add:	75 32                	jne    100b11 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
  100adf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100ae2:	89 d0                	mov    %edx,%eax
  100ae4:	01 c0                	add    %eax,%eax
  100ae6:	01 d0                	add    %edx,%eax
  100ae8:	c1 e0 02             	shl    $0x2,%eax
  100aeb:	05 00 70 11 00       	add    $0x117000,%eax
  100af0:	8b 40 08             	mov    0x8(%eax),%eax
  100af3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100af6:	8d 4a ff             	lea    -0x1(%edx),%ecx
  100af9:	8b 55 0c             	mov    0xc(%ebp),%edx
  100afc:	89 54 24 08          	mov    %edx,0x8(%esp)
  100b00:	8d 55 b0             	lea    -0x50(%ebp),%edx
  100b03:	83 c2 04             	add    $0x4,%edx
  100b06:	89 54 24 04          	mov    %edx,0x4(%esp)
  100b0a:	89 0c 24             	mov    %ecx,(%esp)
  100b0d:	ff d0                	call   *%eax
  100b0f:	eb 24                	jmp    100b35 <runcmd+0xb0>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100b11:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100b15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b18:	83 f8 02             	cmp    $0x2,%eax
  100b1b:	76 9c                	jbe    100ab9 <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100b1d:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100b20:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b24:	c7 04 24 ab 60 10 00 	movl   $0x1060ab,(%esp)
  100b2b:	e8 18 f8 ff ff       	call   100348 <cprintf>
    return 0;
  100b30:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100b35:	c9                   	leave  
  100b36:	c3                   	ret    

00100b37 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100b37:	55                   	push   %ebp
  100b38:	89 e5                	mov    %esp,%ebp
  100b3a:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
  100b3d:	c7 04 24 c4 60 10 00 	movl   $0x1060c4,(%esp)
  100b44:	e8 ff f7 ff ff       	call   100348 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100b49:	c7 04 24 ec 60 10 00 	movl   $0x1060ec,(%esp)
  100b50:	e8 f3 f7 ff ff       	call   100348 <cprintf>

    if (tf != NULL) {
  100b55:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100b59:	74 0b                	je     100b66 <kmonitor+0x2f>
        print_trapframe(tf);
  100b5b:	8b 45 08             	mov    0x8(%ebp),%eax
  100b5e:	89 04 24             	mov    %eax,(%esp)
  100b61:	e8 d5 0c 00 00       	call   10183b <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100b66:	c7 04 24 11 61 10 00 	movl   $0x106111,(%esp)
  100b6d:	e8 cd f6 ff ff       	call   10023f <readline>
  100b72:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100b75:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100b79:	74 18                	je     100b93 <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
  100b7b:	8b 45 08             	mov    0x8(%ebp),%eax
  100b7e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b85:	89 04 24             	mov    %eax,(%esp)
  100b88:	e8 f8 fe ff ff       	call   100a85 <runcmd>
  100b8d:	85 c0                	test   %eax,%eax
  100b8f:	79 02                	jns    100b93 <kmonitor+0x5c>
                break;
  100b91:	eb 02                	jmp    100b95 <kmonitor+0x5e>
            }
        }
    }
  100b93:	eb d1                	jmp    100b66 <kmonitor+0x2f>
}
  100b95:	c9                   	leave  
  100b96:	c3                   	ret    

00100b97 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100b97:	55                   	push   %ebp
  100b98:	89 e5                	mov    %esp,%ebp
  100b9a:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100b9d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100ba4:	eb 3f                	jmp    100be5 <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100ba6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100ba9:	89 d0                	mov    %edx,%eax
  100bab:	01 c0                	add    %eax,%eax
  100bad:	01 d0                	add    %edx,%eax
  100baf:	c1 e0 02             	shl    $0x2,%eax
  100bb2:	05 00 70 11 00       	add    $0x117000,%eax
  100bb7:	8b 48 04             	mov    0x4(%eax),%ecx
  100bba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100bbd:	89 d0                	mov    %edx,%eax
  100bbf:	01 c0                	add    %eax,%eax
  100bc1:	01 d0                	add    %edx,%eax
  100bc3:	c1 e0 02             	shl    $0x2,%eax
  100bc6:	05 00 70 11 00       	add    $0x117000,%eax
  100bcb:	8b 00                	mov    (%eax),%eax
  100bcd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100bd1:	89 44 24 04          	mov    %eax,0x4(%esp)
  100bd5:	c7 04 24 15 61 10 00 	movl   $0x106115,(%esp)
  100bdc:	e8 67 f7 ff ff       	call   100348 <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100be1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100be5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100be8:	83 f8 02             	cmp    $0x2,%eax
  100beb:	76 b9                	jbe    100ba6 <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
  100bed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100bf2:	c9                   	leave  
  100bf3:	c3                   	ret    

00100bf4 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100bf4:	55                   	push   %ebp
  100bf5:	89 e5                	mov    %esp,%ebp
  100bf7:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
  100bfa:	e8 7d fc ff ff       	call   10087c <print_kerninfo>
    return 0;
  100bff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100c04:	c9                   	leave  
  100c05:	c3                   	ret    

00100c06 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100c06:	55                   	push   %ebp
  100c07:	89 e5                	mov    %esp,%ebp
  100c09:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
  100c0c:	e8 b5 fd ff ff       	call   1009c6 <print_stackframe>
    return 0;
  100c11:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100c16:	c9                   	leave  
  100c17:	c3                   	ret    

00100c18 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
  100c18:	55                   	push   %ebp
  100c19:	89 e5                	mov    %esp,%ebp
  100c1b:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
  100c1e:	a1 20 a4 11 00       	mov    0x11a420,%eax
  100c23:	85 c0                	test   %eax,%eax
  100c25:	74 02                	je     100c29 <__panic+0x11>
        goto panic_dead;
  100c27:	eb 59                	jmp    100c82 <__panic+0x6a>
    }
    is_panic = 1;
  100c29:	c7 05 20 a4 11 00 01 	movl   $0x1,0x11a420
  100c30:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  100c33:	8d 45 14             	lea    0x14(%ebp),%eax
  100c36:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
  100c39:	8b 45 0c             	mov    0xc(%ebp),%eax
  100c3c:	89 44 24 08          	mov    %eax,0x8(%esp)
  100c40:	8b 45 08             	mov    0x8(%ebp),%eax
  100c43:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c47:	c7 04 24 1e 61 10 00 	movl   $0x10611e,(%esp)
  100c4e:	e8 f5 f6 ff ff       	call   100348 <cprintf>
    vcprintf(fmt, ap);
  100c53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c56:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c5a:	8b 45 10             	mov    0x10(%ebp),%eax
  100c5d:	89 04 24             	mov    %eax,(%esp)
  100c60:	e8 b0 f6 ff ff       	call   100315 <vcprintf>
    cprintf("\n");
  100c65:	c7 04 24 3a 61 10 00 	movl   $0x10613a,(%esp)
  100c6c:	e8 d7 f6 ff ff       	call   100348 <cprintf>
    
    cprintf("stack trackback:\n");
  100c71:	c7 04 24 3c 61 10 00 	movl   $0x10613c,(%esp)
  100c78:	e8 cb f6 ff ff       	call   100348 <cprintf>
    print_stackframe();
  100c7d:	e8 44 fd ff ff       	call   1009c6 <print_stackframe>
    
    va_end(ap);

panic_dead:
    intr_disable();
  100c82:	e8 85 09 00 00       	call   10160c <intr_disable>
    while (1) {
        kmonitor(NULL);
  100c87:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100c8e:	e8 a4 fe ff ff       	call   100b37 <kmonitor>
    }
  100c93:	eb f2                	jmp    100c87 <__panic+0x6f>

00100c95 <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
  100c95:	55                   	push   %ebp
  100c96:	89 e5                	mov    %esp,%ebp
  100c98:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  100c9b:	8d 45 14             	lea    0x14(%ebp),%eax
  100c9e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
  100ca1:	8b 45 0c             	mov    0xc(%ebp),%eax
  100ca4:	89 44 24 08          	mov    %eax,0x8(%esp)
  100ca8:	8b 45 08             	mov    0x8(%ebp),%eax
  100cab:	89 44 24 04          	mov    %eax,0x4(%esp)
  100caf:	c7 04 24 4e 61 10 00 	movl   $0x10614e,(%esp)
  100cb6:	e8 8d f6 ff ff       	call   100348 <cprintf>
    vcprintf(fmt, ap);
  100cbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100cbe:	89 44 24 04          	mov    %eax,0x4(%esp)
  100cc2:	8b 45 10             	mov    0x10(%ebp),%eax
  100cc5:	89 04 24             	mov    %eax,(%esp)
  100cc8:	e8 48 f6 ff ff       	call   100315 <vcprintf>
    cprintf("\n");
  100ccd:	c7 04 24 3a 61 10 00 	movl   $0x10613a,(%esp)
  100cd4:	e8 6f f6 ff ff       	call   100348 <cprintf>
    va_end(ap);
}
  100cd9:	c9                   	leave  
  100cda:	c3                   	ret    

00100cdb <is_kernel_panic>:

bool
is_kernel_panic(void) {
  100cdb:	55                   	push   %ebp
  100cdc:	89 e5                	mov    %esp,%ebp
    return is_panic;
  100cde:	a1 20 a4 11 00       	mov    0x11a420,%eax
}
  100ce3:	5d                   	pop    %ebp
  100ce4:	c3                   	ret    

00100ce5 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100ce5:	55                   	push   %ebp
  100ce6:	89 e5                	mov    %esp,%ebp
  100ce8:	83 ec 28             	sub    $0x28,%esp
  100ceb:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
  100cf1:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100cf5:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100cf9:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100cfd:	ee                   	out    %al,(%dx)
  100cfe:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100d04:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
  100d08:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100d0c:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100d10:	ee                   	out    %al,(%dx)
  100d11:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
  100d17:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
  100d1b:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100d1f:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100d23:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100d24:	c7 05 0c af 11 00 00 	movl   $0x0,0x11af0c
  100d2b:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100d2e:	c7 04 24 6c 61 10 00 	movl   $0x10616c,(%esp)
  100d35:	e8 0e f6 ff ff       	call   100348 <cprintf>
    pic_enable(IRQ_TIMER);
  100d3a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100d41:	e8 24 09 00 00       	call   10166a <pic_enable>
}
  100d46:	c9                   	leave  
  100d47:	c3                   	ret    

00100d48 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
  100d48:	55                   	push   %ebp
  100d49:	89 e5                	mov    %esp,%ebp
  100d4b:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  100d4e:	9c                   	pushf  
  100d4f:	58                   	pop    %eax
  100d50:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  100d53:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  100d56:	25 00 02 00 00       	and    $0x200,%eax
  100d5b:	85 c0                	test   %eax,%eax
  100d5d:	74 0c                	je     100d6b <__intr_save+0x23>
        intr_disable();
  100d5f:	e8 a8 08 00 00       	call   10160c <intr_disable>
        return 1;
  100d64:	b8 01 00 00 00       	mov    $0x1,%eax
  100d69:	eb 05                	jmp    100d70 <__intr_save+0x28>
    }
    return 0;
  100d6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d70:	c9                   	leave  
  100d71:	c3                   	ret    

00100d72 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
  100d72:	55                   	push   %ebp
  100d73:	89 e5                	mov    %esp,%ebp
  100d75:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  100d78:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100d7c:	74 05                	je     100d83 <__intr_restore+0x11>
        intr_enable();
  100d7e:	e8 83 08 00 00       	call   101606 <intr_enable>
    }
}
  100d83:	c9                   	leave  
  100d84:	c3                   	ret    

00100d85 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100d85:	55                   	push   %ebp
  100d86:	89 e5                	mov    %esp,%ebp
  100d88:	83 ec 10             	sub    $0x10,%esp
  100d8b:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100d91:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  100d95:	89 c2                	mov    %eax,%edx
  100d97:	ec                   	in     (%dx),%al
  100d98:	88 45 fd             	mov    %al,-0x3(%ebp)
  100d9b:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  100da1:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100da5:	89 c2                	mov    %eax,%edx
  100da7:	ec                   	in     (%dx),%al
  100da8:	88 45 f9             	mov    %al,-0x7(%ebp)
  100dab:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
  100db1:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100db5:	89 c2                	mov    %eax,%edx
  100db7:	ec                   	in     (%dx),%al
  100db8:	88 45 f5             	mov    %al,-0xb(%ebp)
  100dbb:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
  100dc1:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100dc5:	89 c2                	mov    %eax,%edx
  100dc7:	ec                   	in     (%dx),%al
  100dc8:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  100dcb:	c9                   	leave  
  100dcc:	c3                   	ret    

00100dcd <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
  100dcd:	55                   	push   %ebp
  100dce:	89 e5                	mov    %esp,%ebp
  100dd0:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
  100dd3:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
  100dda:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ddd:	0f b7 00             	movzwl (%eax),%eax
  100de0:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
  100de4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100de7:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
  100dec:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100def:	0f b7 00             	movzwl (%eax),%eax
  100df2:	66 3d 5a a5          	cmp    $0xa55a,%ax
  100df6:	74 12                	je     100e0a <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
  100df8:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
  100dff:	66 c7 05 46 a4 11 00 	movw   $0x3b4,0x11a446
  100e06:	b4 03 
  100e08:	eb 13                	jmp    100e1d <cga_init+0x50>
    } else {
        *cp = was;
  100e0a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e0d:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100e11:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
  100e14:	66 c7 05 46 a4 11 00 	movw   $0x3d4,0x11a446
  100e1b:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
  100e1d:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100e24:	0f b7 c0             	movzwl %ax,%eax
  100e27:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
  100e2b:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100e2f:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100e33:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100e37:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
  100e38:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100e3f:	83 c0 01             	add    $0x1,%eax
  100e42:	0f b7 c0             	movzwl %ax,%eax
  100e45:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100e49:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  100e4d:	89 c2                	mov    %eax,%edx
  100e4f:	ec                   	in     (%dx),%al
  100e50:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  100e53:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100e57:	0f b6 c0             	movzbl %al,%eax
  100e5a:	c1 e0 08             	shl    $0x8,%eax
  100e5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  100e60:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100e67:	0f b7 c0             	movzwl %ax,%eax
  100e6a:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
  100e6e:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100e72:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100e76:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100e7a:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
  100e7b:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100e82:	83 c0 01             	add    $0x1,%eax
  100e85:	0f b7 c0             	movzwl %ax,%eax
  100e88:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100e8c:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
  100e90:	89 c2                	mov    %eax,%edx
  100e92:	ec                   	in     (%dx),%al
  100e93:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
  100e96:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100e9a:	0f b6 c0             	movzbl %al,%eax
  100e9d:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
  100ea0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ea3:	a3 40 a4 11 00       	mov    %eax,0x11a440
    crt_pos = pos;
  100ea8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100eab:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
}
  100eb1:	c9                   	leave  
  100eb2:	c3                   	ret    

00100eb3 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  100eb3:	55                   	push   %ebp
  100eb4:	89 e5                	mov    %esp,%ebp
  100eb6:	83 ec 48             	sub    $0x48,%esp
  100eb9:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
  100ebf:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100ec3:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100ec7:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100ecb:	ee                   	out    %al,(%dx)
  100ecc:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
  100ed2:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
  100ed6:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100eda:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100ede:	ee                   	out    %al,(%dx)
  100edf:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
  100ee5:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
  100ee9:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100eed:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100ef1:	ee                   	out    %al,(%dx)
  100ef2:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  100ef8:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
  100efc:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100f00:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100f04:	ee                   	out    %al,(%dx)
  100f05:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
  100f0b:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
  100f0f:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100f13:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100f17:	ee                   	out    %al,(%dx)
  100f18:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
  100f1e:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
  100f22:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  100f26:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  100f2a:	ee                   	out    %al,(%dx)
  100f2b:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
  100f31:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
  100f35:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  100f39:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  100f3d:	ee                   	out    %al,(%dx)
  100f3e:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f44:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
  100f48:	89 c2                	mov    %eax,%edx
  100f4a:	ec                   	in     (%dx),%al
  100f4b:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
  100f4e:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  100f52:	3c ff                	cmp    $0xff,%al
  100f54:	0f 95 c0             	setne  %al
  100f57:	0f b6 c0             	movzbl %al,%eax
  100f5a:	a3 48 a4 11 00       	mov    %eax,0x11a448
  100f5f:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f65:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
  100f69:	89 c2                	mov    %eax,%edx
  100f6b:	ec                   	in     (%dx),%al
  100f6c:	88 45 d5             	mov    %al,-0x2b(%ebp)
  100f6f:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
  100f75:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
  100f79:	89 c2                	mov    %eax,%edx
  100f7b:	ec                   	in     (%dx),%al
  100f7c:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  100f7f:	a1 48 a4 11 00       	mov    0x11a448,%eax
  100f84:	85 c0                	test   %eax,%eax
  100f86:	74 0c                	je     100f94 <serial_init+0xe1>
        pic_enable(IRQ_COM1);
  100f88:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  100f8f:	e8 d6 06 00 00       	call   10166a <pic_enable>
    }
}
  100f94:	c9                   	leave  
  100f95:	c3                   	ret    

00100f96 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  100f96:	55                   	push   %ebp
  100f97:	89 e5                	mov    %esp,%ebp
  100f99:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  100f9c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  100fa3:	eb 09                	jmp    100fae <lpt_putc_sub+0x18>
        delay();
  100fa5:	e8 db fd ff ff       	call   100d85 <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  100faa:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  100fae:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
  100fb4:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100fb8:	89 c2                	mov    %eax,%edx
  100fba:	ec                   	in     (%dx),%al
  100fbb:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  100fbe:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  100fc2:	84 c0                	test   %al,%al
  100fc4:	78 09                	js     100fcf <lpt_putc_sub+0x39>
  100fc6:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  100fcd:	7e d6                	jle    100fa5 <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
  100fcf:	8b 45 08             	mov    0x8(%ebp),%eax
  100fd2:	0f b6 c0             	movzbl %al,%eax
  100fd5:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
  100fdb:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100fde:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100fe2:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100fe6:	ee                   	out    %al,(%dx)
  100fe7:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
  100fed:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
  100ff1:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100ff5:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100ff9:	ee                   	out    %al,(%dx)
  100ffa:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
  101000:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
  101004:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  101008:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  10100c:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  10100d:	c9                   	leave  
  10100e:	c3                   	ret    

0010100f <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  10100f:	55                   	push   %ebp
  101010:	89 e5                	mov    %esp,%ebp
  101012:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  101015:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  101019:	74 0d                	je     101028 <lpt_putc+0x19>
        lpt_putc_sub(c);
  10101b:	8b 45 08             	mov    0x8(%ebp),%eax
  10101e:	89 04 24             	mov    %eax,(%esp)
  101021:	e8 70 ff ff ff       	call   100f96 <lpt_putc_sub>
  101026:	eb 24                	jmp    10104c <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
  101028:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  10102f:	e8 62 ff ff ff       	call   100f96 <lpt_putc_sub>
        lpt_putc_sub(' ');
  101034:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  10103b:	e8 56 ff ff ff       	call   100f96 <lpt_putc_sub>
        lpt_putc_sub('\b');
  101040:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101047:	e8 4a ff ff ff       	call   100f96 <lpt_putc_sub>
    }
}
  10104c:	c9                   	leave  
  10104d:	c3                   	ret    

0010104e <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  10104e:	55                   	push   %ebp
  10104f:	89 e5                	mov    %esp,%ebp
  101051:	53                   	push   %ebx
  101052:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
  101055:	8b 45 08             	mov    0x8(%ebp),%eax
  101058:	b0 00                	mov    $0x0,%al
  10105a:	85 c0                	test   %eax,%eax
  10105c:	75 07                	jne    101065 <cga_putc+0x17>
        c |= 0x0700;
  10105e:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  101065:	8b 45 08             	mov    0x8(%ebp),%eax
  101068:	0f b6 c0             	movzbl %al,%eax
  10106b:	83 f8 0a             	cmp    $0xa,%eax
  10106e:	74 4c                	je     1010bc <cga_putc+0x6e>
  101070:	83 f8 0d             	cmp    $0xd,%eax
  101073:	74 57                	je     1010cc <cga_putc+0x7e>
  101075:	83 f8 08             	cmp    $0x8,%eax
  101078:	0f 85 88 00 00 00    	jne    101106 <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
  10107e:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  101085:	66 85 c0             	test   %ax,%ax
  101088:	74 30                	je     1010ba <cga_putc+0x6c>
            crt_pos --;
  10108a:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  101091:	83 e8 01             	sub    $0x1,%eax
  101094:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  10109a:	a1 40 a4 11 00       	mov    0x11a440,%eax
  10109f:	0f b7 15 44 a4 11 00 	movzwl 0x11a444,%edx
  1010a6:	0f b7 d2             	movzwl %dx,%edx
  1010a9:	01 d2                	add    %edx,%edx
  1010ab:	01 c2                	add    %eax,%edx
  1010ad:	8b 45 08             	mov    0x8(%ebp),%eax
  1010b0:	b0 00                	mov    $0x0,%al
  1010b2:	83 c8 20             	or     $0x20,%eax
  1010b5:	66 89 02             	mov    %ax,(%edx)
        }
        break;
  1010b8:	eb 72                	jmp    10112c <cga_putc+0xde>
  1010ba:	eb 70                	jmp    10112c <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
  1010bc:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  1010c3:	83 c0 50             	add    $0x50,%eax
  1010c6:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  1010cc:	0f b7 1d 44 a4 11 00 	movzwl 0x11a444,%ebx
  1010d3:	0f b7 0d 44 a4 11 00 	movzwl 0x11a444,%ecx
  1010da:	0f b7 c1             	movzwl %cx,%eax
  1010dd:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
  1010e3:	c1 e8 10             	shr    $0x10,%eax
  1010e6:	89 c2                	mov    %eax,%edx
  1010e8:	66 c1 ea 06          	shr    $0x6,%dx
  1010ec:	89 d0                	mov    %edx,%eax
  1010ee:	c1 e0 02             	shl    $0x2,%eax
  1010f1:	01 d0                	add    %edx,%eax
  1010f3:	c1 e0 04             	shl    $0x4,%eax
  1010f6:	29 c1                	sub    %eax,%ecx
  1010f8:	89 ca                	mov    %ecx,%edx
  1010fa:	89 d8                	mov    %ebx,%eax
  1010fc:	29 d0                	sub    %edx,%eax
  1010fe:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
        break;
  101104:	eb 26                	jmp    10112c <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  101106:	8b 0d 40 a4 11 00    	mov    0x11a440,%ecx
  10110c:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  101113:	8d 50 01             	lea    0x1(%eax),%edx
  101116:	66 89 15 44 a4 11 00 	mov    %dx,0x11a444
  10111d:	0f b7 c0             	movzwl %ax,%eax
  101120:	01 c0                	add    %eax,%eax
  101122:	8d 14 01             	lea    (%ecx,%eax,1),%edx
  101125:	8b 45 08             	mov    0x8(%ebp),%eax
  101128:	66 89 02             	mov    %ax,(%edx)
        break;
  10112b:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  10112c:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  101133:	66 3d cf 07          	cmp    $0x7cf,%ax
  101137:	76 5b                	jbe    101194 <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  101139:	a1 40 a4 11 00       	mov    0x11a440,%eax
  10113e:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  101144:	a1 40 a4 11 00       	mov    0x11a440,%eax
  101149:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  101150:	00 
  101151:	89 54 24 04          	mov    %edx,0x4(%esp)
  101155:	89 04 24             	mov    %eax,(%esp)
  101158:	e8 cf 4b 00 00       	call   105d2c <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  10115d:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  101164:	eb 15                	jmp    10117b <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
  101166:	a1 40 a4 11 00       	mov    0x11a440,%eax
  10116b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10116e:	01 d2                	add    %edx,%edx
  101170:	01 d0                	add    %edx,%eax
  101172:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  101177:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  10117b:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  101182:	7e e2                	jle    101166 <cga_putc+0x118>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
  101184:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  10118b:	83 e8 50             	sub    $0x50,%eax
  10118e:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  101194:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  10119b:	0f b7 c0             	movzwl %ax,%eax
  10119e:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
  1011a2:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
  1011a6:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1011aa:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1011ae:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
  1011af:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  1011b6:	66 c1 e8 08          	shr    $0x8,%ax
  1011ba:	0f b6 c0             	movzbl %al,%eax
  1011bd:	0f b7 15 46 a4 11 00 	movzwl 0x11a446,%edx
  1011c4:	83 c2 01             	add    $0x1,%edx
  1011c7:	0f b7 d2             	movzwl %dx,%edx
  1011ca:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
  1011ce:	88 45 ed             	mov    %al,-0x13(%ebp)
  1011d1:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1011d5:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1011d9:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
  1011da:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  1011e1:	0f b7 c0             	movzwl %ax,%eax
  1011e4:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
  1011e8:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
  1011ec:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  1011f0:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  1011f4:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
  1011f5:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  1011fc:	0f b6 c0             	movzbl %al,%eax
  1011ff:	0f b7 15 46 a4 11 00 	movzwl 0x11a446,%edx
  101206:	83 c2 01             	add    $0x1,%edx
  101209:	0f b7 d2             	movzwl %dx,%edx
  10120c:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
  101210:	88 45 e5             	mov    %al,-0x1b(%ebp)
  101213:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  101217:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  10121b:	ee                   	out    %al,(%dx)
}
  10121c:	83 c4 34             	add    $0x34,%esp
  10121f:	5b                   	pop    %ebx
  101220:	5d                   	pop    %ebp
  101221:	c3                   	ret    

00101222 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  101222:	55                   	push   %ebp
  101223:	89 e5                	mov    %esp,%ebp
  101225:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  101228:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  10122f:	eb 09                	jmp    10123a <serial_putc_sub+0x18>
        delay();
  101231:	e8 4f fb ff ff       	call   100d85 <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  101236:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  10123a:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101240:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  101244:	89 c2                	mov    %eax,%edx
  101246:	ec                   	in     (%dx),%al
  101247:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  10124a:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  10124e:	0f b6 c0             	movzbl %al,%eax
  101251:	83 e0 20             	and    $0x20,%eax
  101254:	85 c0                	test   %eax,%eax
  101256:	75 09                	jne    101261 <serial_putc_sub+0x3f>
  101258:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  10125f:	7e d0                	jle    101231 <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
  101261:	8b 45 08             	mov    0x8(%ebp),%eax
  101264:	0f b6 c0             	movzbl %al,%eax
  101267:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  10126d:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101270:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  101274:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  101278:	ee                   	out    %al,(%dx)
}
  101279:	c9                   	leave  
  10127a:	c3                   	ret    

0010127b <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  10127b:	55                   	push   %ebp
  10127c:	89 e5                	mov    %esp,%ebp
  10127e:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  101281:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  101285:	74 0d                	je     101294 <serial_putc+0x19>
        serial_putc_sub(c);
  101287:	8b 45 08             	mov    0x8(%ebp),%eax
  10128a:	89 04 24             	mov    %eax,(%esp)
  10128d:	e8 90 ff ff ff       	call   101222 <serial_putc_sub>
  101292:	eb 24                	jmp    1012b8 <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
  101294:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  10129b:	e8 82 ff ff ff       	call   101222 <serial_putc_sub>
        serial_putc_sub(' ');
  1012a0:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1012a7:	e8 76 ff ff ff       	call   101222 <serial_putc_sub>
        serial_putc_sub('\b');
  1012ac:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1012b3:	e8 6a ff ff ff       	call   101222 <serial_putc_sub>
    }
}
  1012b8:	c9                   	leave  
  1012b9:	c3                   	ret    

001012ba <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  1012ba:	55                   	push   %ebp
  1012bb:	89 e5                	mov    %esp,%ebp
  1012bd:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
  1012c0:	eb 33                	jmp    1012f5 <cons_intr+0x3b>
        if (c != 0) {
  1012c2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1012c6:	74 2d                	je     1012f5 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
  1012c8:	a1 64 a6 11 00       	mov    0x11a664,%eax
  1012cd:	8d 50 01             	lea    0x1(%eax),%edx
  1012d0:	89 15 64 a6 11 00    	mov    %edx,0x11a664
  1012d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1012d9:	88 90 60 a4 11 00    	mov    %dl,0x11a460(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  1012df:	a1 64 a6 11 00       	mov    0x11a664,%eax
  1012e4:	3d 00 02 00 00       	cmp    $0x200,%eax
  1012e9:	75 0a                	jne    1012f5 <cons_intr+0x3b>
                cons.wpos = 0;
  1012eb:	c7 05 64 a6 11 00 00 	movl   $0x0,0x11a664
  1012f2:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
  1012f5:	8b 45 08             	mov    0x8(%ebp),%eax
  1012f8:	ff d0                	call   *%eax
  1012fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1012fd:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  101301:	75 bf                	jne    1012c2 <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
  101303:	c9                   	leave  
  101304:	c3                   	ret    

00101305 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  101305:	55                   	push   %ebp
  101306:	89 e5                	mov    %esp,%ebp
  101308:	83 ec 10             	sub    $0x10,%esp
  10130b:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101311:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  101315:	89 c2                	mov    %eax,%edx
  101317:	ec                   	in     (%dx),%al
  101318:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  10131b:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  10131f:	0f b6 c0             	movzbl %al,%eax
  101322:	83 e0 01             	and    $0x1,%eax
  101325:	85 c0                	test   %eax,%eax
  101327:	75 07                	jne    101330 <serial_proc_data+0x2b>
        return -1;
  101329:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10132e:	eb 2a                	jmp    10135a <serial_proc_data+0x55>
  101330:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101336:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  10133a:	89 c2                	mov    %eax,%edx
  10133c:	ec                   	in     (%dx),%al
  10133d:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
  101340:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  101344:	0f b6 c0             	movzbl %al,%eax
  101347:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  10134a:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  10134e:	75 07                	jne    101357 <serial_proc_data+0x52>
        c = '\b';
  101350:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  101357:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  10135a:	c9                   	leave  
  10135b:	c3                   	ret    

0010135c <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  10135c:	55                   	push   %ebp
  10135d:	89 e5                	mov    %esp,%ebp
  10135f:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
  101362:	a1 48 a4 11 00       	mov    0x11a448,%eax
  101367:	85 c0                	test   %eax,%eax
  101369:	74 0c                	je     101377 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
  10136b:	c7 04 24 05 13 10 00 	movl   $0x101305,(%esp)
  101372:	e8 43 ff ff ff       	call   1012ba <cons_intr>
    }
}
  101377:	c9                   	leave  
  101378:	c3                   	ret    

00101379 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  101379:	55                   	push   %ebp
  10137a:	89 e5                	mov    %esp,%ebp
  10137c:	83 ec 38             	sub    $0x38,%esp
  10137f:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101385:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  101389:	89 c2                	mov    %eax,%edx
  10138b:	ec                   	in     (%dx),%al
  10138c:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
  10138f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  101393:	0f b6 c0             	movzbl %al,%eax
  101396:	83 e0 01             	and    $0x1,%eax
  101399:	85 c0                	test   %eax,%eax
  10139b:	75 0a                	jne    1013a7 <kbd_proc_data+0x2e>
        return -1;
  10139d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1013a2:	e9 59 01 00 00       	jmp    101500 <kbd_proc_data+0x187>
  1013a7:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1013ad:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  1013b1:	89 c2                	mov    %eax,%edx
  1013b3:	ec                   	in     (%dx),%al
  1013b4:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  1013b7:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
  1013bb:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  1013be:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  1013c2:	75 17                	jne    1013db <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
  1013c4:	a1 68 a6 11 00       	mov    0x11a668,%eax
  1013c9:	83 c8 40             	or     $0x40,%eax
  1013cc:	a3 68 a6 11 00       	mov    %eax,0x11a668
        return 0;
  1013d1:	b8 00 00 00 00       	mov    $0x0,%eax
  1013d6:	e9 25 01 00 00       	jmp    101500 <kbd_proc_data+0x187>
    } else if (data & 0x80) {
  1013db:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1013df:	84 c0                	test   %al,%al
  1013e1:	79 47                	jns    10142a <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  1013e3:	a1 68 a6 11 00       	mov    0x11a668,%eax
  1013e8:	83 e0 40             	and    $0x40,%eax
  1013eb:	85 c0                	test   %eax,%eax
  1013ed:	75 09                	jne    1013f8 <kbd_proc_data+0x7f>
  1013ef:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1013f3:	83 e0 7f             	and    $0x7f,%eax
  1013f6:	eb 04                	jmp    1013fc <kbd_proc_data+0x83>
  1013f8:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1013fc:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  1013ff:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101403:	0f b6 80 40 70 11 00 	movzbl 0x117040(%eax),%eax
  10140a:	83 c8 40             	or     $0x40,%eax
  10140d:	0f b6 c0             	movzbl %al,%eax
  101410:	f7 d0                	not    %eax
  101412:	89 c2                	mov    %eax,%edx
  101414:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101419:	21 d0                	and    %edx,%eax
  10141b:	a3 68 a6 11 00       	mov    %eax,0x11a668
        return 0;
  101420:	b8 00 00 00 00       	mov    $0x0,%eax
  101425:	e9 d6 00 00 00       	jmp    101500 <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
  10142a:	a1 68 a6 11 00       	mov    0x11a668,%eax
  10142f:	83 e0 40             	and    $0x40,%eax
  101432:	85 c0                	test   %eax,%eax
  101434:	74 11                	je     101447 <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  101436:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  10143a:	a1 68 a6 11 00       	mov    0x11a668,%eax
  10143f:	83 e0 bf             	and    $0xffffffbf,%eax
  101442:	a3 68 a6 11 00       	mov    %eax,0x11a668
    }

    shift |= shiftcode[data];
  101447:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10144b:	0f b6 80 40 70 11 00 	movzbl 0x117040(%eax),%eax
  101452:	0f b6 d0             	movzbl %al,%edx
  101455:	a1 68 a6 11 00       	mov    0x11a668,%eax
  10145a:	09 d0                	or     %edx,%eax
  10145c:	a3 68 a6 11 00       	mov    %eax,0x11a668
    shift ^= togglecode[data];
  101461:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101465:	0f b6 80 40 71 11 00 	movzbl 0x117140(%eax),%eax
  10146c:	0f b6 d0             	movzbl %al,%edx
  10146f:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101474:	31 d0                	xor    %edx,%eax
  101476:	a3 68 a6 11 00       	mov    %eax,0x11a668

    c = charcode[shift & (CTL | SHIFT)][data];
  10147b:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101480:	83 e0 03             	and    $0x3,%eax
  101483:	8b 14 85 40 75 11 00 	mov    0x117540(,%eax,4),%edx
  10148a:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10148e:	01 d0                	add    %edx,%eax
  101490:	0f b6 00             	movzbl (%eax),%eax
  101493:	0f b6 c0             	movzbl %al,%eax
  101496:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  101499:	a1 68 a6 11 00       	mov    0x11a668,%eax
  10149e:	83 e0 08             	and    $0x8,%eax
  1014a1:	85 c0                	test   %eax,%eax
  1014a3:	74 22                	je     1014c7 <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
  1014a5:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  1014a9:	7e 0c                	jle    1014b7 <kbd_proc_data+0x13e>
  1014ab:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  1014af:	7f 06                	jg     1014b7 <kbd_proc_data+0x13e>
            c += 'A' - 'a';
  1014b1:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  1014b5:	eb 10                	jmp    1014c7 <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
  1014b7:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  1014bb:	7e 0a                	jle    1014c7 <kbd_proc_data+0x14e>
  1014bd:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  1014c1:	7f 04                	jg     1014c7 <kbd_proc_data+0x14e>
            c += 'a' - 'A';
  1014c3:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  1014c7:	a1 68 a6 11 00       	mov    0x11a668,%eax
  1014cc:	f7 d0                	not    %eax
  1014ce:	83 e0 06             	and    $0x6,%eax
  1014d1:	85 c0                	test   %eax,%eax
  1014d3:	75 28                	jne    1014fd <kbd_proc_data+0x184>
  1014d5:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  1014dc:	75 1f                	jne    1014fd <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
  1014de:	c7 04 24 87 61 10 00 	movl   $0x106187,(%esp)
  1014e5:	e8 5e ee ff ff       	call   100348 <cprintf>
  1014ea:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
  1014f0:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1014f4:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  1014f8:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
  1014fc:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  1014fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  101500:	c9                   	leave  
  101501:	c3                   	ret    

00101502 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  101502:	55                   	push   %ebp
  101503:	89 e5                	mov    %esp,%ebp
  101505:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
  101508:	c7 04 24 79 13 10 00 	movl   $0x101379,(%esp)
  10150f:	e8 a6 fd ff ff       	call   1012ba <cons_intr>
}
  101514:	c9                   	leave  
  101515:	c3                   	ret    

00101516 <kbd_init>:

static void
kbd_init(void) {
  101516:	55                   	push   %ebp
  101517:	89 e5                	mov    %esp,%ebp
  101519:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
  10151c:	e8 e1 ff ff ff       	call   101502 <kbd_intr>
    pic_enable(IRQ_KBD);
  101521:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  101528:	e8 3d 01 00 00       	call   10166a <pic_enable>
}
  10152d:	c9                   	leave  
  10152e:	c3                   	ret    

0010152f <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  10152f:	55                   	push   %ebp
  101530:	89 e5                	mov    %esp,%ebp
  101532:	83 ec 18             	sub    $0x18,%esp
    cga_init();
  101535:	e8 93 f8 ff ff       	call   100dcd <cga_init>
    serial_init();
  10153a:	e8 74 f9 ff ff       	call   100eb3 <serial_init>
    kbd_init();
  10153f:	e8 d2 ff ff ff       	call   101516 <kbd_init>
    if (!serial_exists) {
  101544:	a1 48 a4 11 00       	mov    0x11a448,%eax
  101549:	85 c0                	test   %eax,%eax
  10154b:	75 0c                	jne    101559 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
  10154d:	c7 04 24 93 61 10 00 	movl   $0x106193,(%esp)
  101554:	e8 ef ed ff ff       	call   100348 <cprintf>
    }
}
  101559:	c9                   	leave  
  10155a:	c3                   	ret    

0010155b <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  10155b:	55                   	push   %ebp
  10155c:	89 e5                	mov    %esp,%ebp
  10155e:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  101561:	e8 e2 f7 ff ff       	call   100d48 <__intr_save>
  101566:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
  101569:	8b 45 08             	mov    0x8(%ebp),%eax
  10156c:	89 04 24             	mov    %eax,(%esp)
  10156f:	e8 9b fa ff ff       	call   10100f <lpt_putc>
        cga_putc(c);
  101574:	8b 45 08             	mov    0x8(%ebp),%eax
  101577:	89 04 24             	mov    %eax,(%esp)
  10157a:	e8 cf fa ff ff       	call   10104e <cga_putc>
        serial_putc(c);
  10157f:	8b 45 08             	mov    0x8(%ebp),%eax
  101582:	89 04 24             	mov    %eax,(%esp)
  101585:	e8 f1 fc ff ff       	call   10127b <serial_putc>
    }
    local_intr_restore(intr_flag);
  10158a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10158d:	89 04 24             	mov    %eax,(%esp)
  101590:	e8 dd f7 ff ff       	call   100d72 <__intr_restore>
}
  101595:	c9                   	leave  
  101596:	c3                   	ret    

00101597 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  101597:	55                   	push   %ebp
  101598:	89 e5                	mov    %esp,%ebp
  10159a:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
  10159d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  1015a4:	e8 9f f7 ff ff       	call   100d48 <__intr_save>
  1015a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
  1015ac:	e8 ab fd ff ff       	call   10135c <serial_intr>
        kbd_intr();
  1015b1:	e8 4c ff ff ff       	call   101502 <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
  1015b6:	8b 15 60 a6 11 00    	mov    0x11a660,%edx
  1015bc:	a1 64 a6 11 00       	mov    0x11a664,%eax
  1015c1:	39 c2                	cmp    %eax,%edx
  1015c3:	74 31                	je     1015f6 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
  1015c5:	a1 60 a6 11 00       	mov    0x11a660,%eax
  1015ca:	8d 50 01             	lea    0x1(%eax),%edx
  1015cd:	89 15 60 a6 11 00    	mov    %edx,0x11a660
  1015d3:	0f b6 80 60 a4 11 00 	movzbl 0x11a460(%eax),%eax
  1015da:	0f b6 c0             	movzbl %al,%eax
  1015dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
  1015e0:	a1 60 a6 11 00       	mov    0x11a660,%eax
  1015e5:	3d 00 02 00 00       	cmp    $0x200,%eax
  1015ea:	75 0a                	jne    1015f6 <cons_getc+0x5f>
                cons.rpos = 0;
  1015ec:	c7 05 60 a6 11 00 00 	movl   $0x0,0x11a660
  1015f3:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
  1015f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1015f9:	89 04 24             	mov    %eax,(%esp)
  1015fc:	e8 71 f7 ff ff       	call   100d72 <__intr_restore>
    return c;
  101601:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  101604:	c9                   	leave  
  101605:	c3                   	ret    

00101606 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
  101606:	55                   	push   %ebp
  101607:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
  101609:	fb                   	sti    
    sti();
}
  10160a:	5d                   	pop    %ebp
  10160b:	c3                   	ret    

0010160c <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  10160c:	55                   	push   %ebp
  10160d:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
  10160f:	fa                   	cli    
    cli();
}
  101610:	5d                   	pop    %ebp
  101611:	c3                   	ret    

00101612 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  101612:	55                   	push   %ebp
  101613:	89 e5                	mov    %esp,%ebp
  101615:	83 ec 14             	sub    $0x14,%esp
  101618:	8b 45 08             	mov    0x8(%ebp),%eax
  10161b:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
  10161f:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101623:	66 a3 50 75 11 00    	mov    %ax,0x117550
    if (did_init) {
  101629:	a1 6c a6 11 00       	mov    0x11a66c,%eax
  10162e:	85 c0                	test   %eax,%eax
  101630:	74 36                	je     101668 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
  101632:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101636:	0f b6 c0             	movzbl %al,%eax
  101639:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  10163f:	88 45 fd             	mov    %al,-0x3(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101642:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  101646:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  10164a:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
  10164b:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  10164f:	66 c1 e8 08          	shr    $0x8,%ax
  101653:	0f b6 c0             	movzbl %al,%eax
  101656:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
  10165c:	88 45 f9             	mov    %al,-0x7(%ebp)
  10165f:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101663:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101667:	ee                   	out    %al,(%dx)
    }
}
  101668:	c9                   	leave  
  101669:	c3                   	ret    

0010166a <pic_enable>:

void
pic_enable(unsigned int irq) {
  10166a:	55                   	push   %ebp
  10166b:	89 e5                	mov    %esp,%ebp
  10166d:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
  101670:	8b 45 08             	mov    0x8(%ebp),%eax
  101673:	ba 01 00 00 00       	mov    $0x1,%edx
  101678:	89 c1                	mov    %eax,%ecx
  10167a:	d3 e2                	shl    %cl,%edx
  10167c:	89 d0                	mov    %edx,%eax
  10167e:	f7 d0                	not    %eax
  101680:	89 c2                	mov    %eax,%edx
  101682:	0f b7 05 50 75 11 00 	movzwl 0x117550,%eax
  101689:	21 d0                	and    %edx,%eax
  10168b:	0f b7 c0             	movzwl %ax,%eax
  10168e:	89 04 24             	mov    %eax,(%esp)
  101691:	e8 7c ff ff ff       	call   101612 <pic_setmask>
}
  101696:	c9                   	leave  
  101697:	c3                   	ret    

00101698 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
  101698:	55                   	push   %ebp
  101699:	89 e5                	mov    %esp,%ebp
  10169b:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
  10169e:	c7 05 6c a6 11 00 01 	movl   $0x1,0x11a66c
  1016a5:	00 00 00 
  1016a8:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  1016ae:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
  1016b2:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  1016b6:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  1016ba:	ee                   	out    %al,(%dx)
  1016bb:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
  1016c1:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
  1016c5:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  1016c9:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  1016cd:	ee                   	out    %al,(%dx)
  1016ce:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
  1016d4:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
  1016d8:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  1016dc:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1016e0:	ee                   	out    %al,(%dx)
  1016e1:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
  1016e7:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
  1016eb:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1016ef:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1016f3:	ee                   	out    %al,(%dx)
  1016f4:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
  1016fa:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
  1016fe:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  101702:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101706:	ee                   	out    %al,(%dx)
  101707:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
  10170d:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
  101711:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101715:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  101719:	ee                   	out    %al,(%dx)
  10171a:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
  101720:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
  101724:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  101728:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  10172c:	ee                   	out    %al,(%dx)
  10172d:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
  101733:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
  101737:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  10173b:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  10173f:	ee                   	out    %al,(%dx)
  101740:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
  101746:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
  10174a:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  10174e:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  101752:	ee                   	out    %al,(%dx)
  101753:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
  101759:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
  10175d:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  101761:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  101765:	ee                   	out    %al,(%dx)
  101766:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
  10176c:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
  101770:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  101774:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  101778:	ee                   	out    %al,(%dx)
  101779:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
  10177f:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
  101783:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  101787:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  10178b:	ee                   	out    %al,(%dx)
  10178c:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
  101792:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
  101796:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
  10179a:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
  10179e:	ee                   	out    %al,(%dx)
  10179f:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
  1017a5:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
  1017a9:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
  1017ad:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
  1017b1:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  1017b2:	0f b7 05 50 75 11 00 	movzwl 0x117550,%eax
  1017b9:	66 83 f8 ff          	cmp    $0xffff,%ax
  1017bd:	74 12                	je     1017d1 <pic_init+0x139>
        pic_setmask(irq_mask);
  1017bf:	0f b7 05 50 75 11 00 	movzwl 0x117550,%eax
  1017c6:	0f b7 c0             	movzwl %ax,%eax
  1017c9:	89 04 24             	mov    %eax,(%esp)
  1017cc:	e8 41 fe ff ff       	call   101612 <pic_setmask>
    }
}
  1017d1:	c9                   	leave  
  1017d2:	c3                   	ret    

001017d3 <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
  1017d3:	55                   	push   %ebp
  1017d4:	89 e5                	mov    %esp,%ebp
  1017d6:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
  1017d9:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  1017e0:	00 
  1017e1:	c7 04 24 c0 61 10 00 	movl   $0x1061c0,(%esp)
  1017e8:	e8 5b eb ff ff       	call   100348 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
  1017ed:	c9                   	leave  
  1017ee:	c3                   	ret    

001017ef <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  1017ef:	55                   	push   %ebp
  1017f0:	89 e5                	mov    %esp,%ebp
      *     Can you see idt[256] in this file? Yes, it's IDT! you can use SETGATE macro to setup each item of IDT
      * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
}
  1017f2:	5d                   	pop    %ebp
  1017f3:	c3                   	ret    

001017f4 <trapname>:

static const char *
trapname(int trapno) {
  1017f4:	55                   	push   %ebp
  1017f5:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  1017f7:	8b 45 08             	mov    0x8(%ebp),%eax
  1017fa:	83 f8 13             	cmp    $0x13,%eax
  1017fd:	77 0c                	ja     10180b <trapname+0x17>
        return excnames[trapno];
  1017ff:	8b 45 08             	mov    0x8(%ebp),%eax
  101802:	8b 04 85 20 65 10 00 	mov    0x106520(,%eax,4),%eax
  101809:	eb 18                	jmp    101823 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  10180b:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  10180f:	7e 0d                	jle    10181e <trapname+0x2a>
  101811:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  101815:	7f 07                	jg     10181e <trapname+0x2a>
        return "Hardware Interrupt";
  101817:	b8 ca 61 10 00       	mov    $0x1061ca,%eax
  10181c:	eb 05                	jmp    101823 <trapname+0x2f>
    }
    return "(unknown trap)";
  10181e:	b8 dd 61 10 00       	mov    $0x1061dd,%eax
}
  101823:	5d                   	pop    %ebp
  101824:	c3                   	ret    

00101825 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  101825:	55                   	push   %ebp
  101826:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  101828:	8b 45 08             	mov    0x8(%ebp),%eax
  10182b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  10182f:	66 83 f8 08          	cmp    $0x8,%ax
  101833:	0f 94 c0             	sete   %al
  101836:	0f b6 c0             	movzbl %al,%eax
}
  101839:	5d                   	pop    %ebp
  10183a:	c3                   	ret    

0010183b <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  10183b:	55                   	push   %ebp
  10183c:	89 e5                	mov    %esp,%ebp
  10183e:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
  101841:	8b 45 08             	mov    0x8(%ebp),%eax
  101844:	89 44 24 04          	mov    %eax,0x4(%esp)
  101848:	c7 04 24 1e 62 10 00 	movl   $0x10621e,(%esp)
  10184f:	e8 f4 ea ff ff       	call   100348 <cprintf>
    print_regs(&tf->tf_regs);
  101854:	8b 45 08             	mov    0x8(%ebp),%eax
  101857:	89 04 24             	mov    %eax,(%esp)
  10185a:	e8 a1 01 00 00       	call   101a00 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  10185f:	8b 45 08             	mov    0x8(%ebp),%eax
  101862:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101866:	0f b7 c0             	movzwl %ax,%eax
  101869:	89 44 24 04          	mov    %eax,0x4(%esp)
  10186d:	c7 04 24 2f 62 10 00 	movl   $0x10622f,(%esp)
  101874:	e8 cf ea ff ff       	call   100348 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101879:	8b 45 08             	mov    0x8(%ebp),%eax
  10187c:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101880:	0f b7 c0             	movzwl %ax,%eax
  101883:	89 44 24 04          	mov    %eax,0x4(%esp)
  101887:	c7 04 24 42 62 10 00 	movl   $0x106242,(%esp)
  10188e:	e8 b5 ea ff ff       	call   100348 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101893:	8b 45 08             	mov    0x8(%ebp),%eax
  101896:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  10189a:	0f b7 c0             	movzwl %ax,%eax
  10189d:	89 44 24 04          	mov    %eax,0x4(%esp)
  1018a1:	c7 04 24 55 62 10 00 	movl   $0x106255,(%esp)
  1018a8:	e8 9b ea ff ff       	call   100348 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  1018ad:	8b 45 08             	mov    0x8(%ebp),%eax
  1018b0:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  1018b4:	0f b7 c0             	movzwl %ax,%eax
  1018b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  1018bb:	c7 04 24 68 62 10 00 	movl   $0x106268,(%esp)
  1018c2:	e8 81 ea ff ff       	call   100348 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  1018c7:	8b 45 08             	mov    0x8(%ebp),%eax
  1018ca:	8b 40 30             	mov    0x30(%eax),%eax
  1018cd:	89 04 24             	mov    %eax,(%esp)
  1018d0:	e8 1f ff ff ff       	call   1017f4 <trapname>
  1018d5:	8b 55 08             	mov    0x8(%ebp),%edx
  1018d8:	8b 52 30             	mov    0x30(%edx),%edx
  1018db:	89 44 24 08          	mov    %eax,0x8(%esp)
  1018df:	89 54 24 04          	mov    %edx,0x4(%esp)
  1018e3:	c7 04 24 7b 62 10 00 	movl   $0x10627b,(%esp)
  1018ea:	e8 59 ea ff ff       	call   100348 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  1018ef:	8b 45 08             	mov    0x8(%ebp),%eax
  1018f2:	8b 40 34             	mov    0x34(%eax),%eax
  1018f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  1018f9:	c7 04 24 8d 62 10 00 	movl   $0x10628d,(%esp)
  101900:	e8 43 ea ff ff       	call   100348 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101905:	8b 45 08             	mov    0x8(%ebp),%eax
  101908:	8b 40 38             	mov    0x38(%eax),%eax
  10190b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10190f:	c7 04 24 9c 62 10 00 	movl   $0x10629c,(%esp)
  101916:	e8 2d ea ff ff       	call   100348 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  10191b:	8b 45 08             	mov    0x8(%ebp),%eax
  10191e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101922:	0f b7 c0             	movzwl %ax,%eax
  101925:	89 44 24 04          	mov    %eax,0x4(%esp)
  101929:	c7 04 24 ab 62 10 00 	movl   $0x1062ab,(%esp)
  101930:	e8 13 ea ff ff       	call   100348 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101935:	8b 45 08             	mov    0x8(%ebp),%eax
  101938:	8b 40 40             	mov    0x40(%eax),%eax
  10193b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10193f:	c7 04 24 be 62 10 00 	movl   $0x1062be,(%esp)
  101946:	e8 fd e9 ff ff       	call   100348 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  10194b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101952:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101959:	eb 3e                	jmp    101999 <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  10195b:	8b 45 08             	mov    0x8(%ebp),%eax
  10195e:	8b 50 40             	mov    0x40(%eax),%edx
  101961:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101964:	21 d0                	and    %edx,%eax
  101966:	85 c0                	test   %eax,%eax
  101968:	74 28                	je     101992 <print_trapframe+0x157>
  10196a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10196d:	8b 04 85 80 75 11 00 	mov    0x117580(,%eax,4),%eax
  101974:	85 c0                	test   %eax,%eax
  101976:	74 1a                	je     101992 <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
  101978:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10197b:	8b 04 85 80 75 11 00 	mov    0x117580(,%eax,4),%eax
  101982:	89 44 24 04          	mov    %eax,0x4(%esp)
  101986:	c7 04 24 cd 62 10 00 	movl   $0x1062cd,(%esp)
  10198d:	e8 b6 e9 ff ff       	call   100348 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101992:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  101996:	d1 65 f0             	shll   -0x10(%ebp)
  101999:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10199c:	83 f8 17             	cmp    $0x17,%eax
  10199f:	76 ba                	jbe    10195b <print_trapframe+0x120>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  1019a1:	8b 45 08             	mov    0x8(%ebp),%eax
  1019a4:	8b 40 40             	mov    0x40(%eax),%eax
  1019a7:	25 00 30 00 00       	and    $0x3000,%eax
  1019ac:	c1 e8 0c             	shr    $0xc,%eax
  1019af:	89 44 24 04          	mov    %eax,0x4(%esp)
  1019b3:	c7 04 24 d1 62 10 00 	movl   $0x1062d1,(%esp)
  1019ba:	e8 89 e9 ff ff       	call   100348 <cprintf>

    if (!trap_in_kernel(tf)) {
  1019bf:	8b 45 08             	mov    0x8(%ebp),%eax
  1019c2:	89 04 24             	mov    %eax,(%esp)
  1019c5:	e8 5b fe ff ff       	call   101825 <trap_in_kernel>
  1019ca:	85 c0                	test   %eax,%eax
  1019cc:	75 30                	jne    1019fe <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  1019ce:	8b 45 08             	mov    0x8(%ebp),%eax
  1019d1:	8b 40 44             	mov    0x44(%eax),%eax
  1019d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1019d8:	c7 04 24 da 62 10 00 	movl   $0x1062da,(%esp)
  1019df:	e8 64 e9 ff ff       	call   100348 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  1019e4:	8b 45 08             	mov    0x8(%ebp),%eax
  1019e7:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  1019eb:	0f b7 c0             	movzwl %ax,%eax
  1019ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  1019f2:	c7 04 24 e9 62 10 00 	movl   $0x1062e9,(%esp)
  1019f9:	e8 4a e9 ff ff       	call   100348 <cprintf>
    }
}
  1019fe:	c9                   	leave  
  1019ff:	c3                   	ret    

00101a00 <print_regs>:

void
print_regs(struct pushregs *regs) {
  101a00:	55                   	push   %ebp
  101a01:	89 e5                	mov    %esp,%ebp
  101a03:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101a06:	8b 45 08             	mov    0x8(%ebp),%eax
  101a09:	8b 00                	mov    (%eax),%eax
  101a0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a0f:	c7 04 24 fc 62 10 00 	movl   $0x1062fc,(%esp)
  101a16:	e8 2d e9 ff ff       	call   100348 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101a1b:	8b 45 08             	mov    0x8(%ebp),%eax
  101a1e:	8b 40 04             	mov    0x4(%eax),%eax
  101a21:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a25:	c7 04 24 0b 63 10 00 	movl   $0x10630b,(%esp)
  101a2c:	e8 17 e9 ff ff       	call   100348 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101a31:	8b 45 08             	mov    0x8(%ebp),%eax
  101a34:	8b 40 08             	mov    0x8(%eax),%eax
  101a37:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a3b:	c7 04 24 1a 63 10 00 	movl   $0x10631a,(%esp)
  101a42:	e8 01 e9 ff ff       	call   100348 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101a47:	8b 45 08             	mov    0x8(%ebp),%eax
  101a4a:	8b 40 0c             	mov    0xc(%eax),%eax
  101a4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a51:	c7 04 24 29 63 10 00 	movl   $0x106329,(%esp)
  101a58:	e8 eb e8 ff ff       	call   100348 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101a5d:	8b 45 08             	mov    0x8(%ebp),%eax
  101a60:	8b 40 10             	mov    0x10(%eax),%eax
  101a63:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a67:	c7 04 24 38 63 10 00 	movl   $0x106338,(%esp)
  101a6e:	e8 d5 e8 ff ff       	call   100348 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101a73:	8b 45 08             	mov    0x8(%ebp),%eax
  101a76:	8b 40 14             	mov    0x14(%eax),%eax
  101a79:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a7d:	c7 04 24 47 63 10 00 	movl   $0x106347,(%esp)
  101a84:	e8 bf e8 ff ff       	call   100348 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101a89:	8b 45 08             	mov    0x8(%ebp),%eax
  101a8c:	8b 40 18             	mov    0x18(%eax),%eax
  101a8f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a93:	c7 04 24 56 63 10 00 	movl   $0x106356,(%esp)
  101a9a:	e8 a9 e8 ff ff       	call   100348 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101a9f:	8b 45 08             	mov    0x8(%ebp),%eax
  101aa2:	8b 40 1c             	mov    0x1c(%eax),%eax
  101aa5:	89 44 24 04          	mov    %eax,0x4(%esp)
  101aa9:	c7 04 24 65 63 10 00 	movl   $0x106365,(%esp)
  101ab0:	e8 93 e8 ff ff       	call   100348 <cprintf>
}
  101ab5:	c9                   	leave  
  101ab6:	c3                   	ret    

00101ab7 <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101ab7:	55                   	push   %ebp
  101ab8:	89 e5                	mov    %esp,%ebp
  101aba:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
  101abd:	8b 45 08             	mov    0x8(%ebp),%eax
  101ac0:	8b 40 30             	mov    0x30(%eax),%eax
  101ac3:	83 f8 2f             	cmp    $0x2f,%eax
  101ac6:	77 1e                	ja     101ae6 <trap_dispatch+0x2f>
  101ac8:	83 f8 2e             	cmp    $0x2e,%eax
  101acb:	0f 83 bf 00 00 00    	jae    101b90 <trap_dispatch+0xd9>
  101ad1:	83 f8 21             	cmp    $0x21,%eax
  101ad4:	74 40                	je     101b16 <trap_dispatch+0x5f>
  101ad6:	83 f8 24             	cmp    $0x24,%eax
  101ad9:	74 15                	je     101af0 <trap_dispatch+0x39>
  101adb:	83 f8 20             	cmp    $0x20,%eax
  101ade:	0f 84 af 00 00 00    	je     101b93 <trap_dispatch+0xdc>
  101ae4:	eb 72                	jmp    101b58 <trap_dispatch+0xa1>
  101ae6:	83 e8 78             	sub    $0x78,%eax
  101ae9:	83 f8 01             	cmp    $0x1,%eax
  101aec:	77 6a                	ja     101b58 <trap_dispatch+0xa1>
  101aee:	eb 4c                	jmp    101b3c <trap_dispatch+0x85>
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        break;
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101af0:	e8 a2 fa ff ff       	call   101597 <cons_getc>
  101af5:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101af8:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101afc:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101b00:	89 54 24 08          	mov    %edx,0x8(%esp)
  101b04:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b08:	c7 04 24 74 63 10 00 	movl   $0x106374,(%esp)
  101b0f:	e8 34 e8 ff ff       	call   100348 <cprintf>
        break;
  101b14:	eb 7e                	jmp    101b94 <trap_dispatch+0xdd>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101b16:	e8 7c fa ff ff       	call   101597 <cons_getc>
  101b1b:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101b1e:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101b22:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101b26:	89 54 24 08          	mov    %edx,0x8(%esp)
  101b2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b2e:	c7 04 24 86 63 10 00 	movl   $0x106386,(%esp)
  101b35:	e8 0e e8 ff ff       	call   100348 <cprintf>
        break;
  101b3a:	eb 58                	jmp    101b94 <trap_dispatch+0xdd>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
  101b3c:	c7 44 24 08 95 63 10 	movl   $0x106395,0x8(%esp)
  101b43:	00 
  101b44:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
  101b4b:	00 
  101b4c:	c7 04 24 a5 63 10 00 	movl   $0x1063a5,(%esp)
  101b53:	e8 c0 f0 ff ff       	call   100c18 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  101b58:	8b 45 08             	mov    0x8(%ebp),%eax
  101b5b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101b5f:	0f b7 c0             	movzwl %ax,%eax
  101b62:	83 e0 03             	and    $0x3,%eax
  101b65:	85 c0                	test   %eax,%eax
  101b67:	75 2b                	jne    101b94 <trap_dispatch+0xdd>
            print_trapframe(tf);
  101b69:	8b 45 08             	mov    0x8(%ebp),%eax
  101b6c:	89 04 24             	mov    %eax,(%esp)
  101b6f:	e8 c7 fc ff ff       	call   10183b <print_trapframe>
            panic("unexpected trap in kernel.\n");
  101b74:	c7 44 24 08 b6 63 10 	movl   $0x1063b6,0x8(%esp)
  101b7b:	00 
  101b7c:	c7 44 24 04 ac 00 00 	movl   $0xac,0x4(%esp)
  101b83:	00 
  101b84:	c7 04 24 a5 63 10 00 	movl   $0x1063a5,(%esp)
  101b8b:	e8 88 f0 ff ff       	call   100c18 <__panic>
        panic("T_SWITCH_** ??\n");
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
  101b90:	90                   	nop
  101b91:	eb 01                	jmp    101b94 <trap_dispatch+0xdd>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        break;
  101b93:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
  101b94:	c9                   	leave  
  101b95:	c3                   	ret    

00101b96 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  101b96:	55                   	push   %ebp
  101b97:	89 e5                	mov    %esp,%ebp
  101b99:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  101b9c:	8b 45 08             	mov    0x8(%ebp),%eax
  101b9f:	89 04 24             	mov    %eax,(%esp)
  101ba2:	e8 10 ff ff ff       	call   101ab7 <trap_dispatch>
}
  101ba7:	c9                   	leave  
  101ba8:	c3                   	ret    

00101ba9 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  101ba9:	1e                   	push   %ds
    pushl %es
  101baa:	06                   	push   %es
    pushl %fs
  101bab:	0f a0                	push   %fs
    pushl %gs
  101bad:	0f a8                	push   %gs
    pushal
  101baf:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  101bb0:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  101bb5:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  101bb7:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  101bb9:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  101bba:	e8 d7 ff ff ff       	call   101b96 <trap>

    # pop the pushed stack pointer
    popl %esp
  101bbf:	5c                   	pop    %esp

00101bc0 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  101bc0:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  101bc1:	0f a9                	pop    %gs
    popl %fs
  101bc3:	0f a1                	pop    %fs
    popl %es
  101bc5:	07                   	pop    %es
    popl %ds
  101bc6:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  101bc7:	83 c4 08             	add    $0x8,%esp
    iret
  101bca:	cf                   	iret   

00101bcb <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  101bcb:	6a 00                	push   $0x0
  pushl $0
  101bcd:	6a 00                	push   $0x0
  jmp __alltraps
  101bcf:	e9 d5 ff ff ff       	jmp    101ba9 <__alltraps>

00101bd4 <vector1>:
.globl vector1
vector1:
  pushl $0
  101bd4:	6a 00                	push   $0x0
  pushl $1
  101bd6:	6a 01                	push   $0x1
  jmp __alltraps
  101bd8:	e9 cc ff ff ff       	jmp    101ba9 <__alltraps>

00101bdd <vector2>:
.globl vector2
vector2:
  pushl $0
  101bdd:	6a 00                	push   $0x0
  pushl $2
  101bdf:	6a 02                	push   $0x2
  jmp __alltraps
  101be1:	e9 c3 ff ff ff       	jmp    101ba9 <__alltraps>

00101be6 <vector3>:
.globl vector3
vector3:
  pushl $0
  101be6:	6a 00                	push   $0x0
  pushl $3
  101be8:	6a 03                	push   $0x3
  jmp __alltraps
  101bea:	e9 ba ff ff ff       	jmp    101ba9 <__alltraps>

00101bef <vector4>:
.globl vector4
vector4:
  pushl $0
  101bef:	6a 00                	push   $0x0
  pushl $4
  101bf1:	6a 04                	push   $0x4
  jmp __alltraps
  101bf3:	e9 b1 ff ff ff       	jmp    101ba9 <__alltraps>

00101bf8 <vector5>:
.globl vector5
vector5:
  pushl $0
  101bf8:	6a 00                	push   $0x0
  pushl $5
  101bfa:	6a 05                	push   $0x5
  jmp __alltraps
  101bfc:	e9 a8 ff ff ff       	jmp    101ba9 <__alltraps>

00101c01 <vector6>:
.globl vector6
vector6:
  pushl $0
  101c01:	6a 00                	push   $0x0
  pushl $6
  101c03:	6a 06                	push   $0x6
  jmp __alltraps
  101c05:	e9 9f ff ff ff       	jmp    101ba9 <__alltraps>

00101c0a <vector7>:
.globl vector7
vector7:
  pushl $0
  101c0a:	6a 00                	push   $0x0
  pushl $7
  101c0c:	6a 07                	push   $0x7
  jmp __alltraps
  101c0e:	e9 96 ff ff ff       	jmp    101ba9 <__alltraps>

00101c13 <vector8>:
.globl vector8
vector8:
  pushl $8
  101c13:	6a 08                	push   $0x8
  jmp __alltraps
  101c15:	e9 8f ff ff ff       	jmp    101ba9 <__alltraps>

00101c1a <vector9>:
.globl vector9
vector9:
  pushl $0
  101c1a:	6a 00                	push   $0x0
  pushl $9
  101c1c:	6a 09                	push   $0x9
  jmp __alltraps
  101c1e:	e9 86 ff ff ff       	jmp    101ba9 <__alltraps>

00101c23 <vector10>:
.globl vector10
vector10:
  pushl $10
  101c23:	6a 0a                	push   $0xa
  jmp __alltraps
  101c25:	e9 7f ff ff ff       	jmp    101ba9 <__alltraps>

00101c2a <vector11>:
.globl vector11
vector11:
  pushl $11
  101c2a:	6a 0b                	push   $0xb
  jmp __alltraps
  101c2c:	e9 78 ff ff ff       	jmp    101ba9 <__alltraps>

00101c31 <vector12>:
.globl vector12
vector12:
  pushl $12
  101c31:	6a 0c                	push   $0xc
  jmp __alltraps
  101c33:	e9 71 ff ff ff       	jmp    101ba9 <__alltraps>

00101c38 <vector13>:
.globl vector13
vector13:
  pushl $13
  101c38:	6a 0d                	push   $0xd
  jmp __alltraps
  101c3a:	e9 6a ff ff ff       	jmp    101ba9 <__alltraps>

00101c3f <vector14>:
.globl vector14
vector14:
  pushl $14
  101c3f:	6a 0e                	push   $0xe
  jmp __alltraps
  101c41:	e9 63 ff ff ff       	jmp    101ba9 <__alltraps>

00101c46 <vector15>:
.globl vector15
vector15:
  pushl $0
  101c46:	6a 00                	push   $0x0
  pushl $15
  101c48:	6a 0f                	push   $0xf
  jmp __alltraps
  101c4a:	e9 5a ff ff ff       	jmp    101ba9 <__alltraps>

00101c4f <vector16>:
.globl vector16
vector16:
  pushl $0
  101c4f:	6a 00                	push   $0x0
  pushl $16
  101c51:	6a 10                	push   $0x10
  jmp __alltraps
  101c53:	e9 51 ff ff ff       	jmp    101ba9 <__alltraps>

00101c58 <vector17>:
.globl vector17
vector17:
  pushl $17
  101c58:	6a 11                	push   $0x11
  jmp __alltraps
  101c5a:	e9 4a ff ff ff       	jmp    101ba9 <__alltraps>

00101c5f <vector18>:
.globl vector18
vector18:
  pushl $0
  101c5f:	6a 00                	push   $0x0
  pushl $18
  101c61:	6a 12                	push   $0x12
  jmp __alltraps
  101c63:	e9 41 ff ff ff       	jmp    101ba9 <__alltraps>

00101c68 <vector19>:
.globl vector19
vector19:
  pushl $0
  101c68:	6a 00                	push   $0x0
  pushl $19
  101c6a:	6a 13                	push   $0x13
  jmp __alltraps
  101c6c:	e9 38 ff ff ff       	jmp    101ba9 <__alltraps>

00101c71 <vector20>:
.globl vector20
vector20:
  pushl $0
  101c71:	6a 00                	push   $0x0
  pushl $20
  101c73:	6a 14                	push   $0x14
  jmp __alltraps
  101c75:	e9 2f ff ff ff       	jmp    101ba9 <__alltraps>

00101c7a <vector21>:
.globl vector21
vector21:
  pushl $0
  101c7a:	6a 00                	push   $0x0
  pushl $21
  101c7c:	6a 15                	push   $0x15
  jmp __alltraps
  101c7e:	e9 26 ff ff ff       	jmp    101ba9 <__alltraps>

00101c83 <vector22>:
.globl vector22
vector22:
  pushl $0
  101c83:	6a 00                	push   $0x0
  pushl $22
  101c85:	6a 16                	push   $0x16
  jmp __alltraps
  101c87:	e9 1d ff ff ff       	jmp    101ba9 <__alltraps>

00101c8c <vector23>:
.globl vector23
vector23:
  pushl $0
  101c8c:	6a 00                	push   $0x0
  pushl $23
  101c8e:	6a 17                	push   $0x17
  jmp __alltraps
  101c90:	e9 14 ff ff ff       	jmp    101ba9 <__alltraps>

00101c95 <vector24>:
.globl vector24
vector24:
  pushl $0
  101c95:	6a 00                	push   $0x0
  pushl $24
  101c97:	6a 18                	push   $0x18
  jmp __alltraps
  101c99:	e9 0b ff ff ff       	jmp    101ba9 <__alltraps>

00101c9e <vector25>:
.globl vector25
vector25:
  pushl $0
  101c9e:	6a 00                	push   $0x0
  pushl $25
  101ca0:	6a 19                	push   $0x19
  jmp __alltraps
  101ca2:	e9 02 ff ff ff       	jmp    101ba9 <__alltraps>

00101ca7 <vector26>:
.globl vector26
vector26:
  pushl $0
  101ca7:	6a 00                	push   $0x0
  pushl $26
  101ca9:	6a 1a                	push   $0x1a
  jmp __alltraps
  101cab:	e9 f9 fe ff ff       	jmp    101ba9 <__alltraps>

00101cb0 <vector27>:
.globl vector27
vector27:
  pushl $0
  101cb0:	6a 00                	push   $0x0
  pushl $27
  101cb2:	6a 1b                	push   $0x1b
  jmp __alltraps
  101cb4:	e9 f0 fe ff ff       	jmp    101ba9 <__alltraps>

00101cb9 <vector28>:
.globl vector28
vector28:
  pushl $0
  101cb9:	6a 00                	push   $0x0
  pushl $28
  101cbb:	6a 1c                	push   $0x1c
  jmp __alltraps
  101cbd:	e9 e7 fe ff ff       	jmp    101ba9 <__alltraps>

00101cc2 <vector29>:
.globl vector29
vector29:
  pushl $0
  101cc2:	6a 00                	push   $0x0
  pushl $29
  101cc4:	6a 1d                	push   $0x1d
  jmp __alltraps
  101cc6:	e9 de fe ff ff       	jmp    101ba9 <__alltraps>

00101ccb <vector30>:
.globl vector30
vector30:
  pushl $0
  101ccb:	6a 00                	push   $0x0
  pushl $30
  101ccd:	6a 1e                	push   $0x1e
  jmp __alltraps
  101ccf:	e9 d5 fe ff ff       	jmp    101ba9 <__alltraps>

00101cd4 <vector31>:
.globl vector31
vector31:
  pushl $0
  101cd4:	6a 00                	push   $0x0
  pushl $31
  101cd6:	6a 1f                	push   $0x1f
  jmp __alltraps
  101cd8:	e9 cc fe ff ff       	jmp    101ba9 <__alltraps>

00101cdd <vector32>:
.globl vector32
vector32:
  pushl $0
  101cdd:	6a 00                	push   $0x0
  pushl $32
  101cdf:	6a 20                	push   $0x20
  jmp __alltraps
  101ce1:	e9 c3 fe ff ff       	jmp    101ba9 <__alltraps>

00101ce6 <vector33>:
.globl vector33
vector33:
  pushl $0
  101ce6:	6a 00                	push   $0x0
  pushl $33
  101ce8:	6a 21                	push   $0x21
  jmp __alltraps
  101cea:	e9 ba fe ff ff       	jmp    101ba9 <__alltraps>

00101cef <vector34>:
.globl vector34
vector34:
  pushl $0
  101cef:	6a 00                	push   $0x0
  pushl $34
  101cf1:	6a 22                	push   $0x22
  jmp __alltraps
  101cf3:	e9 b1 fe ff ff       	jmp    101ba9 <__alltraps>

00101cf8 <vector35>:
.globl vector35
vector35:
  pushl $0
  101cf8:	6a 00                	push   $0x0
  pushl $35
  101cfa:	6a 23                	push   $0x23
  jmp __alltraps
  101cfc:	e9 a8 fe ff ff       	jmp    101ba9 <__alltraps>

00101d01 <vector36>:
.globl vector36
vector36:
  pushl $0
  101d01:	6a 00                	push   $0x0
  pushl $36
  101d03:	6a 24                	push   $0x24
  jmp __alltraps
  101d05:	e9 9f fe ff ff       	jmp    101ba9 <__alltraps>

00101d0a <vector37>:
.globl vector37
vector37:
  pushl $0
  101d0a:	6a 00                	push   $0x0
  pushl $37
  101d0c:	6a 25                	push   $0x25
  jmp __alltraps
  101d0e:	e9 96 fe ff ff       	jmp    101ba9 <__alltraps>

00101d13 <vector38>:
.globl vector38
vector38:
  pushl $0
  101d13:	6a 00                	push   $0x0
  pushl $38
  101d15:	6a 26                	push   $0x26
  jmp __alltraps
  101d17:	e9 8d fe ff ff       	jmp    101ba9 <__alltraps>

00101d1c <vector39>:
.globl vector39
vector39:
  pushl $0
  101d1c:	6a 00                	push   $0x0
  pushl $39
  101d1e:	6a 27                	push   $0x27
  jmp __alltraps
  101d20:	e9 84 fe ff ff       	jmp    101ba9 <__alltraps>

00101d25 <vector40>:
.globl vector40
vector40:
  pushl $0
  101d25:	6a 00                	push   $0x0
  pushl $40
  101d27:	6a 28                	push   $0x28
  jmp __alltraps
  101d29:	e9 7b fe ff ff       	jmp    101ba9 <__alltraps>

00101d2e <vector41>:
.globl vector41
vector41:
  pushl $0
  101d2e:	6a 00                	push   $0x0
  pushl $41
  101d30:	6a 29                	push   $0x29
  jmp __alltraps
  101d32:	e9 72 fe ff ff       	jmp    101ba9 <__alltraps>

00101d37 <vector42>:
.globl vector42
vector42:
  pushl $0
  101d37:	6a 00                	push   $0x0
  pushl $42
  101d39:	6a 2a                	push   $0x2a
  jmp __alltraps
  101d3b:	e9 69 fe ff ff       	jmp    101ba9 <__alltraps>

00101d40 <vector43>:
.globl vector43
vector43:
  pushl $0
  101d40:	6a 00                	push   $0x0
  pushl $43
  101d42:	6a 2b                	push   $0x2b
  jmp __alltraps
  101d44:	e9 60 fe ff ff       	jmp    101ba9 <__alltraps>

00101d49 <vector44>:
.globl vector44
vector44:
  pushl $0
  101d49:	6a 00                	push   $0x0
  pushl $44
  101d4b:	6a 2c                	push   $0x2c
  jmp __alltraps
  101d4d:	e9 57 fe ff ff       	jmp    101ba9 <__alltraps>

00101d52 <vector45>:
.globl vector45
vector45:
  pushl $0
  101d52:	6a 00                	push   $0x0
  pushl $45
  101d54:	6a 2d                	push   $0x2d
  jmp __alltraps
  101d56:	e9 4e fe ff ff       	jmp    101ba9 <__alltraps>

00101d5b <vector46>:
.globl vector46
vector46:
  pushl $0
  101d5b:	6a 00                	push   $0x0
  pushl $46
  101d5d:	6a 2e                	push   $0x2e
  jmp __alltraps
  101d5f:	e9 45 fe ff ff       	jmp    101ba9 <__alltraps>

00101d64 <vector47>:
.globl vector47
vector47:
  pushl $0
  101d64:	6a 00                	push   $0x0
  pushl $47
  101d66:	6a 2f                	push   $0x2f
  jmp __alltraps
  101d68:	e9 3c fe ff ff       	jmp    101ba9 <__alltraps>

00101d6d <vector48>:
.globl vector48
vector48:
  pushl $0
  101d6d:	6a 00                	push   $0x0
  pushl $48
  101d6f:	6a 30                	push   $0x30
  jmp __alltraps
  101d71:	e9 33 fe ff ff       	jmp    101ba9 <__alltraps>

00101d76 <vector49>:
.globl vector49
vector49:
  pushl $0
  101d76:	6a 00                	push   $0x0
  pushl $49
  101d78:	6a 31                	push   $0x31
  jmp __alltraps
  101d7a:	e9 2a fe ff ff       	jmp    101ba9 <__alltraps>

00101d7f <vector50>:
.globl vector50
vector50:
  pushl $0
  101d7f:	6a 00                	push   $0x0
  pushl $50
  101d81:	6a 32                	push   $0x32
  jmp __alltraps
  101d83:	e9 21 fe ff ff       	jmp    101ba9 <__alltraps>

00101d88 <vector51>:
.globl vector51
vector51:
  pushl $0
  101d88:	6a 00                	push   $0x0
  pushl $51
  101d8a:	6a 33                	push   $0x33
  jmp __alltraps
  101d8c:	e9 18 fe ff ff       	jmp    101ba9 <__alltraps>

00101d91 <vector52>:
.globl vector52
vector52:
  pushl $0
  101d91:	6a 00                	push   $0x0
  pushl $52
  101d93:	6a 34                	push   $0x34
  jmp __alltraps
  101d95:	e9 0f fe ff ff       	jmp    101ba9 <__alltraps>

00101d9a <vector53>:
.globl vector53
vector53:
  pushl $0
  101d9a:	6a 00                	push   $0x0
  pushl $53
  101d9c:	6a 35                	push   $0x35
  jmp __alltraps
  101d9e:	e9 06 fe ff ff       	jmp    101ba9 <__alltraps>

00101da3 <vector54>:
.globl vector54
vector54:
  pushl $0
  101da3:	6a 00                	push   $0x0
  pushl $54
  101da5:	6a 36                	push   $0x36
  jmp __alltraps
  101da7:	e9 fd fd ff ff       	jmp    101ba9 <__alltraps>

00101dac <vector55>:
.globl vector55
vector55:
  pushl $0
  101dac:	6a 00                	push   $0x0
  pushl $55
  101dae:	6a 37                	push   $0x37
  jmp __alltraps
  101db0:	e9 f4 fd ff ff       	jmp    101ba9 <__alltraps>

00101db5 <vector56>:
.globl vector56
vector56:
  pushl $0
  101db5:	6a 00                	push   $0x0
  pushl $56
  101db7:	6a 38                	push   $0x38
  jmp __alltraps
  101db9:	e9 eb fd ff ff       	jmp    101ba9 <__alltraps>

00101dbe <vector57>:
.globl vector57
vector57:
  pushl $0
  101dbe:	6a 00                	push   $0x0
  pushl $57
  101dc0:	6a 39                	push   $0x39
  jmp __alltraps
  101dc2:	e9 e2 fd ff ff       	jmp    101ba9 <__alltraps>

00101dc7 <vector58>:
.globl vector58
vector58:
  pushl $0
  101dc7:	6a 00                	push   $0x0
  pushl $58
  101dc9:	6a 3a                	push   $0x3a
  jmp __alltraps
  101dcb:	e9 d9 fd ff ff       	jmp    101ba9 <__alltraps>

00101dd0 <vector59>:
.globl vector59
vector59:
  pushl $0
  101dd0:	6a 00                	push   $0x0
  pushl $59
  101dd2:	6a 3b                	push   $0x3b
  jmp __alltraps
  101dd4:	e9 d0 fd ff ff       	jmp    101ba9 <__alltraps>

00101dd9 <vector60>:
.globl vector60
vector60:
  pushl $0
  101dd9:	6a 00                	push   $0x0
  pushl $60
  101ddb:	6a 3c                	push   $0x3c
  jmp __alltraps
  101ddd:	e9 c7 fd ff ff       	jmp    101ba9 <__alltraps>

00101de2 <vector61>:
.globl vector61
vector61:
  pushl $0
  101de2:	6a 00                	push   $0x0
  pushl $61
  101de4:	6a 3d                	push   $0x3d
  jmp __alltraps
  101de6:	e9 be fd ff ff       	jmp    101ba9 <__alltraps>

00101deb <vector62>:
.globl vector62
vector62:
  pushl $0
  101deb:	6a 00                	push   $0x0
  pushl $62
  101ded:	6a 3e                	push   $0x3e
  jmp __alltraps
  101def:	e9 b5 fd ff ff       	jmp    101ba9 <__alltraps>

00101df4 <vector63>:
.globl vector63
vector63:
  pushl $0
  101df4:	6a 00                	push   $0x0
  pushl $63
  101df6:	6a 3f                	push   $0x3f
  jmp __alltraps
  101df8:	e9 ac fd ff ff       	jmp    101ba9 <__alltraps>

00101dfd <vector64>:
.globl vector64
vector64:
  pushl $0
  101dfd:	6a 00                	push   $0x0
  pushl $64
  101dff:	6a 40                	push   $0x40
  jmp __alltraps
  101e01:	e9 a3 fd ff ff       	jmp    101ba9 <__alltraps>

00101e06 <vector65>:
.globl vector65
vector65:
  pushl $0
  101e06:	6a 00                	push   $0x0
  pushl $65
  101e08:	6a 41                	push   $0x41
  jmp __alltraps
  101e0a:	e9 9a fd ff ff       	jmp    101ba9 <__alltraps>

00101e0f <vector66>:
.globl vector66
vector66:
  pushl $0
  101e0f:	6a 00                	push   $0x0
  pushl $66
  101e11:	6a 42                	push   $0x42
  jmp __alltraps
  101e13:	e9 91 fd ff ff       	jmp    101ba9 <__alltraps>

00101e18 <vector67>:
.globl vector67
vector67:
  pushl $0
  101e18:	6a 00                	push   $0x0
  pushl $67
  101e1a:	6a 43                	push   $0x43
  jmp __alltraps
  101e1c:	e9 88 fd ff ff       	jmp    101ba9 <__alltraps>

00101e21 <vector68>:
.globl vector68
vector68:
  pushl $0
  101e21:	6a 00                	push   $0x0
  pushl $68
  101e23:	6a 44                	push   $0x44
  jmp __alltraps
  101e25:	e9 7f fd ff ff       	jmp    101ba9 <__alltraps>

00101e2a <vector69>:
.globl vector69
vector69:
  pushl $0
  101e2a:	6a 00                	push   $0x0
  pushl $69
  101e2c:	6a 45                	push   $0x45
  jmp __alltraps
  101e2e:	e9 76 fd ff ff       	jmp    101ba9 <__alltraps>

00101e33 <vector70>:
.globl vector70
vector70:
  pushl $0
  101e33:	6a 00                	push   $0x0
  pushl $70
  101e35:	6a 46                	push   $0x46
  jmp __alltraps
  101e37:	e9 6d fd ff ff       	jmp    101ba9 <__alltraps>

00101e3c <vector71>:
.globl vector71
vector71:
  pushl $0
  101e3c:	6a 00                	push   $0x0
  pushl $71
  101e3e:	6a 47                	push   $0x47
  jmp __alltraps
  101e40:	e9 64 fd ff ff       	jmp    101ba9 <__alltraps>

00101e45 <vector72>:
.globl vector72
vector72:
  pushl $0
  101e45:	6a 00                	push   $0x0
  pushl $72
  101e47:	6a 48                	push   $0x48
  jmp __alltraps
  101e49:	e9 5b fd ff ff       	jmp    101ba9 <__alltraps>

00101e4e <vector73>:
.globl vector73
vector73:
  pushl $0
  101e4e:	6a 00                	push   $0x0
  pushl $73
  101e50:	6a 49                	push   $0x49
  jmp __alltraps
  101e52:	e9 52 fd ff ff       	jmp    101ba9 <__alltraps>

00101e57 <vector74>:
.globl vector74
vector74:
  pushl $0
  101e57:	6a 00                	push   $0x0
  pushl $74
  101e59:	6a 4a                	push   $0x4a
  jmp __alltraps
  101e5b:	e9 49 fd ff ff       	jmp    101ba9 <__alltraps>

00101e60 <vector75>:
.globl vector75
vector75:
  pushl $0
  101e60:	6a 00                	push   $0x0
  pushl $75
  101e62:	6a 4b                	push   $0x4b
  jmp __alltraps
  101e64:	e9 40 fd ff ff       	jmp    101ba9 <__alltraps>

00101e69 <vector76>:
.globl vector76
vector76:
  pushl $0
  101e69:	6a 00                	push   $0x0
  pushl $76
  101e6b:	6a 4c                	push   $0x4c
  jmp __alltraps
  101e6d:	e9 37 fd ff ff       	jmp    101ba9 <__alltraps>

00101e72 <vector77>:
.globl vector77
vector77:
  pushl $0
  101e72:	6a 00                	push   $0x0
  pushl $77
  101e74:	6a 4d                	push   $0x4d
  jmp __alltraps
  101e76:	e9 2e fd ff ff       	jmp    101ba9 <__alltraps>

00101e7b <vector78>:
.globl vector78
vector78:
  pushl $0
  101e7b:	6a 00                	push   $0x0
  pushl $78
  101e7d:	6a 4e                	push   $0x4e
  jmp __alltraps
  101e7f:	e9 25 fd ff ff       	jmp    101ba9 <__alltraps>

00101e84 <vector79>:
.globl vector79
vector79:
  pushl $0
  101e84:	6a 00                	push   $0x0
  pushl $79
  101e86:	6a 4f                	push   $0x4f
  jmp __alltraps
  101e88:	e9 1c fd ff ff       	jmp    101ba9 <__alltraps>

00101e8d <vector80>:
.globl vector80
vector80:
  pushl $0
  101e8d:	6a 00                	push   $0x0
  pushl $80
  101e8f:	6a 50                	push   $0x50
  jmp __alltraps
  101e91:	e9 13 fd ff ff       	jmp    101ba9 <__alltraps>

00101e96 <vector81>:
.globl vector81
vector81:
  pushl $0
  101e96:	6a 00                	push   $0x0
  pushl $81
  101e98:	6a 51                	push   $0x51
  jmp __alltraps
  101e9a:	e9 0a fd ff ff       	jmp    101ba9 <__alltraps>

00101e9f <vector82>:
.globl vector82
vector82:
  pushl $0
  101e9f:	6a 00                	push   $0x0
  pushl $82
  101ea1:	6a 52                	push   $0x52
  jmp __alltraps
  101ea3:	e9 01 fd ff ff       	jmp    101ba9 <__alltraps>

00101ea8 <vector83>:
.globl vector83
vector83:
  pushl $0
  101ea8:	6a 00                	push   $0x0
  pushl $83
  101eaa:	6a 53                	push   $0x53
  jmp __alltraps
  101eac:	e9 f8 fc ff ff       	jmp    101ba9 <__alltraps>

00101eb1 <vector84>:
.globl vector84
vector84:
  pushl $0
  101eb1:	6a 00                	push   $0x0
  pushl $84
  101eb3:	6a 54                	push   $0x54
  jmp __alltraps
  101eb5:	e9 ef fc ff ff       	jmp    101ba9 <__alltraps>

00101eba <vector85>:
.globl vector85
vector85:
  pushl $0
  101eba:	6a 00                	push   $0x0
  pushl $85
  101ebc:	6a 55                	push   $0x55
  jmp __alltraps
  101ebe:	e9 e6 fc ff ff       	jmp    101ba9 <__alltraps>

00101ec3 <vector86>:
.globl vector86
vector86:
  pushl $0
  101ec3:	6a 00                	push   $0x0
  pushl $86
  101ec5:	6a 56                	push   $0x56
  jmp __alltraps
  101ec7:	e9 dd fc ff ff       	jmp    101ba9 <__alltraps>

00101ecc <vector87>:
.globl vector87
vector87:
  pushl $0
  101ecc:	6a 00                	push   $0x0
  pushl $87
  101ece:	6a 57                	push   $0x57
  jmp __alltraps
  101ed0:	e9 d4 fc ff ff       	jmp    101ba9 <__alltraps>

00101ed5 <vector88>:
.globl vector88
vector88:
  pushl $0
  101ed5:	6a 00                	push   $0x0
  pushl $88
  101ed7:	6a 58                	push   $0x58
  jmp __alltraps
  101ed9:	e9 cb fc ff ff       	jmp    101ba9 <__alltraps>

00101ede <vector89>:
.globl vector89
vector89:
  pushl $0
  101ede:	6a 00                	push   $0x0
  pushl $89
  101ee0:	6a 59                	push   $0x59
  jmp __alltraps
  101ee2:	e9 c2 fc ff ff       	jmp    101ba9 <__alltraps>

00101ee7 <vector90>:
.globl vector90
vector90:
  pushl $0
  101ee7:	6a 00                	push   $0x0
  pushl $90
  101ee9:	6a 5a                	push   $0x5a
  jmp __alltraps
  101eeb:	e9 b9 fc ff ff       	jmp    101ba9 <__alltraps>

00101ef0 <vector91>:
.globl vector91
vector91:
  pushl $0
  101ef0:	6a 00                	push   $0x0
  pushl $91
  101ef2:	6a 5b                	push   $0x5b
  jmp __alltraps
  101ef4:	e9 b0 fc ff ff       	jmp    101ba9 <__alltraps>

00101ef9 <vector92>:
.globl vector92
vector92:
  pushl $0
  101ef9:	6a 00                	push   $0x0
  pushl $92
  101efb:	6a 5c                	push   $0x5c
  jmp __alltraps
  101efd:	e9 a7 fc ff ff       	jmp    101ba9 <__alltraps>

00101f02 <vector93>:
.globl vector93
vector93:
  pushl $0
  101f02:	6a 00                	push   $0x0
  pushl $93
  101f04:	6a 5d                	push   $0x5d
  jmp __alltraps
  101f06:	e9 9e fc ff ff       	jmp    101ba9 <__alltraps>

00101f0b <vector94>:
.globl vector94
vector94:
  pushl $0
  101f0b:	6a 00                	push   $0x0
  pushl $94
  101f0d:	6a 5e                	push   $0x5e
  jmp __alltraps
  101f0f:	e9 95 fc ff ff       	jmp    101ba9 <__alltraps>

00101f14 <vector95>:
.globl vector95
vector95:
  pushl $0
  101f14:	6a 00                	push   $0x0
  pushl $95
  101f16:	6a 5f                	push   $0x5f
  jmp __alltraps
  101f18:	e9 8c fc ff ff       	jmp    101ba9 <__alltraps>

00101f1d <vector96>:
.globl vector96
vector96:
  pushl $0
  101f1d:	6a 00                	push   $0x0
  pushl $96
  101f1f:	6a 60                	push   $0x60
  jmp __alltraps
  101f21:	e9 83 fc ff ff       	jmp    101ba9 <__alltraps>

00101f26 <vector97>:
.globl vector97
vector97:
  pushl $0
  101f26:	6a 00                	push   $0x0
  pushl $97
  101f28:	6a 61                	push   $0x61
  jmp __alltraps
  101f2a:	e9 7a fc ff ff       	jmp    101ba9 <__alltraps>

00101f2f <vector98>:
.globl vector98
vector98:
  pushl $0
  101f2f:	6a 00                	push   $0x0
  pushl $98
  101f31:	6a 62                	push   $0x62
  jmp __alltraps
  101f33:	e9 71 fc ff ff       	jmp    101ba9 <__alltraps>

00101f38 <vector99>:
.globl vector99
vector99:
  pushl $0
  101f38:	6a 00                	push   $0x0
  pushl $99
  101f3a:	6a 63                	push   $0x63
  jmp __alltraps
  101f3c:	e9 68 fc ff ff       	jmp    101ba9 <__alltraps>

00101f41 <vector100>:
.globl vector100
vector100:
  pushl $0
  101f41:	6a 00                	push   $0x0
  pushl $100
  101f43:	6a 64                	push   $0x64
  jmp __alltraps
  101f45:	e9 5f fc ff ff       	jmp    101ba9 <__alltraps>

00101f4a <vector101>:
.globl vector101
vector101:
  pushl $0
  101f4a:	6a 00                	push   $0x0
  pushl $101
  101f4c:	6a 65                	push   $0x65
  jmp __alltraps
  101f4e:	e9 56 fc ff ff       	jmp    101ba9 <__alltraps>

00101f53 <vector102>:
.globl vector102
vector102:
  pushl $0
  101f53:	6a 00                	push   $0x0
  pushl $102
  101f55:	6a 66                	push   $0x66
  jmp __alltraps
  101f57:	e9 4d fc ff ff       	jmp    101ba9 <__alltraps>

00101f5c <vector103>:
.globl vector103
vector103:
  pushl $0
  101f5c:	6a 00                	push   $0x0
  pushl $103
  101f5e:	6a 67                	push   $0x67
  jmp __alltraps
  101f60:	e9 44 fc ff ff       	jmp    101ba9 <__alltraps>

00101f65 <vector104>:
.globl vector104
vector104:
  pushl $0
  101f65:	6a 00                	push   $0x0
  pushl $104
  101f67:	6a 68                	push   $0x68
  jmp __alltraps
  101f69:	e9 3b fc ff ff       	jmp    101ba9 <__alltraps>

00101f6e <vector105>:
.globl vector105
vector105:
  pushl $0
  101f6e:	6a 00                	push   $0x0
  pushl $105
  101f70:	6a 69                	push   $0x69
  jmp __alltraps
  101f72:	e9 32 fc ff ff       	jmp    101ba9 <__alltraps>

00101f77 <vector106>:
.globl vector106
vector106:
  pushl $0
  101f77:	6a 00                	push   $0x0
  pushl $106
  101f79:	6a 6a                	push   $0x6a
  jmp __alltraps
  101f7b:	e9 29 fc ff ff       	jmp    101ba9 <__alltraps>

00101f80 <vector107>:
.globl vector107
vector107:
  pushl $0
  101f80:	6a 00                	push   $0x0
  pushl $107
  101f82:	6a 6b                	push   $0x6b
  jmp __alltraps
  101f84:	e9 20 fc ff ff       	jmp    101ba9 <__alltraps>

00101f89 <vector108>:
.globl vector108
vector108:
  pushl $0
  101f89:	6a 00                	push   $0x0
  pushl $108
  101f8b:	6a 6c                	push   $0x6c
  jmp __alltraps
  101f8d:	e9 17 fc ff ff       	jmp    101ba9 <__alltraps>

00101f92 <vector109>:
.globl vector109
vector109:
  pushl $0
  101f92:	6a 00                	push   $0x0
  pushl $109
  101f94:	6a 6d                	push   $0x6d
  jmp __alltraps
  101f96:	e9 0e fc ff ff       	jmp    101ba9 <__alltraps>

00101f9b <vector110>:
.globl vector110
vector110:
  pushl $0
  101f9b:	6a 00                	push   $0x0
  pushl $110
  101f9d:	6a 6e                	push   $0x6e
  jmp __alltraps
  101f9f:	e9 05 fc ff ff       	jmp    101ba9 <__alltraps>

00101fa4 <vector111>:
.globl vector111
vector111:
  pushl $0
  101fa4:	6a 00                	push   $0x0
  pushl $111
  101fa6:	6a 6f                	push   $0x6f
  jmp __alltraps
  101fa8:	e9 fc fb ff ff       	jmp    101ba9 <__alltraps>

00101fad <vector112>:
.globl vector112
vector112:
  pushl $0
  101fad:	6a 00                	push   $0x0
  pushl $112
  101faf:	6a 70                	push   $0x70
  jmp __alltraps
  101fb1:	e9 f3 fb ff ff       	jmp    101ba9 <__alltraps>

00101fb6 <vector113>:
.globl vector113
vector113:
  pushl $0
  101fb6:	6a 00                	push   $0x0
  pushl $113
  101fb8:	6a 71                	push   $0x71
  jmp __alltraps
  101fba:	e9 ea fb ff ff       	jmp    101ba9 <__alltraps>

00101fbf <vector114>:
.globl vector114
vector114:
  pushl $0
  101fbf:	6a 00                	push   $0x0
  pushl $114
  101fc1:	6a 72                	push   $0x72
  jmp __alltraps
  101fc3:	e9 e1 fb ff ff       	jmp    101ba9 <__alltraps>

00101fc8 <vector115>:
.globl vector115
vector115:
  pushl $0
  101fc8:	6a 00                	push   $0x0
  pushl $115
  101fca:	6a 73                	push   $0x73
  jmp __alltraps
  101fcc:	e9 d8 fb ff ff       	jmp    101ba9 <__alltraps>

00101fd1 <vector116>:
.globl vector116
vector116:
  pushl $0
  101fd1:	6a 00                	push   $0x0
  pushl $116
  101fd3:	6a 74                	push   $0x74
  jmp __alltraps
  101fd5:	e9 cf fb ff ff       	jmp    101ba9 <__alltraps>

00101fda <vector117>:
.globl vector117
vector117:
  pushl $0
  101fda:	6a 00                	push   $0x0
  pushl $117
  101fdc:	6a 75                	push   $0x75
  jmp __alltraps
  101fde:	e9 c6 fb ff ff       	jmp    101ba9 <__alltraps>

00101fe3 <vector118>:
.globl vector118
vector118:
  pushl $0
  101fe3:	6a 00                	push   $0x0
  pushl $118
  101fe5:	6a 76                	push   $0x76
  jmp __alltraps
  101fe7:	e9 bd fb ff ff       	jmp    101ba9 <__alltraps>

00101fec <vector119>:
.globl vector119
vector119:
  pushl $0
  101fec:	6a 00                	push   $0x0
  pushl $119
  101fee:	6a 77                	push   $0x77
  jmp __alltraps
  101ff0:	e9 b4 fb ff ff       	jmp    101ba9 <__alltraps>

00101ff5 <vector120>:
.globl vector120
vector120:
  pushl $0
  101ff5:	6a 00                	push   $0x0
  pushl $120
  101ff7:	6a 78                	push   $0x78
  jmp __alltraps
  101ff9:	e9 ab fb ff ff       	jmp    101ba9 <__alltraps>

00101ffe <vector121>:
.globl vector121
vector121:
  pushl $0
  101ffe:	6a 00                	push   $0x0
  pushl $121
  102000:	6a 79                	push   $0x79
  jmp __alltraps
  102002:	e9 a2 fb ff ff       	jmp    101ba9 <__alltraps>

00102007 <vector122>:
.globl vector122
vector122:
  pushl $0
  102007:	6a 00                	push   $0x0
  pushl $122
  102009:	6a 7a                	push   $0x7a
  jmp __alltraps
  10200b:	e9 99 fb ff ff       	jmp    101ba9 <__alltraps>

00102010 <vector123>:
.globl vector123
vector123:
  pushl $0
  102010:	6a 00                	push   $0x0
  pushl $123
  102012:	6a 7b                	push   $0x7b
  jmp __alltraps
  102014:	e9 90 fb ff ff       	jmp    101ba9 <__alltraps>

00102019 <vector124>:
.globl vector124
vector124:
  pushl $0
  102019:	6a 00                	push   $0x0
  pushl $124
  10201b:	6a 7c                	push   $0x7c
  jmp __alltraps
  10201d:	e9 87 fb ff ff       	jmp    101ba9 <__alltraps>

00102022 <vector125>:
.globl vector125
vector125:
  pushl $0
  102022:	6a 00                	push   $0x0
  pushl $125
  102024:	6a 7d                	push   $0x7d
  jmp __alltraps
  102026:	e9 7e fb ff ff       	jmp    101ba9 <__alltraps>

0010202b <vector126>:
.globl vector126
vector126:
  pushl $0
  10202b:	6a 00                	push   $0x0
  pushl $126
  10202d:	6a 7e                	push   $0x7e
  jmp __alltraps
  10202f:	e9 75 fb ff ff       	jmp    101ba9 <__alltraps>

00102034 <vector127>:
.globl vector127
vector127:
  pushl $0
  102034:	6a 00                	push   $0x0
  pushl $127
  102036:	6a 7f                	push   $0x7f
  jmp __alltraps
  102038:	e9 6c fb ff ff       	jmp    101ba9 <__alltraps>

0010203d <vector128>:
.globl vector128
vector128:
  pushl $0
  10203d:	6a 00                	push   $0x0
  pushl $128
  10203f:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  102044:	e9 60 fb ff ff       	jmp    101ba9 <__alltraps>

00102049 <vector129>:
.globl vector129
vector129:
  pushl $0
  102049:	6a 00                	push   $0x0
  pushl $129
  10204b:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  102050:	e9 54 fb ff ff       	jmp    101ba9 <__alltraps>

00102055 <vector130>:
.globl vector130
vector130:
  pushl $0
  102055:	6a 00                	push   $0x0
  pushl $130
  102057:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  10205c:	e9 48 fb ff ff       	jmp    101ba9 <__alltraps>

00102061 <vector131>:
.globl vector131
vector131:
  pushl $0
  102061:	6a 00                	push   $0x0
  pushl $131
  102063:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  102068:	e9 3c fb ff ff       	jmp    101ba9 <__alltraps>

0010206d <vector132>:
.globl vector132
vector132:
  pushl $0
  10206d:	6a 00                	push   $0x0
  pushl $132
  10206f:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  102074:	e9 30 fb ff ff       	jmp    101ba9 <__alltraps>

00102079 <vector133>:
.globl vector133
vector133:
  pushl $0
  102079:	6a 00                	push   $0x0
  pushl $133
  10207b:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  102080:	e9 24 fb ff ff       	jmp    101ba9 <__alltraps>

00102085 <vector134>:
.globl vector134
vector134:
  pushl $0
  102085:	6a 00                	push   $0x0
  pushl $134
  102087:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  10208c:	e9 18 fb ff ff       	jmp    101ba9 <__alltraps>

00102091 <vector135>:
.globl vector135
vector135:
  pushl $0
  102091:	6a 00                	push   $0x0
  pushl $135
  102093:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  102098:	e9 0c fb ff ff       	jmp    101ba9 <__alltraps>

0010209d <vector136>:
.globl vector136
vector136:
  pushl $0
  10209d:	6a 00                	push   $0x0
  pushl $136
  10209f:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  1020a4:	e9 00 fb ff ff       	jmp    101ba9 <__alltraps>

001020a9 <vector137>:
.globl vector137
vector137:
  pushl $0
  1020a9:	6a 00                	push   $0x0
  pushl $137
  1020ab:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  1020b0:	e9 f4 fa ff ff       	jmp    101ba9 <__alltraps>

001020b5 <vector138>:
.globl vector138
vector138:
  pushl $0
  1020b5:	6a 00                	push   $0x0
  pushl $138
  1020b7:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  1020bc:	e9 e8 fa ff ff       	jmp    101ba9 <__alltraps>

001020c1 <vector139>:
.globl vector139
vector139:
  pushl $0
  1020c1:	6a 00                	push   $0x0
  pushl $139
  1020c3:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  1020c8:	e9 dc fa ff ff       	jmp    101ba9 <__alltraps>

001020cd <vector140>:
.globl vector140
vector140:
  pushl $0
  1020cd:	6a 00                	push   $0x0
  pushl $140
  1020cf:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  1020d4:	e9 d0 fa ff ff       	jmp    101ba9 <__alltraps>

001020d9 <vector141>:
.globl vector141
vector141:
  pushl $0
  1020d9:	6a 00                	push   $0x0
  pushl $141
  1020db:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  1020e0:	e9 c4 fa ff ff       	jmp    101ba9 <__alltraps>

001020e5 <vector142>:
.globl vector142
vector142:
  pushl $0
  1020e5:	6a 00                	push   $0x0
  pushl $142
  1020e7:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  1020ec:	e9 b8 fa ff ff       	jmp    101ba9 <__alltraps>

001020f1 <vector143>:
.globl vector143
vector143:
  pushl $0
  1020f1:	6a 00                	push   $0x0
  pushl $143
  1020f3:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  1020f8:	e9 ac fa ff ff       	jmp    101ba9 <__alltraps>

001020fd <vector144>:
.globl vector144
vector144:
  pushl $0
  1020fd:	6a 00                	push   $0x0
  pushl $144
  1020ff:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  102104:	e9 a0 fa ff ff       	jmp    101ba9 <__alltraps>

00102109 <vector145>:
.globl vector145
vector145:
  pushl $0
  102109:	6a 00                	push   $0x0
  pushl $145
  10210b:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  102110:	e9 94 fa ff ff       	jmp    101ba9 <__alltraps>

00102115 <vector146>:
.globl vector146
vector146:
  pushl $0
  102115:	6a 00                	push   $0x0
  pushl $146
  102117:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  10211c:	e9 88 fa ff ff       	jmp    101ba9 <__alltraps>

00102121 <vector147>:
.globl vector147
vector147:
  pushl $0
  102121:	6a 00                	push   $0x0
  pushl $147
  102123:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  102128:	e9 7c fa ff ff       	jmp    101ba9 <__alltraps>

0010212d <vector148>:
.globl vector148
vector148:
  pushl $0
  10212d:	6a 00                	push   $0x0
  pushl $148
  10212f:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  102134:	e9 70 fa ff ff       	jmp    101ba9 <__alltraps>

00102139 <vector149>:
.globl vector149
vector149:
  pushl $0
  102139:	6a 00                	push   $0x0
  pushl $149
  10213b:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  102140:	e9 64 fa ff ff       	jmp    101ba9 <__alltraps>

00102145 <vector150>:
.globl vector150
vector150:
  pushl $0
  102145:	6a 00                	push   $0x0
  pushl $150
  102147:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  10214c:	e9 58 fa ff ff       	jmp    101ba9 <__alltraps>

00102151 <vector151>:
.globl vector151
vector151:
  pushl $0
  102151:	6a 00                	push   $0x0
  pushl $151
  102153:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  102158:	e9 4c fa ff ff       	jmp    101ba9 <__alltraps>

0010215d <vector152>:
.globl vector152
vector152:
  pushl $0
  10215d:	6a 00                	push   $0x0
  pushl $152
  10215f:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  102164:	e9 40 fa ff ff       	jmp    101ba9 <__alltraps>

00102169 <vector153>:
.globl vector153
vector153:
  pushl $0
  102169:	6a 00                	push   $0x0
  pushl $153
  10216b:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  102170:	e9 34 fa ff ff       	jmp    101ba9 <__alltraps>

00102175 <vector154>:
.globl vector154
vector154:
  pushl $0
  102175:	6a 00                	push   $0x0
  pushl $154
  102177:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  10217c:	e9 28 fa ff ff       	jmp    101ba9 <__alltraps>

00102181 <vector155>:
.globl vector155
vector155:
  pushl $0
  102181:	6a 00                	push   $0x0
  pushl $155
  102183:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  102188:	e9 1c fa ff ff       	jmp    101ba9 <__alltraps>

0010218d <vector156>:
.globl vector156
vector156:
  pushl $0
  10218d:	6a 00                	push   $0x0
  pushl $156
  10218f:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  102194:	e9 10 fa ff ff       	jmp    101ba9 <__alltraps>

00102199 <vector157>:
.globl vector157
vector157:
  pushl $0
  102199:	6a 00                	push   $0x0
  pushl $157
  10219b:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  1021a0:	e9 04 fa ff ff       	jmp    101ba9 <__alltraps>

001021a5 <vector158>:
.globl vector158
vector158:
  pushl $0
  1021a5:	6a 00                	push   $0x0
  pushl $158
  1021a7:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  1021ac:	e9 f8 f9 ff ff       	jmp    101ba9 <__alltraps>

001021b1 <vector159>:
.globl vector159
vector159:
  pushl $0
  1021b1:	6a 00                	push   $0x0
  pushl $159
  1021b3:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  1021b8:	e9 ec f9 ff ff       	jmp    101ba9 <__alltraps>

001021bd <vector160>:
.globl vector160
vector160:
  pushl $0
  1021bd:	6a 00                	push   $0x0
  pushl $160
  1021bf:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  1021c4:	e9 e0 f9 ff ff       	jmp    101ba9 <__alltraps>

001021c9 <vector161>:
.globl vector161
vector161:
  pushl $0
  1021c9:	6a 00                	push   $0x0
  pushl $161
  1021cb:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  1021d0:	e9 d4 f9 ff ff       	jmp    101ba9 <__alltraps>

001021d5 <vector162>:
.globl vector162
vector162:
  pushl $0
  1021d5:	6a 00                	push   $0x0
  pushl $162
  1021d7:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  1021dc:	e9 c8 f9 ff ff       	jmp    101ba9 <__alltraps>

001021e1 <vector163>:
.globl vector163
vector163:
  pushl $0
  1021e1:	6a 00                	push   $0x0
  pushl $163
  1021e3:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  1021e8:	e9 bc f9 ff ff       	jmp    101ba9 <__alltraps>

001021ed <vector164>:
.globl vector164
vector164:
  pushl $0
  1021ed:	6a 00                	push   $0x0
  pushl $164
  1021ef:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  1021f4:	e9 b0 f9 ff ff       	jmp    101ba9 <__alltraps>

001021f9 <vector165>:
.globl vector165
vector165:
  pushl $0
  1021f9:	6a 00                	push   $0x0
  pushl $165
  1021fb:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  102200:	e9 a4 f9 ff ff       	jmp    101ba9 <__alltraps>

00102205 <vector166>:
.globl vector166
vector166:
  pushl $0
  102205:	6a 00                	push   $0x0
  pushl $166
  102207:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  10220c:	e9 98 f9 ff ff       	jmp    101ba9 <__alltraps>

00102211 <vector167>:
.globl vector167
vector167:
  pushl $0
  102211:	6a 00                	push   $0x0
  pushl $167
  102213:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  102218:	e9 8c f9 ff ff       	jmp    101ba9 <__alltraps>

0010221d <vector168>:
.globl vector168
vector168:
  pushl $0
  10221d:	6a 00                	push   $0x0
  pushl $168
  10221f:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  102224:	e9 80 f9 ff ff       	jmp    101ba9 <__alltraps>

00102229 <vector169>:
.globl vector169
vector169:
  pushl $0
  102229:	6a 00                	push   $0x0
  pushl $169
  10222b:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  102230:	e9 74 f9 ff ff       	jmp    101ba9 <__alltraps>

00102235 <vector170>:
.globl vector170
vector170:
  pushl $0
  102235:	6a 00                	push   $0x0
  pushl $170
  102237:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  10223c:	e9 68 f9 ff ff       	jmp    101ba9 <__alltraps>

00102241 <vector171>:
.globl vector171
vector171:
  pushl $0
  102241:	6a 00                	push   $0x0
  pushl $171
  102243:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  102248:	e9 5c f9 ff ff       	jmp    101ba9 <__alltraps>

0010224d <vector172>:
.globl vector172
vector172:
  pushl $0
  10224d:	6a 00                	push   $0x0
  pushl $172
  10224f:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  102254:	e9 50 f9 ff ff       	jmp    101ba9 <__alltraps>

00102259 <vector173>:
.globl vector173
vector173:
  pushl $0
  102259:	6a 00                	push   $0x0
  pushl $173
  10225b:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  102260:	e9 44 f9 ff ff       	jmp    101ba9 <__alltraps>

00102265 <vector174>:
.globl vector174
vector174:
  pushl $0
  102265:	6a 00                	push   $0x0
  pushl $174
  102267:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  10226c:	e9 38 f9 ff ff       	jmp    101ba9 <__alltraps>

00102271 <vector175>:
.globl vector175
vector175:
  pushl $0
  102271:	6a 00                	push   $0x0
  pushl $175
  102273:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  102278:	e9 2c f9 ff ff       	jmp    101ba9 <__alltraps>

0010227d <vector176>:
.globl vector176
vector176:
  pushl $0
  10227d:	6a 00                	push   $0x0
  pushl $176
  10227f:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  102284:	e9 20 f9 ff ff       	jmp    101ba9 <__alltraps>

00102289 <vector177>:
.globl vector177
vector177:
  pushl $0
  102289:	6a 00                	push   $0x0
  pushl $177
  10228b:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  102290:	e9 14 f9 ff ff       	jmp    101ba9 <__alltraps>

00102295 <vector178>:
.globl vector178
vector178:
  pushl $0
  102295:	6a 00                	push   $0x0
  pushl $178
  102297:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  10229c:	e9 08 f9 ff ff       	jmp    101ba9 <__alltraps>

001022a1 <vector179>:
.globl vector179
vector179:
  pushl $0
  1022a1:	6a 00                	push   $0x0
  pushl $179
  1022a3:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  1022a8:	e9 fc f8 ff ff       	jmp    101ba9 <__alltraps>

001022ad <vector180>:
.globl vector180
vector180:
  pushl $0
  1022ad:	6a 00                	push   $0x0
  pushl $180
  1022af:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  1022b4:	e9 f0 f8 ff ff       	jmp    101ba9 <__alltraps>

001022b9 <vector181>:
.globl vector181
vector181:
  pushl $0
  1022b9:	6a 00                	push   $0x0
  pushl $181
  1022bb:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  1022c0:	e9 e4 f8 ff ff       	jmp    101ba9 <__alltraps>

001022c5 <vector182>:
.globl vector182
vector182:
  pushl $0
  1022c5:	6a 00                	push   $0x0
  pushl $182
  1022c7:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  1022cc:	e9 d8 f8 ff ff       	jmp    101ba9 <__alltraps>

001022d1 <vector183>:
.globl vector183
vector183:
  pushl $0
  1022d1:	6a 00                	push   $0x0
  pushl $183
  1022d3:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  1022d8:	e9 cc f8 ff ff       	jmp    101ba9 <__alltraps>

001022dd <vector184>:
.globl vector184
vector184:
  pushl $0
  1022dd:	6a 00                	push   $0x0
  pushl $184
  1022df:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  1022e4:	e9 c0 f8 ff ff       	jmp    101ba9 <__alltraps>

001022e9 <vector185>:
.globl vector185
vector185:
  pushl $0
  1022e9:	6a 00                	push   $0x0
  pushl $185
  1022eb:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  1022f0:	e9 b4 f8 ff ff       	jmp    101ba9 <__alltraps>

001022f5 <vector186>:
.globl vector186
vector186:
  pushl $0
  1022f5:	6a 00                	push   $0x0
  pushl $186
  1022f7:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  1022fc:	e9 a8 f8 ff ff       	jmp    101ba9 <__alltraps>

00102301 <vector187>:
.globl vector187
vector187:
  pushl $0
  102301:	6a 00                	push   $0x0
  pushl $187
  102303:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  102308:	e9 9c f8 ff ff       	jmp    101ba9 <__alltraps>

0010230d <vector188>:
.globl vector188
vector188:
  pushl $0
  10230d:	6a 00                	push   $0x0
  pushl $188
  10230f:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  102314:	e9 90 f8 ff ff       	jmp    101ba9 <__alltraps>

00102319 <vector189>:
.globl vector189
vector189:
  pushl $0
  102319:	6a 00                	push   $0x0
  pushl $189
  10231b:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  102320:	e9 84 f8 ff ff       	jmp    101ba9 <__alltraps>

00102325 <vector190>:
.globl vector190
vector190:
  pushl $0
  102325:	6a 00                	push   $0x0
  pushl $190
  102327:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  10232c:	e9 78 f8 ff ff       	jmp    101ba9 <__alltraps>

00102331 <vector191>:
.globl vector191
vector191:
  pushl $0
  102331:	6a 00                	push   $0x0
  pushl $191
  102333:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  102338:	e9 6c f8 ff ff       	jmp    101ba9 <__alltraps>

0010233d <vector192>:
.globl vector192
vector192:
  pushl $0
  10233d:	6a 00                	push   $0x0
  pushl $192
  10233f:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  102344:	e9 60 f8 ff ff       	jmp    101ba9 <__alltraps>

00102349 <vector193>:
.globl vector193
vector193:
  pushl $0
  102349:	6a 00                	push   $0x0
  pushl $193
  10234b:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  102350:	e9 54 f8 ff ff       	jmp    101ba9 <__alltraps>

00102355 <vector194>:
.globl vector194
vector194:
  pushl $0
  102355:	6a 00                	push   $0x0
  pushl $194
  102357:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  10235c:	e9 48 f8 ff ff       	jmp    101ba9 <__alltraps>

00102361 <vector195>:
.globl vector195
vector195:
  pushl $0
  102361:	6a 00                	push   $0x0
  pushl $195
  102363:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  102368:	e9 3c f8 ff ff       	jmp    101ba9 <__alltraps>

0010236d <vector196>:
.globl vector196
vector196:
  pushl $0
  10236d:	6a 00                	push   $0x0
  pushl $196
  10236f:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  102374:	e9 30 f8 ff ff       	jmp    101ba9 <__alltraps>

00102379 <vector197>:
.globl vector197
vector197:
  pushl $0
  102379:	6a 00                	push   $0x0
  pushl $197
  10237b:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  102380:	e9 24 f8 ff ff       	jmp    101ba9 <__alltraps>

00102385 <vector198>:
.globl vector198
vector198:
  pushl $0
  102385:	6a 00                	push   $0x0
  pushl $198
  102387:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  10238c:	e9 18 f8 ff ff       	jmp    101ba9 <__alltraps>

00102391 <vector199>:
.globl vector199
vector199:
  pushl $0
  102391:	6a 00                	push   $0x0
  pushl $199
  102393:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  102398:	e9 0c f8 ff ff       	jmp    101ba9 <__alltraps>

0010239d <vector200>:
.globl vector200
vector200:
  pushl $0
  10239d:	6a 00                	push   $0x0
  pushl $200
  10239f:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  1023a4:	e9 00 f8 ff ff       	jmp    101ba9 <__alltraps>

001023a9 <vector201>:
.globl vector201
vector201:
  pushl $0
  1023a9:	6a 00                	push   $0x0
  pushl $201
  1023ab:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  1023b0:	e9 f4 f7 ff ff       	jmp    101ba9 <__alltraps>

001023b5 <vector202>:
.globl vector202
vector202:
  pushl $0
  1023b5:	6a 00                	push   $0x0
  pushl $202
  1023b7:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  1023bc:	e9 e8 f7 ff ff       	jmp    101ba9 <__alltraps>

001023c1 <vector203>:
.globl vector203
vector203:
  pushl $0
  1023c1:	6a 00                	push   $0x0
  pushl $203
  1023c3:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  1023c8:	e9 dc f7 ff ff       	jmp    101ba9 <__alltraps>

001023cd <vector204>:
.globl vector204
vector204:
  pushl $0
  1023cd:	6a 00                	push   $0x0
  pushl $204
  1023cf:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  1023d4:	e9 d0 f7 ff ff       	jmp    101ba9 <__alltraps>

001023d9 <vector205>:
.globl vector205
vector205:
  pushl $0
  1023d9:	6a 00                	push   $0x0
  pushl $205
  1023db:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  1023e0:	e9 c4 f7 ff ff       	jmp    101ba9 <__alltraps>

001023e5 <vector206>:
.globl vector206
vector206:
  pushl $0
  1023e5:	6a 00                	push   $0x0
  pushl $206
  1023e7:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  1023ec:	e9 b8 f7 ff ff       	jmp    101ba9 <__alltraps>

001023f1 <vector207>:
.globl vector207
vector207:
  pushl $0
  1023f1:	6a 00                	push   $0x0
  pushl $207
  1023f3:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  1023f8:	e9 ac f7 ff ff       	jmp    101ba9 <__alltraps>

001023fd <vector208>:
.globl vector208
vector208:
  pushl $0
  1023fd:	6a 00                	push   $0x0
  pushl $208
  1023ff:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  102404:	e9 a0 f7 ff ff       	jmp    101ba9 <__alltraps>

00102409 <vector209>:
.globl vector209
vector209:
  pushl $0
  102409:	6a 00                	push   $0x0
  pushl $209
  10240b:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  102410:	e9 94 f7 ff ff       	jmp    101ba9 <__alltraps>

00102415 <vector210>:
.globl vector210
vector210:
  pushl $0
  102415:	6a 00                	push   $0x0
  pushl $210
  102417:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  10241c:	e9 88 f7 ff ff       	jmp    101ba9 <__alltraps>

00102421 <vector211>:
.globl vector211
vector211:
  pushl $0
  102421:	6a 00                	push   $0x0
  pushl $211
  102423:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  102428:	e9 7c f7 ff ff       	jmp    101ba9 <__alltraps>

0010242d <vector212>:
.globl vector212
vector212:
  pushl $0
  10242d:	6a 00                	push   $0x0
  pushl $212
  10242f:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  102434:	e9 70 f7 ff ff       	jmp    101ba9 <__alltraps>

00102439 <vector213>:
.globl vector213
vector213:
  pushl $0
  102439:	6a 00                	push   $0x0
  pushl $213
  10243b:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  102440:	e9 64 f7 ff ff       	jmp    101ba9 <__alltraps>

00102445 <vector214>:
.globl vector214
vector214:
  pushl $0
  102445:	6a 00                	push   $0x0
  pushl $214
  102447:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  10244c:	e9 58 f7 ff ff       	jmp    101ba9 <__alltraps>

00102451 <vector215>:
.globl vector215
vector215:
  pushl $0
  102451:	6a 00                	push   $0x0
  pushl $215
  102453:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  102458:	e9 4c f7 ff ff       	jmp    101ba9 <__alltraps>

0010245d <vector216>:
.globl vector216
vector216:
  pushl $0
  10245d:	6a 00                	push   $0x0
  pushl $216
  10245f:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  102464:	e9 40 f7 ff ff       	jmp    101ba9 <__alltraps>

00102469 <vector217>:
.globl vector217
vector217:
  pushl $0
  102469:	6a 00                	push   $0x0
  pushl $217
  10246b:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  102470:	e9 34 f7 ff ff       	jmp    101ba9 <__alltraps>

00102475 <vector218>:
.globl vector218
vector218:
  pushl $0
  102475:	6a 00                	push   $0x0
  pushl $218
  102477:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  10247c:	e9 28 f7 ff ff       	jmp    101ba9 <__alltraps>

00102481 <vector219>:
.globl vector219
vector219:
  pushl $0
  102481:	6a 00                	push   $0x0
  pushl $219
  102483:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  102488:	e9 1c f7 ff ff       	jmp    101ba9 <__alltraps>

0010248d <vector220>:
.globl vector220
vector220:
  pushl $0
  10248d:	6a 00                	push   $0x0
  pushl $220
  10248f:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  102494:	e9 10 f7 ff ff       	jmp    101ba9 <__alltraps>

00102499 <vector221>:
.globl vector221
vector221:
  pushl $0
  102499:	6a 00                	push   $0x0
  pushl $221
  10249b:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  1024a0:	e9 04 f7 ff ff       	jmp    101ba9 <__alltraps>

001024a5 <vector222>:
.globl vector222
vector222:
  pushl $0
  1024a5:	6a 00                	push   $0x0
  pushl $222
  1024a7:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  1024ac:	e9 f8 f6 ff ff       	jmp    101ba9 <__alltraps>

001024b1 <vector223>:
.globl vector223
vector223:
  pushl $0
  1024b1:	6a 00                	push   $0x0
  pushl $223
  1024b3:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  1024b8:	e9 ec f6 ff ff       	jmp    101ba9 <__alltraps>

001024bd <vector224>:
.globl vector224
vector224:
  pushl $0
  1024bd:	6a 00                	push   $0x0
  pushl $224
  1024bf:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  1024c4:	e9 e0 f6 ff ff       	jmp    101ba9 <__alltraps>

001024c9 <vector225>:
.globl vector225
vector225:
  pushl $0
  1024c9:	6a 00                	push   $0x0
  pushl $225
  1024cb:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  1024d0:	e9 d4 f6 ff ff       	jmp    101ba9 <__alltraps>

001024d5 <vector226>:
.globl vector226
vector226:
  pushl $0
  1024d5:	6a 00                	push   $0x0
  pushl $226
  1024d7:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  1024dc:	e9 c8 f6 ff ff       	jmp    101ba9 <__alltraps>

001024e1 <vector227>:
.globl vector227
vector227:
  pushl $0
  1024e1:	6a 00                	push   $0x0
  pushl $227
  1024e3:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  1024e8:	e9 bc f6 ff ff       	jmp    101ba9 <__alltraps>

001024ed <vector228>:
.globl vector228
vector228:
  pushl $0
  1024ed:	6a 00                	push   $0x0
  pushl $228
  1024ef:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  1024f4:	e9 b0 f6 ff ff       	jmp    101ba9 <__alltraps>

001024f9 <vector229>:
.globl vector229
vector229:
  pushl $0
  1024f9:	6a 00                	push   $0x0
  pushl $229
  1024fb:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  102500:	e9 a4 f6 ff ff       	jmp    101ba9 <__alltraps>

00102505 <vector230>:
.globl vector230
vector230:
  pushl $0
  102505:	6a 00                	push   $0x0
  pushl $230
  102507:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  10250c:	e9 98 f6 ff ff       	jmp    101ba9 <__alltraps>

00102511 <vector231>:
.globl vector231
vector231:
  pushl $0
  102511:	6a 00                	push   $0x0
  pushl $231
  102513:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  102518:	e9 8c f6 ff ff       	jmp    101ba9 <__alltraps>

0010251d <vector232>:
.globl vector232
vector232:
  pushl $0
  10251d:	6a 00                	push   $0x0
  pushl $232
  10251f:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  102524:	e9 80 f6 ff ff       	jmp    101ba9 <__alltraps>

00102529 <vector233>:
.globl vector233
vector233:
  pushl $0
  102529:	6a 00                	push   $0x0
  pushl $233
  10252b:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  102530:	e9 74 f6 ff ff       	jmp    101ba9 <__alltraps>

00102535 <vector234>:
.globl vector234
vector234:
  pushl $0
  102535:	6a 00                	push   $0x0
  pushl $234
  102537:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  10253c:	e9 68 f6 ff ff       	jmp    101ba9 <__alltraps>

00102541 <vector235>:
.globl vector235
vector235:
  pushl $0
  102541:	6a 00                	push   $0x0
  pushl $235
  102543:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  102548:	e9 5c f6 ff ff       	jmp    101ba9 <__alltraps>

0010254d <vector236>:
.globl vector236
vector236:
  pushl $0
  10254d:	6a 00                	push   $0x0
  pushl $236
  10254f:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  102554:	e9 50 f6 ff ff       	jmp    101ba9 <__alltraps>

00102559 <vector237>:
.globl vector237
vector237:
  pushl $0
  102559:	6a 00                	push   $0x0
  pushl $237
  10255b:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  102560:	e9 44 f6 ff ff       	jmp    101ba9 <__alltraps>

00102565 <vector238>:
.globl vector238
vector238:
  pushl $0
  102565:	6a 00                	push   $0x0
  pushl $238
  102567:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  10256c:	e9 38 f6 ff ff       	jmp    101ba9 <__alltraps>

00102571 <vector239>:
.globl vector239
vector239:
  pushl $0
  102571:	6a 00                	push   $0x0
  pushl $239
  102573:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  102578:	e9 2c f6 ff ff       	jmp    101ba9 <__alltraps>

0010257d <vector240>:
.globl vector240
vector240:
  pushl $0
  10257d:	6a 00                	push   $0x0
  pushl $240
  10257f:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  102584:	e9 20 f6 ff ff       	jmp    101ba9 <__alltraps>

00102589 <vector241>:
.globl vector241
vector241:
  pushl $0
  102589:	6a 00                	push   $0x0
  pushl $241
  10258b:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  102590:	e9 14 f6 ff ff       	jmp    101ba9 <__alltraps>

00102595 <vector242>:
.globl vector242
vector242:
  pushl $0
  102595:	6a 00                	push   $0x0
  pushl $242
  102597:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  10259c:	e9 08 f6 ff ff       	jmp    101ba9 <__alltraps>

001025a1 <vector243>:
.globl vector243
vector243:
  pushl $0
  1025a1:	6a 00                	push   $0x0
  pushl $243
  1025a3:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  1025a8:	e9 fc f5 ff ff       	jmp    101ba9 <__alltraps>

001025ad <vector244>:
.globl vector244
vector244:
  pushl $0
  1025ad:	6a 00                	push   $0x0
  pushl $244
  1025af:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  1025b4:	e9 f0 f5 ff ff       	jmp    101ba9 <__alltraps>

001025b9 <vector245>:
.globl vector245
vector245:
  pushl $0
  1025b9:	6a 00                	push   $0x0
  pushl $245
  1025bb:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  1025c0:	e9 e4 f5 ff ff       	jmp    101ba9 <__alltraps>

001025c5 <vector246>:
.globl vector246
vector246:
  pushl $0
  1025c5:	6a 00                	push   $0x0
  pushl $246
  1025c7:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  1025cc:	e9 d8 f5 ff ff       	jmp    101ba9 <__alltraps>

001025d1 <vector247>:
.globl vector247
vector247:
  pushl $0
  1025d1:	6a 00                	push   $0x0
  pushl $247
  1025d3:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  1025d8:	e9 cc f5 ff ff       	jmp    101ba9 <__alltraps>

001025dd <vector248>:
.globl vector248
vector248:
  pushl $0
  1025dd:	6a 00                	push   $0x0
  pushl $248
  1025df:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  1025e4:	e9 c0 f5 ff ff       	jmp    101ba9 <__alltraps>

001025e9 <vector249>:
.globl vector249
vector249:
  pushl $0
  1025e9:	6a 00                	push   $0x0
  pushl $249
  1025eb:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  1025f0:	e9 b4 f5 ff ff       	jmp    101ba9 <__alltraps>

001025f5 <vector250>:
.globl vector250
vector250:
  pushl $0
  1025f5:	6a 00                	push   $0x0
  pushl $250
  1025f7:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  1025fc:	e9 a8 f5 ff ff       	jmp    101ba9 <__alltraps>

00102601 <vector251>:
.globl vector251
vector251:
  pushl $0
  102601:	6a 00                	push   $0x0
  pushl $251
  102603:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  102608:	e9 9c f5 ff ff       	jmp    101ba9 <__alltraps>

0010260d <vector252>:
.globl vector252
vector252:
  pushl $0
  10260d:	6a 00                	push   $0x0
  pushl $252
  10260f:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  102614:	e9 90 f5 ff ff       	jmp    101ba9 <__alltraps>

00102619 <vector253>:
.globl vector253
vector253:
  pushl $0
  102619:	6a 00                	push   $0x0
  pushl $253
  10261b:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  102620:	e9 84 f5 ff ff       	jmp    101ba9 <__alltraps>

00102625 <vector254>:
.globl vector254
vector254:
  pushl $0
  102625:	6a 00                	push   $0x0
  pushl $254
  102627:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  10262c:	e9 78 f5 ff ff       	jmp    101ba9 <__alltraps>

00102631 <vector255>:
.globl vector255
vector255:
  pushl $0
  102631:	6a 00                	push   $0x0
  pushl $255
  102633:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  102638:	e9 6c f5 ff ff       	jmp    101ba9 <__alltraps>

0010263d <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  10263d:	55                   	push   %ebp
  10263e:	89 e5                	mov    %esp,%ebp
    return page - pages;
  102640:	8b 55 08             	mov    0x8(%ebp),%edx
  102643:	a1 24 af 11 00       	mov    0x11af24,%eax
  102648:	29 c2                	sub    %eax,%edx
  10264a:	89 d0                	mov    %edx,%eax
  10264c:	c1 f8 02             	sar    $0x2,%eax
  10264f:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  102655:	5d                   	pop    %ebp
  102656:	c3                   	ret    

00102657 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  102657:	55                   	push   %ebp
  102658:	89 e5                	mov    %esp,%ebp
  10265a:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  10265d:	8b 45 08             	mov    0x8(%ebp),%eax
  102660:	89 04 24             	mov    %eax,(%esp)
  102663:	e8 d5 ff ff ff       	call   10263d <page2ppn>
  102668:	c1 e0 0c             	shl    $0xc,%eax
}
  10266b:	c9                   	leave  
  10266c:	c3                   	ret    

0010266d <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
  10266d:	55                   	push   %ebp
  10266e:	89 e5                	mov    %esp,%ebp
    return page->ref;
  102670:	8b 45 08             	mov    0x8(%ebp),%eax
  102673:	8b 00                	mov    (%eax),%eax
}
  102675:	5d                   	pop    %ebp
  102676:	c3                   	ret    

00102677 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
  102677:	55                   	push   %ebp
  102678:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  10267a:	8b 45 08             	mov    0x8(%ebp),%eax
  10267d:	8b 55 0c             	mov    0xc(%ebp),%edx
  102680:	89 10                	mov    %edx,(%eax)
}
  102682:	5d                   	pop    %ebp
  102683:	c3                   	ret    

00102684 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
  102684:	55                   	push   %ebp
  102685:	89 e5                	mov    %esp,%ebp
  102687:	83 ec 10             	sub    $0x10,%esp
  10268a:	c7 45 fc 10 af 11 00 	movl   $0x11af10,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  102691:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102694:	8b 55 fc             	mov    -0x4(%ebp),%edx
  102697:	89 50 04             	mov    %edx,0x4(%eax)
  10269a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10269d:	8b 50 04             	mov    0x4(%eax),%edx
  1026a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1026a3:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
  1026a5:	c7 05 18 af 11 00 00 	movl   $0x0,0x11af18
  1026ac:	00 00 00 
}
  1026af:	c9                   	leave  
  1026b0:	c3                   	ret    

001026b1 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
  1026b1:	55                   	push   %ebp
  1026b2:	89 e5                	mov    %esp,%ebp
  1026b4:	83 ec 58             	sub    $0x58,%esp
    assert(n > 0);
  1026b7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1026bb:	75 24                	jne    1026e1 <default_init_memmap+0x30>
  1026bd:	c7 44 24 0c 70 65 10 	movl   $0x106570,0xc(%esp)
  1026c4:	00 
  1026c5:	c7 44 24 08 76 65 10 	movl   $0x106576,0x8(%esp)
  1026cc:	00 
  1026cd:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  1026d4:	00 
  1026d5:	c7 04 24 8b 65 10 00 	movl   $0x10658b,(%esp)
  1026dc:	e8 37 e5 ff ff       	call   100c18 <__panic>
    struct Page *p = base;
  1026e1:	8b 45 08             	mov    0x8(%ebp),%eax
  1026e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  1026e7:	eb 7d                	jmp    102766 <default_init_memmap+0xb5>
        assert(PageReserved(p));
  1026e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1026ec:	83 c0 04             	add    $0x4,%eax
  1026ef:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  1026f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1026f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1026fc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1026ff:	0f a3 10             	bt     %edx,(%eax)
  102702:	19 c0                	sbb    %eax,%eax
  102704:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
  102707:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10270b:	0f 95 c0             	setne  %al
  10270e:	0f b6 c0             	movzbl %al,%eax
  102711:	85 c0                	test   %eax,%eax
  102713:	75 24                	jne    102739 <default_init_memmap+0x88>
  102715:	c7 44 24 0c a1 65 10 	movl   $0x1065a1,0xc(%esp)
  10271c:	00 
  10271d:	c7 44 24 08 76 65 10 	movl   $0x106576,0x8(%esp)
  102724:	00 
  102725:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  10272c:	00 
  10272d:	c7 04 24 8b 65 10 00 	movl   $0x10658b,(%esp)
  102734:	e8 df e4 ff ff       	call   100c18 <__panic>
        p->flags = p->property = 0;
  102739:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10273c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  102743:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102746:	8b 50 08             	mov    0x8(%eax),%edx
  102749:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10274c:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
  10274f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  102756:	00 
  102757:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10275a:	89 04 24             	mov    %eax,(%esp)
  10275d:	e8 15 ff ff ff       	call   102677 <set_page_ref>

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
  102762:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  102766:	8b 55 0c             	mov    0xc(%ebp),%edx
  102769:	89 d0                	mov    %edx,%eax
  10276b:	c1 e0 02             	shl    $0x2,%eax
  10276e:	01 d0                	add    %edx,%eax
  102770:	c1 e0 02             	shl    $0x2,%eax
  102773:	89 c2                	mov    %eax,%edx
  102775:	8b 45 08             	mov    0x8(%ebp),%eax
  102778:	01 d0                	add    %edx,%eax
  10277a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  10277d:	0f 85 66 ff ff ff    	jne    1026e9 <default_init_memmap+0x38>
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
        
    }
    base->property = n;
  102783:	8b 45 08             	mov    0x8(%ebp),%eax
  102786:	8b 55 0c             	mov    0xc(%ebp),%edx
  102789:	89 50 08             	mov    %edx,0x8(%eax)
    nr_free += n;
  10278c:	8b 15 18 af 11 00    	mov    0x11af18,%edx
  102792:	8b 45 0c             	mov    0xc(%ebp),%eax
  102795:	01 d0                	add    %edx,%eax
  102797:	a3 18 af 11 00       	mov    %eax,0x11af18
    SetPageProperty(base);
  10279c:	8b 45 08             	mov    0x8(%ebp),%eax
  10279f:	83 c0 04             	add    $0x4,%eax
  1027a2:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  1027a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1027ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1027af:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1027b2:	0f ab 10             	bts    %edx,(%eax)
    list_add(&free_list, &(base->page_link));
  1027b5:	8b 45 08             	mov    0x8(%ebp),%eax
  1027b8:	83 c0 0c             	add    $0xc,%eax
  1027bb:	c7 45 dc 10 af 11 00 	movl   $0x11af10,-0x24(%ebp)
  1027c2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  1027c5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1027c8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  1027cb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1027ce:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
  1027d1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1027d4:	8b 40 04             	mov    0x4(%eax),%eax
  1027d7:	8b 55 d0             	mov    -0x30(%ebp),%edx
  1027da:	89 55 cc             	mov    %edx,-0x34(%ebp)
  1027dd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1027e0:	89 55 c8             	mov    %edx,-0x38(%ebp)
  1027e3:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  1027e6:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1027e9:	8b 55 cc             	mov    -0x34(%ebp),%edx
  1027ec:	89 10                	mov    %edx,(%eax)
  1027ee:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1027f1:	8b 10                	mov    (%eax),%edx
  1027f3:	8b 45 c8             	mov    -0x38(%ebp),%eax
  1027f6:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  1027f9:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1027fc:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  1027ff:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  102802:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102805:	8b 55 c8             	mov    -0x38(%ebp),%edx
  102808:	89 10                	mov    %edx,(%eax)
}
  10280a:	c9                   	leave  
  10280b:	c3                   	ret    

0010280c <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
  10280c:	55                   	push   %ebp
  10280d:	89 e5                	mov    %esp,%ebp
  10280f:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
  102815:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  102819:	75 24                	jne    10283f <default_alloc_pages+0x33>
  10281b:	c7 44 24 0c 70 65 10 	movl   $0x106570,0xc(%esp)
  102822:	00 
  102823:	c7 44 24 08 76 65 10 	movl   $0x106576,0x8(%esp)
  10282a:	00 
  10282b:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  102832:	00 
  102833:	c7 04 24 8b 65 10 00 	movl   $0x10658b,(%esp)
  10283a:	e8 d9 e3 ff ff       	call   100c18 <__panic>
    if (n > nr_free) {
  10283f:	a1 18 af 11 00       	mov    0x11af18,%eax
  102844:	3b 45 08             	cmp    0x8(%ebp),%eax
  102847:	73 0a                	jae    102853 <default_alloc_pages+0x47>
        return NULL;
  102849:	b8 00 00 00 00       	mov    $0x0,%eax
  10284e:	e9 bd 01 00 00       	jmp    102a10 <default_alloc_pages+0x204>
    }
    struct Page *page = NULL;
  102853:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
  10285a:	c7 45 f0 10 af 11 00 	movl   $0x11af10,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
  102861:	eb 1c                	jmp    10287f <default_alloc_pages+0x73>
        struct Page *p = le2page(le, page_link);
  102863:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102866:	83 e8 0c             	sub    $0xc,%eax
  102869:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
  10286c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10286f:	8b 40 08             	mov    0x8(%eax),%eax
  102872:	3b 45 08             	cmp    0x8(%ebp),%eax
  102875:	72 08                	jb     10287f <default_alloc_pages+0x73>
            page = p;
  102877:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10287a:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
  10287d:	eb 18                	jmp    102897 <default_alloc_pages+0x8b>
  10287f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102882:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  102885:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102888:	8b 40 04             	mov    0x4(%eax),%eax
    if (n > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
  10288b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10288e:	81 7d f0 10 af 11 00 	cmpl   $0x11af10,-0x10(%ebp)
  102895:	75 cc                	jne    102863 <default_alloc_pages+0x57>
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    if (page != NULL) {
  102897:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10289b:	0f 84 6c 01 00 00    	je     102a0d <default_alloc_pages+0x201>
        list_entry_t *p1=list_next(&(page->page_link));       
  1028a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1028a4:	83 c0 0c             	add    $0xc,%eax
  1028a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  1028aa:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1028ad:	8b 40 04             	mov    0x4(%eax),%eax
  1028b0:	89 45 e8             	mov    %eax,-0x18(%ebp)
        list_entry_t *p2=list_prev(&(page->page_link)); 
  1028b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1028b6:	83 c0 0c             	add    $0xc,%eax
  1028b9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
  1028bc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1028bf:	8b 00                	mov    (%eax),%eax
  1028c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        //SetPageReserved(page);                   
        if (page->property > n) {
  1028c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1028c7:	8b 40 08             	mov    0x8(%eax),%eax
  1028ca:	3b 45 08             	cmp    0x8(%ebp),%eax
  1028cd:	0f 86 e9 00 00 00    	jbe    1029bc <default_alloc_pages+0x1b0>
            struct Page *p = page + n;
  1028d3:	8b 55 08             	mov    0x8(%ebp),%edx
  1028d6:	89 d0                	mov    %edx,%eax
  1028d8:	c1 e0 02             	shl    $0x2,%eax
  1028db:	01 d0                	add    %edx,%eax
  1028dd:	c1 e0 02             	shl    $0x2,%eax
  1028e0:	89 c2                	mov    %eax,%edx
  1028e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1028e5:	01 d0                	add    %edx,%eax
  1028e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
            p->property = page->property - n;
  1028ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1028ed:	8b 40 08             	mov    0x8(%eax),%eax
  1028f0:	2b 45 08             	sub    0x8(%ebp),%eax
  1028f3:	89 c2                	mov    %eax,%edx
  1028f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1028f8:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);                 
  1028fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1028fe:	83 c0 04             	add    $0x4,%eax
  102901:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  102908:	89 45 cc             	mov    %eax,-0x34(%ebp)
  10290b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  10290e:	8b 55 d0             	mov    -0x30(%ebp),%edx
  102911:	0f ab 10             	bts    %edx,(%eax)
            list_add(&(p->page_link),p1);
  102914:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102917:	83 c0 0c             	add    $0xc,%eax
  10291a:	89 45 c8             	mov    %eax,-0x38(%ebp)
  10291d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102920:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  102923:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102926:	89 45 c0             	mov    %eax,-0x40(%ebp)
  102929:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  10292c:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
  10292f:	8b 45 c0             	mov    -0x40(%ebp),%eax
  102932:	8b 40 04             	mov    0x4(%eax),%eax
  102935:	8b 55 bc             	mov    -0x44(%ebp),%edx
  102938:	89 55 b8             	mov    %edx,-0x48(%ebp)
  10293b:	8b 55 c0             	mov    -0x40(%ebp),%edx
  10293e:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  102941:	89 45 b0             	mov    %eax,-0x50(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  102944:	8b 45 b0             	mov    -0x50(%ebp),%eax
  102947:	8b 55 b8             	mov    -0x48(%ebp),%edx
  10294a:	89 10                	mov    %edx,(%eax)
  10294c:	8b 45 b0             	mov    -0x50(%ebp),%eax
  10294f:	8b 10                	mov    (%eax),%edx
  102951:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  102954:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  102957:	8b 45 b8             	mov    -0x48(%ebp),%eax
  10295a:	8b 55 b0             	mov    -0x50(%ebp),%edx
  10295d:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  102960:	8b 45 b8             	mov    -0x48(%ebp),%eax
  102963:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  102966:	89 10                	mov    %edx,(%eax)
            list_add(p2,&(p->page_link));                                   
  102968:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10296b:	8d 50 0c             	lea    0xc(%eax),%edx
  10296e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102971:	89 45 ac             	mov    %eax,-0x54(%ebp)
  102974:	89 55 a8             	mov    %edx,-0x58(%ebp)
  102977:	8b 45 ac             	mov    -0x54(%ebp),%eax
  10297a:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  10297d:	8b 45 a8             	mov    -0x58(%ebp),%eax
  102980:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
  102983:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  102986:	8b 40 04             	mov    0x4(%eax),%eax
  102989:	8b 55 a0             	mov    -0x60(%ebp),%edx
  10298c:	89 55 9c             	mov    %edx,-0x64(%ebp)
  10298f:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  102992:	89 55 98             	mov    %edx,-0x68(%ebp)
  102995:	89 45 94             	mov    %eax,-0x6c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  102998:	8b 45 94             	mov    -0x6c(%ebp),%eax
  10299b:	8b 55 9c             	mov    -0x64(%ebp),%edx
  10299e:	89 10                	mov    %edx,(%eax)
  1029a0:	8b 45 94             	mov    -0x6c(%ebp),%eax
  1029a3:	8b 10                	mov    (%eax),%edx
  1029a5:	8b 45 98             	mov    -0x68(%ebp),%eax
  1029a8:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  1029ab:	8b 45 9c             	mov    -0x64(%ebp),%eax
  1029ae:	8b 55 94             	mov    -0x6c(%ebp),%edx
  1029b1:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  1029b4:	8b 45 9c             	mov    -0x64(%ebp),%eax
  1029b7:	8b 55 98             	mov    -0x68(%ebp),%edx
  1029ba:	89 10                	mov    %edx,(%eax)
    }
        nr_free -= n;
  1029bc:	a1 18 af 11 00       	mov    0x11af18,%eax
  1029c1:	2b 45 08             	sub    0x8(%ebp),%eax
  1029c4:	a3 18 af 11 00       	mov    %eax,0x11af18
        list_del(&(page->page_link));
  1029c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1029cc:	83 c0 0c             	add    $0xc,%eax
  1029cf:	89 45 90             	mov    %eax,-0x70(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  1029d2:	8b 45 90             	mov    -0x70(%ebp),%eax
  1029d5:	8b 40 04             	mov    0x4(%eax),%eax
  1029d8:	8b 55 90             	mov    -0x70(%ebp),%edx
  1029db:	8b 12                	mov    (%edx),%edx
  1029dd:	89 55 8c             	mov    %edx,-0x74(%ebp)
  1029e0:	89 45 88             	mov    %eax,-0x78(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  1029e3:	8b 45 8c             	mov    -0x74(%ebp),%eax
  1029e6:	8b 55 88             	mov    -0x78(%ebp),%edx
  1029e9:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  1029ec:	8b 45 88             	mov    -0x78(%ebp),%eax
  1029ef:	8b 55 8c             	mov    -0x74(%ebp),%edx
  1029f2:	89 10                	mov    %edx,(%eax)
        ClearPageProperty(page);
  1029f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1029f7:	83 c0 04             	add    $0x4,%eax
  1029fa:	c7 45 84 01 00 00 00 	movl   $0x1,-0x7c(%ebp)
  102a01:	89 45 80             	mov    %eax,-0x80(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102a04:	8b 45 80             	mov    -0x80(%ebp),%eax
  102a07:	8b 55 84             	mov    -0x7c(%ebp),%edx
  102a0a:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
  102a0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  102a10:	c9                   	leave  
  102a11:	c3                   	ret    

00102a12 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
  102a12:	55                   	push   %ebp
  102a13:	89 e5                	mov    %esp,%ebp
  102a15:	81 ec b8 00 00 00    	sub    $0xb8,%esp
    assert(n > 0);
  102a1b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102a1f:	75 24                	jne    102a45 <default_free_pages+0x33>
  102a21:	c7 44 24 0c 70 65 10 	movl   $0x106570,0xc(%esp)
  102a28:	00 
  102a29:	c7 44 24 08 76 65 10 	movl   $0x106576,0x8(%esp)
  102a30:	00 
  102a31:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
  102a38:	00 
  102a39:	c7 04 24 8b 65 10 00 	movl   $0x10658b,(%esp)
  102a40:	e8 d3 e1 ff ff       	call   100c18 <__panic>
    struct Page *p = base;
  102a45:	8b 45 08             	mov    0x8(%ebp),%eax
  102a48:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  102a4b:	e9 9d 00 00 00       	jmp    102aed <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
  102a50:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102a53:	83 c0 04             	add    $0x4,%eax
  102a56:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  102a5d:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  102a60:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102a63:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102a66:	0f a3 10             	bt     %edx,(%eax)
  102a69:	19 c0                	sbb    %eax,%eax
  102a6b:	89 45 dc             	mov    %eax,-0x24(%ebp)
    return oldbit != 0;
  102a6e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  102a72:	0f 95 c0             	setne  %al
  102a75:	0f b6 c0             	movzbl %al,%eax
  102a78:	85 c0                	test   %eax,%eax
  102a7a:	75 2c                	jne    102aa8 <default_free_pages+0x96>
  102a7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102a7f:	83 c0 04             	add    $0x4,%eax
  102a82:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
  102a89:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  102a8c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  102a8f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  102a92:	0f a3 10             	bt     %edx,(%eax)
  102a95:	19 c0                	sbb    %eax,%eax
  102a97:	89 45 d0             	mov    %eax,-0x30(%ebp)
    return oldbit != 0;
  102a9a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  102a9e:	0f 95 c0             	setne  %al
  102aa1:	0f b6 c0             	movzbl %al,%eax
  102aa4:	85 c0                	test   %eax,%eax
  102aa6:	74 24                	je     102acc <default_free_pages+0xba>
  102aa8:	c7 44 24 0c b4 65 10 	movl   $0x1065b4,0xc(%esp)
  102aaf:	00 
  102ab0:	c7 44 24 08 76 65 10 	movl   $0x106576,0x8(%esp)
  102ab7:	00 
  102ab8:	c7 44 24 04 a1 00 00 	movl   $0xa1,0x4(%esp)
  102abf:	00 
  102ac0:	c7 04 24 8b 65 10 00 	movl   $0x10658b,(%esp)
  102ac7:	e8 4c e1 ff ff       	call   100c18 <__panic>
        p->flags = 0;
  102acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102acf:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
  102ad6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  102add:	00 
  102ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102ae1:	89 04 24             	mov    %eax,(%esp)
  102ae4:	e8 8e fb ff ff       	call   102677 <set_page_ref>

static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
  102ae9:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  102aed:	8b 55 0c             	mov    0xc(%ebp),%edx
  102af0:	89 d0                	mov    %edx,%eax
  102af2:	c1 e0 02             	shl    $0x2,%eax
  102af5:	01 d0                	add    %edx,%eax
  102af7:	c1 e0 02             	shl    $0x2,%eax
  102afa:	89 c2                	mov    %eax,%edx
  102afc:	8b 45 08             	mov    0x8(%ebp),%eax
  102aff:	01 d0                	add    %edx,%eax
  102b01:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102b04:	0f 85 46 ff ff ff    	jne    102a50 <default_free_pages+0x3e>
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
  102b0a:	8b 45 08             	mov    0x8(%ebp),%eax
  102b0d:	8b 55 0c             	mov    0xc(%ebp),%edx
  102b10:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  102b13:	8b 45 08             	mov    0x8(%ebp),%eax
  102b16:	83 c0 04             	add    $0x4,%eax
  102b19:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
  102b20:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102b23:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102b26:	8b 55 cc             	mov    -0x34(%ebp),%edx
  102b29:	0f ab 10             	bts    %edx,(%eax)
  102b2c:	c7 45 c4 10 af 11 00 	movl   $0x11af10,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  102b33:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102b36:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
  102b39:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
  102b3c:	e9 08 01 00 00       	jmp    102c49 <default_free_pages+0x237>
        p = le2page(le, page_link);
  102b41:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102b44:	83 e8 0c             	sub    $0xc,%eax
  102b47:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102b4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102b4d:	89 45 c0             	mov    %eax,-0x40(%ebp)
  102b50:	8b 45 c0             	mov    -0x40(%ebp),%eax
  102b53:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
  102b56:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) {
  102b59:	8b 45 08             	mov    0x8(%ebp),%eax
  102b5c:	8b 50 08             	mov    0x8(%eax),%edx
  102b5f:	89 d0                	mov    %edx,%eax
  102b61:	c1 e0 02             	shl    $0x2,%eax
  102b64:	01 d0                	add    %edx,%eax
  102b66:	c1 e0 02             	shl    $0x2,%eax
  102b69:	89 c2                	mov    %eax,%edx
  102b6b:	8b 45 08             	mov    0x8(%ebp),%eax
  102b6e:	01 d0                	add    %edx,%eax
  102b70:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102b73:	75 5a                	jne    102bcf <default_free_pages+0x1bd>
            base->property += p->property;
  102b75:	8b 45 08             	mov    0x8(%ebp),%eax
  102b78:	8b 50 08             	mov    0x8(%eax),%edx
  102b7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102b7e:	8b 40 08             	mov    0x8(%eax),%eax
  102b81:	01 c2                	add    %eax,%edx
  102b83:	8b 45 08             	mov    0x8(%ebp),%eax
  102b86:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
  102b89:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102b8c:	83 c0 04             	add    $0x4,%eax
  102b8f:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
  102b96:	89 45 b8             	mov    %eax,-0x48(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102b99:	8b 45 b8             	mov    -0x48(%ebp),%eax
  102b9c:	8b 55 bc             	mov    -0x44(%ebp),%edx
  102b9f:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
  102ba2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102ba5:	83 c0 0c             	add    $0xc,%eax
  102ba8:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  102bab:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  102bae:	8b 40 04             	mov    0x4(%eax),%eax
  102bb1:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  102bb4:	8b 12                	mov    (%edx),%edx
  102bb6:	89 55 b0             	mov    %edx,-0x50(%ebp)
  102bb9:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  102bbc:	8b 45 b0             	mov    -0x50(%ebp),%eax
  102bbf:	8b 55 ac             	mov    -0x54(%ebp),%edx
  102bc2:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  102bc5:	8b 45 ac             	mov    -0x54(%ebp),%eax
  102bc8:	8b 55 b0             	mov    -0x50(%ebp),%edx
  102bcb:	89 10                	mov    %edx,(%eax)
  102bcd:	eb 7a                	jmp    102c49 <default_free_pages+0x237>
        }
        else if (p + p->property == base) {
  102bcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102bd2:	8b 50 08             	mov    0x8(%eax),%edx
  102bd5:	89 d0                	mov    %edx,%eax
  102bd7:	c1 e0 02             	shl    $0x2,%eax
  102bda:	01 d0                	add    %edx,%eax
  102bdc:	c1 e0 02             	shl    $0x2,%eax
  102bdf:	89 c2                	mov    %eax,%edx
  102be1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102be4:	01 d0                	add    %edx,%eax
  102be6:	3b 45 08             	cmp    0x8(%ebp),%eax
  102be9:	75 5e                	jne    102c49 <default_free_pages+0x237>
            p->property += base->property;
  102beb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102bee:	8b 50 08             	mov    0x8(%eax),%edx
  102bf1:	8b 45 08             	mov    0x8(%ebp),%eax
  102bf4:	8b 40 08             	mov    0x8(%eax),%eax
  102bf7:	01 c2                	add    %eax,%edx
  102bf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102bfc:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
  102bff:	8b 45 08             	mov    0x8(%ebp),%eax
  102c02:	83 c0 04             	add    $0x4,%eax
  102c05:	c7 45 a8 01 00 00 00 	movl   $0x1,-0x58(%ebp)
  102c0c:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  102c0f:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  102c12:	8b 55 a8             	mov    -0x58(%ebp),%edx
  102c15:	0f b3 10             	btr    %edx,(%eax)
            base = p;
  102c18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c1b:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
  102c1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c21:	83 c0 0c             	add    $0xc,%eax
  102c24:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  102c27:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102c2a:	8b 40 04             	mov    0x4(%eax),%eax
  102c2d:	8b 55 a0             	mov    -0x60(%ebp),%edx
  102c30:	8b 12                	mov    (%edx),%edx
  102c32:	89 55 9c             	mov    %edx,-0x64(%ebp)
  102c35:	89 45 98             	mov    %eax,-0x68(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  102c38:	8b 45 9c             	mov    -0x64(%ebp),%eax
  102c3b:	8b 55 98             	mov    -0x68(%ebp),%edx
  102c3e:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  102c41:	8b 45 98             	mov    -0x68(%ebp),%eax
  102c44:	8b 55 9c             	mov    -0x64(%ebp),%edx
  102c47:	89 10                	mov    %edx,(%eax)
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
    while (le != &free_list) {
  102c49:	81 7d f0 10 af 11 00 	cmpl   $0x11af10,-0x10(%ebp)
  102c50:	0f 85 eb fe ff ff    	jne    102b41 <default_free_pages+0x12f>
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
  102c56:	8b 15 18 af 11 00    	mov    0x11af18,%edx
  102c5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  102c5f:	01 d0                	add    %edx,%eax
  102c61:	a3 18 af 11 00       	mov    %eax,0x11af18
    if(base->property>n)
  102c66:	8b 45 08             	mov    0x8(%ebp),%eax
  102c69:	8b 40 08             	mov    0x8(%eax),%eax
  102c6c:	3b 45 0c             	cmp    0xc(%ebp),%eax
  102c6f:	76 66                	jbe    102cd7 <default_free_pages+0x2c5>
    list_add(&free_list, &(base->page_link));
  102c71:	8b 45 08             	mov    0x8(%ebp),%eax
  102c74:	83 c0 0c             	add    $0xc,%eax
  102c77:	c7 45 94 10 af 11 00 	movl   $0x11af10,-0x6c(%ebp)
  102c7e:	89 45 90             	mov    %eax,-0x70(%ebp)
  102c81:	8b 45 94             	mov    -0x6c(%ebp),%eax
  102c84:	89 45 8c             	mov    %eax,-0x74(%ebp)
  102c87:	8b 45 90             	mov    -0x70(%ebp),%eax
  102c8a:	89 45 88             	mov    %eax,-0x78(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
  102c8d:	8b 45 8c             	mov    -0x74(%ebp),%eax
  102c90:	8b 40 04             	mov    0x4(%eax),%eax
  102c93:	8b 55 88             	mov    -0x78(%ebp),%edx
  102c96:	89 55 84             	mov    %edx,-0x7c(%ebp)
  102c99:	8b 55 8c             	mov    -0x74(%ebp),%edx
  102c9c:	89 55 80             	mov    %edx,-0x80(%ebp)
  102c9f:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  102ca5:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  102cab:	8b 55 84             	mov    -0x7c(%ebp),%edx
  102cae:	89 10                	mov    %edx,(%eax)
  102cb0:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  102cb6:	8b 10                	mov    (%eax),%edx
  102cb8:	8b 45 80             	mov    -0x80(%ebp),%eax
  102cbb:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  102cbe:	8b 45 84             	mov    -0x7c(%ebp),%eax
  102cc1:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
  102cc7:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  102cca:	8b 45 84             	mov    -0x7c(%ebp),%eax
  102ccd:	8b 55 80             	mov    -0x80(%ebp),%edx
  102cd0:	89 10                	mov    %edx,(%eax)
  102cd2:	e9 fe 00 00 00       	jmp    102dd5 <default_free_pages+0x3c3>
  102cd7:	c7 85 78 ff ff ff 10 	movl   $0x11af10,-0x88(%ebp)
  102cde:	af 11 00 
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  102ce1:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
  102ce7:	8b 40 04             	mov    0x4(%eax),%eax
    else
    {
	    list_entry_t *le1 = list_next(&free_list);
  102cea:	89 45 ec             	mov    %eax,-0x14(%ebp)
  102ced:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102cf0:	89 85 74 ff ff ff    	mov    %eax,-0x8c(%ebp)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
  102cf6:	8b 85 74 ff ff ff    	mov    -0x8c(%ebp),%eax
  102cfc:	8b 00                	mov    (%eax),%eax
	    list_entry_t *le0 = list_prev(le1);
  102cfe:	89 45 e8             	mov    %eax,-0x18(%ebp)
	    while (le1 != &free_list) {
  102d01:	eb 39                	jmp    102d3c <default_free_pages+0x32a>
		p = le2page(le1, page_link);
  102d03:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102d06:	83 e8 0c             	sub    $0xc,%eax
  102d09:	89 45 f4             	mov    %eax,-0xc(%ebp)
		if(base+base->property<le1)break;
  102d0c:	8b 45 08             	mov    0x8(%ebp),%eax
  102d0f:	8b 50 08             	mov    0x8(%eax),%edx
  102d12:	89 d0                	mov    %edx,%eax
  102d14:	c1 e0 02             	shl    $0x2,%eax
  102d17:	01 d0                	add    %edx,%eax
  102d19:	c1 e0 02             	shl    $0x2,%eax
  102d1c:	89 c2                	mov    %eax,%edx
  102d1e:	8b 45 08             	mov    0x8(%ebp),%eax
  102d21:	01 d0                	add    %edx,%eax
  102d23:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  102d26:	73 02                	jae    102d2a <default_free_pages+0x318>
  102d28:	eb 1b                	jmp    102d45 <default_free_pages+0x333>
		le0=le0->next;
  102d2a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102d2d:	8b 40 04             	mov    0x4(%eax),%eax
  102d30:	89 45 e8             	mov    %eax,-0x18(%ebp)
		le1=le1->next;
  102d33:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102d36:	8b 40 04             	mov    0x4(%eax),%eax
  102d39:	89 45 ec             	mov    %eax,-0x14(%ebp)
    list_add(&free_list, &(base->page_link));
    else
    {
	    list_entry_t *le1 = list_next(&free_list);
	    list_entry_t *le0 = list_prev(le1);
	    while (le1 != &free_list) {
  102d3c:	81 7d ec 10 af 11 00 	cmpl   $0x11af10,-0x14(%ebp)
  102d43:	75 be                	jne    102d03 <default_free_pages+0x2f1>
		p = le2page(le1, page_link);
		if(base+base->property<le1)break;
		le0=le0->next;
		le1=le1->next;
	    }
	    list_add(le0, &(base->page_link));
  102d45:	8b 45 08             	mov    0x8(%ebp),%eax
  102d48:	8d 50 0c             	lea    0xc(%eax),%edx
  102d4b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102d4e:	89 85 70 ff ff ff    	mov    %eax,-0x90(%ebp)
  102d54:	89 95 6c ff ff ff    	mov    %edx,-0x94(%ebp)
  102d5a:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
  102d60:	89 85 68 ff ff ff    	mov    %eax,-0x98(%ebp)
  102d66:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
  102d6c:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
  102d72:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
  102d78:	8b 40 04             	mov    0x4(%eax),%eax
  102d7b:	8b 95 64 ff ff ff    	mov    -0x9c(%ebp),%edx
  102d81:	89 95 60 ff ff ff    	mov    %edx,-0xa0(%ebp)
  102d87:	8b 95 68 ff ff ff    	mov    -0x98(%ebp),%edx
  102d8d:	89 95 5c ff ff ff    	mov    %edx,-0xa4(%ebp)
  102d93:	89 85 58 ff ff ff    	mov    %eax,-0xa8(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  102d99:	8b 85 58 ff ff ff    	mov    -0xa8(%ebp),%eax
  102d9f:	8b 95 60 ff ff ff    	mov    -0xa0(%ebp),%edx
  102da5:	89 10                	mov    %edx,(%eax)
  102da7:	8b 85 58 ff ff ff    	mov    -0xa8(%ebp),%eax
  102dad:	8b 10                	mov    (%eax),%edx
  102daf:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  102db5:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  102db8:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
  102dbe:	8b 95 58 ff ff ff    	mov    -0xa8(%ebp),%edx
  102dc4:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  102dc7:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
  102dcd:	8b 95 5c ff ff ff    	mov    -0xa4(%ebp),%edx
  102dd3:	89 10                	mov    %edx,(%eax)
    }
}
  102dd5:	c9                   	leave  
  102dd6:	c3                   	ret    

00102dd7 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
  102dd7:	55                   	push   %ebp
  102dd8:	89 e5                	mov    %esp,%ebp
    return nr_free;
  102dda:	a1 18 af 11 00       	mov    0x11af18,%eax
}
  102ddf:	5d                   	pop    %ebp
  102de0:	c3                   	ret    

00102de1 <basic_check>:

static void
basic_check(void) {
  102de1:	55                   	push   %ebp
  102de2:	89 e5                	mov    %esp,%ebp
  102de4:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
  102de7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  102dee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102df1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102df4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102df7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
  102dfa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  102e01:	e8 db 0e 00 00       	call   103ce1 <alloc_pages>
  102e06:	89 45 ec             	mov    %eax,-0x14(%ebp)
  102e09:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  102e0d:	75 24                	jne    102e33 <basic_check+0x52>
  102e0f:	c7 44 24 0c d9 65 10 	movl   $0x1065d9,0xc(%esp)
  102e16:	00 
  102e17:	c7 44 24 08 76 65 10 	movl   $0x106576,0x8(%esp)
  102e1e:	00 
  102e1f:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
  102e26:	00 
  102e27:	c7 04 24 8b 65 10 00 	movl   $0x10658b,(%esp)
  102e2e:	e8 e5 dd ff ff       	call   100c18 <__panic>
    assert((p1 = alloc_page()) != NULL);
  102e33:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  102e3a:	e8 a2 0e 00 00       	call   103ce1 <alloc_pages>
  102e3f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102e42:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  102e46:	75 24                	jne    102e6c <basic_check+0x8b>
  102e48:	c7 44 24 0c f5 65 10 	movl   $0x1065f5,0xc(%esp)
  102e4f:	00 
  102e50:	c7 44 24 08 76 65 10 	movl   $0x106576,0x8(%esp)
  102e57:	00 
  102e58:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
  102e5f:	00 
  102e60:	c7 04 24 8b 65 10 00 	movl   $0x10658b,(%esp)
  102e67:	e8 ac dd ff ff       	call   100c18 <__panic>
    assert((p2 = alloc_page()) != NULL);
  102e6c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  102e73:	e8 69 0e 00 00       	call   103ce1 <alloc_pages>
  102e78:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102e7b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  102e7f:	75 24                	jne    102ea5 <basic_check+0xc4>
  102e81:	c7 44 24 0c 11 66 10 	movl   $0x106611,0xc(%esp)
  102e88:	00 
  102e89:	c7 44 24 08 76 65 10 	movl   $0x106576,0x8(%esp)
  102e90:	00 
  102e91:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
  102e98:	00 
  102e99:	c7 04 24 8b 65 10 00 	movl   $0x10658b,(%esp)
  102ea0:	e8 73 dd ff ff       	call   100c18 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
  102ea5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102ea8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  102eab:	74 10                	je     102ebd <basic_check+0xdc>
  102ead:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102eb0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102eb3:	74 08                	je     102ebd <basic_check+0xdc>
  102eb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102eb8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102ebb:	75 24                	jne    102ee1 <basic_check+0x100>
  102ebd:	c7 44 24 0c 30 66 10 	movl   $0x106630,0xc(%esp)
  102ec4:	00 
  102ec5:	c7 44 24 08 76 65 10 	movl   $0x106576,0x8(%esp)
  102ecc:	00 
  102ecd:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
  102ed4:	00 
  102ed5:	c7 04 24 8b 65 10 00 	movl   $0x10658b,(%esp)
  102edc:	e8 37 dd ff ff       	call   100c18 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
  102ee1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102ee4:	89 04 24             	mov    %eax,(%esp)
  102ee7:	e8 81 f7 ff ff       	call   10266d <page_ref>
  102eec:	85 c0                	test   %eax,%eax
  102eee:	75 1e                	jne    102f0e <basic_check+0x12d>
  102ef0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102ef3:	89 04 24             	mov    %eax,(%esp)
  102ef6:	e8 72 f7 ff ff       	call   10266d <page_ref>
  102efb:	85 c0                	test   %eax,%eax
  102efd:	75 0f                	jne    102f0e <basic_check+0x12d>
  102eff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102f02:	89 04 24             	mov    %eax,(%esp)
  102f05:	e8 63 f7 ff ff       	call   10266d <page_ref>
  102f0a:	85 c0                	test   %eax,%eax
  102f0c:	74 24                	je     102f32 <basic_check+0x151>
  102f0e:	c7 44 24 0c 54 66 10 	movl   $0x106654,0xc(%esp)
  102f15:	00 
  102f16:	c7 44 24 08 76 65 10 	movl   $0x106576,0x8(%esp)
  102f1d:	00 
  102f1e:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
  102f25:	00 
  102f26:	c7 04 24 8b 65 10 00 	movl   $0x10658b,(%esp)
  102f2d:	e8 e6 dc ff ff       	call   100c18 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
  102f32:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102f35:	89 04 24             	mov    %eax,(%esp)
  102f38:	e8 1a f7 ff ff       	call   102657 <page2pa>
  102f3d:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  102f43:	c1 e2 0c             	shl    $0xc,%edx
  102f46:	39 d0                	cmp    %edx,%eax
  102f48:	72 24                	jb     102f6e <basic_check+0x18d>
  102f4a:	c7 44 24 0c 90 66 10 	movl   $0x106690,0xc(%esp)
  102f51:	00 
  102f52:	c7 44 24 08 76 65 10 	movl   $0x106576,0x8(%esp)
  102f59:	00 
  102f5a:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
  102f61:	00 
  102f62:	c7 04 24 8b 65 10 00 	movl   $0x10658b,(%esp)
  102f69:	e8 aa dc ff ff       	call   100c18 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
  102f6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102f71:	89 04 24             	mov    %eax,(%esp)
  102f74:	e8 de f6 ff ff       	call   102657 <page2pa>
  102f79:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  102f7f:	c1 e2 0c             	shl    $0xc,%edx
  102f82:	39 d0                	cmp    %edx,%eax
  102f84:	72 24                	jb     102faa <basic_check+0x1c9>
  102f86:	c7 44 24 0c ad 66 10 	movl   $0x1066ad,0xc(%esp)
  102f8d:	00 
  102f8e:	c7 44 24 08 76 65 10 	movl   $0x106576,0x8(%esp)
  102f95:	00 
  102f96:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
  102f9d:	00 
  102f9e:	c7 04 24 8b 65 10 00 	movl   $0x10658b,(%esp)
  102fa5:	e8 6e dc ff ff       	call   100c18 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
  102faa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102fad:	89 04 24             	mov    %eax,(%esp)
  102fb0:	e8 a2 f6 ff ff       	call   102657 <page2pa>
  102fb5:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  102fbb:	c1 e2 0c             	shl    $0xc,%edx
  102fbe:	39 d0                	cmp    %edx,%eax
  102fc0:	72 24                	jb     102fe6 <basic_check+0x205>
  102fc2:	c7 44 24 0c ca 66 10 	movl   $0x1066ca,0xc(%esp)
  102fc9:	00 
  102fca:	c7 44 24 08 76 65 10 	movl   $0x106576,0x8(%esp)
  102fd1:	00 
  102fd2:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
  102fd9:	00 
  102fda:	c7 04 24 8b 65 10 00 	movl   $0x10658b,(%esp)
  102fe1:	e8 32 dc ff ff       	call   100c18 <__panic>

    list_entry_t free_list_store = free_list;
  102fe6:	a1 10 af 11 00       	mov    0x11af10,%eax
  102feb:	8b 15 14 af 11 00    	mov    0x11af14,%edx
  102ff1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102ff4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  102ff7:	c7 45 e0 10 af 11 00 	movl   $0x11af10,-0x20(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  102ffe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103001:	8b 55 e0             	mov    -0x20(%ebp),%edx
  103004:	89 50 04             	mov    %edx,0x4(%eax)
  103007:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10300a:	8b 50 04             	mov    0x4(%eax),%edx
  10300d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103010:	89 10                	mov    %edx,(%eax)
  103012:	c7 45 dc 10 af 11 00 	movl   $0x11af10,-0x24(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
  103019:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10301c:	8b 40 04             	mov    0x4(%eax),%eax
  10301f:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  103022:	0f 94 c0             	sete   %al
  103025:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  103028:	85 c0                	test   %eax,%eax
  10302a:	75 24                	jne    103050 <basic_check+0x26f>
  10302c:	c7 44 24 0c e7 66 10 	movl   $0x1066e7,0xc(%esp)
  103033:	00 
  103034:	c7 44 24 08 76 65 10 	movl   $0x106576,0x8(%esp)
  10303b:	00 
  10303c:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
  103043:	00 
  103044:	c7 04 24 8b 65 10 00 	movl   $0x10658b,(%esp)
  10304b:	e8 c8 db ff ff       	call   100c18 <__panic>

    unsigned int nr_free_store = nr_free;
  103050:	a1 18 af 11 00       	mov    0x11af18,%eax
  103055:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
  103058:	c7 05 18 af 11 00 00 	movl   $0x0,0x11af18
  10305f:	00 00 00 

    assert(alloc_page() == NULL);
  103062:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103069:	e8 73 0c 00 00       	call   103ce1 <alloc_pages>
  10306e:	85 c0                	test   %eax,%eax
  103070:	74 24                	je     103096 <basic_check+0x2b5>
  103072:	c7 44 24 0c fe 66 10 	movl   $0x1066fe,0xc(%esp)
  103079:	00 
  10307a:	c7 44 24 08 76 65 10 	movl   $0x106576,0x8(%esp)
  103081:	00 
  103082:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
  103089:	00 
  10308a:	c7 04 24 8b 65 10 00 	movl   $0x10658b,(%esp)
  103091:	e8 82 db ff ff       	call   100c18 <__panic>

    free_page(p0);
  103096:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10309d:	00 
  10309e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1030a1:	89 04 24             	mov    %eax,(%esp)
  1030a4:	e8 70 0c 00 00       	call   103d19 <free_pages>
    free_page(p1);
  1030a9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1030b0:	00 
  1030b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1030b4:	89 04 24             	mov    %eax,(%esp)
  1030b7:	e8 5d 0c 00 00       	call   103d19 <free_pages>
    free_page(p2);
  1030bc:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1030c3:	00 
  1030c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1030c7:	89 04 24             	mov    %eax,(%esp)
  1030ca:	e8 4a 0c 00 00       	call   103d19 <free_pages>
    assert(nr_free == 3);
  1030cf:	a1 18 af 11 00       	mov    0x11af18,%eax
  1030d4:	83 f8 03             	cmp    $0x3,%eax
  1030d7:	74 24                	je     1030fd <basic_check+0x31c>
  1030d9:	c7 44 24 0c 13 67 10 	movl   $0x106713,0xc(%esp)
  1030e0:	00 
  1030e1:	c7 44 24 08 76 65 10 	movl   $0x106576,0x8(%esp)
  1030e8:	00 
  1030e9:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
  1030f0:	00 
  1030f1:	c7 04 24 8b 65 10 00 	movl   $0x10658b,(%esp)
  1030f8:	e8 1b db ff ff       	call   100c18 <__panic>

    assert((p0 = alloc_page()) != NULL);
  1030fd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103104:	e8 d8 0b 00 00       	call   103ce1 <alloc_pages>
  103109:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10310c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  103110:	75 24                	jne    103136 <basic_check+0x355>
  103112:	c7 44 24 0c d9 65 10 	movl   $0x1065d9,0xc(%esp)
  103119:	00 
  10311a:	c7 44 24 08 76 65 10 	movl   $0x106576,0x8(%esp)
  103121:	00 
  103122:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
  103129:	00 
  10312a:	c7 04 24 8b 65 10 00 	movl   $0x10658b,(%esp)
  103131:	e8 e2 da ff ff       	call   100c18 <__panic>
    assert((p1 = alloc_page()) != NULL);
  103136:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10313d:	e8 9f 0b 00 00       	call   103ce1 <alloc_pages>
  103142:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103145:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103149:	75 24                	jne    10316f <basic_check+0x38e>
  10314b:	c7 44 24 0c f5 65 10 	movl   $0x1065f5,0xc(%esp)
  103152:	00 
  103153:	c7 44 24 08 76 65 10 	movl   $0x106576,0x8(%esp)
  10315a:	00 
  10315b:	c7 44 24 04 eb 00 00 	movl   $0xeb,0x4(%esp)
  103162:	00 
  103163:	c7 04 24 8b 65 10 00 	movl   $0x10658b,(%esp)
  10316a:	e8 a9 da ff ff       	call   100c18 <__panic>
    assert((p2 = alloc_page()) != NULL);
  10316f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103176:	e8 66 0b 00 00       	call   103ce1 <alloc_pages>
  10317b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10317e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103182:	75 24                	jne    1031a8 <basic_check+0x3c7>
  103184:	c7 44 24 0c 11 66 10 	movl   $0x106611,0xc(%esp)
  10318b:	00 
  10318c:	c7 44 24 08 76 65 10 	movl   $0x106576,0x8(%esp)
  103193:	00 
  103194:	c7 44 24 04 ec 00 00 	movl   $0xec,0x4(%esp)
  10319b:	00 
  10319c:	c7 04 24 8b 65 10 00 	movl   $0x10658b,(%esp)
  1031a3:	e8 70 da ff ff       	call   100c18 <__panic>

    assert(alloc_page() == NULL);
  1031a8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1031af:	e8 2d 0b 00 00       	call   103ce1 <alloc_pages>
  1031b4:	85 c0                	test   %eax,%eax
  1031b6:	74 24                	je     1031dc <basic_check+0x3fb>
  1031b8:	c7 44 24 0c fe 66 10 	movl   $0x1066fe,0xc(%esp)
  1031bf:	00 
  1031c0:	c7 44 24 08 76 65 10 	movl   $0x106576,0x8(%esp)
  1031c7:	00 
  1031c8:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
  1031cf:	00 
  1031d0:	c7 04 24 8b 65 10 00 	movl   $0x10658b,(%esp)
  1031d7:	e8 3c da ff ff       	call   100c18 <__panic>

    free_page(p0);
  1031dc:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1031e3:	00 
  1031e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1031e7:	89 04 24             	mov    %eax,(%esp)
  1031ea:	e8 2a 0b 00 00       	call   103d19 <free_pages>
  1031ef:	c7 45 d8 10 af 11 00 	movl   $0x11af10,-0x28(%ebp)
  1031f6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1031f9:	8b 40 04             	mov    0x4(%eax),%eax
  1031fc:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  1031ff:	0f 94 c0             	sete   %al
  103202:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
  103205:	85 c0                	test   %eax,%eax
  103207:	74 24                	je     10322d <basic_check+0x44c>
  103209:	c7 44 24 0c 20 67 10 	movl   $0x106720,0xc(%esp)
  103210:	00 
  103211:	c7 44 24 08 76 65 10 	movl   $0x106576,0x8(%esp)
  103218:	00 
  103219:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
  103220:	00 
  103221:	c7 04 24 8b 65 10 00 	movl   $0x10658b,(%esp)
  103228:	e8 eb d9 ff ff       	call   100c18 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
  10322d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103234:	e8 a8 0a 00 00       	call   103ce1 <alloc_pages>
  103239:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10323c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10323f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  103242:	74 24                	je     103268 <basic_check+0x487>
  103244:	c7 44 24 0c 38 67 10 	movl   $0x106738,0xc(%esp)
  10324b:	00 
  10324c:	c7 44 24 08 76 65 10 	movl   $0x106576,0x8(%esp)
  103253:	00 
  103254:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
  10325b:	00 
  10325c:	c7 04 24 8b 65 10 00 	movl   $0x10658b,(%esp)
  103263:	e8 b0 d9 ff ff       	call   100c18 <__panic>
    assert(alloc_page() == NULL);
  103268:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10326f:	e8 6d 0a 00 00       	call   103ce1 <alloc_pages>
  103274:	85 c0                	test   %eax,%eax
  103276:	74 24                	je     10329c <basic_check+0x4bb>
  103278:	c7 44 24 0c fe 66 10 	movl   $0x1066fe,0xc(%esp)
  10327f:	00 
  103280:	c7 44 24 08 76 65 10 	movl   $0x106576,0x8(%esp)
  103287:	00 
  103288:	c7 44 24 04 f5 00 00 	movl   $0xf5,0x4(%esp)
  10328f:	00 
  103290:	c7 04 24 8b 65 10 00 	movl   $0x10658b,(%esp)
  103297:	e8 7c d9 ff ff       	call   100c18 <__panic>

    assert(nr_free == 0);
  10329c:	a1 18 af 11 00       	mov    0x11af18,%eax
  1032a1:	85 c0                	test   %eax,%eax
  1032a3:	74 24                	je     1032c9 <basic_check+0x4e8>
  1032a5:	c7 44 24 0c 51 67 10 	movl   $0x106751,0xc(%esp)
  1032ac:	00 
  1032ad:	c7 44 24 08 76 65 10 	movl   $0x106576,0x8(%esp)
  1032b4:	00 
  1032b5:	c7 44 24 04 f7 00 00 	movl   $0xf7,0x4(%esp)
  1032bc:	00 
  1032bd:	c7 04 24 8b 65 10 00 	movl   $0x10658b,(%esp)
  1032c4:	e8 4f d9 ff ff       	call   100c18 <__panic>
    free_list = free_list_store;
  1032c9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1032cc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1032cf:	a3 10 af 11 00       	mov    %eax,0x11af10
  1032d4:	89 15 14 af 11 00    	mov    %edx,0x11af14
    nr_free = nr_free_store;
  1032da:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1032dd:	a3 18 af 11 00       	mov    %eax,0x11af18

    free_page(p);
  1032e2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1032e9:	00 
  1032ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1032ed:	89 04 24             	mov    %eax,(%esp)
  1032f0:	e8 24 0a 00 00       	call   103d19 <free_pages>
    free_page(p1);
  1032f5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1032fc:	00 
  1032fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103300:	89 04 24             	mov    %eax,(%esp)
  103303:	e8 11 0a 00 00       	call   103d19 <free_pages>
    free_page(p2);
  103308:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10330f:	00 
  103310:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103313:	89 04 24             	mov    %eax,(%esp)
  103316:	e8 fe 09 00 00       	call   103d19 <free_pages>
}
  10331b:	c9                   	leave  
  10331c:	c3                   	ret    

0010331d <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
  10331d:	55                   	push   %ebp
  10331e:	89 e5                	mov    %esp,%ebp
  103320:	53                   	push   %ebx
  103321:	81 ec 94 00 00 00    	sub    $0x94,%esp
    int count = 0, total = 0;
  103327:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  10332e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
  103335:	c7 45 ec 10 af 11 00 	movl   $0x11af10,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  10333c:	eb 6b                	jmp    1033a9 <default_check+0x8c>
        struct Page *p = le2page(le, page_link);
  10333e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103341:	83 e8 0c             	sub    $0xc,%eax
  103344:	89 45 e8             	mov    %eax,-0x18(%ebp)
        assert(PageProperty(p));
  103347:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10334a:	83 c0 04             	add    $0x4,%eax
  10334d:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  103354:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  103357:	8b 45 cc             	mov    -0x34(%ebp),%eax
  10335a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  10335d:	0f a3 10             	bt     %edx,(%eax)
  103360:	19 c0                	sbb    %eax,%eax
  103362:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
  103365:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  103369:	0f 95 c0             	setne  %al
  10336c:	0f b6 c0             	movzbl %al,%eax
  10336f:	85 c0                	test   %eax,%eax
  103371:	75 24                	jne    103397 <default_check+0x7a>
  103373:	c7 44 24 0c 5e 67 10 	movl   $0x10675e,0xc(%esp)
  10337a:	00 
  10337b:	c7 44 24 08 76 65 10 	movl   $0x106576,0x8(%esp)
  103382:	00 
  103383:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
  10338a:	00 
  10338b:	c7 04 24 8b 65 10 00 	movl   $0x10658b,(%esp)
  103392:	e8 81 d8 ff ff       	call   100c18 <__panic>
        count ++, total += p->property;
  103397:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  10339b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10339e:	8b 50 08             	mov    0x8(%eax),%edx
  1033a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1033a4:	01 d0                	add    %edx,%eax
  1033a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1033a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1033ac:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  1033af:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1033b2:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
  1033b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1033b8:	81 7d ec 10 af 11 00 	cmpl   $0x11af10,-0x14(%ebp)
  1033bf:	0f 85 79 ff ff ff    	jne    10333e <default_check+0x21>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
  1033c5:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  1033c8:	e8 7e 09 00 00       	call   103d4b <nr_free_pages>
  1033cd:	39 c3                	cmp    %eax,%ebx
  1033cf:	74 24                	je     1033f5 <default_check+0xd8>
  1033d1:	c7 44 24 0c 6e 67 10 	movl   $0x10676e,0xc(%esp)
  1033d8:	00 
  1033d9:	c7 44 24 08 76 65 10 	movl   $0x106576,0x8(%esp)
  1033e0:	00 
  1033e1:	c7 44 24 04 0b 01 00 	movl   $0x10b,0x4(%esp)
  1033e8:	00 
  1033e9:	c7 04 24 8b 65 10 00 	movl   $0x10658b,(%esp)
  1033f0:	e8 23 d8 ff ff       	call   100c18 <__panic>

    basic_check();
  1033f5:	e8 e7 f9 ff ff       	call   102de1 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
  1033fa:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  103401:	e8 db 08 00 00       	call   103ce1 <alloc_pages>
  103406:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(p0 != NULL);
  103409:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10340d:	75 24                	jne    103433 <default_check+0x116>
  10340f:	c7 44 24 0c 87 67 10 	movl   $0x106787,0xc(%esp)
  103416:	00 
  103417:	c7 44 24 08 76 65 10 	movl   $0x106576,0x8(%esp)
  10341e:	00 
  10341f:	c7 44 24 04 10 01 00 	movl   $0x110,0x4(%esp)
  103426:	00 
  103427:	c7 04 24 8b 65 10 00 	movl   $0x10658b,(%esp)
  10342e:	e8 e5 d7 ff ff       	call   100c18 <__panic>
    assert(!PageProperty(p0));
  103433:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103436:	83 c0 04             	add    $0x4,%eax
  103439:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  103440:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  103443:	8b 45 bc             	mov    -0x44(%ebp),%eax
  103446:	8b 55 c0             	mov    -0x40(%ebp),%edx
  103449:	0f a3 10             	bt     %edx,(%eax)
  10344c:	19 c0                	sbb    %eax,%eax
  10344e:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
  103451:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
  103455:	0f 95 c0             	setne  %al
  103458:	0f b6 c0             	movzbl %al,%eax
  10345b:	85 c0                	test   %eax,%eax
  10345d:	74 24                	je     103483 <default_check+0x166>
  10345f:	c7 44 24 0c 92 67 10 	movl   $0x106792,0xc(%esp)
  103466:	00 
  103467:	c7 44 24 08 76 65 10 	movl   $0x106576,0x8(%esp)
  10346e:	00 
  10346f:	c7 44 24 04 11 01 00 	movl   $0x111,0x4(%esp)
  103476:	00 
  103477:	c7 04 24 8b 65 10 00 	movl   $0x10658b,(%esp)
  10347e:	e8 95 d7 ff ff       	call   100c18 <__panic>

    list_entry_t free_list_store = free_list;
  103483:	a1 10 af 11 00       	mov    0x11af10,%eax
  103488:	8b 15 14 af 11 00    	mov    0x11af14,%edx
  10348e:	89 45 80             	mov    %eax,-0x80(%ebp)
  103491:	89 55 84             	mov    %edx,-0x7c(%ebp)
  103494:	c7 45 b4 10 af 11 00 	movl   $0x11af10,-0x4c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  10349b:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  10349e:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  1034a1:	89 50 04             	mov    %edx,0x4(%eax)
  1034a4:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1034a7:	8b 50 04             	mov    0x4(%eax),%edx
  1034aa:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1034ad:	89 10                	mov    %edx,(%eax)
  1034af:	c7 45 b0 10 af 11 00 	movl   $0x11af10,-0x50(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
  1034b6:	8b 45 b0             	mov    -0x50(%ebp),%eax
  1034b9:	8b 40 04             	mov    0x4(%eax),%eax
  1034bc:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  1034bf:	0f 94 c0             	sete   %al
  1034c2:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  1034c5:	85 c0                	test   %eax,%eax
  1034c7:	75 24                	jne    1034ed <default_check+0x1d0>
  1034c9:	c7 44 24 0c e7 66 10 	movl   $0x1066e7,0xc(%esp)
  1034d0:	00 
  1034d1:	c7 44 24 08 76 65 10 	movl   $0x106576,0x8(%esp)
  1034d8:	00 
  1034d9:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
  1034e0:	00 
  1034e1:	c7 04 24 8b 65 10 00 	movl   $0x10658b,(%esp)
  1034e8:	e8 2b d7 ff ff       	call   100c18 <__panic>
    assert(alloc_page() == NULL);
  1034ed:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1034f4:	e8 e8 07 00 00       	call   103ce1 <alloc_pages>
  1034f9:	85 c0                	test   %eax,%eax
  1034fb:	74 24                	je     103521 <default_check+0x204>
  1034fd:	c7 44 24 0c fe 66 10 	movl   $0x1066fe,0xc(%esp)
  103504:	00 
  103505:	c7 44 24 08 76 65 10 	movl   $0x106576,0x8(%esp)
  10350c:	00 
  10350d:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
  103514:	00 
  103515:	c7 04 24 8b 65 10 00 	movl   $0x10658b,(%esp)
  10351c:	e8 f7 d6 ff ff       	call   100c18 <__panic>

    unsigned int nr_free_store = nr_free;
  103521:	a1 18 af 11 00       	mov    0x11af18,%eax
  103526:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
  103529:	c7 05 18 af 11 00 00 	movl   $0x0,0x11af18
  103530:	00 00 00 

    free_pages(p0 + 2, 3);
  103533:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103536:	83 c0 28             	add    $0x28,%eax
  103539:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  103540:	00 
  103541:	89 04 24             	mov    %eax,(%esp)
  103544:	e8 d0 07 00 00       	call   103d19 <free_pages>
    assert(alloc_pages(4) == NULL);
  103549:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  103550:	e8 8c 07 00 00       	call   103ce1 <alloc_pages>
  103555:	85 c0                	test   %eax,%eax
  103557:	74 24                	je     10357d <default_check+0x260>
  103559:	c7 44 24 0c a4 67 10 	movl   $0x1067a4,0xc(%esp)
  103560:	00 
  103561:	c7 44 24 08 76 65 10 	movl   $0x106576,0x8(%esp)
  103568:	00 
  103569:	c7 44 24 04 1c 01 00 	movl   $0x11c,0x4(%esp)
  103570:	00 
  103571:	c7 04 24 8b 65 10 00 	movl   $0x10658b,(%esp)
  103578:	e8 9b d6 ff ff       	call   100c18 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
  10357d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103580:	83 c0 28             	add    $0x28,%eax
  103583:	83 c0 04             	add    $0x4,%eax
  103586:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
  10358d:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  103590:	8b 45 a8             	mov    -0x58(%ebp),%eax
  103593:	8b 55 ac             	mov    -0x54(%ebp),%edx
  103596:	0f a3 10             	bt     %edx,(%eax)
  103599:	19 c0                	sbb    %eax,%eax
  10359b:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
  10359e:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  1035a2:	0f 95 c0             	setne  %al
  1035a5:	0f b6 c0             	movzbl %al,%eax
  1035a8:	85 c0                	test   %eax,%eax
  1035aa:	74 0e                	je     1035ba <default_check+0x29d>
  1035ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1035af:	83 c0 28             	add    $0x28,%eax
  1035b2:	8b 40 08             	mov    0x8(%eax),%eax
  1035b5:	83 f8 03             	cmp    $0x3,%eax
  1035b8:	74 24                	je     1035de <default_check+0x2c1>
  1035ba:	c7 44 24 0c bc 67 10 	movl   $0x1067bc,0xc(%esp)
  1035c1:	00 
  1035c2:	c7 44 24 08 76 65 10 	movl   $0x106576,0x8(%esp)
  1035c9:	00 
  1035ca:	c7 44 24 04 1d 01 00 	movl   $0x11d,0x4(%esp)
  1035d1:	00 
  1035d2:	c7 04 24 8b 65 10 00 	movl   $0x10658b,(%esp)
  1035d9:	e8 3a d6 ff ff       	call   100c18 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
  1035de:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  1035e5:	e8 f7 06 00 00       	call   103ce1 <alloc_pages>
  1035ea:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1035ed:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  1035f1:	75 24                	jne    103617 <default_check+0x2fa>
  1035f3:	c7 44 24 0c e8 67 10 	movl   $0x1067e8,0xc(%esp)
  1035fa:	00 
  1035fb:	c7 44 24 08 76 65 10 	movl   $0x106576,0x8(%esp)
  103602:	00 
  103603:	c7 44 24 04 1e 01 00 	movl   $0x11e,0x4(%esp)
  10360a:	00 
  10360b:	c7 04 24 8b 65 10 00 	movl   $0x10658b,(%esp)
  103612:	e8 01 d6 ff ff       	call   100c18 <__panic>
    assert(alloc_page() == NULL);
  103617:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10361e:	e8 be 06 00 00       	call   103ce1 <alloc_pages>
  103623:	85 c0                	test   %eax,%eax
  103625:	74 24                	je     10364b <default_check+0x32e>
  103627:	c7 44 24 0c fe 66 10 	movl   $0x1066fe,0xc(%esp)
  10362e:	00 
  10362f:	c7 44 24 08 76 65 10 	movl   $0x106576,0x8(%esp)
  103636:	00 
  103637:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
  10363e:	00 
  10363f:	c7 04 24 8b 65 10 00 	movl   $0x10658b,(%esp)
  103646:	e8 cd d5 ff ff       	call   100c18 <__panic>
    assert(p0 + 2 == p1);
  10364b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10364e:	83 c0 28             	add    $0x28,%eax
  103651:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  103654:	74 24                	je     10367a <default_check+0x35d>
  103656:	c7 44 24 0c 06 68 10 	movl   $0x106806,0xc(%esp)
  10365d:	00 
  10365e:	c7 44 24 08 76 65 10 	movl   $0x106576,0x8(%esp)
  103665:	00 
  103666:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
  10366d:	00 
  10366e:	c7 04 24 8b 65 10 00 	movl   $0x10658b,(%esp)
  103675:	e8 9e d5 ff ff       	call   100c18 <__panic>

    p2 = p0 + 1;
  10367a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10367d:	83 c0 14             	add    $0x14,%eax
  103680:	89 45 d8             	mov    %eax,-0x28(%ebp)
    free_page(p0);
  103683:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10368a:	00 
  10368b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10368e:	89 04 24             	mov    %eax,(%esp)
  103691:	e8 83 06 00 00       	call   103d19 <free_pages>
    free_pages(p1, 3);
  103696:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  10369d:	00 
  10369e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1036a1:	89 04 24             	mov    %eax,(%esp)
  1036a4:	e8 70 06 00 00       	call   103d19 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
  1036a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1036ac:	83 c0 04             	add    $0x4,%eax
  1036af:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
  1036b6:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1036b9:	8b 45 9c             	mov    -0x64(%ebp),%eax
  1036bc:	8b 55 a0             	mov    -0x60(%ebp),%edx
  1036bf:	0f a3 10             	bt     %edx,(%eax)
  1036c2:	19 c0                	sbb    %eax,%eax
  1036c4:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
  1036c7:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
  1036cb:	0f 95 c0             	setne  %al
  1036ce:	0f b6 c0             	movzbl %al,%eax
  1036d1:	85 c0                	test   %eax,%eax
  1036d3:	74 0b                	je     1036e0 <default_check+0x3c3>
  1036d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1036d8:	8b 40 08             	mov    0x8(%eax),%eax
  1036db:	83 f8 01             	cmp    $0x1,%eax
  1036de:	74 24                	je     103704 <default_check+0x3e7>
  1036e0:	c7 44 24 0c 14 68 10 	movl   $0x106814,0xc(%esp)
  1036e7:	00 
  1036e8:	c7 44 24 08 76 65 10 	movl   $0x106576,0x8(%esp)
  1036ef:	00 
  1036f0:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
  1036f7:	00 
  1036f8:	c7 04 24 8b 65 10 00 	movl   $0x10658b,(%esp)
  1036ff:	e8 14 d5 ff ff       	call   100c18 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
  103704:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103707:	83 c0 04             	add    $0x4,%eax
  10370a:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
  103711:	89 45 90             	mov    %eax,-0x70(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  103714:	8b 45 90             	mov    -0x70(%ebp),%eax
  103717:	8b 55 94             	mov    -0x6c(%ebp),%edx
  10371a:	0f a3 10             	bt     %edx,(%eax)
  10371d:	19 c0                	sbb    %eax,%eax
  10371f:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
  103722:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
  103726:	0f 95 c0             	setne  %al
  103729:	0f b6 c0             	movzbl %al,%eax
  10372c:	85 c0                	test   %eax,%eax
  10372e:	74 0b                	je     10373b <default_check+0x41e>
  103730:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103733:	8b 40 08             	mov    0x8(%eax),%eax
  103736:	83 f8 03             	cmp    $0x3,%eax
  103739:	74 24                	je     10375f <default_check+0x442>
  10373b:	c7 44 24 0c 3c 68 10 	movl   $0x10683c,0xc(%esp)
  103742:	00 
  103743:	c7 44 24 08 76 65 10 	movl   $0x106576,0x8(%esp)
  10374a:	00 
  10374b:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
  103752:	00 
  103753:	c7 04 24 8b 65 10 00 	movl   $0x10658b,(%esp)
  10375a:	e8 b9 d4 ff ff       	call   100c18 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
  10375f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103766:	e8 76 05 00 00       	call   103ce1 <alloc_pages>
  10376b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10376e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103771:	83 e8 14             	sub    $0x14,%eax
  103774:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  103777:	74 24                	je     10379d <default_check+0x480>
  103779:	c7 44 24 0c 62 68 10 	movl   $0x106862,0xc(%esp)
  103780:	00 
  103781:	c7 44 24 08 76 65 10 	movl   $0x106576,0x8(%esp)
  103788:	00 
  103789:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
  103790:	00 
  103791:	c7 04 24 8b 65 10 00 	movl   $0x10658b,(%esp)
  103798:	e8 7b d4 ff ff       	call   100c18 <__panic>
    free_page(p0);
  10379d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1037a4:	00 
  1037a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1037a8:	89 04 24             	mov    %eax,(%esp)
  1037ab:	e8 69 05 00 00       	call   103d19 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
  1037b0:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  1037b7:	e8 25 05 00 00       	call   103ce1 <alloc_pages>
  1037bc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1037bf:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1037c2:	83 c0 14             	add    $0x14,%eax
  1037c5:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  1037c8:	74 24                	je     1037ee <default_check+0x4d1>
  1037ca:	c7 44 24 0c 80 68 10 	movl   $0x106880,0xc(%esp)
  1037d1:	00 
  1037d2:	c7 44 24 08 76 65 10 	movl   $0x106576,0x8(%esp)
  1037d9:	00 
  1037da:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
  1037e1:	00 
  1037e2:	c7 04 24 8b 65 10 00 	movl   $0x10658b,(%esp)
  1037e9:	e8 2a d4 ff ff       	call   100c18 <__panic>

    free_pages(p0, 2);
  1037ee:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  1037f5:	00 
  1037f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1037f9:	89 04 24             	mov    %eax,(%esp)
  1037fc:	e8 18 05 00 00       	call   103d19 <free_pages>
    free_page(p2);
  103801:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103808:	00 
  103809:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10380c:	89 04 24             	mov    %eax,(%esp)
  10380f:	e8 05 05 00 00       	call   103d19 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
  103814:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  10381b:	e8 c1 04 00 00       	call   103ce1 <alloc_pages>
  103820:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103823:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  103827:	75 24                	jne    10384d <default_check+0x530>
  103829:	c7 44 24 0c a0 68 10 	movl   $0x1068a0,0xc(%esp)
  103830:	00 
  103831:	c7 44 24 08 76 65 10 	movl   $0x106576,0x8(%esp)
  103838:	00 
  103839:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
  103840:	00 
  103841:	c7 04 24 8b 65 10 00 	movl   $0x10658b,(%esp)
  103848:	e8 cb d3 ff ff       	call   100c18 <__panic>
    assert(alloc_page() == NULL);
  10384d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103854:	e8 88 04 00 00       	call   103ce1 <alloc_pages>
  103859:	85 c0                	test   %eax,%eax
  10385b:	74 24                	je     103881 <default_check+0x564>
  10385d:	c7 44 24 0c fe 66 10 	movl   $0x1066fe,0xc(%esp)
  103864:	00 
  103865:	c7 44 24 08 76 65 10 	movl   $0x106576,0x8(%esp)
  10386c:	00 
  10386d:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
  103874:	00 
  103875:	c7 04 24 8b 65 10 00 	movl   $0x10658b,(%esp)
  10387c:	e8 97 d3 ff ff       	call   100c18 <__panic>

    assert(nr_free == 0);
  103881:	a1 18 af 11 00       	mov    0x11af18,%eax
  103886:	85 c0                	test   %eax,%eax
  103888:	74 24                	je     1038ae <default_check+0x591>
  10388a:	c7 44 24 0c 51 67 10 	movl   $0x106751,0xc(%esp)
  103891:	00 
  103892:	c7 44 24 08 76 65 10 	movl   $0x106576,0x8(%esp)
  103899:	00 
  10389a:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
  1038a1:	00 
  1038a2:	c7 04 24 8b 65 10 00 	movl   $0x10658b,(%esp)
  1038a9:	e8 6a d3 ff ff       	call   100c18 <__panic>
    nr_free = nr_free_store;
  1038ae:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1038b1:	a3 18 af 11 00       	mov    %eax,0x11af18

    free_list = free_list_store;
  1038b6:	8b 45 80             	mov    -0x80(%ebp),%eax
  1038b9:	8b 55 84             	mov    -0x7c(%ebp),%edx
  1038bc:	a3 10 af 11 00       	mov    %eax,0x11af10
  1038c1:	89 15 14 af 11 00    	mov    %edx,0x11af14
    free_pages(p0, 5);
  1038c7:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  1038ce:	00 
  1038cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1038d2:	89 04 24             	mov    %eax,(%esp)
  1038d5:	e8 3f 04 00 00       	call   103d19 <free_pages>

    le = &free_list;
  1038da:	c7 45 ec 10 af 11 00 	movl   $0x11af10,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  1038e1:	eb 5b                	jmp    10393e <default_check+0x621>
        assert(le->next->prev == le && le->prev->next == le);
  1038e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1038e6:	8b 40 04             	mov    0x4(%eax),%eax
  1038e9:	8b 00                	mov    (%eax),%eax
  1038eb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  1038ee:	75 0d                	jne    1038fd <default_check+0x5e0>
  1038f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1038f3:	8b 00                	mov    (%eax),%eax
  1038f5:	8b 40 04             	mov    0x4(%eax),%eax
  1038f8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  1038fb:	74 24                	je     103921 <default_check+0x604>
  1038fd:	c7 44 24 0c c0 68 10 	movl   $0x1068c0,0xc(%esp)
  103904:	00 
  103905:	c7 44 24 08 76 65 10 	movl   $0x106576,0x8(%esp)
  10390c:	00 
  10390d:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
  103914:	00 
  103915:	c7 04 24 8b 65 10 00 	movl   $0x10658b,(%esp)
  10391c:	e8 f7 d2 ff ff       	call   100c18 <__panic>
        struct Page *p = le2page(le, page_link);
  103921:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103924:	83 e8 0c             	sub    $0xc,%eax
  103927:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        count --, total -= p->property;
  10392a:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  10392e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  103931:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  103934:	8b 40 08             	mov    0x8(%eax),%eax
  103937:	29 c2                	sub    %eax,%edx
  103939:	89 d0                	mov    %edx,%eax
  10393b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10393e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103941:	89 45 88             	mov    %eax,-0x78(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  103944:	8b 45 88             	mov    -0x78(%ebp),%eax
  103947:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
  10394a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10394d:	81 7d ec 10 af 11 00 	cmpl   $0x11af10,-0x14(%ebp)
  103954:	75 8d                	jne    1038e3 <default_check+0x5c6>
        assert(le->next->prev == le && le->prev->next == le);
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
  103956:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10395a:	74 24                	je     103980 <default_check+0x663>
  10395c:	c7 44 24 0c ed 68 10 	movl   $0x1068ed,0xc(%esp)
  103963:	00 
  103964:	c7 44 24 08 76 65 10 	movl   $0x106576,0x8(%esp)
  10396b:	00 
  10396c:	c7 44 24 04 3e 01 00 	movl   $0x13e,0x4(%esp)
  103973:	00 
  103974:	c7 04 24 8b 65 10 00 	movl   $0x10658b,(%esp)
  10397b:	e8 98 d2 ff ff       	call   100c18 <__panic>
    assert(total == 0);
  103980:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103984:	74 24                	je     1039aa <default_check+0x68d>
  103986:	c7 44 24 0c f8 68 10 	movl   $0x1068f8,0xc(%esp)
  10398d:	00 
  10398e:	c7 44 24 08 76 65 10 	movl   $0x106576,0x8(%esp)
  103995:	00 
  103996:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
  10399d:	00 
  10399e:	c7 04 24 8b 65 10 00 	movl   $0x10658b,(%esp)
  1039a5:	e8 6e d2 ff ff       	call   100c18 <__panic>
}
  1039aa:	81 c4 94 00 00 00    	add    $0x94,%esp
  1039b0:	5b                   	pop    %ebx
  1039b1:	5d                   	pop    %ebp
  1039b2:	c3                   	ret    

001039b3 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  1039b3:	55                   	push   %ebp
  1039b4:	89 e5                	mov    %esp,%ebp
    return page - pages;
  1039b6:	8b 55 08             	mov    0x8(%ebp),%edx
  1039b9:	a1 24 af 11 00       	mov    0x11af24,%eax
  1039be:	29 c2                	sub    %eax,%edx
  1039c0:	89 d0                	mov    %edx,%eax
  1039c2:	c1 f8 02             	sar    $0x2,%eax
  1039c5:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  1039cb:	5d                   	pop    %ebp
  1039cc:	c3                   	ret    

001039cd <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  1039cd:	55                   	push   %ebp
  1039ce:	89 e5                	mov    %esp,%ebp
  1039d0:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  1039d3:	8b 45 08             	mov    0x8(%ebp),%eax
  1039d6:	89 04 24             	mov    %eax,(%esp)
  1039d9:	e8 d5 ff ff ff       	call   1039b3 <page2ppn>
  1039de:	c1 e0 0c             	shl    $0xc,%eax
}
  1039e1:	c9                   	leave  
  1039e2:	c3                   	ret    

001039e3 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
  1039e3:	55                   	push   %ebp
  1039e4:	89 e5                	mov    %esp,%ebp
  1039e6:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
  1039e9:	8b 45 08             	mov    0x8(%ebp),%eax
  1039ec:	c1 e8 0c             	shr    $0xc,%eax
  1039ef:	89 c2                	mov    %eax,%edx
  1039f1:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  1039f6:	39 c2                	cmp    %eax,%edx
  1039f8:	72 1c                	jb     103a16 <pa2page+0x33>
        panic("pa2page called with invalid pa");
  1039fa:	c7 44 24 08 34 69 10 	movl   $0x106934,0x8(%esp)
  103a01:	00 
  103a02:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  103a09:	00 
  103a0a:	c7 04 24 53 69 10 00 	movl   $0x106953,(%esp)
  103a11:	e8 02 d2 ff ff       	call   100c18 <__panic>
    }
    return &pages[PPN(pa)];
  103a16:	8b 0d 24 af 11 00    	mov    0x11af24,%ecx
  103a1c:	8b 45 08             	mov    0x8(%ebp),%eax
  103a1f:	c1 e8 0c             	shr    $0xc,%eax
  103a22:	89 c2                	mov    %eax,%edx
  103a24:	89 d0                	mov    %edx,%eax
  103a26:	c1 e0 02             	shl    $0x2,%eax
  103a29:	01 d0                	add    %edx,%eax
  103a2b:	c1 e0 02             	shl    $0x2,%eax
  103a2e:	01 c8                	add    %ecx,%eax
}
  103a30:	c9                   	leave  
  103a31:	c3                   	ret    

00103a32 <page2kva>:

static inline void *
page2kva(struct Page *page) {
  103a32:	55                   	push   %ebp
  103a33:	89 e5                	mov    %esp,%ebp
  103a35:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
  103a38:	8b 45 08             	mov    0x8(%ebp),%eax
  103a3b:	89 04 24             	mov    %eax,(%esp)
  103a3e:	e8 8a ff ff ff       	call   1039cd <page2pa>
  103a43:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103a46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103a49:	c1 e8 0c             	shr    $0xc,%eax
  103a4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103a4f:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  103a54:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  103a57:	72 23                	jb     103a7c <page2kva+0x4a>
  103a59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103a5c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103a60:	c7 44 24 08 64 69 10 	movl   $0x106964,0x8(%esp)
  103a67:	00 
  103a68:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  103a6f:	00 
  103a70:	c7 04 24 53 69 10 00 	movl   $0x106953,(%esp)
  103a77:	e8 9c d1 ff ff       	call   100c18 <__panic>
  103a7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103a7f:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
  103a84:	c9                   	leave  
  103a85:	c3                   	ret    

00103a86 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
  103a86:	55                   	push   %ebp
  103a87:	89 e5                	mov    %esp,%ebp
  103a89:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
  103a8c:	8b 45 08             	mov    0x8(%ebp),%eax
  103a8f:	83 e0 01             	and    $0x1,%eax
  103a92:	85 c0                	test   %eax,%eax
  103a94:	75 1c                	jne    103ab2 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
  103a96:	c7 44 24 08 88 69 10 	movl   $0x106988,0x8(%esp)
  103a9d:	00 
  103a9e:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  103aa5:	00 
  103aa6:	c7 04 24 53 69 10 00 	movl   $0x106953,(%esp)
  103aad:	e8 66 d1 ff ff       	call   100c18 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
  103ab2:	8b 45 08             	mov    0x8(%ebp),%eax
  103ab5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103aba:	89 04 24             	mov    %eax,(%esp)
  103abd:	e8 21 ff ff ff       	call   1039e3 <pa2page>
}
  103ac2:	c9                   	leave  
  103ac3:	c3                   	ret    

00103ac4 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
  103ac4:	55                   	push   %ebp
  103ac5:	89 e5                	mov    %esp,%ebp
  103ac7:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
  103aca:	8b 45 08             	mov    0x8(%ebp),%eax
  103acd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103ad2:	89 04 24             	mov    %eax,(%esp)
  103ad5:	e8 09 ff ff ff       	call   1039e3 <pa2page>
}
  103ada:	c9                   	leave  
  103adb:	c3                   	ret    

00103adc <page_ref>:

static inline int
page_ref(struct Page *page) {
  103adc:	55                   	push   %ebp
  103add:	89 e5                	mov    %esp,%ebp
    return page->ref;
  103adf:	8b 45 08             	mov    0x8(%ebp),%eax
  103ae2:	8b 00                	mov    (%eax),%eax
}
  103ae4:	5d                   	pop    %ebp
  103ae5:	c3                   	ret    

00103ae6 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
  103ae6:	55                   	push   %ebp
  103ae7:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  103ae9:	8b 45 08             	mov    0x8(%ebp),%eax
  103aec:	8b 55 0c             	mov    0xc(%ebp),%edx
  103aef:	89 10                	mov    %edx,(%eax)
}
  103af1:	5d                   	pop    %ebp
  103af2:	c3                   	ret    

00103af3 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
  103af3:	55                   	push   %ebp
  103af4:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
  103af6:	8b 45 08             	mov    0x8(%ebp),%eax
  103af9:	8b 00                	mov    (%eax),%eax
  103afb:	8d 50 01             	lea    0x1(%eax),%edx
  103afe:	8b 45 08             	mov    0x8(%ebp),%eax
  103b01:	89 10                	mov    %edx,(%eax)
    return page->ref;
  103b03:	8b 45 08             	mov    0x8(%ebp),%eax
  103b06:	8b 00                	mov    (%eax),%eax
}
  103b08:	5d                   	pop    %ebp
  103b09:	c3                   	ret    

00103b0a <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
  103b0a:	55                   	push   %ebp
  103b0b:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
  103b0d:	8b 45 08             	mov    0x8(%ebp),%eax
  103b10:	8b 00                	mov    (%eax),%eax
  103b12:	8d 50 ff             	lea    -0x1(%eax),%edx
  103b15:	8b 45 08             	mov    0x8(%ebp),%eax
  103b18:	89 10                	mov    %edx,(%eax)
    return page->ref;
  103b1a:	8b 45 08             	mov    0x8(%ebp),%eax
  103b1d:	8b 00                	mov    (%eax),%eax
}
  103b1f:	5d                   	pop    %ebp
  103b20:	c3                   	ret    

00103b21 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
  103b21:	55                   	push   %ebp
  103b22:	89 e5                	mov    %esp,%ebp
  103b24:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  103b27:	9c                   	pushf  
  103b28:	58                   	pop    %eax
  103b29:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  103b2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  103b2f:	25 00 02 00 00       	and    $0x200,%eax
  103b34:	85 c0                	test   %eax,%eax
  103b36:	74 0c                	je     103b44 <__intr_save+0x23>
        intr_disable();
  103b38:	e8 cf da ff ff       	call   10160c <intr_disable>
        return 1;
  103b3d:	b8 01 00 00 00       	mov    $0x1,%eax
  103b42:	eb 05                	jmp    103b49 <__intr_save+0x28>
    }
    return 0;
  103b44:	b8 00 00 00 00       	mov    $0x0,%eax
}
  103b49:	c9                   	leave  
  103b4a:	c3                   	ret    

00103b4b <__intr_restore>:

static inline void
__intr_restore(bool flag) {
  103b4b:	55                   	push   %ebp
  103b4c:	89 e5                	mov    %esp,%ebp
  103b4e:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  103b51:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  103b55:	74 05                	je     103b5c <__intr_restore+0x11>
        intr_enable();
  103b57:	e8 aa da ff ff       	call   101606 <intr_enable>
    }
}
  103b5c:	c9                   	leave  
  103b5d:	c3                   	ret    

00103b5e <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  103b5e:	55                   	push   %ebp
  103b5f:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  103b61:	8b 45 08             	mov    0x8(%ebp),%eax
  103b64:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  103b67:	b8 23 00 00 00       	mov    $0x23,%eax
  103b6c:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  103b6e:	b8 23 00 00 00       	mov    $0x23,%eax
  103b73:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  103b75:	b8 10 00 00 00       	mov    $0x10,%eax
  103b7a:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  103b7c:	b8 10 00 00 00       	mov    $0x10,%eax
  103b81:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  103b83:	b8 10 00 00 00       	mov    $0x10,%eax
  103b88:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  103b8a:	ea 91 3b 10 00 08 00 	ljmp   $0x8,$0x103b91
}
  103b91:	5d                   	pop    %ebp
  103b92:	c3                   	ret    

00103b93 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
  103b93:	55                   	push   %ebp
  103b94:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
  103b96:	8b 45 08             	mov    0x8(%ebp),%eax
  103b99:	a3 a4 ae 11 00       	mov    %eax,0x11aea4
}
  103b9e:	5d                   	pop    %ebp
  103b9f:	c3                   	ret    

00103ba0 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  103ba0:	55                   	push   %ebp
  103ba1:	89 e5                	mov    %esp,%ebp
  103ba3:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
  103ba6:	b8 00 70 11 00       	mov    $0x117000,%eax
  103bab:	89 04 24             	mov    %eax,(%esp)
  103bae:	e8 e0 ff ff ff       	call   103b93 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
  103bb3:	66 c7 05 a8 ae 11 00 	movw   $0x10,0x11aea8
  103bba:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
  103bbc:	66 c7 05 28 7a 11 00 	movw   $0x68,0x117a28
  103bc3:	68 00 
  103bc5:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  103bca:	66 a3 2a 7a 11 00    	mov    %ax,0x117a2a
  103bd0:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  103bd5:	c1 e8 10             	shr    $0x10,%eax
  103bd8:	a2 2c 7a 11 00       	mov    %al,0x117a2c
  103bdd:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  103be4:	83 e0 f0             	and    $0xfffffff0,%eax
  103be7:	83 c8 09             	or     $0x9,%eax
  103bea:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  103bef:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  103bf6:	83 e0 ef             	and    $0xffffffef,%eax
  103bf9:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  103bfe:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  103c05:	83 e0 9f             	and    $0xffffff9f,%eax
  103c08:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  103c0d:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  103c14:	83 c8 80             	or     $0xffffff80,%eax
  103c17:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  103c1c:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  103c23:	83 e0 f0             	and    $0xfffffff0,%eax
  103c26:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  103c2b:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  103c32:	83 e0 ef             	and    $0xffffffef,%eax
  103c35:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  103c3a:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  103c41:	83 e0 df             	and    $0xffffffdf,%eax
  103c44:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  103c49:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  103c50:	83 c8 40             	or     $0x40,%eax
  103c53:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  103c58:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  103c5f:	83 e0 7f             	and    $0x7f,%eax
  103c62:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  103c67:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  103c6c:	c1 e8 18             	shr    $0x18,%eax
  103c6f:	a2 2f 7a 11 00       	mov    %al,0x117a2f

    // reload all segment registers
    lgdt(&gdt_pd);
  103c74:	c7 04 24 30 7a 11 00 	movl   $0x117a30,(%esp)
  103c7b:	e8 de fe ff ff       	call   103b5e <lgdt>
  103c80:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
  103c86:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  103c8a:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
  103c8d:	c9                   	leave  
  103c8e:	c3                   	ret    

00103c8f <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
  103c8f:	55                   	push   %ebp
  103c90:	89 e5                	mov    %esp,%ebp
  103c92:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
  103c95:	c7 05 1c af 11 00 18 	movl   $0x106918,0x11af1c
  103c9c:	69 10 00 
    cprintf("memory management: %s\n", pmm_manager->name);
  103c9f:	a1 1c af 11 00       	mov    0x11af1c,%eax
  103ca4:	8b 00                	mov    (%eax),%eax
  103ca6:	89 44 24 04          	mov    %eax,0x4(%esp)
  103caa:	c7 04 24 b4 69 10 00 	movl   $0x1069b4,(%esp)
  103cb1:	e8 92 c6 ff ff       	call   100348 <cprintf>
    pmm_manager->init();
  103cb6:	a1 1c af 11 00       	mov    0x11af1c,%eax
  103cbb:	8b 40 04             	mov    0x4(%eax),%eax
  103cbe:	ff d0                	call   *%eax
}
  103cc0:	c9                   	leave  
  103cc1:	c3                   	ret    

00103cc2 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
  103cc2:	55                   	push   %ebp
  103cc3:	89 e5                	mov    %esp,%ebp
  103cc5:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
  103cc8:	a1 1c af 11 00       	mov    0x11af1c,%eax
  103ccd:	8b 40 08             	mov    0x8(%eax),%eax
  103cd0:	8b 55 0c             	mov    0xc(%ebp),%edx
  103cd3:	89 54 24 04          	mov    %edx,0x4(%esp)
  103cd7:	8b 55 08             	mov    0x8(%ebp),%edx
  103cda:	89 14 24             	mov    %edx,(%esp)
  103cdd:	ff d0                	call   *%eax
}
  103cdf:	c9                   	leave  
  103ce0:	c3                   	ret    

00103ce1 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
  103ce1:	55                   	push   %ebp
  103ce2:	89 e5                	mov    %esp,%ebp
  103ce4:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
  103ce7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  103cee:	e8 2e fe ff ff       	call   103b21 <__intr_save>
  103cf3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
  103cf6:	a1 1c af 11 00       	mov    0x11af1c,%eax
  103cfb:	8b 40 0c             	mov    0xc(%eax),%eax
  103cfe:	8b 55 08             	mov    0x8(%ebp),%edx
  103d01:	89 14 24             	mov    %edx,(%esp)
  103d04:	ff d0                	call   *%eax
  103d06:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
  103d09:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103d0c:	89 04 24             	mov    %eax,(%esp)
  103d0f:	e8 37 fe ff ff       	call   103b4b <__intr_restore>
    return page;
  103d14:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  103d17:	c9                   	leave  
  103d18:	c3                   	ret    

00103d19 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
  103d19:	55                   	push   %ebp
  103d1a:	89 e5                	mov    %esp,%ebp
  103d1c:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  103d1f:	e8 fd fd ff ff       	call   103b21 <__intr_save>
  103d24:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
  103d27:	a1 1c af 11 00       	mov    0x11af1c,%eax
  103d2c:	8b 40 10             	mov    0x10(%eax),%eax
  103d2f:	8b 55 0c             	mov    0xc(%ebp),%edx
  103d32:	89 54 24 04          	mov    %edx,0x4(%esp)
  103d36:	8b 55 08             	mov    0x8(%ebp),%edx
  103d39:	89 14 24             	mov    %edx,(%esp)
  103d3c:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
  103d3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103d41:	89 04 24             	mov    %eax,(%esp)
  103d44:	e8 02 fe ff ff       	call   103b4b <__intr_restore>
}
  103d49:	c9                   	leave  
  103d4a:	c3                   	ret    

00103d4b <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
  103d4b:	55                   	push   %ebp
  103d4c:	89 e5                	mov    %esp,%ebp
  103d4e:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
  103d51:	e8 cb fd ff ff       	call   103b21 <__intr_save>
  103d56:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
  103d59:	a1 1c af 11 00       	mov    0x11af1c,%eax
  103d5e:	8b 40 14             	mov    0x14(%eax),%eax
  103d61:	ff d0                	call   *%eax
  103d63:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
  103d66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103d69:	89 04 24             	mov    %eax,(%esp)
  103d6c:	e8 da fd ff ff       	call   103b4b <__intr_restore>
    return ret;
  103d71:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  103d74:	c9                   	leave  
  103d75:	c3                   	ret    

00103d76 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
  103d76:	55                   	push   %ebp
  103d77:	89 e5                	mov    %esp,%ebp
  103d79:	57                   	push   %edi
  103d7a:	56                   	push   %esi
  103d7b:	53                   	push   %ebx
  103d7c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
  103d82:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
  103d89:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  103d90:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
  103d97:	c7 04 24 cb 69 10 00 	movl   $0x1069cb,(%esp)
  103d9e:	e8 a5 c5 ff ff       	call   100348 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  103da3:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  103daa:	e9 15 01 00 00       	jmp    103ec4 <page_init+0x14e>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  103daf:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103db2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103db5:	89 d0                	mov    %edx,%eax
  103db7:	c1 e0 02             	shl    $0x2,%eax
  103dba:	01 d0                	add    %edx,%eax
  103dbc:	c1 e0 02             	shl    $0x2,%eax
  103dbf:	01 c8                	add    %ecx,%eax
  103dc1:	8b 50 08             	mov    0x8(%eax),%edx
  103dc4:	8b 40 04             	mov    0x4(%eax),%eax
  103dc7:	89 45 b8             	mov    %eax,-0x48(%ebp)
  103dca:	89 55 bc             	mov    %edx,-0x44(%ebp)
  103dcd:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103dd0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103dd3:	89 d0                	mov    %edx,%eax
  103dd5:	c1 e0 02             	shl    $0x2,%eax
  103dd8:	01 d0                	add    %edx,%eax
  103dda:	c1 e0 02             	shl    $0x2,%eax
  103ddd:	01 c8                	add    %ecx,%eax
  103ddf:	8b 48 0c             	mov    0xc(%eax),%ecx
  103de2:	8b 58 10             	mov    0x10(%eax),%ebx
  103de5:	8b 45 b8             	mov    -0x48(%ebp),%eax
  103de8:	8b 55 bc             	mov    -0x44(%ebp),%edx
  103deb:	01 c8                	add    %ecx,%eax
  103ded:	11 da                	adc    %ebx,%edx
  103def:	89 45 b0             	mov    %eax,-0x50(%ebp)
  103df2:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
  103df5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103df8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103dfb:	89 d0                	mov    %edx,%eax
  103dfd:	c1 e0 02             	shl    $0x2,%eax
  103e00:	01 d0                	add    %edx,%eax
  103e02:	c1 e0 02             	shl    $0x2,%eax
  103e05:	01 c8                	add    %ecx,%eax
  103e07:	83 c0 14             	add    $0x14,%eax
  103e0a:	8b 00                	mov    (%eax),%eax
  103e0c:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
  103e12:	8b 45 b0             	mov    -0x50(%ebp),%eax
  103e15:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  103e18:	83 c0 ff             	add    $0xffffffff,%eax
  103e1b:	83 d2 ff             	adc    $0xffffffff,%edx
  103e1e:	89 c6                	mov    %eax,%esi
  103e20:	89 d7                	mov    %edx,%edi
  103e22:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103e25:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103e28:	89 d0                	mov    %edx,%eax
  103e2a:	c1 e0 02             	shl    $0x2,%eax
  103e2d:	01 d0                	add    %edx,%eax
  103e2f:	c1 e0 02             	shl    $0x2,%eax
  103e32:	01 c8                	add    %ecx,%eax
  103e34:	8b 48 0c             	mov    0xc(%eax),%ecx
  103e37:	8b 58 10             	mov    0x10(%eax),%ebx
  103e3a:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  103e40:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  103e44:	89 74 24 14          	mov    %esi,0x14(%esp)
  103e48:	89 7c 24 18          	mov    %edi,0x18(%esp)
  103e4c:	8b 45 b8             	mov    -0x48(%ebp),%eax
  103e4f:	8b 55 bc             	mov    -0x44(%ebp),%edx
  103e52:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103e56:	89 54 24 10          	mov    %edx,0x10(%esp)
  103e5a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  103e5e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  103e62:	c7 04 24 d8 69 10 00 	movl   $0x1069d8,(%esp)
  103e69:	e8 da c4 ff ff       	call   100348 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
  103e6e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103e71:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103e74:	89 d0                	mov    %edx,%eax
  103e76:	c1 e0 02             	shl    $0x2,%eax
  103e79:	01 d0                	add    %edx,%eax
  103e7b:	c1 e0 02             	shl    $0x2,%eax
  103e7e:	01 c8                	add    %ecx,%eax
  103e80:	83 c0 14             	add    $0x14,%eax
  103e83:	8b 00                	mov    (%eax),%eax
  103e85:	83 f8 01             	cmp    $0x1,%eax
  103e88:	75 36                	jne    103ec0 <page_init+0x14a>
            if (maxpa < end && begin < KMEMSIZE) {
  103e8a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103e8d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  103e90:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
  103e93:	77 2b                	ja     103ec0 <page_init+0x14a>
  103e95:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
  103e98:	72 05                	jb     103e9f <page_init+0x129>
  103e9a:	3b 45 b0             	cmp    -0x50(%ebp),%eax
  103e9d:	73 21                	jae    103ec0 <page_init+0x14a>
  103e9f:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
  103ea3:	77 1b                	ja     103ec0 <page_init+0x14a>
  103ea5:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
  103ea9:	72 09                	jb     103eb4 <page_init+0x13e>
  103eab:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
  103eb2:	77 0c                	ja     103ec0 <page_init+0x14a>
                maxpa = end;
  103eb4:	8b 45 b0             	mov    -0x50(%ebp),%eax
  103eb7:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  103eba:	89 45 e0             	mov    %eax,-0x20(%ebp)
  103ebd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  103ec0:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  103ec4:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  103ec7:	8b 00                	mov    (%eax),%eax
  103ec9:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  103ecc:	0f 8f dd fe ff ff    	jg     103daf <page_init+0x39>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
  103ed2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  103ed6:	72 1d                	jb     103ef5 <page_init+0x17f>
  103ed8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  103edc:	77 09                	ja     103ee7 <page_init+0x171>
  103ede:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
  103ee5:	76 0e                	jbe    103ef5 <page_init+0x17f>
        maxpa = KMEMSIZE;
  103ee7:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
  103eee:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
  103ef5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103ef8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  103efb:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  103eff:	c1 ea 0c             	shr    $0xc,%edx
  103f02:	a3 80 ae 11 00       	mov    %eax,0x11ae80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
  103f07:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
  103f0e:	b8 28 af 11 00       	mov    $0x11af28,%eax
  103f13:	8d 50 ff             	lea    -0x1(%eax),%edx
  103f16:	8b 45 ac             	mov    -0x54(%ebp),%eax
  103f19:	01 d0                	add    %edx,%eax
  103f1b:	89 45 a8             	mov    %eax,-0x58(%ebp)
  103f1e:	8b 45 a8             	mov    -0x58(%ebp),%eax
  103f21:	ba 00 00 00 00       	mov    $0x0,%edx
  103f26:	f7 75 ac             	divl   -0x54(%ebp)
  103f29:	89 d0                	mov    %edx,%eax
  103f2b:	8b 55 a8             	mov    -0x58(%ebp),%edx
  103f2e:	29 c2                	sub    %eax,%edx
  103f30:	89 d0                	mov    %edx,%eax
  103f32:	a3 24 af 11 00       	mov    %eax,0x11af24

    for (i = 0; i < npage; i ++) {
  103f37:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  103f3e:	eb 2f                	jmp    103f6f <page_init+0x1f9>
        SetPageReserved(pages + i);
  103f40:	8b 0d 24 af 11 00    	mov    0x11af24,%ecx
  103f46:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103f49:	89 d0                	mov    %edx,%eax
  103f4b:	c1 e0 02             	shl    $0x2,%eax
  103f4e:	01 d0                	add    %edx,%eax
  103f50:	c1 e0 02             	shl    $0x2,%eax
  103f53:	01 c8                	add    %ecx,%eax
  103f55:	83 c0 04             	add    $0x4,%eax
  103f58:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
  103f5f:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  103f62:	8b 45 8c             	mov    -0x74(%ebp),%eax
  103f65:	8b 55 90             	mov    -0x70(%ebp),%edx
  103f68:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
  103f6b:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  103f6f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103f72:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  103f77:	39 c2                	cmp    %eax,%edx
  103f79:	72 c5                	jb     103f40 <page_init+0x1ca>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
  103f7b:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  103f81:	89 d0                	mov    %edx,%eax
  103f83:	c1 e0 02             	shl    $0x2,%eax
  103f86:	01 d0                	add    %edx,%eax
  103f88:	c1 e0 02             	shl    $0x2,%eax
  103f8b:	89 c2                	mov    %eax,%edx
  103f8d:	a1 24 af 11 00       	mov    0x11af24,%eax
  103f92:	01 d0                	add    %edx,%eax
  103f94:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  103f97:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
  103f9e:	77 23                	ja     103fc3 <page_init+0x24d>
  103fa0:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  103fa3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103fa7:	c7 44 24 08 08 6a 10 	movl   $0x106a08,0x8(%esp)
  103fae:	00 
  103faf:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
  103fb6:	00 
  103fb7:	c7 04 24 2c 6a 10 00 	movl   $0x106a2c,(%esp)
  103fbe:	e8 55 cc ff ff       	call   100c18 <__panic>
  103fc3:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  103fc6:	05 00 00 00 40       	add    $0x40000000,%eax
  103fcb:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
  103fce:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  103fd5:	e9 74 01 00 00       	jmp    10414e <page_init+0x3d8>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  103fda:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103fdd:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103fe0:	89 d0                	mov    %edx,%eax
  103fe2:	c1 e0 02             	shl    $0x2,%eax
  103fe5:	01 d0                	add    %edx,%eax
  103fe7:	c1 e0 02             	shl    $0x2,%eax
  103fea:	01 c8                	add    %ecx,%eax
  103fec:	8b 50 08             	mov    0x8(%eax),%edx
  103fef:	8b 40 04             	mov    0x4(%eax),%eax
  103ff2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  103ff5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  103ff8:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103ffb:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103ffe:	89 d0                	mov    %edx,%eax
  104000:	c1 e0 02             	shl    $0x2,%eax
  104003:	01 d0                	add    %edx,%eax
  104005:	c1 e0 02             	shl    $0x2,%eax
  104008:	01 c8                	add    %ecx,%eax
  10400a:	8b 48 0c             	mov    0xc(%eax),%ecx
  10400d:	8b 58 10             	mov    0x10(%eax),%ebx
  104010:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104013:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104016:	01 c8                	add    %ecx,%eax
  104018:	11 da                	adc    %ebx,%edx
  10401a:	89 45 c8             	mov    %eax,-0x38(%ebp)
  10401d:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
  104020:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104023:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104026:	89 d0                	mov    %edx,%eax
  104028:	c1 e0 02             	shl    $0x2,%eax
  10402b:	01 d0                	add    %edx,%eax
  10402d:	c1 e0 02             	shl    $0x2,%eax
  104030:	01 c8                	add    %ecx,%eax
  104032:	83 c0 14             	add    $0x14,%eax
  104035:	8b 00                	mov    (%eax),%eax
  104037:	83 f8 01             	cmp    $0x1,%eax
  10403a:	0f 85 0a 01 00 00    	jne    10414a <page_init+0x3d4>
            if (begin < freemem) {
  104040:	8b 45 a0             	mov    -0x60(%ebp),%eax
  104043:	ba 00 00 00 00       	mov    $0x0,%edx
  104048:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  10404b:	72 17                	jb     104064 <page_init+0x2ee>
  10404d:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  104050:	77 05                	ja     104057 <page_init+0x2e1>
  104052:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  104055:	76 0d                	jbe    104064 <page_init+0x2ee>
                begin = freemem;
  104057:	8b 45 a0             	mov    -0x60(%ebp),%eax
  10405a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  10405d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
  104064:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  104068:	72 1d                	jb     104087 <page_init+0x311>
  10406a:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  10406e:	77 09                	ja     104079 <page_init+0x303>
  104070:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
  104077:	76 0e                	jbe    104087 <page_init+0x311>
                end = KMEMSIZE;
  104079:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
  104080:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
  104087:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10408a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10408d:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  104090:	0f 87 b4 00 00 00    	ja     10414a <page_init+0x3d4>
  104096:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  104099:	72 09                	jb     1040a4 <page_init+0x32e>
  10409b:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  10409e:	0f 83 a6 00 00 00    	jae    10414a <page_init+0x3d4>
                begin = ROUNDUP(begin, PGSIZE);
  1040a4:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
  1040ab:	8b 55 d0             	mov    -0x30(%ebp),%edx
  1040ae:	8b 45 9c             	mov    -0x64(%ebp),%eax
  1040b1:	01 d0                	add    %edx,%eax
  1040b3:	83 e8 01             	sub    $0x1,%eax
  1040b6:	89 45 98             	mov    %eax,-0x68(%ebp)
  1040b9:	8b 45 98             	mov    -0x68(%ebp),%eax
  1040bc:	ba 00 00 00 00       	mov    $0x0,%edx
  1040c1:	f7 75 9c             	divl   -0x64(%ebp)
  1040c4:	89 d0                	mov    %edx,%eax
  1040c6:	8b 55 98             	mov    -0x68(%ebp),%edx
  1040c9:	29 c2                	sub    %eax,%edx
  1040cb:	89 d0                	mov    %edx,%eax
  1040cd:	ba 00 00 00 00       	mov    $0x0,%edx
  1040d2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1040d5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
  1040d8:	8b 45 c8             	mov    -0x38(%ebp),%eax
  1040db:	89 45 94             	mov    %eax,-0x6c(%ebp)
  1040de:	8b 45 94             	mov    -0x6c(%ebp),%eax
  1040e1:	ba 00 00 00 00       	mov    $0x0,%edx
  1040e6:	89 c7                	mov    %eax,%edi
  1040e8:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  1040ee:	89 7d 80             	mov    %edi,-0x80(%ebp)
  1040f1:	89 d0                	mov    %edx,%eax
  1040f3:	83 e0 00             	and    $0x0,%eax
  1040f6:	89 45 84             	mov    %eax,-0x7c(%ebp)
  1040f9:	8b 45 80             	mov    -0x80(%ebp),%eax
  1040fc:	8b 55 84             	mov    -0x7c(%ebp),%edx
  1040ff:	89 45 c8             	mov    %eax,-0x38(%ebp)
  104102:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
  104105:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104108:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10410b:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  10410e:	77 3a                	ja     10414a <page_init+0x3d4>
  104110:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  104113:	72 05                	jb     10411a <page_init+0x3a4>
  104115:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  104118:	73 30                	jae    10414a <page_init+0x3d4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
  10411a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  10411d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  104120:	8b 45 c8             	mov    -0x38(%ebp),%eax
  104123:	8b 55 cc             	mov    -0x34(%ebp),%edx
  104126:	29 c8                	sub    %ecx,%eax
  104128:	19 da                	sbb    %ebx,%edx
  10412a:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  10412e:	c1 ea 0c             	shr    $0xc,%edx
  104131:	89 c3                	mov    %eax,%ebx
  104133:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104136:	89 04 24             	mov    %eax,(%esp)
  104139:	e8 a5 f8 ff ff       	call   1039e3 <pa2page>
  10413e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  104142:	89 04 24             	mov    %eax,(%esp)
  104145:	e8 78 fb ff ff       	call   103cc2 <init_memmap>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
  10414a:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  10414e:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104151:	8b 00                	mov    (%eax),%eax
  104153:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  104156:	0f 8f 7e fe ff ff    	jg     103fda <page_init+0x264>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
  10415c:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  104162:	5b                   	pop    %ebx
  104163:	5e                   	pop    %esi
  104164:	5f                   	pop    %edi
  104165:	5d                   	pop    %ebp
  104166:	c3                   	ret    

00104167 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
  104167:	55                   	push   %ebp
  104168:	89 e5                	mov    %esp,%ebp
  10416a:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
  10416d:	8b 45 14             	mov    0x14(%ebp),%eax
  104170:	8b 55 0c             	mov    0xc(%ebp),%edx
  104173:	31 d0                	xor    %edx,%eax
  104175:	25 ff 0f 00 00       	and    $0xfff,%eax
  10417a:	85 c0                	test   %eax,%eax
  10417c:	74 24                	je     1041a2 <boot_map_segment+0x3b>
  10417e:	c7 44 24 0c 3a 6a 10 	movl   $0x106a3a,0xc(%esp)
  104185:	00 
  104186:	c7 44 24 08 51 6a 10 	movl   $0x106a51,0x8(%esp)
  10418d:	00 
  10418e:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
  104195:	00 
  104196:	c7 04 24 2c 6a 10 00 	movl   $0x106a2c,(%esp)
  10419d:	e8 76 ca ff ff       	call   100c18 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
  1041a2:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
  1041a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1041ac:	25 ff 0f 00 00       	and    $0xfff,%eax
  1041b1:	89 c2                	mov    %eax,%edx
  1041b3:	8b 45 10             	mov    0x10(%ebp),%eax
  1041b6:	01 c2                	add    %eax,%edx
  1041b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1041bb:	01 d0                	add    %edx,%eax
  1041bd:	83 e8 01             	sub    $0x1,%eax
  1041c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1041c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1041c6:	ba 00 00 00 00       	mov    $0x0,%edx
  1041cb:	f7 75 f0             	divl   -0x10(%ebp)
  1041ce:	89 d0                	mov    %edx,%eax
  1041d0:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1041d3:	29 c2                	sub    %eax,%edx
  1041d5:	89 d0                	mov    %edx,%eax
  1041d7:	c1 e8 0c             	shr    $0xc,%eax
  1041da:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
  1041dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  1041e0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1041e3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1041e6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1041eb:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
  1041ee:	8b 45 14             	mov    0x14(%ebp),%eax
  1041f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1041f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1041f7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1041fc:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  1041ff:	eb 6b                	jmp    10426c <boot_map_segment+0x105>
        pte_t *ptep = get_pte(pgdir, la, 1);
  104201:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  104208:	00 
  104209:	8b 45 0c             	mov    0xc(%ebp),%eax
  10420c:	89 44 24 04          	mov    %eax,0x4(%esp)
  104210:	8b 45 08             	mov    0x8(%ebp),%eax
  104213:	89 04 24             	mov    %eax,(%esp)
  104216:	e8 82 01 00 00       	call   10439d <get_pte>
  10421b:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
  10421e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  104222:	75 24                	jne    104248 <boot_map_segment+0xe1>
  104224:	c7 44 24 0c 66 6a 10 	movl   $0x106a66,0xc(%esp)
  10422b:	00 
  10422c:	c7 44 24 08 51 6a 10 	movl   $0x106a51,0x8(%esp)
  104233:	00 
  104234:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
  10423b:	00 
  10423c:	c7 04 24 2c 6a 10 00 	movl   $0x106a2c,(%esp)
  104243:	e8 d0 c9 ff ff       	call   100c18 <__panic>
        *ptep = pa | PTE_P | perm;
  104248:	8b 45 18             	mov    0x18(%ebp),%eax
  10424b:	8b 55 14             	mov    0x14(%ebp),%edx
  10424e:	09 d0                	or     %edx,%eax
  104250:	83 c8 01             	or     $0x1,%eax
  104253:	89 c2                	mov    %eax,%edx
  104255:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104258:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  10425a:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  10425e:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
  104265:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  10426c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104270:	75 8f                	jne    104201 <boot_map_segment+0x9a>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
  104272:	c9                   	leave  
  104273:	c3                   	ret    

00104274 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
  104274:	55                   	push   %ebp
  104275:	89 e5                	mov    %esp,%ebp
  104277:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
  10427a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104281:	e8 5b fa ff ff       	call   103ce1 <alloc_pages>
  104286:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
  104289:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10428d:	75 1c                	jne    1042ab <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
  10428f:	c7 44 24 08 73 6a 10 	movl   $0x106a73,0x8(%esp)
  104296:	00 
  104297:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
  10429e:	00 
  10429f:	c7 04 24 2c 6a 10 00 	movl   $0x106a2c,(%esp)
  1042a6:	e8 6d c9 ff ff       	call   100c18 <__panic>
    }
    return page2kva(p);
  1042ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1042ae:	89 04 24             	mov    %eax,(%esp)
  1042b1:	e8 7c f7 ff ff       	call   103a32 <page2kva>
}
  1042b6:	c9                   	leave  
  1042b7:	c3                   	ret    

001042b8 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
  1042b8:	55                   	push   %ebp
  1042b9:	89 e5                	mov    %esp,%ebp
  1042bb:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
  1042be:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1042c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1042c6:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  1042cd:	77 23                	ja     1042f2 <pmm_init+0x3a>
  1042cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1042d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1042d6:	c7 44 24 08 08 6a 10 	movl   $0x106a08,0x8(%esp)
  1042dd:	00 
  1042de:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
  1042e5:	00 
  1042e6:	c7 04 24 2c 6a 10 00 	movl   $0x106a2c,(%esp)
  1042ed:	e8 26 c9 ff ff       	call   100c18 <__panic>
  1042f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1042f5:	05 00 00 00 40       	add    $0x40000000,%eax
  1042fa:	a3 20 af 11 00       	mov    %eax,0x11af20
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
  1042ff:	e8 8b f9 ff ff       	call   103c8f <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
  104304:	e8 6d fa ff ff       	call   103d76 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
  104309:	e8 7b 03 00 00       	call   104689 <check_alloc_page>

    check_pgdir();
  10430e:	e8 94 03 00 00       	call   1046a7 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
  104313:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104318:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
  10431e:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104323:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104326:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  10432d:	77 23                	ja     104352 <pmm_init+0x9a>
  10432f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104332:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104336:	c7 44 24 08 08 6a 10 	movl   $0x106a08,0x8(%esp)
  10433d:	00 
  10433e:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
  104345:	00 
  104346:	c7 04 24 2c 6a 10 00 	movl   $0x106a2c,(%esp)
  10434d:	e8 c6 c8 ff ff       	call   100c18 <__panic>
  104352:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104355:	05 00 00 00 40       	add    $0x40000000,%eax
  10435a:	83 c8 03             	or     $0x3,%eax
  10435d:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
  10435f:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104364:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
  10436b:	00 
  10436c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  104373:	00 
  104374:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
  10437b:	38 
  10437c:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
  104383:	c0 
  104384:	89 04 24             	mov    %eax,(%esp)
  104387:	e8 db fd ff ff       	call   104167 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
  10438c:	e8 0f f8 ff ff       	call   103ba0 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
  104391:	e8 ac 09 00 00       	call   104d42 <check_boot_pgdir>

    print_pgdir();
  104396:	e8 34 0e 00 00       	call   1051cf <print_pgdir>

}
  10439b:	c9                   	leave  
  10439c:	c3                   	ret    

0010439d <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
  10439d:	55                   	push   %ebp
  10439e:	89 e5                	mov    %esp,%ebp
  1043a0:	83 ec 38             	sub    $0x38,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    pde_t *pdep = &pgdir[PDX(la)];
  1043a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1043a6:	c1 e8 16             	shr    $0x16,%eax
  1043a9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1043b0:	8b 45 08             	mov    0x8(%ebp),%eax
  1043b3:	01 d0                	add    %edx,%eax
  1043b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if((*pdep & PTE_P)==0)
  1043b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1043bb:	8b 00                	mov    (%eax),%eax
  1043bd:	83 e0 01             	and    $0x1,%eax
  1043c0:	85 c0                	test   %eax,%eax
  1043c2:	0f 85 ab 00 00 00    	jne    104473 <get_pte+0xd6>
     {
      struct Page *page;
      if(create==1)
  1043c8:	83 7d 10 01          	cmpl   $0x1,0x10(%ebp)
  1043cc:	75 4b                	jne    104419 <get_pte+0x7c>
      {
       page=alloc_pages(1);
  1043ce:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1043d5:	e8 07 f9 ff ff       	call   103ce1 <alloc_pages>
  1043da:	89 45 f0             	mov    %eax,-0x10(%ebp)
      }
      else return NULL;
      set_page_ref(page,1);
  1043dd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1043e4:	00 
  1043e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1043e8:	89 04 24             	mov    %eax,(%esp)
  1043eb:	e8 f6 f6 ff ff       	call   103ae6 <set_page_ref>
      uintptr_t pa=page2pa(page);
  1043f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1043f3:	89 04 24             	mov    %eax,(%esp)
  1043f6:	e8 d2 f5 ff ff       	call   1039cd <page2pa>
  1043fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
      memset(KADDR(pa),0,sizeof(struct Page));
  1043fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104401:	89 45 e8             	mov    %eax,-0x18(%ebp)
  104404:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104407:	c1 e8 0c             	shr    $0xc,%eax
  10440a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10440d:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  104412:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  104415:	72 2f                	jb     104446 <get_pte+0xa9>
  104417:	eb 0a                	jmp    104423 <get_pte+0x86>
      struct Page *page;
      if(create==1)
      {
       page=alloc_pages(1);
      }
      else return NULL;
  104419:	b8 00 00 00 00       	mov    $0x0,%eax
  10441e:	e9 ac 00 00 00       	jmp    1044cf <get_pte+0x132>
      set_page_ref(page,1);
      uintptr_t pa=page2pa(page);
      memset(KADDR(pa),0,sizeof(struct Page));
  104423:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104426:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10442a:	c7 44 24 08 64 69 10 	movl   $0x106964,0x8(%esp)
  104431:	00 
  104432:	c7 44 24 04 75 01 00 	movl   $0x175,0x4(%esp)
  104439:	00 
  10443a:	c7 04 24 2c 6a 10 00 	movl   $0x106a2c,(%esp)
  104441:	e8 d2 c7 ff ff       	call   100c18 <__panic>
  104446:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104449:	2d 00 00 00 40       	sub    $0x40000000,%eax
  10444e:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
  104455:	00 
  104456:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10445d:	00 
  10445e:	89 04 24             	mov    %eax,(%esp)
  104461:	e8 87 18 00 00       	call   105ced <memset>
      *pdep=pa|PTE_P|PTE_W|PTE_U;
  104466:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104469:	83 c8 07             	or     $0x7,%eax
  10446c:	89 c2                	mov    %eax,%edx
  10446e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104471:	89 10                	mov    %edx,(%eax)
 
      }
      return (pte_t*)KADDR((PDE_ADDR(*pdep)))+PTX(la);
  104473:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104476:	8b 00                	mov    (%eax),%eax
  104478:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  10447d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  104480:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104483:	c1 e8 0c             	shr    $0xc,%eax
  104486:	89 45 dc             	mov    %eax,-0x24(%ebp)
  104489:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  10448e:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  104491:	72 23                	jb     1044b6 <get_pte+0x119>
  104493:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104496:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10449a:	c7 44 24 08 64 69 10 	movl   $0x106964,0x8(%esp)
  1044a1:	00 
  1044a2:	c7 44 24 04 79 01 00 	movl   $0x179,0x4(%esp)
  1044a9:	00 
  1044aa:	c7 04 24 2c 6a 10 00 	movl   $0x106a2c,(%esp)
  1044b1:	e8 62 c7 ff ff       	call   100c18 <__panic>
  1044b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1044b9:	2d 00 00 00 40       	sub    $0x40000000,%eax
  1044be:	8b 55 0c             	mov    0xc(%ebp),%edx
  1044c1:	c1 ea 0c             	shr    $0xc,%edx
  1044c4:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
  1044ca:	c1 e2 02             	shl    $0x2,%edx
  1044cd:	01 d0                	add    %edx,%eax
}
  1044cf:	c9                   	leave  
  1044d0:	c3                   	ret    

001044d1 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
  1044d1:	55                   	push   %ebp
  1044d2:	89 e5                	mov    %esp,%ebp
  1044d4:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  1044d7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1044de:	00 
  1044df:	8b 45 0c             	mov    0xc(%ebp),%eax
  1044e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1044e6:	8b 45 08             	mov    0x8(%ebp),%eax
  1044e9:	89 04 24             	mov    %eax,(%esp)
  1044ec:	e8 ac fe ff ff       	call   10439d <get_pte>
  1044f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
  1044f4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1044f8:	74 08                	je     104502 <get_page+0x31>
        *ptep_store = ptep;
  1044fa:	8b 45 10             	mov    0x10(%ebp),%eax
  1044fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104500:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
  104502:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104506:	74 1b                	je     104523 <get_page+0x52>
  104508:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10450b:	8b 00                	mov    (%eax),%eax
  10450d:	83 e0 01             	and    $0x1,%eax
  104510:	85 c0                	test   %eax,%eax
  104512:	74 0f                	je     104523 <get_page+0x52>
        return pte2page(*ptep);
  104514:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104517:	8b 00                	mov    (%eax),%eax
  104519:	89 04 24             	mov    %eax,(%esp)
  10451c:	e8 65 f5 ff ff       	call   103a86 <pte2page>
  104521:	eb 05                	jmp    104528 <get_page+0x57>
    }
    return NULL;
  104523:	b8 00 00 00 00       	mov    $0x0,%eax
}
  104528:	c9                   	leave  
  104529:	c3                   	ret    

0010452a <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
  10452a:	55                   	push   %ebp
  10452b:	89 e5                	mov    %esp,%ebp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
}
  10452d:	5d                   	pop    %ebp
  10452e:	c3                   	ret    

0010452f <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
  10452f:	55                   	push   %ebp
  104530:	89 e5                	mov    %esp,%ebp
  104532:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  104535:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10453c:	00 
  10453d:	8b 45 0c             	mov    0xc(%ebp),%eax
  104540:	89 44 24 04          	mov    %eax,0x4(%esp)
  104544:	8b 45 08             	mov    0x8(%ebp),%eax
  104547:	89 04 24             	mov    %eax,(%esp)
  10454a:	e8 4e fe ff ff       	call   10439d <get_pte>
  10454f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
  104552:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104556:	74 19                	je     104571 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
  104558:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10455b:	89 44 24 08          	mov    %eax,0x8(%esp)
  10455f:	8b 45 0c             	mov    0xc(%ebp),%eax
  104562:	89 44 24 04          	mov    %eax,0x4(%esp)
  104566:	8b 45 08             	mov    0x8(%ebp),%eax
  104569:	89 04 24             	mov    %eax,(%esp)
  10456c:	e8 b9 ff ff ff       	call   10452a <page_remove_pte>
    }
}
  104571:	c9                   	leave  
  104572:	c3                   	ret    

00104573 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
  104573:	55                   	push   %ebp
  104574:	89 e5                	mov    %esp,%ebp
  104576:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
  104579:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  104580:	00 
  104581:	8b 45 10             	mov    0x10(%ebp),%eax
  104584:	89 44 24 04          	mov    %eax,0x4(%esp)
  104588:	8b 45 08             	mov    0x8(%ebp),%eax
  10458b:	89 04 24             	mov    %eax,(%esp)
  10458e:	e8 0a fe ff ff       	call   10439d <get_pte>
  104593:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
  104596:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10459a:	75 0a                	jne    1045a6 <page_insert+0x33>
        return -E_NO_MEM;
  10459c:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  1045a1:	e9 84 00 00 00       	jmp    10462a <page_insert+0xb7>
    }
    page_ref_inc(page);
  1045a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1045a9:	89 04 24             	mov    %eax,(%esp)
  1045ac:	e8 42 f5 ff ff       	call   103af3 <page_ref_inc>
    if (*ptep & PTE_P) {
  1045b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1045b4:	8b 00                	mov    (%eax),%eax
  1045b6:	83 e0 01             	and    $0x1,%eax
  1045b9:	85 c0                	test   %eax,%eax
  1045bb:	74 3e                	je     1045fb <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
  1045bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1045c0:	8b 00                	mov    (%eax),%eax
  1045c2:	89 04 24             	mov    %eax,(%esp)
  1045c5:	e8 bc f4 ff ff       	call   103a86 <pte2page>
  1045ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
  1045cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1045d0:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1045d3:	75 0d                	jne    1045e2 <page_insert+0x6f>
            page_ref_dec(page);
  1045d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1045d8:	89 04 24             	mov    %eax,(%esp)
  1045db:	e8 2a f5 ff ff       	call   103b0a <page_ref_dec>
  1045e0:	eb 19                	jmp    1045fb <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
  1045e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1045e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  1045e9:	8b 45 10             	mov    0x10(%ebp),%eax
  1045ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  1045f0:	8b 45 08             	mov    0x8(%ebp),%eax
  1045f3:	89 04 24             	mov    %eax,(%esp)
  1045f6:	e8 2f ff ff ff       	call   10452a <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
  1045fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1045fe:	89 04 24             	mov    %eax,(%esp)
  104601:	e8 c7 f3 ff ff       	call   1039cd <page2pa>
  104606:	0b 45 14             	or     0x14(%ebp),%eax
  104609:	83 c8 01             	or     $0x1,%eax
  10460c:	89 c2                	mov    %eax,%edx
  10460e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104611:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
  104613:	8b 45 10             	mov    0x10(%ebp),%eax
  104616:	89 44 24 04          	mov    %eax,0x4(%esp)
  10461a:	8b 45 08             	mov    0x8(%ebp),%eax
  10461d:	89 04 24             	mov    %eax,(%esp)
  104620:	e8 07 00 00 00       	call   10462c <tlb_invalidate>
    return 0;
  104625:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10462a:	c9                   	leave  
  10462b:	c3                   	ret    

0010462c <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
  10462c:	55                   	push   %ebp
  10462d:	89 e5                	mov    %esp,%ebp
  10462f:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
  104632:	0f 20 d8             	mov    %cr3,%eax
  104635:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
  104638:	8b 45 f0             	mov    -0x10(%ebp),%eax
    if (rcr3() == PADDR(pgdir)) {
  10463b:	89 c2                	mov    %eax,%edx
  10463d:	8b 45 08             	mov    0x8(%ebp),%eax
  104640:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104643:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  10464a:	77 23                	ja     10466f <tlb_invalidate+0x43>
  10464c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10464f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104653:	c7 44 24 08 08 6a 10 	movl   $0x106a08,0x8(%esp)
  10465a:	00 
  10465b:	c7 44 24 04 d3 01 00 	movl   $0x1d3,0x4(%esp)
  104662:	00 
  104663:	c7 04 24 2c 6a 10 00 	movl   $0x106a2c,(%esp)
  10466a:	e8 a9 c5 ff ff       	call   100c18 <__panic>
  10466f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104672:	05 00 00 00 40       	add    $0x40000000,%eax
  104677:	39 c2                	cmp    %eax,%edx
  104679:	75 0c                	jne    104687 <tlb_invalidate+0x5b>
        invlpg((void *)la);
  10467b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10467e:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
  104681:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104684:	0f 01 38             	invlpg (%eax)
    }
}
  104687:	c9                   	leave  
  104688:	c3                   	ret    

00104689 <check_alloc_page>:

static void
check_alloc_page(void) {
  104689:	55                   	push   %ebp
  10468a:	89 e5                	mov    %esp,%ebp
  10468c:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
  10468f:	a1 1c af 11 00       	mov    0x11af1c,%eax
  104694:	8b 40 18             	mov    0x18(%eax),%eax
  104697:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
  104699:	c7 04 24 8c 6a 10 00 	movl   $0x106a8c,(%esp)
  1046a0:	e8 a3 bc ff ff       	call   100348 <cprintf>
}
  1046a5:	c9                   	leave  
  1046a6:	c3                   	ret    

001046a7 <check_pgdir>:

static void
check_pgdir(void) {
  1046a7:	55                   	push   %ebp
  1046a8:	89 e5                	mov    %esp,%ebp
  1046aa:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
  1046ad:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  1046b2:	3d 00 80 03 00       	cmp    $0x38000,%eax
  1046b7:	76 24                	jbe    1046dd <check_pgdir+0x36>
  1046b9:	c7 44 24 0c ab 6a 10 	movl   $0x106aab,0xc(%esp)
  1046c0:	00 
  1046c1:	c7 44 24 08 51 6a 10 	movl   $0x106a51,0x8(%esp)
  1046c8:	00 
  1046c9:	c7 44 24 04 e0 01 00 	movl   $0x1e0,0x4(%esp)
  1046d0:	00 
  1046d1:	c7 04 24 2c 6a 10 00 	movl   $0x106a2c,(%esp)
  1046d8:	e8 3b c5 ff ff       	call   100c18 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
  1046dd:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1046e2:	85 c0                	test   %eax,%eax
  1046e4:	74 0e                	je     1046f4 <check_pgdir+0x4d>
  1046e6:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1046eb:	25 ff 0f 00 00       	and    $0xfff,%eax
  1046f0:	85 c0                	test   %eax,%eax
  1046f2:	74 24                	je     104718 <check_pgdir+0x71>
  1046f4:	c7 44 24 0c c8 6a 10 	movl   $0x106ac8,0xc(%esp)
  1046fb:	00 
  1046fc:	c7 44 24 08 51 6a 10 	movl   $0x106a51,0x8(%esp)
  104703:	00 
  104704:	c7 44 24 04 e1 01 00 	movl   $0x1e1,0x4(%esp)
  10470b:	00 
  10470c:	c7 04 24 2c 6a 10 00 	movl   $0x106a2c,(%esp)
  104713:	e8 00 c5 ff ff       	call   100c18 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
  104718:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  10471d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104724:	00 
  104725:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10472c:	00 
  10472d:	89 04 24             	mov    %eax,(%esp)
  104730:	e8 9c fd ff ff       	call   1044d1 <get_page>
  104735:	85 c0                	test   %eax,%eax
  104737:	74 24                	je     10475d <check_pgdir+0xb6>
  104739:	c7 44 24 0c 00 6b 10 	movl   $0x106b00,0xc(%esp)
  104740:	00 
  104741:	c7 44 24 08 51 6a 10 	movl   $0x106a51,0x8(%esp)
  104748:	00 
  104749:	c7 44 24 04 e2 01 00 	movl   $0x1e2,0x4(%esp)
  104750:	00 
  104751:	c7 04 24 2c 6a 10 00 	movl   $0x106a2c,(%esp)
  104758:	e8 bb c4 ff ff       	call   100c18 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
  10475d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104764:	e8 78 f5 ff ff       	call   103ce1 <alloc_pages>
  104769:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
  10476c:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104771:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  104778:	00 
  104779:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104780:	00 
  104781:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104784:	89 54 24 04          	mov    %edx,0x4(%esp)
  104788:	89 04 24             	mov    %eax,(%esp)
  10478b:	e8 e3 fd ff ff       	call   104573 <page_insert>
  104790:	85 c0                	test   %eax,%eax
  104792:	74 24                	je     1047b8 <check_pgdir+0x111>
  104794:	c7 44 24 0c 28 6b 10 	movl   $0x106b28,0xc(%esp)
  10479b:	00 
  10479c:	c7 44 24 08 51 6a 10 	movl   $0x106a51,0x8(%esp)
  1047a3:	00 
  1047a4:	c7 44 24 04 e6 01 00 	movl   $0x1e6,0x4(%esp)
  1047ab:	00 
  1047ac:	c7 04 24 2c 6a 10 00 	movl   $0x106a2c,(%esp)
  1047b3:	e8 60 c4 ff ff       	call   100c18 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
  1047b8:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1047bd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1047c4:	00 
  1047c5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1047cc:	00 
  1047cd:	89 04 24             	mov    %eax,(%esp)
  1047d0:	e8 c8 fb ff ff       	call   10439d <get_pte>
  1047d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1047d8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1047dc:	75 24                	jne    104802 <check_pgdir+0x15b>
  1047de:	c7 44 24 0c 54 6b 10 	movl   $0x106b54,0xc(%esp)
  1047e5:	00 
  1047e6:	c7 44 24 08 51 6a 10 	movl   $0x106a51,0x8(%esp)
  1047ed:	00 
  1047ee:	c7 44 24 04 e9 01 00 	movl   $0x1e9,0x4(%esp)
  1047f5:	00 
  1047f6:	c7 04 24 2c 6a 10 00 	movl   $0x106a2c,(%esp)
  1047fd:	e8 16 c4 ff ff       	call   100c18 <__panic>
    assert(pte2page(*ptep) == p1);
  104802:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104805:	8b 00                	mov    (%eax),%eax
  104807:	89 04 24             	mov    %eax,(%esp)
  10480a:	e8 77 f2 ff ff       	call   103a86 <pte2page>
  10480f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104812:	74 24                	je     104838 <check_pgdir+0x191>
  104814:	c7 44 24 0c 81 6b 10 	movl   $0x106b81,0xc(%esp)
  10481b:	00 
  10481c:	c7 44 24 08 51 6a 10 	movl   $0x106a51,0x8(%esp)
  104823:	00 
  104824:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
  10482b:	00 
  10482c:	c7 04 24 2c 6a 10 00 	movl   $0x106a2c,(%esp)
  104833:	e8 e0 c3 ff ff       	call   100c18 <__panic>
    assert(page_ref(p1) == 1);
  104838:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10483b:	89 04 24             	mov    %eax,(%esp)
  10483e:	e8 99 f2 ff ff       	call   103adc <page_ref>
  104843:	83 f8 01             	cmp    $0x1,%eax
  104846:	74 24                	je     10486c <check_pgdir+0x1c5>
  104848:	c7 44 24 0c 97 6b 10 	movl   $0x106b97,0xc(%esp)
  10484f:	00 
  104850:	c7 44 24 08 51 6a 10 	movl   $0x106a51,0x8(%esp)
  104857:	00 
  104858:	c7 44 24 04 eb 01 00 	movl   $0x1eb,0x4(%esp)
  10485f:	00 
  104860:	c7 04 24 2c 6a 10 00 	movl   $0x106a2c,(%esp)
  104867:	e8 ac c3 ff ff       	call   100c18 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
  10486c:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104871:	8b 00                	mov    (%eax),%eax
  104873:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104878:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10487b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10487e:	c1 e8 0c             	shr    $0xc,%eax
  104881:	89 45 e8             	mov    %eax,-0x18(%ebp)
  104884:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  104889:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  10488c:	72 23                	jb     1048b1 <check_pgdir+0x20a>
  10488e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104891:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104895:	c7 44 24 08 64 69 10 	movl   $0x106964,0x8(%esp)
  10489c:	00 
  10489d:	c7 44 24 04 ed 01 00 	movl   $0x1ed,0x4(%esp)
  1048a4:	00 
  1048a5:	c7 04 24 2c 6a 10 00 	movl   $0x106a2c,(%esp)
  1048ac:	e8 67 c3 ff ff       	call   100c18 <__panic>
  1048b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1048b4:	2d 00 00 00 40       	sub    $0x40000000,%eax
  1048b9:	83 c0 04             	add    $0x4,%eax
  1048bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
  1048bf:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1048c4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1048cb:	00 
  1048cc:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  1048d3:	00 
  1048d4:	89 04 24             	mov    %eax,(%esp)
  1048d7:	e8 c1 fa ff ff       	call   10439d <get_pte>
  1048dc:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  1048df:	74 24                	je     104905 <check_pgdir+0x25e>
  1048e1:	c7 44 24 0c ac 6b 10 	movl   $0x106bac,0xc(%esp)
  1048e8:	00 
  1048e9:	c7 44 24 08 51 6a 10 	movl   $0x106a51,0x8(%esp)
  1048f0:	00 
  1048f1:	c7 44 24 04 ee 01 00 	movl   $0x1ee,0x4(%esp)
  1048f8:	00 
  1048f9:	c7 04 24 2c 6a 10 00 	movl   $0x106a2c,(%esp)
  104900:	e8 13 c3 ff ff       	call   100c18 <__panic>

    p2 = alloc_page();
  104905:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10490c:	e8 d0 f3 ff ff       	call   103ce1 <alloc_pages>
  104911:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
  104914:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104919:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  104920:	00 
  104921:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  104928:	00 
  104929:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10492c:	89 54 24 04          	mov    %edx,0x4(%esp)
  104930:	89 04 24             	mov    %eax,(%esp)
  104933:	e8 3b fc ff ff       	call   104573 <page_insert>
  104938:	85 c0                	test   %eax,%eax
  10493a:	74 24                	je     104960 <check_pgdir+0x2b9>
  10493c:	c7 44 24 0c d4 6b 10 	movl   $0x106bd4,0xc(%esp)
  104943:	00 
  104944:	c7 44 24 08 51 6a 10 	movl   $0x106a51,0x8(%esp)
  10494b:	00 
  10494c:	c7 44 24 04 f1 01 00 	movl   $0x1f1,0x4(%esp)
  104953:	00 
  104954:	c7 04 24 2c 6a 10 00 	movl   $0x106a2c,(%esp)
  10495b:	e8 b8 c2 ff ff       	call   100c18 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  104960:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104965:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10496c:	00 
  10496d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104974:	00 
  104975:	89 04 24             	mov    %eax,(%esp)
  104978:	e8 20 fa ff ff       	call   10439d <get_pte>
  10497d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104980:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104984:	75 24                	jne    1049aa <check_pgdir+0x303>
  104986:	c7 44 24 0c 0c 6c 10 	movl   $0x106c0c,0xc(%esp)
  10498d:	00 
  10498e:	c7 44 24 08 51 6a 10 	movl   $0x106a51,0x8(%esp)
  104995:	00 
  104996:	c7 44 24 04 f2 01 00 	movl   $0x1f2,0x4(%esp)
  10499d:	00 
  10499e:	c7 04 24 2c 6a 10 00 	movl   $0x106a2c,(%esp)
  1049a5:	e8 6e c2 ff ff       	call   100c18 <__panic>
    assert(*ptep & PTE_U);
  1049aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1049ad:	8b 00                	mov    (%eax),%eax
  1049af:	83 e0 04             	and    $0x4,%eax
  1049b2:	85 c0                	test   %eax,%eax
  1049b4:	75 24                	jne    1049da <check_pgdir+0x333>
  1049b6:	c7 44 24 0c 3c 6c 10 	movl   $0x106c3c,0xc(%esp)
  1049bd:	00 
  1049be:	c7 44 24 08 51 6a 10 	movl   $0x106a51,0x8(%esp)
  1049c5:	00 
  1049c6:	c7 44 24 04 f3 01 00 	movl   $0x1f3,0x4(%esp)
  1049cd:	00 
  1049ce:	c7 04 24 2c 6a 10 00 	movl   $0x106a2c,(%esp)
  1049d5:	e8 3e c2 ff ff       	call   100c18 <__panic>
    assert(*ptep & PTE_W);
  1049da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1049dd:	8b 00                	mov    (%eax),%eax
  1049df:	83 e0 02             	and    $0x2,%eax
  1049e2:	85 c0                	test   %eax,%eax
  1049e4:	75 24                	jne    104a0a <check_pgdir+0x363>
  1049e6:	c7 44 24 0c 4a 6c 10 	movl   $0x106c4a,0xc(%esp)
  1049ed:	00 
  1049ee:	c7 44 24 08 51 6a 10 	movl   $0x106a51,0x8(%esp)
  1049f5:	00 
  1049f6:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
  1049fd:	00 
  1049fe:	c7 04 24 2c 6a 10 00 	movl   $0x106a2c,(%esp)
  104a05:	e8 0e c2 ff ff       	call   100c18 <__panic>
    assert(boot_pgdir[0] & PTE_U);
  104a0a:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104a0f:	8b 00                	mov    (%eax),%eax
  104a11:	83 e0 04             	and    $0x4,%eax
  104a14:	85 c0                	test   %eax,%eax
  104a16:	75 24                	jne    104a3c <check_pgdir+0x395>
  104a18:	c7 44 24 0c 58 6c 10 	movl   $0x106c58,0xc(%esp)
  104a1f:	00 
  104a20:	c7 44 24 08 51 6a 10 	movl   $0x106a51,0x8(%esp)
  104a27:	00 
  104a28:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
  104a2f:	00 
  104a30:	c7 04 24 2c 6a 10 00 	movl   $0x106a2c,(%esp)
  104a37:	e8 dc c1 ff ff       	call   100c18 <__panic>
    assert(page_ref(p2) == 1);
  104a3c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104a3f:	89 04 24             	mov    %eax,(%esp)
  104a42:	e8 95 f0 ff ff       	call   103adc <page_ref>
  104a47:	83 f8 01             	cmp    $0x1,%eax
  104a4a:	74 24                	je     104a70 <check_pgdir+0x3c9>
  104a4c:	c7 44 24 0c 6e 6c 10 	movl   $0x106c6e,0xc(%esp)
  104a53:	00 
  104a54:	c7 44 24 08 51 6a 10 	movl   $0x106a51,0x8(%esp)
  104a5b:	00 
  104a5c:	c7 44 24 04 f6 01 00 	movl   $0x1f6,0x4(%esp)
  104a63:	00 
  104a64:	c7 04 24 2c 6a 10 00 	movl   $0x106a2c,(%esp)
  104a6b:	e8 a8 c1 ff ff       	call   100c18 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
  104a70:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104a75:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  104a7c:	00 
  104a7d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  104a84:	00 
  104a85:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104a88:	89 54 24 04          	mov    %edx,0x4(%esp)
  104a8c:	89 04 24             	mov    %eax,(%esp)
  104a8f:	e8 df fa ff ff       	call   104573 <page_insert>
  104a94:	85 c0                	test   %eax,%eax
  104a96:	74 24                	je     104abc <check_pgdir+0x415>
  104a98:	c7 44 24 0c 80 6c 10 	movl   $0x106c80,0xc(%esp)
  104a9f:	00 
  104aa0:	c7 44 24 08 51 6a 10 	movl   $0x106a51,0x8(%esp)
  104aa7:	00 
  104aa8:	c7 44 24 04 f8 01 00 	movl   $0x1f8,0x4(%esp)
  104aaf:	00 
  104ab0:	c7 04 24 2c 6a 10 00 	movl   $0x106a2c,(%esp)
  104ab7:	e8 5c c1 ff ff       	call   100c18 <__panic>
    assert(page_ref(p1) == 2);
  104abc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104abf:	89 04 24             	mov    %eax,(%esp)
  104ac2:	e8 15 f0 ff ff       	call   103adc <page_ref>
  104ac7:	83 f8 02             	cmp    $0x2,%eax
  104aca:	74 24                	je     104af0 <check_pgdir+0x449>
  104acc:	c7 44 24 0c ac 6c 10 	movl   $0x106cac,0xc(%esp)
  104ad3:	00 
  104ad4:	c7 44 24 08 51 6a 10 	movl   $0x106a51,0x8(%esp)
  104adb:	00 
  104adc:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
  104ae3:	00 
  104ae4:	c7 04 24 2c 6a 10 00 	movl   $0x106a2c,(%esp)
  104aeb:	e8 28 c1 ff ff       	call   100c18 <__panic>
    assert(page_ref(p2) == 0);
  104af0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104af3:	89 04 24             	mov    %eax,(%esp)
  104af6:	e8 e1 ef ff ff       	call   103adc <page_ref>
  104afb:	85 c0                	test   %eax,%eax
  104afd:	74 24                	je     104b23 <check_pgdir+0x47c>
  104aff:	c7 44 24 0c be 6c 10 	movl   $0x106cbe,0xc(%esp)
  104b06:	00 
  104b07:	c7 44 24 08 51 6a 10 	movl   $0x106a51,0x8(%esp)
  104b0e:	00 
  104b0f:	c7 44 24 04 fa 01 00 	movl   $0x1fa,0x4(%esp)
  104b16:	00 
  104b17:	c7 04 24 2c 6a 10 00 	movl   $0x106a2c,(%esp)
  104b1e:	e8 f5 c0 ff ff       	call   100c18 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  104b23:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104b28:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104b2f:	00 
  104b30:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104b37:	00 
  104b38:	89 04 24             	mov    %eax,(%esp)
  104b3b:	e8 5d f8 ff ff       	call   10439d <get_pte>
  104b40:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104b43:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104b47:	75 24                	jne    104b6d <check_pgdir+0x4c6>
  104b49:	c7 44 24 0c 0c 6c 10 	movl   $0x106c0c,0xc(%esp)
  104b50:	00 
  104b51:	c7 44 24 08 51 6a 10 	movl   $0x106a51,0x8(%esp)
  104b58:	00 
  104b59:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
  104b60:	00 
  104b61:	c7 04 24 2c 6a 10 00 	movl   $0x106a2c,(%esp)
  104b68:	e8 ab c0 ff ff       	call   100c18 <__panic>
    assert(pte2page(*ptep) == p1);
  104b6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104b70:	8b 00                	mov    (%eax),%eax
  104b72:	89 04 24             	mov    %eax,(%esp)
  104b75:	e8 0c ef ff ff       	call   103a86 <pte2page>
  104b7a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104b7d:	74 24                	je     104ba3 <check_pgdir+0x4fc>
  104b7f:	c7 44 24 0c 81 6b 10 	movl   $0x106b81,0xc(%esp)
  104b86:	00 
  104b87:	c7 44 24 08 51 6a 10 	movl   $0x106a51,0x8(%esp)
  104b8e:	00 
  104b8f:	c7 44 24 04 fc 01 00 	movl   $0x1fc,0x4(%esp)
  104b96:	00 
  104b97:	c7 04 24 2c 6a 10 00 	movl   $0x106a2c,(%esp)
  104b9e:	e8 75 c0 ff ff       	call   100c18 <__panic>
    assert((*ptep & PTE_U) == 0);
  104ba3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104ba6:	8b 00                	mov    (%eax),%eax
  104ba8:	83 e0 04             	and    $0x4,%eax
  104bab:	85 c0                	test   %eax,%eax
  104bad:	74 24                	je     104bd3 <check_pgdir+0x52c>
  104baf:	c7 44 24 0c d0 6c 10 	movl   $0x106cd0,0xc(%esp)
  104bb6:	00 
  104bb7:	c7 44 24 08 51 6a 10 	movl   $0x106a51,0x8(%esp)
  104bbe:	00 
  104bbf:	c7 44 24 04 fd 01 00 	movl   $0x1fd,0x4(%esp)
  104bc6:	00 
  104bc7:	c7 04 24 2c 6a 10 00 	movl   $0x106a2c,(%esp)
  104bce:	e8 45 c0 ff ff       	call   100c18 <__panic>

    page_remove(boot_pgdir, 0x0);
  104bd3:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104bd8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104bdf:	00 
  104be0:	89 04 24             	mov    %eax,(%esp)
  104be3:	e8 47 f9 ff ff       	call   10452f <page_remove>
    assert(page_ref(p1) == 1);
  104be8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104beb:	89 04 24             	mov    %eax,(%esp)
  104bee:	e8 e9 ee ff ff       	call   103adc <page_ref>
  104bf3:	83 f8 01             	cmp    $0x1,%eax
  104bf6:	74 24                	je     104c1c <check_pgdir+0x575>
  104bf8:	c7 44 24 0c 97 6b 10 	movl   $0x106b97,0xc(%esp)
  104bff:	00 
  104c00:	c7 44 24 08 51 6a 10 	movl   $0x106a51,0x8(%esp)
  104c07:	00 
  104c08:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
  104c0f:	00 
  104c10:	c7 04 24 2c 6a 10 00 	movl   $0x106a2c,(%esp)
  104c17:	e8 fc bf ff ff       	call   100c18 <__panic>
    assert(page_ref(p2) == 0);
  104c1c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104c1f:	89 04 24             	mov    %eax,(%esp)
  104c22:	e8 b5 ee ff ff       	call   103adc <page_ref>
  104c27:	85 c0                	test   %eax,%eax
  104c29:	74 24                	je     104c4f <check_pgdir+0x5a8>
  104c2b:	c7 44 24 0c be 6c 10 	movl   $0x106cbe,0xc(%esp)
  104c32:	00 
  104c33:	c7 44 24 08 51 6a 10 	movl   $0x106a51,0x8(%esp)
  104c3a:	00 
  104c3b:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
  104c42:	00 
  104c43:	c7 04 24 2c 6a 10 00 	movl   $0x106a2c,(%esp)
  104c4a:	e8 c9 bf ff ff       	call   100c18 <__panic>

    page_remove(boot_pgdir, PGSIZE);
  104c4f:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104c54:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104c5b:	00 
  104c5c:	89 04 24             	mov    %eax,(%esp)
  104c5f:	e8 cb f8 ff ff       	call   10452f <page_remove>
    assert(page_ref(p1) == 0);
  104c64:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104c67:	89 04 24             	mov    %eax,(%esp)
  104c6a:	e8 6d ee ff ff       	call   103adc <page_ref>
  104c6f:	85 c0                	test   %eax,%eax
  104c71:	74 24                	je     104c97 <check_pgdir+0x5f0>
  104c73:	c7 44 24 0c e5 6c 10 	movl   $0x106ce5,0xc(%esp)
  104c7a:	00 
  104c7b:	c7 44 24 08 51 6a 10 	movl   $0x106a51,0x8(%esp)
  104c82:	00 
  104c83:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
  104c8a:	00 
  104c8b:	c7 04 24 2c 6a 10 00 	movl   $0x106a2c,(%esp)
  104c92:	e8 81 bf ff ff       	call   100c18 <__panic>
    assert(page_ref(p2) == 0);
  104c97:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104c9a:	89 04 24             	mov    %eax,(%esp)
  104c9d:	e8 3a ee ff ff       	call   103adc <page_ref>
  104ca2:	85 c0                	test   %eax,%eax
  104ca4:	74 24                	je     104cca <check_pgdir+0x623>
  104ca6:	c7 44 24 0c be 6c 10 	movl   $0x106cbe,0xc(%esp)
  104cad:	00 
  104cae:	c7 44 24 08 51 6a 10 	movl   $0x106a51,0x8(%esp)
  104cb5:	00 
  104cb6:	c7 44 24 04 05 02 00 	movl   $0x205,0x4(%esp)
  104cbd:	00 
  104cbe:	c7 04 24 2c 6a 10 00 	movl   $0x106a2c,(%esp)
  104cc5:	e8 4e bf ff ff       	call   100c18 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
  104cca:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104ccf:	8b 00                	mov    (%eax),%eax
  104cd1:	89 04 24             	mov    %eax,(%esp)
  104cd4:	e8 eb ed ff ff       	call   103ac4 <pde2page>
  104cd9:	89 04 24             	mov    %eax,(%esp)
  104cdc:	e8 fb ed ff ff       	call   103adc <page_ref>
  104ce1:	83 f8 01             	cmp    $0x1,%eax
  104ce4:	74 24                	je     104d0a <check_pgdir+0x663>
  104ce6:	c7 44 24 0c f8 6c 10 	movl   $0x106cf8,0xc(%esp)
  104ced:	00 
  104cee:	c7 44 24 08 51 6a 10 	movl   $0x106a51,0x8(%esp)
  104cf5:	00 
  104cf6:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
  104cfd:	00 
  104cfe:	c7 04 24 2c 6a 10 00 	movl   $0x106a2c,(%esp)
  104d05:	e8 0e bf ff ff       	call   100c18 <__panic>
    free_page(pde2page(boot_pgdir[0]));
  104d0a:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104d0f:	8b 00                	mov    (%eax),%eax
  104d11:	89 04 24             	mov    %eax,(%esp)
  104d14:	e8 ab ed ff ff       	call   103ac4 <pde2page>
  104d19:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104d20:	00 
  104d21:	89 04 24             	mov    %eax,(%esp)
  104d24:	e8 f0 ef ff ff       	call   103d19 <free_pages>
    boot_pgdir[0] = 0;
  104d29:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104d2e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
  104d34:	c7 04 24 1f 6d 10 00 	movl   $0x106d1f,(%esp)
  104d3b:	e8 08 b6 ff ff       	call   100348 <cprintf>
}
  104d40:	c9                   	leave  
  104d41:	c3                   	ret    

00104d42 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
  104d42:	55                   	push   %ebp
  104d43:	89 e5                	mov    %esp,%ebp
  104d45:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  104d48:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  104d4f:	e9 ca 00 00 00       	jmp    104e1e <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
  104d54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104d57:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104d5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104d5d:	c1 e8 0c             	shr    $0xc,%eax
  104d60:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104d63:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  104d68:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  104d6b:	72 23                	jb     104d90 <check_boot_pgdir+0x4e>
  104d6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104d70:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104d74:	c7 44 24 08 64 69 10 	movl   $0x106964,0x8(%esp)
  104d7b:	00 
  104d7c:	c7 44 24 04 13 02 00 	movl   $0x213,0x4(%esp)
  104d83:	00 
  104d84:	c7 04 24 2c 6a 10 00 	movl   $0x106a2c,(%esp)
  104d8b:	e8 88 be ff ff       	call   100c18 <__panic>
  104d90:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104d93:	2d 00 00 00 40       	sub    $0x40000000,%eax
  104d98:	89 c2                	mov    %eax,%edx
  104d9a:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104d9f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104da6:	00 
  104da7:	89 54 24 04          	mov    %edx,0x4(%esp)
  104dab:	89 04 24             	mov    %eax,(%esp)
  104dae:	e8 ea f5 ff ff       	call   10439d <get_pte>
  104db3:	89 45 e8             	mov    %eax,-0x18(%ebp)
  104db6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  104dba:	75 24                	jne    104de0 <check_boot_pgdir+0x9e>
  104dbc:	c7 44 24 0c 3c 6d 10 	movl   $0x106d3c,0xc(%esp)
  104dc3:	00 
  104dc4:	c7 44 24 08 51 6a 10 	movl   $0x106a51,0x8(%esp)
  104dcb:	00 
  104dcc:	c7 44 24 04 13 02 00 	movl   $0x213,0x4(%esp)
  104dd3:	00 
  104dd4:	c7 04 24 2c 6a 10 00 	movl   $0x106a2c,(%esp)
  104ddb:	e8 38 be ff ff       	call   100c18 <__panic>
        assert(PTE_ADDR(*ptep) == i);
  104de0:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104de3:	8b 00                	mov    (%eax),%eax
  104de5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104dea:	89 c2                	mov    %eax,%edx
  104dec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104def:	39 c2                	cmp    %eax,%edx
  104df1:	74 24                	je     104e17 <check_boot_pgdir+0xd5>
  104df3:	c7 44 24 0c 79 6d 10 	movl   $0x106d79,0xc(%esp)
  104dfa:	00 
  104dfb:	c7 44 24 08 51 6a 10 	movl   $0x106a51,0x8(%esp)
  104e02:	00 
  104e03:	c7 44 24 04 14 02 00 	movl   $0x214,0x4(%esp)
  104e0a:	00 
  104e0b:	c7 04 24 2c 6a 10 00 	movl   $0x106a2c,(%esp)
  104e12:	e8 01 be ff ff       	call   100c18 <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  104e17:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  104e1e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104e21:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  104e26:	39 c2                	cmp    %eax,%edx
  104e28:	0f 82 26 ff ff ff    	jb     104d54 <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
  104e2e:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104e33:	05 ac 0f 00 00       	add    $0xfac,%eax
  104e38:	8b 00                	mov    (%eax),%eax
  104e3a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104e3f:	89 c2                	mov    %eax,%edx
  104e41:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104e46:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104e49:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
  104e50:	77 23                	ja     104e75 <check_boot_pgdir+0x133>
  104e52:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104e55:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104e59:	c7 44 24 08 08 6a 10 	movl   $0x106a08,0x8(%esp)
  104e60:	00 
  104e61:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
  104e68:	00 
  104e69:	c7 04 24 2c 6a 10 00 	movl   $0x106a2c,(%esp)
  104e70:	e8 a3 bd ff ff       	call   100c18 <__panic>
  104e75:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104e78:	05 00 00 00 40       	add    $0x40000000,%eax
  104e7d:	39 c2                	cmp    %eax,%edx
  104e7f:	74 24                	je     104ea5 <check_boot_pgdir+0x163>
  104e81:	c7 44 24 0c 90 6d 10 	movl   $0x106d90,0xc(%esp)
  104e88:	00 
  104e89:	c7 44 24 08 51 6a 10 	movl   $0x106a51,0x8(%esp)
  104e90:	00 
  104e91:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
  104e98:	00 
  104e99:	c7 04 24 2c 6a 10 00 	movl   $0x106a2c,(%esp)
  104ea0:	e8 73 bd ff ff       	call   100c18 <__panic>

    assert(boot_pgdir[0] == 0);
  104ea5:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104eaa:	8b 00                	mov    (%eax),%eax
  104eac:	85 c0                	test   %eax,%eax
  104eae:	74 24                	je     104ed4 <check_boot_pgdir+0x192>
  104eb0:	c7 44 24 0c c4 6d 10 	movl   $0x106dc4,0xc(%esp)
  104eb7:	00 
  104eb8:	c7 44 24 08 51 6a 10 	movl   $0x106a51,0x8(%esp)
  104ebf:	00 
  104ec0:	c7 44 24 04 19 02 00 	movl   $0x219,0x4(%esp)
  104ec7:	00 
  104ec8:	c7 04 24 2c 6a 10 00 	movl   $0x106a2c,(%esp)
  104ecf:	e8 44 bd ff ff       	call   100c18 <__panic>

    struct Page *p;
    p = alloc_page();
  104ed4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104edb:	e8 01 ee ff ff       	call   103ce1 <alloc_pages>
  104ee0:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
  104ee3:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104ee8:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  104eef:	00 
  104ef0:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
  104ef7:	00 
  104ef8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  104efb:	89 54 24 04          	mov    %edx,0x4(%esp)
  104eff:	89 04 24             	mov    %eax,(%esp)
  104f02:	e8 6c f6 ff ff       	call   104573 <page_insert>
  104f07:	85 c0                	test   %eax,%eax
  104f09:	74 24                	je     104f2f <check_boot_pgdir+0x1ed>
  104f0b:	c7 44 24 0c d8 6d 10 	movl   $0x106dd8,0xc(%esp)
  104f12:	00 
  104f13:	c7 44 24 08 51 6a 10 	movl   $0x106a51,0x8(%esp)
  104f1a:	00 
  104f1b:	c7 44 24 04 1d 02 00 	movl   $0x21d,0x4(%esp)
  104f22:	00 
  104f23:	c7 04 24 2c 6a 10 00 	movl   $0x106a2c,(%esp)
  104f2a:	e8 e9 bc ff ff       	call   100c18 <__panic>
    assert(page_ref(p) == 1);
  104f2f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104f32:	89 04 24             	mov    %eax,(%esp)
  104f35:	e8 a2 eb ff ff       	call   103adc <page_ref>
  104f3a:	83 f8 01             	cmp    $0x1,%eax
  104f3d:	74 24                	je     104f63 <check_boot_pgdir+0x221>
  104f3f:	c7 44 24 0c 06 6e 10 	movl   $0x106e06,0xc(%esp)
  104f46:	00 
  104f47:	c7 44 24 08 51 6a 10 	movl   $0x106a51,0x8(%esp)
  104f4e:	00 
  104f4f:	c7 44 24 04 1e 02 00 	movl   $0x21e,0x4(%esp)
  104f56:	00 
  104f57:	c7 04 24 2c 6a 10 00 	movl   $0x106a2c,(%esp)
  104f5e:	e8 b5 bc ff ff       	call   100c18 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
  104f63:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104f68:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  104f6f:	00 
  104f70:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
  104f77:	00 
  104f78:	8b 55 e0             	mov    -0x20(%ebp),%edx
  104f7b:	89 54 24 04          	mov    %edx,0x4(%esp)
  104f7f:	89 04 24             	mov    %eax,(%esp)
  104f82:	e8 ec f5 ff ff       	call   104573 <page_insert>
  104f87:	85 c0                	test   %eax,%eax
  104f89:	74 24                	je     104faf <check_boot_pgdir+0x26d>
  104f8b:	c7 44 24 0c 18 6e 10 	movl   $0x106e18,0xc(%esp)
  104f92:	00 
  104f93:	c7 44 24 08 51 6a 10 	movl   $0x106a51,0x8(%esp)
  104f9a:	00 
  104f9b:	c7 44 24 04 1f 02 00 	movl   $0x21f,0x4(%esp)
  104fa2:	00 
  104fa3:	c7 04 24 2c 6a 10 00 	movl   $0x106a2c,(%esp)
  104faa:	e8 69 bc ff ff       	call   100c18 <__panic>
    assert(page_ref(p) == 2);
  104faf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104fb2:	89 04 24             	mov    %eax,(%esp)
  104fb5:	e8 22 eb ff ff       	call   103adc <page_ref>
  104fba:	83 f8 02             	cmp    $0x2,%eax
  104fbd:	74 24                	je     104fe3 <check_boot_pgdir+0x2a1>
  104fbf:	c7 44 24 0c 4f 6e 10 	movl   $0x106e4f,0xc(%esp)
  104fc6:	00 
  104fc7:	c7 44 24 08 51 6a 10 	movl   $0x106a51,0x8(%esp)
  104fce:	00 
  104fcf:	c7 44 24 04 20 02 00 	movl   $0x220,0x4(%esp)
  104fd6:	00 
  104fd7:	c7 04 24 2c 6a 10 00 	movl   $0x106a2c,(%esp)
  104fde:	e8 35 bc ff ff       	call   100c18 <__panic>

    const char *str = "ucore: Hello world!!";
  104fe3:	c7 45 dc 60 6e 10 00 	movl   $0x106e60,-0x24(%ebp)
    strcpy((void *)0x100, str);
  104fea:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104fed:	89 44 24 04          	mov    %eax,0x4(%esp)
  104ff1:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  104ff8:	e8 19 0a 00 00       	call   105a16 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
  104ffd:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
  105004:	00 
  105005:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  10500c:	e8 7e 0a 00 00       	call   105a8f <strcmp>
  105011:	85 c0                	test   %eax,%eax
  105013:	74 24                	je     105039 <check_boot_pgdir+0x2f7>
  105015:	c7 44 24 0c 78 6e 10 	movl   $0x106e78,0xc(%esp)
  10501c:	00 
  10501d:	c7 44 24 08 51 6a 10 	movl   $0x106a51,0x8(%esp)
  105024:	00 
  105025:	c7 44 24 04 24 02 00 	movl   $0x224,0x4(%esp)
  10502c:	00 
  10502d:	c7 04 24 2c 6a 10 00 	movl   $0x106a2c,(%esp)
  105034:	e8 df bb ff ff       	call   100c18 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
  105039:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10503c:	89 04 24             	mov    %eax,(%esp)
  10503f:	e8 ee e9 ff ff       	call   103a32 <page2kva>
  105044:	05 00 01 00 00       	add    $0x100,%eax
  105049:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
  10504c:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  105053:	e8 66 09 00 00       	call   1059be <strlen>
  105058:	85 c0                	test   %eax,%eax
  10505a:	74 24                	je     105080 <check_boot_pgdir+0x33e>
  10505c:	c7 44 24 0c b0 6e 10 	movl   $0x106eb0,0xc(%esp)
  105063:	00 
  105064:	c7 44 24 08 51 6a 10 	movl   $0x106a51,0x8(%esp)
  10506b:	00 
  10506c:	c7 44 24 04 27 02 00 	movl   $0x227,0x4(%esp)
  105073:	00 
  105074:	c7 04 24 2c 6a 10 00 	movl   $0x106a2c,(%esp)
  10507b:	e8 98 bb ff ff       	call   100c18 <__panic>

    free_page(p);
  105080:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105087:	00 
  105088:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10508b:	89 04 24             	mov    %eax,(%esp)
  10508e:	e8 86 ec ff ff       	call   103d19 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
  105093:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  105098:	8b 00                	mov    (%eax),%eax
  10509a:	89 04 24             	mov    %eax,(%esp)
  10509d:	e8 22 ea ff ff       	call   103ac4 <pde2page>
  1050a2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1050a9:	00 
  1050aa:	89 04 24             	mov    %eax,(%esp)
  1050ad:	e8 67 ec ff ff       	call   103d19 <free_pages>
    boot_pgdir[0] = 0;
  1050b2:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1050b7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
  1050bd:	c7 04 24 d4 6e 10 00 	movl   $0x106ed4,(%esp)
  1050c4:	e8 7f b2 ff ff       	call   100348 <cprintf>
}
  1050c9:	c9                   	leave  
  1050ca:	c3                   	ret    

001050cb <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
  1050cb:	55                   	push   %ebp
  1050cc:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
  1050ce:	8b 45 08             	mov    0x8(%ebp),%eax
  1050d1:	83 e0 04             	and    $0x4,%eax
  1050d4:	85 c0                	test   %eax,%eax
  1050d6:	74 07                	je     1050df <perm2str+0x14>
  1050d8:	b8 75 00 00 00       	mov    $0x75,%eax
  1050dd:	eb 05                	jmp    1050e4 <perm2str+0x19>
  1050df:	b8 2d 00 00 00       	mov    $0x2d,%eax
  1050e4:	a2 08 af 11 00       	mov    %al,0x11af08
    str[1] = 'r';
  1050e9:	c6 05 09 af 11 00 72 	movb   $0x72,0x11af09
    str[2] = (perm & PTE_W) ? 'w' : '-';
  1050f0:	8b 45 08             	mov    0x8(%ebp),%eax
  1050f3:	83 e0 02             	and    $0x2,%eax
  1050f6:	85 c0                	test   %eax,%eax
  1050f8:	74 07                	je     105101 <perm2str+0x36>
  1050fa:	b8 77 00 00 00       	mov    $0x77,%eax
  1050ff:	eb 05                	jmp    105106 <perm2str+0x3b>
  105101:	b8 2d 00 00 00       	mov    $0x2d,%eax
  105106:	a2 0a af 11 00       	mov    %al,0x11af0a
    str[3] = '\0';
  10510b:	c6 05 0b af 11 00 00 	movb   $0x0,0x11af0b
    return str;
  105112:	b8 08 af 11 00       	mov    $0x11af08,%eax
}
  105117:	5d                   	pop    %ebp
  105118:	c3                   	ret    

00105119 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
  105119:	55                   	push   %ebp
  10511a:	89 e5                	mov    %esp,%ebp
  10511c:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
  10511f:	8b 45 10             	mov    0x10(%ebp),%eax
  105122:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105125:	72 0a                	jb     105131 <get_pgtable_items+0x18>
        return 0;
  105127:	b8 00 00 00 00       	mov    $0x0,%eax
  10512c:	e9 9c 00 00 00       	jmp    1051cd <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
  105131:	eb 04                	jmp    105137 <get_pgtable_items+0x1e>
        start ++;
  105133:	83 45 10 01          	addl   $0x1,0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
  105137:	8b 45 10             	mov    0x10(%ebp),%eax
  10513a:	3b 45 0c             	cmp    0xc(%ebp),%eax
  10513d:	73 18                	jae    105157 <get_pgtable_items+0x3e>
  10513f:	8b 45 10             	mov    0x10(%ebp),%eax
  105142:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  105149:	8b 45 14             	mov    0x14(%ebp),%eax
  10514c:	01 d0                	add    %edx,%eax
  10514e:	8b 00                	mov    (%eax),%eax
  105150:	83 e0 01             	and    $0x1,%eax
  105153:	85 c0                	test   %eax,%eax
  105155:	74 dc                	je     105133 <get_pgtable_items+0x1a>
        start ++;
    }
    if (start < right) {
  105157:	8b 45 10             	mov    0x10(%ebp),%eax
  10515a:	3b 45 0c             	cmp    0xc(%ebp),%eax
  10515d:	73 69                	jae    1051c8 <get_pgtable_items+0xaf>
        if (left_store != NULL) {
  10515f:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
  105163:	74 08                	je     10516d <get_pgtable_items+0x54>
            *left_store = start;
  105165:	8b 45 18             	mov    0x18(%ebp),%eax
  105168:	8b 55 10             	mov    0x10(%ebp),%edx
  10516b:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
  10516d:	8b 45 10             	mov    0x10(%ebp),%eax
  105170:	8d 50 01             	lea    0x1(%eax),%edx
  105173:	89 55 10             	mov    %edx,0x10(%ebp)
  105176:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  10517d:	8b 45 14             	mov    0x14(%ebp),%eax
  105180:	01 d0                	add    %edx,%eax
  105182:	8b 00                	mov    (%eax),%eax
  105184:	83 e0 07             	and    $0x7,%eax
  105187:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  10518a:	eb 04                	jmp    105190 <get_pgtable_items+0x77>
            start ++;
  10518c:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
  105190:	8b 45 10             	mov    0x10(%ebp),%eax
  105193:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105196:	73 1d                	jae    1051b5 <get_pgtable_items+0x9c>
  105198:	8b 45 10             	mov    0x10(%ebp),%eax
  10519b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1051a2:	8b 45 14             	mov    0x14(%ebp),%eax
  1051a5:	01 d0                	add    %edx,%eax
  1051a7:	8b 00                	mov    (%eax),%eax
  1051a9:	83 e0 07             	and    $0x7,%eax
  1051ac:	89 c2                	mov    %eax,%edx
  1051ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1051b1:	39 c2                	cmp    %eax,%edx
  1051b3:	74 d7                	je     10518c <get_pgtable_items+0x73>
            start ++;
        }
        if (right_store != NULL) {
  1051b5:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  1051b9:	74 08                	je     1051c3 <get_pgtable_items+0xaa>
            *right_store = start;
  1051bb:	8b 45 1c             	mov    0x1c(%ebp),%eax
  1051be:	8b 55 10             	mov    0x10(%ebp),%edx
  1051c1:	89 10                	mov    %edx,(%eax)
        }
        return perm;
  1051c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1051c6:	eb 05                	jmp    1051cd <get_pgtable_items+0xb4>
    }
    return 0;
  1051c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1051cd:	c9                   	leave  
  1051ce:	c3                   	ret    

001051cf <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  1051cf:	55                   	push   %ebp
  1051d0:	89 e5                	mov    %esp,%ebp
  1051d2:	57                   	push   %edi
  1051d3:	56                   	push   %esi
  1051d4:	53                   	push   %ebx
  1051d5:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
  1051d8:	c7 04 24 f4 6e 10 00 	movl   $0x106ef4,(%esp)
  1051df:	e8 64 b1 ff ff       	call   100348 <cprintf>
    size_t left, right = 0, perm;
  1051e4:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  1051eb:	e9 fa 00 00 00       	jmp    1052ea <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  1051f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1051f3:	89 04 24             	mov    %eax,(%esp)
  1051f6:	e8 d0 fe ff ff       	call   1050cb <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
  1051fb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  1051fe:	8b 55 e0             	mov    -0x20(%ebp),%edx
  105201:	29 d1                	sub    %edx,%ecx
  105203:	89 ca                	mov    %ecx,%edx
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  105205:	89 d6                	mov    %edx,%esi
  105207:	c1 e6 16             	shl    $0x16,%esi
  10520a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10520d:	89 d3                	mov    %edx,%ebx
  10520f:	c1 e3 16             	shl    $0x16,%ebx
  105212:	8b 55 e0             	mov    -0x20(%ebp),%edx
  105215:	89 d1                	mov    %edx,%ecx
  105217:	c1 e1 16             	shl    $0x16,%ecx
  10521a:	8b 7d dc             	mov    -0x24(%ebp),%edi
  10521d:	8b 55 e0             	mov    -0x20(%ebp),%edx
  105220:	29 d7                	sub    %edx,%edi
  105222:	89 fa                	mov    %edi,%edx
  105224:	89 44 24 14          	mov    %eax,0x14(%esp)
  105228:	89 74 24 10          	mov    %esi,0x10(%esp)
  10522c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  105230:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  105234:	89 54 24 04          	mov    %edx,0x4(%esp)
  105238:	c7 04 24 25 6f 10 00 	movl   $0x106f25,(%esp)
  10523f:	e8 04 b1 ff ff       	call   100348 <cprintf>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
  105244:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105247:	c1 e0 0a             	shl    $0xa,%eax
  10524a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  10524d:	eb 54                	jmp    1052a3 <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  10524f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105252:	89 04 24             	mov    %eax,(%esp)
  105255:	e8 71 fe ff ff       	call   1050cb <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
  10525a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  10525d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  105260:	29 d1                	sub    %edx,%ecx
  105262:	89 ca                	mov    %ecx,%edx
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  105264:	89 d6                	mov    %edx,%esi
  105266:	c1 e6 0c             	shl    $0xc,%esi
  105269:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10526c:	89 d3                	mov    %edx,%ebx
  10526e:	c1 e3 0c             	shl    $0xc,%ebx
  105271:	8b 55 d8             	mov    -0x28(%ebp),%edx
  105274:	c1 e2 0c             	shl    $0xc,%edx
  105277:	89 d1                	mov    %edx,%ecx
  105279:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  10527c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  10527f:	29 d7                	sub    %edx,%edi
  105281:	89 fa                	mov    %edi,%edx
  105283:	89 44 24 14          	mov    %eax,0x14(%esp)
  105287:	89 74 24 10          	mov    %esi,0x10(%esp)
  10528b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  10528f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  105293:	89 54 24 04          	mov    %edx,0x4(%esp)
  105297:	c7 04 24 44 6f 10 00 	movl   $0x106f44,(%esp)
  10529e:	e8 a5 b0 ff ff       	call   100348 <cprintf>
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  1052a3:	ba 00 00 c0 fa       	mov    $0xfac00000,%edx
  1052a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1052ab:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  1052ae:	89 ce                	mov    %ecx,%esi
  1052b0:	c1 e6 0a             	shl    $0xa,%esi
  1052b3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  1052b6:	89 cb                	mov    %ecx,%ebx
  1052b8:	c1 e3 0a             	shl    $0xa,%ebx
  1052bb:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
  1052be:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  1052c2:	8d 4d d8             	lea    -0x28(%ebp),%ecx
  1052c5:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  1052c9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  1052cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  1052d1:	89 74 24 04          	mov    %esi,0x4(%esp)
  1052d5:	89 1c 24             	mov    %ebx,(%esp)
  1052d8:	e8 3c fe ff ff       	call   105119 <get_pgtable_items>
  1052dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1052e0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1052e4:	0f 85 65 ff ff ff    	jne    10524f <print_pgdir+0x80>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  1052ea:	ba 00 b0 fe fa       	mov    $0xfafeb000,%edx
  1052ef:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1052f2:	8d 4d dc             	lea    -0x24(%ebp),%ecx
  1052f5:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  1052f9:	8d 4d e0             	lea    -0x20(%ebp),%ecx
  1052fc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  105300:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105304:	89 44 24 08          	mov    %eax,0x8(%esp)
  105308:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
  10530f:	00 
  105310:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  105317:	e8 fd fd ff ff       	call   105119 <get_pgtable_items>
  10531c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10531f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105323:	0f 85 c7 fe ff ff    	jne    1051f0 <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
  105329:	c7 04 24 68 6f 10 00 	movl   $0x106f68,(%esp)
  105330:	e8 13 b0 ff ff       	call   100348 <cprintf>
}
  105335:	83 c4 4c             	add    $0x4c,%esp
  105338:	5b                   	pop    %ebx
  105339:	5e                   	pop    %esi
  10533a:	5f                   	pop    %edi
  10533b:	5d                   	pop    %ebp
  10533c:	c3                   	ret    

0010533d <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  10533d:	55                   	push   %ebp
  10533e:	89 e5                	mov    %esp,%ebp
  105340:	83 ec 58             	sub    $0x58,%esp
  105343:	8b 45 10             	mov    0x10(%ebp),%eax
  105346:	89 45 d0             	mov    %eax,-0x30(%ebp)
  105349:	8b 45 14             	mov    0x14(%ebp),%eax
  10534c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  10534f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  105352:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  105355:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105358:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  10535b:	8b 45 18             	mov    0x18(%ebp),%eax
  10535e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105361:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105364:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105367:	89 45 e0             	mov    %eax,-0x20(%ebp)
  10536a:	89 55 f0             	mov    %edx,-0x10(%ebp)
  10536d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105370:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105373:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  105377:	74 1c                	je     105395 <printnum+0x58>
  105379:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10537c:	ba 00 00 00 00       	mov    $0x0,%edx
  105381:	f7 75 e4             	divl   -0x1c(%ebp)
  105384:	89 55 f4             	mov    %edx,-0xc(%ebp)
  105387:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10538a:	ba 00 00 00 00       	mov    $0x0,%edx
  10538f:	f7 75 e4             	divl   -0x1c(%ebp)
  105392:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105395:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105398:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10539b:	f7 75 e4             	divl   -0x1c(%ebp)
  10539e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1053a1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  1053a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1053a7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1053aa:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1053ad:	89 55 ec             	mov    %edx,-0x14(%ebp)
  1053b0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1053b3:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  1053b6:	8b 45 18             	mov    0x18(%ebp),%eax
  1053b9:	ba 00 00 00 00       	mov    $0x0,%edx
  1053be:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  1053c1:	77 56                	ja     105419 <printnum+0xdc>
  1053c3:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  1053c6:	72 05                	jb     1053cd <printnum+0x90>
  1053c8:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  1053cb:	77 4c                	ja     105419 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
  1053cd:	8b 45 1c             	mov    0x1c(%ebp),%eax
  1053d0:	8d 50 ff             	lea    -0x1(%eax),%edx
  1053d3:	8b 45 20             	mov    0x20(%ebp),%eax
  1053d6:	89 44 24 18          	mov    %eax,0x18(%esp)
  1053da:	89 54 24 14          	mov    %edx,0x14(%esp)
  1053de:	8b 45 18             	mov    0x18(%ebp),%eax
  1053e1:	89 44 24 10          	mov    %eax,0x10(%esp)
  1053e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1053e8:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1053eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  1053ef:	89 54 24 0c          	mov    %edx,0xc(%esp)
  1053f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1053f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  1053fa:	8b 45 08             	mov    0x8(%ebp),%eax
  1053fd:	89 04 24             	mov    %eax,(%esp)
  105400:	e8 38 ff ff ff       	call   10533d <printnum>
  105405:	eb 1c                	jmp    105423 <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  105407:	8b 45 0c             	mov    0xc(%ebp),%eax
  10540a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10540e:	8b 45 20             	mov    0x20(%ebp),%eax
  105411:	89 04 24             	mov    %eax,(%esp)
  105414:	8b 45 08             	mov    0x8(%ebp),%eax
  105417:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  105419:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  10541d:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  105421:	7f e4                	jg     105407 <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  105423:	8b 45 d8             	mov    -0x28(%ebp),%eax
  105426:	05 1c 70 10 00       	add    $0x10701c,%eax
  10542b:	0f b6 00             	movzbl (%eax),%eax
  10542e:	0f be c0             	movsbl %al,%eax
  105431:	8b 55 0c             	mov    0xc(%ebp),%edx
  105434:	89 54 24 04          	mov    %edx,0x4(%esp)
  105438:	89 04 24             	mov    %eax,(%esp)
  10543b:	8b 45 08             	mov    0x8(%ebp),%eax
  10543e:	ff d0                	call   *%eax
}
  105440:	c9                   	leave  
  105441:	c3                   	ret    

00105442 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  105442:	55                   	push   %ebp
  105443:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  105445:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  105449:	7e 14                	jle    10545f <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  10544b:	8b 45 08             	mov    0x8(%ebp),%eax
  10544e:	8b 00                	mov    (%eax),%eax
  105450:	8d 48 08             	lea    0x8(%eax),%ecx
  105453:	8b 55 08             	mov    0x8(%ebp),%edx
  105456:	89 0a                	mov    %ecx,(%edx)
  105458:	8b 50 04             	mov    0x4(%eax),%edx
  10545b:	8b 00                	mov    (%eax),%eax
  10545d:	eb 30                	jmp    10548f <getuint+0x4d>
    }
    else if (lflag) {
  10545f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105463:	74 16                	je     10547b <getuint+0x39>
        return va_arg(*ap, unsigned long);
  105465:	8b 45 08             	mov    0x8(%ebp),%eax
  105468:	8b 00                	mov    (%eax),%eax
  10546a:	8d 48 04             	lea    0x4(%eax),%ecx
  10546d:	8b 55 08             	mov    0x8(%ebp),%edx
  105470:	89 0a                	mov    %ecx,(%edx)
  105472:	8b 00                	mov    (%eax),%eax
  105474:	ba 00 00 00 00       	mov    $0x0,%edx
  105479:	eb 14                	jmp    10548f <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  10547b:	8b 45 08             	mov    0x8(%ebp),%eax
  10547e:	8b 00                	mov    (%eax),%eax
  105480:	8d 48 04             	lea    0x4(%eax),%ecx
  105483:	8b 55 08             	mov    0x8(%ebp),%edx
  105486:	89 0a                	mov    %ecx,(%edx)
  105488:	8b 00                	mov    (%eax),%eax
  10548a:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  10548f:	5d                   	pop    %ebp
  105490:	c3                   	ret    

00105491 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  105491:	55                   	push   %ebp
  105492:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  105494:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  105498:	7e 14                	jle    1054ae <getint+0x1d>
        return va_arg(*ap, long long);
  10549a:	8b 45 08             	mov    0x8(%ebp),%eax
  10549d:	8b 00                	mov    (%eax),%eax
  10549f:	8d 48 08             	lea    0x8(%eax),%ecx
  1054a2:	8b 55 08             	mov    0x8(%ebp),%edx
  1054a5:	89 0a                	mov    %ecx,(%edx)
  1054a7:	8b 50 04             	mov    0x4(%eax),%edx
  1054aa:	8b 00                	mov    (%eax),%eax
  1054ac:	eb 28                	jmp    1054d6 <getint+0x45>
    }
    else if (lflag) {
  1054ae:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1054b2:	74 12                	je     1054c6 <getint+0x35>
        return va_arg(*ap, long);
  1054b4:	8b 45 08             	mov    0x8(%ebp),%eax
  1054b7:	8b 00                	mov    (%eax),%eax
  1054b9:	8d 48 04             	lea    0x4(%eax),%ecx
  1054bc:	8b 55 08             	mov    0x8(%ebp),%edx
  1054bf:	89 0a                	mov    %ecx,(%edx)
  1054c1:	8b 00                	mov    (%eax),%eax
  1054c3:	99                   	cltd   
  1054c4:	eb 10                	jmp    1054d6 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  1054c6:	8b 45 08             	mov    0x8(%ebp),%eax
  1054c9:	8b 00                	mov    (%eax),%eax
  1054cb:	8d 48 04             	lea    0x4(%eax),%ecx
  1054ce:	8b 55 08             	mov    0x8(%ebp),%edx
  1054d1:	89 0a                	mov    %ecx,(%edx)
  1054d3:	8b 00                	mov    (%eax),%eax
  1054d5:	99                   	cltd   
    }
}
  1054d6:	5d                   	pop    %ebp
  1054d7:	c3                   	ret    

001054d8 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  1054d8:	55                   	push   %ebp
  1054d9:	89 e5                	mov    %esp,%ebp
  1054db:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  1054de:	8d 45 14             	lea    0x14(%ebp),%eax
  1054e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  1054e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1054e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1054eb:	8b 45 10             	mov    0x10(%ebp),%eax
  1054ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  1054f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1054f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  1054f9:	8b 45 08             	mov    0x8(%ebp),%eax
  1054fc:	89 04 24             	mov    %eax,(%esp)
  1054ff:	e8 02 00 00 00       	call   105506 <vprintfmt>
    va_end(ap);
}
  105504:	c9                   	leave  
  105505:	c3                   	ret    

00105506 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  105506:	55                   	push   %ebp
  105507:	89 e5                	mov    %esp,%ebp
  105509:	56                   	push   %esi
  10550a:	53                   	push   %ebx
  10550b:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  10550e:	eb 18                	jmp    105528 <vprintfmt+0x22>
            if (ch == '\0') {
  105510:	85 db                	test   %ebx,%ebx
  105512:	75 05                	jne    105519 <vprintfmt+0x13>
                return;
  105514:	e9 d1 03 00 00       	jmp    1058ea <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
  105519:	8b 45 0c             	mov    0xc(%ebp),%eax
  10551c:	89 44 24 04          	mov    %eax,0x4(%esp)
  105520:	89 1c 24             	mov    %ebx,(%esp)
  105523:	8b 45 08             	mov    0x8(%ebp),%eax
  105526:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105528:	8b 45 10             	mov    0x10(%ebp),%eax
  10552b:	8d 50 01             	lea    0x1(%eax),%edx
  10552e:	89 55 10             	mov    %edx,0x10(%ebp)
  105531:	0f b6 00             	movzbl (%eax),%eax
  105534:	0f b6 d8             	movzbl %al,%ebx
  105537:	83 fb 25             	cmp    $0x25,%ebx
  10553a:	75 d4                	jne    105510 <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
  10553c:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  105540:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  105547:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10554a:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  10554d:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  105554:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105557:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  10555a:	8b 45 10             	mov    0x10(%ebp),%eax
  10555d:	8d 50 01             	lea    0x1(%eax),%edx
  105560:	89 55 10             	mov    %edx,0x10(%ebp)
  105563:	0f b6 00             	movzbl (%eax),%eax
  105566:	0f b6 d8             	movzbl %al,%ebx
  105569:	8d 43 dd             	lea    -0x23(%ebx),%eax
  10556c:	83 f8 55             	cmp    $0x55,%eax
  10556f:	0f 87 44 03 00 00    	ja     1058b9 <vprintfmt+0x3b3>
  105575:	8b 04 85 40 70 10 00 	mov    0x107040(,%eax,4),%eax
  10557c:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  10557e:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  105582:	eb d6                	jmp    10555a <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  105584:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  105588:	eb d0                	jmp    10555a <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  10558a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  105591:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  105594:	89 d0                	mov    %edx,%eax
  105596:	c1 e0 02             	shl    $0x2,%eax
  105599:	01 d0                	add    %edx,%eax
  10559b:	01 c0                	add    %eax,%eax
  10559d:	01 d8                	add    %ebx,%eax
  10559f:	83 e8 30             	sub    $0x30,%eax
  1055a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  1055a5:	8b 45 10             	mov    0x10(%ebp),%eax
  1055a8:	0f b6 00             	movzbl (%eax),%eax
  1055ab:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  1055ae:	83 fb 2f             	cmp    $0x2f,%ebx
  1055b1:	7e 0b                	jle    1055be <vprintfmt+0xb8>
  1055b3:	83 fb 39             	cmp    $0x39,%ebx
  1055b6:	7f 06                	jg     1055be <vprintfmt+0xb8>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  1055b8:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
  1055bc:	eb d3                	jmp    105591 <vprintfmt+0x8b>
            goto process_precision;
  1055be:	eb 33                	jmp    1055f3 <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
  1055c0:	8b 45 14             	mov    0x14(%ebp),%eax
  1055c3:	8d 50 04             	lea    0x4(%eax),%edx
  1055c6:	89 55 14             	mov    %edx,0x14(%ebp)
  1055c9:	8b 00                	mov    (%eax),%eax
  1055cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  1055ce:	eb 23                	jmp    1055f3 <vprintfmt+0xed>

        case '.':
            if (width < 0)
  1055d0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1055d4:	79 0c                	jns    1055e2 <vprintfmt+0xdc>
                width = 0;
  1055d6:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  1055dd:	e9 78 ff ff ff       	jmp    10555a <vprintfmt+0x54>
  1055e2:	e9 73 ff ff ff       	jmp    10555a <vprintfmt+0x54>

        case '#':
            altflag = 1;
  1055e7:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  1055ee:	e9 67 ff ff ff       	jmp    10555a <vprintfmt+0x54>

        process_precision:
            if (width < 0)
  1055f3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1055f7:	79 12                	jns    10560b <vprintfmt+0x105>
                width = precision, precision = -1;
  1055f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1055fc:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1055ff:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  105606:	e9 4f ff ff ff       	jmp    10555a <vprintfmt+0x54>
  10560b:	e9 4a ff ff ff       	jmp    10555a <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  105610:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
  105614:	e9 41 ff ff ff       	jmp    10555a <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  105619:	8b 45 14             	mov    0x14(%ebp),%eax
  10561c:	8d 50 04             	lea    0x4(%eax),%edx
  10561f:	89 55 14             	mov    %edx,0x14(%ebp)
  105622:	8b 00                	mov    (%eax),%eax
  105624:	8b 55 0c             	mov    0xc(%ebp),%edx
  105627:	89 54 24 04          	mov    %edx,0x4(%esp)
  10562b:	89 04 24             	mov    %eax,(%esp)
  10562e:	8b 45 08             	mov    0x8(%ebp),%eax
  105631:	ff d0                	call   *%eax
            break;
  105633:	e9 ac 02 00 00       	jmp    1058e4 <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
  105638:	8b 45 14             	mov    0x14(%ebp),%eax
  10563b:	8d 50 04             	lea    0x4(%eax),%edx
  10563e:	89 55 14             	mov    %edx,0x14(%ebp)
  105641:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  105643:	85 db                	test   %ebx,%ebx
  105645:	79 02                	jns    105649 <vprintfmt+0x143>
                err = -err;
  105647:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  105649:	83 fb 06             	cmp    $0x6,%ebx
  10564c:	7f 0b                	jg     105659 <vprintfmt+0x153>
  10564e:	8b 34 9d 00 70 10 00 	mov    0x107000(,%ebx,4),%esi
  105655:	85 f6                	test   %esi,%esi
  105657:	75 23                	jne    10567c <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
  105659:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  10565d:	c7 44 24 08 2d 70 10 	movl   $0x10702d,0x8(%esp)
  105664:	00 
  105665:	8b 45 0c             	mov    0xc(%ebp),%eax
  105668:	89 44 24 04          	mov    %eax,0x4(%esp)
  10566c:	8b 45 08             	mov    0x8(%ebp),%eax
  10566f:	89 04 24             	mov    %eax,(%esp)
  105672:	e8 61 fe ff ff       	call   1054d8 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  105677:	e9 68 02 00 00       	jmp    1058e4 <vprintfmt+0x3de>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
  10567c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  105680:	c7 44 24 08 36 70 10 	movl   $0x107036,0x8(%esp)
  105687:	00 
  105688:	8b 45 0c             	mov    0xc(%ebp),%eax
  10568b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10568f:	8b 45 08             	mov    0x8(%ebp),%eax
  105692:	89 04 24             	mov    %eax,(%esp)
  105695:	e8 3e fe ff ff       	call   1054d8 <printfmt>
            }
            break;
  10569a:	e9 45 02 00 00       	jmp    1058e4 <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  10569f:	8b 45 14             	mov    0x14(%ebp),%eax
  1056a2:	8d 50 04             	lea    0x4(%eax),%edx
  1056a5:	89 55 14             	mov    %edx,0x14(%ebp)
  1056a8:	8b 30                	mov    (%eax),%esi
  1056aa:	85 f6                	test   %esi,%esi
  1056ac:	75 05                	jne    1056b3 <vprintfmt+0x1ad>
                p = "(null)";
  1056ae:	be 39 70 10 00       	mov    $0x107039,%esi
            }
            if (width > 0 && padc != '-') {
  1056b3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1056b7:	7e 3e                	jle    1056f7 <vprintfmt+0x1f1>
  1056b9:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  1056bd:	74 38                	je     1056f7 <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  1056bf:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  1056c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1056c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  1056c9:	89 34 24             	mov    %esi,(%esp)
  1056cc:	e8 15 03 00 00       	call   1059e6 <strnlen>
  1056d1:	29 c3                	sub    %eax,%ebx
  1056d3:	89 d8                	mov    %ebx,%eax
  1056d5:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1056d8:	eb 17                	jmp    1056f1 <vprintfmt+0x1eb>
                    putch(padc, putdat);
  1056da:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  1056de:	8b 55 0c             	mov    0xc(%ebp),%edx
  1056e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  1056e5:	89 04 24             	mov    %eax,(%esp)
  1056e8:	8b 45 08             	mov    0x8(%ebp),%eax
  1056eb:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
  1056ed:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  1056f1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1056f5:	7f e3                	jg     1056da <vprintfmt+0x1d4>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  1056f7:	eb 38                	jmp    105731 <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
  1056f9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  1056fd:	74 1f                	je     10571e <vprintfmt+0x218>
  1056ff:	83 fb 1f             	cmp    $0x1f,%ebx
  105702:	7e 05                	jle    105709 <vprintfmt+0x203>
  105704:	83 fb 7e             	cmp    $0x7e,%ebx
  105707:	7e 15                	jle    10571e <vprintfmt+0x218>
                    putch('?', putdat);
  105709:	8b 45 0c             	mov    0xc(%ebp),%eax
  10570c:	89 44 24 04          	mov    %eax,0x4(%esp)
  105710:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  105717:	8b 45 08             	mov    0x8(%ebp),%eax
  10571a:	ff d0                	call   *%eax
  10571c:	eb 0f                	jmp    10572d <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
  10571e:	8b 45 0c             	mov    0xc(%ebp),%eax
  105721:	89 44 24 04          	mov    %eax,0x4(%esp)
  105725:	89 1c 24             	mov    %ebx,(%esp)
  105728:	8b 45 08             	mov    0x8(%ebp),%eax
  10572b:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  10572d:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  105731:	89 f0                	mov    %esi,%eax
  105733:	8d 70 01             	lea    0x1(%eax),%esi
  105736:	0f b6 00             	movzbl (%eax),%eax
  105739:	0f be d8             	movsbl %al,%ebx
  10573c:	85 db                	test   %ebx,%ebx
  10573e:	74 10                	je     105750 <vprintfmt+0x24a>
  105740:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105744:	78 b3                	js     1056f9 <vprintfmt+0x1f3>
  105746:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  10574a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10574e:	79 a9                	jns    1056f9 <vprintfmt+0x1f3>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  105750:	eb 17                	jmp    105769 <vprintfmt+0x263>
                putch(' ', putdat);
  105752:	8b 45 0c             	mov    0xc(%ebp),%eax
  105755:	89 44 24 04          	mov    %eax,0x4(%esp)
  105759:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  105760:	8b 45 08             	mov    0x8(%ebp),%eax
  105763:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  105765:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  105769:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10576d:	7f e3                	jg     105752 <vprintfmt+0x24c>
                putch(' ', putdat);
            }
            break;
  10576f:	e9 70 01 00 00       	jmp    1058e4 <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  105774:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105777:	89 44 24 04          	mov    %eax,0x4(%esp)
  10577b:	8d 45 14             	lea    0x14(%ebp),%eax
  10577e:	89 04 24             	mov    %eax,(%esp)
  105781:	e8 0b fd ff ff       	call   105491 <getint>
  105786:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105789:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  10578c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10578f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105792:	85 d2                	test   %edx,%edx
  105794:	79 26                	jns    1057bc <vprintfmt+0x2b6>
                putch('-', putdat);
  105796:	8b 45 0c             	mov    0xc(%ebp),%eax
  105799:	89 44 24 04          	mov    %eax,0x4(%esp)
  10579d:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  1057a4:	8b 45 08             	mov    0x8(%ebp),%eax
  1057a7:	ff d0                	call   *%eax
                num = -(long long)num;
  1057a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1057ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1057af:	f7 d8                	neg    %eax
  1057b1:	83 d2 00             	adc    $0x0,%edx
  1057b4:	f7 da                	neg    %edx
  1057b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1057b9:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  1057bc:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  1057c3:	e9 a8 00 00 00       	jmp    105870 <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  1057c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1057cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1057cf:	8d 45 14             	lea    0x14(%ebp),%eax
  1057d2:	89 04 24             	mov    %eax,(%esp)
  1057d5:	e8 68 fc ff ff       	call   105442 <getuint>
  1057da:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1057dd:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  1057e0:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  1057e7:	e9 84 00 00 00       	jmp    105870 <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  1057ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1057ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  1057f3:	8d 45 14             	lea    0x14(%ebp),%eax
  1057f6:	89 04 24             	mov    %eax,(%esp)
  1057f9:	e8 44 fc ff ff       	call   105442 <getuint>
  1057fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105801:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  105804:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  10580b:	eb 63                	jmp    105870 <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
  10580d:	8b 45 0c             	mov    0xc(%ebp),%eax
  105810:	89 44 24 04          	mov    %eax,0x4(%esp)
  105814:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  10581b:	8b 45 08             	mov    0x8(%ebp),%eax
  10581e:	ff d0                	call   *%eax
            putch('x', putdat);
  105820:	8b 45 0c             	mov    0xc(%ebp),%eax
  105823:	89 44 24 04          	mov    %eax,0x4(%esp)
  105827:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  10582e:	8b 45 08             	mov    0x8(%ebp),%eax
  105831:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  105833:	8b 45 14             	mov    0x14(%ebp),%eax
  105836:	8d 50 04             	lea    0x4(%eax),%edx
  105839:	89 55 14             	mov    %edx,0x14(%ebp)
  10583c:	8b 00                	mov    (%eax),%eax
  10583e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105841:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  105848:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  10584f:	eb 1f                	jmp    105870 <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  105851:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105854:	89 44 24 04          	mov    %eax,0x4(%esp)
  105858:	8d 45 14             	lea    0x14(%ebp),%eax
  10585b:	89 04 24             	mov    %eax,(%esp)
  10585e:	e8 df fb ff ff       	call   105442 <getuint>
  105863:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105866:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  105869:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  105870:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  105874:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105877:	89 54 24 18          	mov    %edx,0x18(%esp)
  10587b:	8b 55 e8             	mov    -0x18(%ebp),%edx
  10587e:	89 54 24 14          	mov    %edx,0x14(%esp)
  105882:	89 44 24 10          	mov    %eax,0x10(%esp)
  105886:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105889:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10588c:	89 44 24 08          	mov    %eax,0x8(%esp)
  105890:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105894:	8b 45 0c             	mov    0xc(%ebp),%eax
  105897:	89 44 24 04          	mov    %eax,0x4(%esp)
  10589b:	8b 45 08             	mov    0x8(%ebp),%eax
  10589e:	89 04 24             	mov    %eax,(%esp)
  1058a1:	e8 97 fa ff ff       	call   10533d <printnum>
            break;
  1058a6:	eb 3c                	jmp    1058e4 <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  1058a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1058ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  1058af:	89 1c 24             	mov    %ebx,(%esp)
  1058b2:	8b 45 08             	mov    0x8(%ebp),%eax
  1058b5:	ff d0                	call   *%eax
            break;
  1058b7:	eb 2b                	jmp    1058e4 <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  1058b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1058bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  1058c0:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  1058c7:	8b 45 08             	mov    0x8(%ebp),%eax
  1058ca:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  1058cc:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  1058d0:	eb 04                	jmp    1058d6 <vprintfmt+0x3d0>
  1058d2:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  1058d6:	8b 45 10             	mov    0x10(%ebp),%eax
  1058d9:	83 e8 01             	sub    $0x1,%eax
  1058dc:	0f b6 00             	movzbl (%eax),%eax
  1058df:	3c 25                	cmp    $0x25,%al
  1058e1:	75 ef                	jne    1058d2 <vprintfmt+0x3cc>
                /* do nothing */;
            break;
  1058e3:	90                   	nop
        }
    }
  1058e4:	90                   	nop
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  1058e5:	e9 3e fc ff ff       	jmp    105528 <vprintfmt+0x22>
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  1058ea:	83 c4 40             	add    $0x40,%esp
  1058ed:	5b                   	pop    %ebx
  1058ee:	5e                   	pop    %esi
  1058ef:	5d                   	pop    %ebp
  1058f0:	c3                   	ret    

001058f1 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  1058f1:	55                   	push   %ebp
  1058f2:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  1058f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1058f7:	8b 40 08             	mov    0x8(%eax),%eax
  1058fa:	8d 50 01             	lea    0x1(%eax),%edx
  1058fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  105900:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  105903:	8b 45 0c             	mov    0xc(%ebp),%eax
  105906:	8b 10                	mov    (%eax),%edx
  105908:	8b 45 0c             	mov    0xc(%ebp),%eax
  10590b:	8b 40 04             	mov    0x4(%eax),%eax
  10590e:	39 c2                	cmp    %eax,%edx
  105910:	73 12                	jae    105924 <sprintputch+0x33>
        *b->buf ++ = ch;
  105912:	8b 45 0c             	mov    0xc(%ebp),%eax
  105915:	8b 00                	mov    (%eax),%eax
  105917:	8d 48 01             	lea    0x1(%eax),%ecx
  10591a:	8b 55 0c             	mov    0xc(%ebp),%edx
  10591d:	89 0a                	mov    %ecx,(%edx)
  10591f:	8b 55 08             	mov    0x8(%ebp),%edx
  105922:	88 10                	mov    %dl,(%eax)
    }
}
  105924:	5d                   	pop    %ebp
  105925:	c3                   	ret    

00105926 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  105926:	55                   	push   %ebp
  105927:	89 e5                	mov    %esp,%ebp
  105929:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  10592c:	8d 45 14             	lea    0x14(%ebp),%eax
  10592f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  105932:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105935:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105939:	8b 45 10             	mov    0x10(%ebp),%eax
  10593c:	89 44 24 08          	mov    %eax,0x8(%esp)
  105940:	8b 45 0c             	mov    0xc(%ebp),%eax
  105943:	89 44 24 04          	mov    %eax,0x4(%esp)
  105947:	8b 45 08             	mov    0x8(%ebp),%eax
  10594a:	89 04 24             	mov    %eax,(%esp)
  10594d:	e8 08 00 00 00       	call   10595a <vsnprintf>
  105952:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  105955:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  105958:	c9                   	leave  
  105959:	c3                   	ret    

0010595a <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  10595a:	55                   	push   %ebp
  10595b:	89 e5                	mov    %esp,%ebp
  10595d:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  105960:	8b 45 08             	mov    0x8(%ebp),%eax
  105963:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105966:	8b 45 0c             	mov    0xc(%ebp),%eax
  105969:	8d 50 ff             	lea    -0x1(%eax),%edx
  10596c:	8b 45 08             	mov    0x8(%ebp),%eax
  10596f:	01 d0                	add    %edx,%eax
  105971:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105974:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  10597b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  10597f:	74 0a                	je     10598b <vsnprintf+0x31>
  105981:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105984:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105987:	39 c2                	cmp    %eax,%edx
  105989:	76 07                	jbe    105992 <vsnprintf+0x38>
        return -E_INVAL;
  10598b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  105990:	eb 2a                	jmp    1059bc <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  105992:	8b 45 14             	mov    0x14(%ebp),%eax
  105995:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105999:	8b 45 10             	mov    0x10(%ebp),%eax
  10599c:	89 44 24 08          	mov    %eax,0x8(%esp)
  1059a0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  1059a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  1059a7:	c7 04 24 f1 58 10 00 	movl   $0x1058f1,(%esp)
  1059ae:	e8 53 fb ff ff       	call   105506 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  1059b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1059b6:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  1059b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1059bc:	c9                   	leave  
  1059bd:	c3                   	ret    

001059be <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  1059be:	55                   	push   %ebp
  1059bf:	89 e5                	mov    %esp,%ebp
  1059c1:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  1059c4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  1059cb:	eb 04                	jmp    1059d1 <strlen+0x13>
        cnt ++;
  1059cd:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
  1059d1:	8b 45 08             	mov    0x8(%ebp),%eax
  1059d4:	8d 50 01             	lea    0x1(%eax),%edx
  1059d7:	89 55 08             	mov    %edx,0x8(%ebp)
  1059da:	0f b6 00             	movzbl (%eax),%eax
  1059dd:	84 c0                	test   %al,%al
  1059df:	75 ec                	jne    1059cd <strlen+0xf>
        cnt ++;
    }
    return cnt;
  1059e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1059e4:	c9                   	leave  
  1059e5:	c3                   	ret    

001059e6 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  1059e6:	55                   	push   %ebp
  1059e7:	89 e5                	mov    %esp,%ebp
  1059e9:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  1059ec:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  1059f3:	eb 04                	jmp    1059f9 <strnlen+0x13>
        cnt ++;
  1059f5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  1059f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1059fc:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1059ff:	73 10                	jae    105a11 <strnlen+0x2b>
  105a01:	8b 45 08             	mov    0x8(%ebp),%eax
  105a04:	8d 50 01             	lea    0x1(%eax),%edx
  105a07:	89 55 08             	mov    %edx,0x8(%ebp)
  105a0a:	0f b6 00             	movzbl (%eax),%eax
  105a0d:	84 c0                	test   %al,%al
  105a0f:	75 e4                	jne    1059f5 <strnlen+0xf>
        cnt ++;
    }
    return cnt;
  105a11:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  105a14:	c9                   	leave  
  105a15:	c3                   	ret    

00105a16 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  105a16:	55                   	push   %ebp
  105a17:	89 e5                	mov    %esp,%ebp
  105a19:	57                   	push   %edi
  105a1a:	56                   	push   %esi
  105a1b:	83 ec 20             	sub    $0x20,%esp
  105a1e:	8b 45 08             	mov    0x8(%ebp),%eax
  105a21:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105a24:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a27:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  105a2a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105a2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105a30:	89 d1                	mov    %edx,%ecx
  105a32:	89 c2                	mov    %eax,%edx
  105a34:	89 ce                	mov    %ecx,%esi
  105a36:	89 d7                	mov    %edx,%edi
  105a38:	ac                   	lods   %ds:(%esi),%al
  105a39:	aa                   	stos   %al,%es:(%edi)
  105a3a:	84 c0                	test   %al,%al
  105a3c:	75 fa                	jne    105a38 <strcpy+0x22>
  105a3e:	89 fa                	mov    %edi,%edx
  105a40:	89 f1                	mov    %esi,%ecx
  105a42:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  105a45:	89 55 e8             	mov    %edx,-0x18(%ebp)
  105a48:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  105a4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  105a4e:	83 c4 20             	add    $0x20,%esp
  105a51:	5e                   	pop    %esi
  105a52:	5f                   	pop    %edi
  105a53:	5d                   	pop    %ebp
  105a54:	c3                   	ret    

00105a55 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  105a55:	55                   	push   %ebp
  105a56:	89 e5                	mov    %esp,%ebp
  105a58:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  105a5b:	8b 45 08             	mov    0x8(%ebp),%eax
  105a5e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  105a61:	eb 21                	jmp    105a84 <strncpy+0x2f>
        if ((*p = *src) != '\0') {
  105a63:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a66:	0f b6 10             	movzbl (%eax),%edx
  105a69:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105a6c:	88 10                	mov    %dl,(%eax)
  105a6e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105a71:	0f b6 00             	movzbl (%eax),%eax
  105a74:	84 c0                	test   %al,%al
  105a76:	74 04                	je     105a7c <strncpy+0x27>
            src ++;
  105a78:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
  105a7c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  105a80:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
  105a84:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105a88:	75 d9                	jne    105a63 <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
  105a8a:	8b 45 08             	mov    0x8(%ebp),%eax
}
  105a8d:	c9                   	leave  
  105a8e:	c3                   	ret    

00105a8f <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  105a8f:	55                   	push   %ebp
  105a90:	89 e5                	mov    %esp,%ebp
  105a92:	57                   	push   %edi
  105a93:	56                   	push   %esi
  105a94:	83 ec 20             	sub    $0x20,%esp
  105a97:	8b 45 08             	mov    0x8(%ebp),%eax
  105a9a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105a9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  105aa0:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
  105aa3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105aa6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105aa9:	89 d1                	mov    %edx,%ecx
  105aab:	89 c2                	mov    %eax,%edx
  105aad:	89 ce                	mov    %ecx,%esi
  105aaf:	89 d7                	mov    %edx,%edi
  105ab1:	ac                   	lods   %ds:(%esi),%al
  105ab2:	ae                   	scas   %es:(%edi),%al
  105ab3:	75 08                	jne    105abd <strcmp+0x2e>
  105ab5:	84 c0                	test   %al,%al
  105ab7:	75 f8                	jne    105ab1 <strcmp+0x22>
  105ab9:	31 c0                	xor    %eax,%eax
  105abb:	eb 04                	jmp    105ac1 <strcmp+0x32>
  105abd:	19 c0                	sbb    %eax,%eax
  105abf:	0c 01                	or     $0x1,%al
  105ac1:	89 fa                	mov    %edi,%edx
  105ac3:	89 f1                	mov    %esi,%ecx
  105ac5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105ac8:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  105acb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
  105ace:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  105ad1:	83 c4 20             	add    $0x20,%esp
  105ad4:	5e                   	pop    %esi
  105ad5:	5f                   	pop    %edi
  105ad6:	5d                   	pop    %ebp
  105ad7:	c3                   	ret    

00105ad8 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  105ad8:	55                   	push   %ebp
  105ad9:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  105adb:	eb 0c                	jmp    105ae9 <strncmp+0x11>
        n --, s1 ++, s2 ++;
  105add:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  105ae1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105ae5:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  105ae9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105aed:	74 1a                	je     105b09 <strncmp+0x31>
  105aef:	8b 45 08             	mov    0x8(%ebp),%eax
  105af2:	0f b6 00             	movzbl (%eax),%eax
  105af5:	84 c0                	test   %al,%al
  105af7:	74 10                	je     105b09 <strncmp+0x31>
  105af9:	8b 45 08             	mov    0x8(%ebp),%eax
  105afc:	0f b6 10             	movzbl (%eax),%edx
  105aff:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b02:	0f b6 00             	movzbl (%eax),%eax
  105b05:	38 c2                	cmp    %al,%dl
  105b07:	74 d4                	je     105add <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  105b09:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105b0d:	74 18                	je     105b27 <strncmp+0x4f>
  105b0f:	8b 45 08             	mov    0x8(%ebp),%eax
  105b12:	0f b6 00             	movzbl (%eax),%eax
  105b15:	0f b6 d0             	movzbl %al,%edx
  105b18:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b1b:	0f b6 00             	movzbl (%eax),%eax
  105b1e:	0f b6 c0             	movzbl %al,%eax
  105b21:	29 c2                	sub    %eax,%edx
  105b23:	89 d0                	mov    %edx,%eax
  105b25:	eb 05                	jmp    105b2c <strncmp+0x54>
  105b27:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105b2c:	5d                   	pop    %ebp
  105b2d:	c3                   	ret    

00105b2e <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  105b2e:	55                   	push   %ebp
  105b2f:	89 e5                	mov    %esp,%ebp
  105b31:	83 ec 04             	sub    $0x4,%esp
  105b34:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b37:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105b3a:	eb 14                	jmp    105b50 <strchr+0x22>
        if (*s == c) {
  105b3c:	8b 45 08             	mov    0x8(%ebp),%eax
  105b3f:	0f b6 00             	movzbl (%eax),%eax
  105b42:	3a 45 fc             	cmp    -0x4(%ebp),%al
  105b45:	75 05                	jne    105b4c <strchr+0x1e>
            return (char *)s;
  105b47:	8b 45 08             	mov    0x8(%ebp),%eax
  105b4a:	eb 13                	jmp    105b5f <strchr+0x31>
        }
        s ++;
  105b4c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
  105b50:	8b 45 08             	mov    0x8(%ebp),%eax
  105b53:	0f b6 00             	movzbl (%eax),%eax
  105b56:	84 c0                	test   %al,%al
  105b58:	75 e2                	jne    105b3c <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
  105b5a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105b5f:	c9                   	leave  
  105b60:	c3                   	ret    

00105b61 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  105b61:	55                   	push   %ebp
  105b62:	89 e5                	mov    %esp,%ebp
  105b64:	83 ec 04             	sub    $0x4,%esp
  105b67:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b6a:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105b6d:	eb 11                	jmp    105b80 <strfind+0x1f>
        if (*s == c) {
  105b6f:	8b 45 08             	mov    0x8(%ebp),%eax
  105b72:	0f b6 00             	movzbl (%eax),%eax
  105b75:	3a 45 fc             	cmp    -0x4(%ebp),%al
  105b78:	75 02                	jne    105b7c <strfind+0x1b>
            break;
  105b7a:	eb 0e                	jmp    105b8a <strfind+0x29>
        }
        s ++;
  105b7c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
  105b80:	8b 45 08             	mov    0x8(%ebp),%eax
  105b83:	0f b6 00             	movzbl (%eax),%eax
  105b86:	84 c0                	test   %al,%al
  105b88:	75 e5                	jne    105b6f <strfind+0xe>
        if (*s == c) {
            break;
        }
        s ++;
    }
    return (char *)s;
  105b8a:	8b 45 08             	mov    0x8(%ebp),%eax
}
  105b8d:	c9                   	leave  
  105b8e:	c3                   	ret    

00105b8f <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  105b8f:	55                   	push   %ebp
  105b90:	89 e5                	mov    %esp,%ebp
  105b92:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  105b95:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  105b9c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  105ba3:	eb 04                	jmp    105ba9 <strtol+0x1a>
        s ++;
  105ba5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  105ba9:	8b 45 08             	mov    0x8(%ebp),%eax
  105bac:	0f b6 00             	movzbl (%eax),%eax
  105baf:	3c 20                	cmp    $0x20,%al
  105bb1:	74 f2                	je     105ba5 <strtol+0x16>
  105bb3:	8b 45 08             	mov    0x8(%ebp),%eax
  105bb6:	0f b6 00             	movzbl (%eax),%eax
  105bb9:	3c 09                	cmp    $0x9,%al
  105bbb:	74 e8                	je     105ba5 <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
  105bbd:	8b 45 08             	mov    0x8(%ebp),%eax
  105bc0:	0f b6 00             	movzbl (%eax),%eax
  105bc3:	3c 2b                	cmp    $0x2b,%al
  105bc5:	75 06                	jne    105bcd <strtol+0x3e>
        s ++;
  105bc7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105bcb:	eb 15                	jmp    105be2 <strtol+0x53>
    }
    else if (*s == '-') {
  105bcd:	8b 45 08             	mov    0x8(%ebp),%eax
  105bd0:	0f b6 00             	movzbl (%eax),%eax
  105bd3:	3c 2d                	cmp    $0x2d,%al
  105bd5:	75 0b                	jne    105be2 <strtol+0x53>
        s ++, neg = 1;
  105bd7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105bdb:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  105be2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105be6:	74 06                	je     105bee <strtol+0x5f>
  105be8:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  105bec:	75 24                	jne    105c12 <strtol+0x83>
  105bee:	8b 45 08             	mov    0x8(%ebp),%eax
  105bf1:	0f b6 00             	movzbl (%eax),%eax
  105bf4:	3c 30                	cmp    $0x30,%al
  105bf6:	75 1a                	jne    105c12 <strtol+0x83>
  105bf8:	8b 45 08             	mov    0x8(%ebp),%eax
  105bfb:	83 c0 01             	add    $0x1,%eax
  105bfe:	0f b6 00             	movzbl (%eax),%eax
  105c01:	3c 78                	cmp    $0x78,%al
  105c03:	75 0d                	jne    105c12 <strtol+0x83>
        s += 2, base = 16;
  105c05:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  105c09:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  105c10:	eb 2a                	jmp    105c3c <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
  105c12:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105c16:	75 17                	jne    105c2f <strtol+0xa0>
  105c18:	8b 45 08             	mov    0x8(%ebp),%eax
  105c1b:	0f b6 00             	movzbl (%eax),%eax
  105c1e:	3c 30                	cmp    $0x30,%al
  105c20:	75 0d                	jne    105c2f <strtol+0xa0>
        s ++, base = 8;
  105c22:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105c26:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  105c2d:	eb 0d                	jmp    105c3c <strtol+0xad>
    }
    else if (base == 0) {
  105c2f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105c33:	75 07                	jne    105c3c <strtol+0xad>
        base = 10;
  105c35:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  105c3c:	8b 45 08             	mov    0x8(%ebp),%eax
  105c3f:	0f b6 00             	movzbl (%eax),%eax
  105c42:	3c 2f                	cmp    $0x2f,%al
  105c44:	7e 1b                	jle    105c61 <strtol+0xd2>
  105c46:	8b 45 08             	mov    0x8(%ebp),%eax
  105c49:	0f b6 00             	movzbl (%eax),%eax
  105c4c:	3c 39                	cmp    $0x39,%al
  105c4e:	7f 11                	jg     105c61 <strtol+0xd2>
            dig = *s - '0';
  105c50:	8b 45 08             	mov    0x8(%ebp),%eax
  105c53:	0f b6 00             	movzbl (%eax),%eax
  105c56:	0f be c0             	movsbl %al,%eax
  105c59:	83 e8 30             	sub    $0x30,%eax
  105c5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105c5f:	eb 48                	jmp    105ca9 <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
  105c61:	8b 45 08             	mov    0x8(%ebp),%eax
  105c64:	0f b6 00             	movzbl (%eax),%eax
  105c67:	3c 60                	cmp    $0x60,%al
  105c69:	7e 1b                	jle    105c86 <strtol+0xf7>
  105c6b:	8b 45 08             	mov    0x8(%ebp),%eax
  105c6e:	0f b6 00             	movzbl (%eax),%eax
  105c71:	3c 7a                	cmp    $0x7a,%al
  105c73:	7f 11                	jg     105c86 <strtol+0xf7>
            dig = *s - 'a' + 10;
  105c75:	8b 45 08             	mov    0x8(%ebp),%eax
  105c78:	0f b6 00             	movzbl (%eax),%eax
  105c7b:	0f be c0             	movsbl %al,%eax
  105c7e:	83 e8 57             	sub    $0x57,%eax
  105c81:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105c84:	eb 23                	jmp    105ca9 <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  105c86:	8b 45 08             	mov    0x8(%ebp),%eax
  105c89:	0f b6 00             	movzbl (%eax),%eax
  105c8c:	3c 40                	cmp    $0x40,%al
  105c8e:	7e 3d                	jle    105ccd <strtol+0x13e>
  105c90:	8b 45 08             	mov    0x8(%ebp),%eax
  105c93:	0f b6 00             	movzbl (%eax),%eax
  105c96:	3c 5a                	cmp    $0x5a,%al
  105c98:	7f 33                	jg     105ccd <strtol+0x13e>
            dig = *s - 'A' + 10;
  105c9a:	8b 45 08             	mov    0x8(%ebp),%eax
  105c9d:	0f b6 00             	movzbl (%eax),%eax
  105ca0:	0f be c0             	movsbl %al,%eax
  105ca3:	83 e8 37             	sub    $0x37,%eax
  105ca6:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  105ca9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105cac:	3b 45 10             	cmp    0x10(%ebp),%eax
  105caf:	7c 02                	jl     105cb3 <strtol+0x124>
            break;
  105cb1:	eb 1a                	jmp    105ccd <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
  105cb3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105cb7:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105cba:	0f af 45 10          	imul   0x10(%ebp),%eax
  105cbe:	89 c2                	mov    %eax,%edx
  105cc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105cc3:	01 d0                	add    %edx,%eax
  105cc5:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
  105cc8:	e9 6f ff ff ff       	jmp    105c3c <strtol+0xad>

    if (endptr) {
  105ccd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105cd1:	74 08                	je     105cdb <strtol+0x14c>
        *endptr = (char *) s;
  105cd3:	8b 45 0c             	mov    0xc(%ebp),%eax
  105cd6:	8b 55 08             	mov    0x8(%ebp),%edx
  105cd9:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  105cdb:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  105cdf:	74 07                	je     105ce8 <strtol+0x159>
  105ce1:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105ce4:	f7 d8                	neg    %eax
  105ce6:	eb 03                	jmp    105ceb <strtol+0x15c>
  105ce8:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  105ceb:	c9                   	leave  
  105cec:	c3                   	ret    

00105ced <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  105ced:	55                   	push   %ebp
  105cee:	89 e5                	mov    %esp,%ebp
  105cf0:	57                   	push   %edi
  105cf1:	83 ec 24             	sub    $0x24,%esp
  105cf4:	8b 45 0c             	mov    0xc(%ebp),%eax
  105cf7:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  105cfa:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  105cfe:	8b 55 08             	mov    0x8(%ebp),%edx
  105d01:	89 55 f8             	mov    %edx,-0x8(%ebp)
  105d04:	88 45 f7             	mov    %al,-0x9(%ebp)
  105d07:	8b 45 10             	mov    0x10(%ebp),%eax
  105d0a:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  105d0d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  105d10:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  105d14:	8b 55 f8             	mov    -0x8(%ebp),%edx
  105d17:	89 d7                	mov    %edx,%edi
  105d19:	f3 aa                	rep stos %al,%es:(%edi)
  105d1b:	89 fa                	mov    %edi,%edx
  105d1d:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  105d20:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  105d23:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  105d26:	83 c4 24             	add    $0x24,%esp
  105d29:	5f                   	pop    %edi
  105d2a:	5d                   	pop    %ebp
  105d2b:	c3                   	ret    

00105d2c <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  105d2c:	55                   	push   %ebp
  105d2d:	89 e5                	mov    %esp,%ebp
  105d2f:	57                   	push   %edi
  105d30:	56                   	push   %esi
  105d31:	53                   	push   %ebx
  105d32:	83 ec 30             	sub    $0x30,%esp
  105d35:	8b 45 08             	mov    0x8(%ebp),%eax
  105d38:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105d3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d3e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105d41:	8b 45 10             	mov    0x10(%ebp),%eax
  105d44:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  105d47:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105d4a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  105d4d:	73 42                	jae    105d91 <memmove+0x65>
  105d4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105d52:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105d55:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105d58:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105d5b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105d5e:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  105d61:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105d64:	c1 e8 02             	shr    $0x2,%eax
  105d67:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  105d69:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  105d6c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105d6f:	89 d7                	mov    %edx,%edi
  105d71:	89 c6                	mov    %eax,%esi
  105d73:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  105d75:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  105d78:	83 e1 03             	and    $0x3,%ecx
  105d7b:	74 02                	je     105d7f <memmove+0x53>
  105d7d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105d7f:	89 f0                	mov    %esi,%eax
  105d81:	89 fa                	mov    %edi,%edx
  105d83:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  105d86:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  105d89:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
  105d8c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105d8f:	eb 36                	jmp    105dc7 <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  105d91:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105d94:	8d 50 ff             	lea    -0x1(%eax),%edx
  105d97:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105d9a:	01 c2                	add    %eax,%edx
  105d9c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105d9f:	8d 48 ff             	lea    -0x1(%eax),%ecx
  105da2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105da5:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
  105da8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105dab:	89 c1                	mov    %eax,%ecx
  105dad:	89 d8                	mov    %ebx,%eax
  105daf:	89 d6                	mov    %edx,%esi
  105db1:	89 c7                	mov    %eax,%edi
  105db3:	fd                   	std    
  105db4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105db6:	fc                   	cld    
  105db7:	89 f8                	mov    %edi,%eax
  105db9:	89 f2                	mov    %esi,%edx
  105dbb:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  105dbe:	89 55 c8             	mov    %edx,-0x38(%ebp)
  105dc1:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
  105dc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  105dc7:	83 c4 30             	add    $0x30,%esp
  105dca:	5b                   	pop    %ebx
  105dcb:	5e                   	pop    %esi
  105dcc:	5f                   	pop    %edi
  105dcd:	5d                   	pop    %ebp
  105dce:	c3                   	ret    

00105dcf <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  105dcf:	55                   	push   %ebp
  105dd0:	89 e5                	mov    %esp,%ebp
  105dd2:	57                   	push   %edi
  105dd3:	56                   	push   %esi
  105dd4:	83 ec 20             	sub    $0x20,%esp
  105dd7:	8b 45 08             	mov    0x8(%ebp),%eax
  105dda:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105ddd:	8b 45 0c             	mov    0xc(%ebp),%eax
  105de0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105de3:	8b 45 10             	mov    0x10(%ebp),%eax
  105de6:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  105de9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105dec:	c1 e8 02             	shr    $0x2,%eax
  105def:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  105df1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105df4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105df7:	89 d7                	mov    %edx,%edi
  105df9:	89 c6                	mov    %eax,%esi
  105dfb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  105dfd:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  105e00:	83 e1 03             	and    $0x3,%ecx
  105e03:	74 02                	je     105e07 <memcpy+0x38>
  105e05:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105e07:	89 f0                	mov    %esi,%eax
  105e09:	89 fa                	mov    %edi,%edx
  105e0b:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  105e0e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  105e11:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
  105e14:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  105e17:	83 c4 20             	add    $0x20,%esp
  105e1a:	5e                   	pop    %esi
  105e1b:	5f                   	pop    %edi
  105e1c:	5d                   	pop    %ebp
  105e1d:	c3                   	ret    

00105e1e <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  105e1e:	55                   	push   %ebp
  105e1f:	89 e5                	mov    %esp,%ebp
  105e21:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  105e24:	8b 45 08             	mov    0x8(%ebp),%eax
  105e27:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  105e2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e2d:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  105e30:	eb 30                	jmp    105e62 <memcmp+0x44>
        if (*s1 != *s2) {
  105e32:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105e35:	0f b6 10             	movzbl (%eax),%edx
  105e38:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105e3b:	0f b6 00             	movzbl (%eax),%eax
  105e3e:	38 c2                	cmp    %al,%dl
  105e40:	74 18                	je     105e5a <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  105e42:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105e45:	0f b6 00             	movzbl (%eax),%eax
  105e48:	0f b6 d0             	movzbl %al,%edx
  105e4b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105e4e:	0f b6 00             	movzbl (%eax),%eax
  105e51:	0f b6 c0             	movzbl %al,%eax
  105e54:	29 c2                	sub    %eax,%edx
  105e56:	89 d0                	mov    %edx,%eax
  105e58:	eb 1a                	jmp    105e74 <memcmp+0x56>
        }
        s1 ++, s2 ++;
  105e5a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  105e5e:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
  105e62:	8b 45 10             	mov    0x10(%ebp),%eax
  105e65:	8d 50 ff             	lea    -0x1(%eax),%edx
  105e68:	89 55 10             	mov    %edx,0x10(%ebp)
  105e6b:	85 c0                	test   %eax,%eax
  105e6d:	75 c3                	jne    105e32 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
  105e6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105e74:	c9                   	leave  
  105e75:	c3                   	ret    
