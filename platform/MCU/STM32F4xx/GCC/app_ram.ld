/**
 *  UNPUBLISHED PROPRIETARY SOURCE CODE
 *  Copyright (c) 2016 MXCHIP Inc.
 *
 *  The contents of this file may not be disclosed to third parties, copied or
 *  duplicated in any form, in whole or in part, without the prior written
 *  permission of MXCHIP Corporation.
 *
 */

Reset_Handler = _mico_start;

ENTRY( _mico_start );

/* Include memory map */
INCLUDE memory.ld

SECTIONS
{

    /* Data transfer area for serial flash writing app  - at start of memory */
    .sflash_trnsf :
    {
        KEEP(*(*.data_config))
        KEEP(*(*.data_transfer))
    }>RAM_TRANS AT> RAM_TRANS


    .vectors :
    {
        . = ALIGN(512);
        link_interrupt_vectors_location = .;
        KEEP(*(*.interrupt_vector_table))
    }>RAM_PROG AT> RAM_PROG

    .text :
    {
        . = ALIGN(4);

        link_code_location = .;
        KEEP(*(.text.irq ))
        *(.text .text.* .gnu.linkonce.t.*)
        KEEP(*(.init))
        KEEP(*(.fini))
        link_code_end = .;

        /* .ctors */
        *crtbegin.o(.ctors)
        *crtbegin?.o(.ctors)
        *(EXCLUDE_FILE(*crtend?.o *crtend.o) .ctors)
        *(SORT(.ctors.*))
        *(.ctors)

        /* .dtors */
        *crtbegin.o(.dtors)
        *crtbegin?.o(.dtors)
        *(EXCLUDE_FILE(*crtend?.o *crtend.o) .dtors)
        *(SORT(.dtors.*))
        *(.dtors)

        *(.rodata*)

        KEEP(*(.eh_frame*))

    }>RAM_PROG AT> RAM_PROG

    /*
     * The .ARM.exidx and .ARM.exidx sections are used for C++ exception handling.
     * It is located here for completeness. Bare-metal ARM projects
     * typically cannot afford the overhead associated with C++
     * exceptions handling.
     */
    .ARM.exidx :
    {
        __exidx_start = ALIGN(4);
        *(.ARM.exidx* .gnu.linkonce.armexidx.*)
        __exidx_end = .;
    } >RAM_PROG AT> RAM_PROG

    .ARM.extab :
    {
        __extab_start = ALIGN(4);
        *(.ARM.extab*)
        __extab_end = .;
    } > RAM_PROG  AT> RAM_PROG

    .fast : /* This section contains code that is run from RAM after being loaded from flash - functions can be put in this section with the C attribute: __attribute__ ((section (".fast"))) */
    {
        link_run_from_ram_code_flash_location = LOADADDR( .fast ); /* This is the location in flash of the code */
        link_run_from_ram_code_ram_location = .;
        *(.fast .fast.* .text.fastcode)
        link_run_from_ram_code_ram_end = .;
    }>RAM_PROG AT> RAM_PROG

    .data : /* Contains the non-zero initialised global variables */
    {
        link_global_data_initial_values = LOADADDR( .data ); /* This is the location in flash of the initial values of global variables */
        link_global_data_start = .;
        *(.data*)

        . = ALIGN(4);
        /* preinit data */
        PROVIDE_HIDDEN (__preinit_array_start = .);
        KEEP(*(.preinit_array))
        PROVIDE_HIDDEN (__preinit_array_end = .);

        . = ALIGN(4);
        /* init data */
        PROVIDE_HIDDEN (__init_array_start = .);
        KEEP(*(SORT(.init_array.*)))
        KEEP(*(.init_array))
        PROVIDE_HIDDEN (__init_array_end = .);

        . = ALIGN(4);
        /* finit data */
        PROVIDE_HIDDEN (__fini_array_start = .);
        KEEP(*(SORT(.fini_array.*)))
        KEEP(*(.fini_array))
        PROVIDE_HIDDEN (__fini_array_end = .);

        KEEP(*(.jcr*))
        . = ALIGN(4);

        link_global_data_end = .;
        /* All data end */
        __data_end__ = .;
        _edata = .;
    }>RAM_PROG AT> RAM_PROG


    .bss : /* Zero initialised memory used for zero initialised variables */
    {
        link_bss_location = ALIGN(., 4);
        __bss_start__ = .;
        *(.bss*)
        *(COMMON)
        link_bss_end = .;
        . = ALIGN(., 4);
        __bss_end__ = .;
    }>RAM_PROG AT> RAM_PROG

    .stack : /* Contains the initial stack */
    {
        link_stack_location = ALIGN(., 4);
        *(.stack)
        . = ALIGN(MAX(link_stack_location + __STACKSIZE__ , .), 4);
        link_stack_end = .;
    }>RAM_PROG AT> RAM_PROG

}

/* Declare libc Heap to start at end of allocated RAM */
_estack = link_stack_end;
PROVIDE( _heap = link_stack_end );
PROVIDE(__stack = link_stack_end);

/* End of the heap is top of RAM, aligned 8 byte */

PROVIDE( _eheap = ALIGN( ORIGIN( SRAM ) + LENGTH( SRAM ) - 8, 8 ) );

