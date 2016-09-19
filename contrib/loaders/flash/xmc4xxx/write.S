	.text
	.syntax unified
	.cpu cortex-m4
	.thumb
	.thumb_func

/*	r0 source data start
	r1 source data end
	r2 destination start
	r3 flash status word

	r4, r5, r6 clobbered
*/

program_page:
	ldr	r4, X5554
	movs	r3, #0xf5       // Clear status
	str	r3, [r4]
	movs	r3, #0x50	// Enter page mode
	str	r3, [r4]

	add	r6, r0, #0x100	// Load 256 bytes to buffer
	ldr	r5, X55f0
loop:	ldmia	r0!, {r3, r4}
	cmp	r6, r0
	stmia	r5, {r3, r4}
	bne	loop

	ldr	r4, X5554	// Write page
	mov	r3, #0xaa
	str	r3, [r4]
	ldr	r4, Xaaa8
	mov	r3, #0x55
	str	r3, [r4]
	ldr	r4, X5554
	mov	r3, #0xa0 // should be 0xc0 for user config
	str	r3, [r4]
	mov	r3, #0xaa
	str	r3, [r2]

	ldr	r4, X2010	// wait until done
busy:	ldr	r3, [r4, #0]
	lsls	r5, r3, #31
	bmi	busy

	add	r2, r2, #0x100	// next page
	cmp	r0, r1
	bne	program_page

done:	bkpt #0

X5554:	.word	0x0c005554
X55f0:	.word	0x0c0055f0
X55f4:	.word	0x0c0055f4
Xaaa8:	.word	0x0c00aaa8
X2010:	.word	0x58002010
