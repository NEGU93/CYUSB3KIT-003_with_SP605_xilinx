/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                       */
/*  \   \        Copyright (c) 2003-2009 Xilinx, Inc.                */
/*  /   /          All Right Reserved.                                 */
/* /---/   /\                                                         */
/* \   \  /  \                                                      */
/*  \___\/\___\                                                    */
/***********************************************************************/

/* This file is designed for use with ISim build 0xc3576ebc */

#define XSI_HIDE_SYMBOL_SPEC true
#include "xsi.h"
#include <memory.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
static const char *ng0 = "C:/Users/savj/Desktop/AN65974/AN65974_Source Files/FPGA Source files/fx3_slaveFIFO2b_xilinx/fpga_slavefifo2b_verilog/slaveFIFO2b_streamOUT.v";
static unsigned int ng1[] = {3U, 0U};
static unsigned int ng2[] = {4U, 0U};
static unsigned int ng3[] = {0U, 0U};
static unsigned int ng4[] = {1U, 0U};
static unsigned int ng5[] = {5U, 0U};
static unsigned int ng6[] = {2U, 0U};
static int ng7[] = {0, 0};



static void Cont_28_0(char *t0)
{
    char t3[8];
    char t4[8];
    char t8[8];
    char t28[8];
    char t44[8];
    char *t1;
    char *t2;
    char *t5;
    char *t6;
    char *t7;
    char *t9;
    char *t10;
    unsigned int t11;
    unsigned int t12;
    unsigned int t13;
    unsigned int t14;
    unsigned int t15;
    unsigned int t16;
    unsigned int t17;
    unsigned int t18;
    unsigned int t19;
    unsigned int t20;
    unsigned int t21;
    unsigned int t22;
    char *t23;
    char *t24;
    char *t25;
    char *t26;
    char *t27;
    char *t29;
    char *t30;
    unsigned int t31;
    unsigned int t32;
    unsigned int t33;
    unsigned int t34;
    unsigned int t35;
    unsigned int t36;
    unsigned int t37;
    unsigned int t38;
    unsigned int t39;
    unsigned int t40;
    unsigned int t41;
    unsigned int t42;
    char *t43;
    unsigned int t45;
    unsigned int t46;
    unsigned int t47;
    char *t48;
    char *t49;
    char *t50;
    unsigned int t51;
    unsigned int t52;
    unsigned int t53;
    unsigned int t54;
    unsigned int t55;
    unsigned int t56;
    unsigned int t57;
    char *t58;
    char *t59;
    unsigned int t60;
    unsigned int t61;
    unsigned int t62;
    int t63;
    unsigned int t64;
    unsigned int t65;
    unsigned int t66;
    int t67;
    unsigned int t68;
    unsigned int t69;
    unsigned int t70;
    unsigned int t71;
    char *t72;
    unsigned int t73;
    unsigned int t74;
    unsigned int t75;
    unsigned int t76;
    unsigned int t77;
    char *t78;
    char *t79;
    unsigned int t80;
    unsigned int t81;
    unsigned int t82;
    char *t83;
    unsigned int t84;
    unsigned int t85;
    unsigned int t86;
    unsigned int t87;
    char *t88;
    char *t89;
    char *t90;
    char *t91;
    char *t92;
    char *t93;
    unsigned int t94;
    unsigned int t95;
    char *t96;
    unsigned int t97;
    unsigned int t98;
    char *t99;
    unsigned int t100;
    unsigned int t101;
    char *t102;

LAB0:    t1 = (t0 + 4784U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(28, ng0);
    t2 = (t0 + 3384);
    t5 = (t2 + 56U);
    t6 = *((char **)t5);
    t7 = ((char*)((ng1)));
    memset(t8, 0, 8);
    t9 = (t6 + 4);
    t10 = (t7 + 4);
    t11 = *((unsigned int *)t6);
    t12 = *((unsigned int *)t7);
    t13 = (t11 ^ t12);
    t14 = *((unsigned int *)t9);
    t15 = *((unsigned int *)t10);
    t16 = (t14 ^ t15);
    t17 = (t13 | t16);
    t18 = *((unsigned int *)t9);
    t19 = *((unsigned int *)t10);
    t20 = (t18 | t19);
    t21 = (~(t20));
    t22 = (t17 & t21);
    if (t22 != 0)
        goto LAB7;

LAB4:    if (t20 != 0)
        goto LAB6;

LAB5:    *((unsigned int *)t8) = 1;

LAB7:    t24 = (t0 + 3384);
    t25 = (t24 + 56U);
    t26 = *((char **)t25);
    t27 = ((char*)((ng2)));
    memset(t28, 0, 8);
    t29 = (t26 + 4);
    t30 = (t27 + 4);
    t31 = *((unsigned int *)t26);
    t32 = *((unsigned int *)t27);
    t33 = (t31 ^ t32);
    t34 = *((unsigned int *)t29);
    t35 = *((unsigned int *)t30);
    t36 = (t34 ^ t35);
    t37 = (t33 | t36);
    t38 = *((unsigned int *)t29);
    t39 = *((unsigned int *)t30);
    t40 = (t38 | t39);
    t41 = (~(t40));
    t42 = (t37 & t41);
    if (t42 != 0)
        goto LAB11;

LAB8:    if (t40 != 0)
        goto LAB10;

LAB9:    *((unsigned int *)t28) = 1;

LAB11:    t45 = *((unsigned int *)t8);
    t46 = *((unsigned int *)t28);
    t47 = (t45 | t46);
    *((unsigned int *)t44) = t47;
    t48 = (t8 + 4);
    t49 = (t28 + 4);
    t50 = (t44 + 4);
    t51 = *((unsigned int *)t48);
    t52 = *((unsigned int *)t49);
    t53 = (t51 | t52);
    *((unsigned int *)t50) = t53;
    t54 = *((unsigned int *)t50);
    t55 = (t54 != 0);
    if (t55 == 1)
        goto LAB12;

LAB13:
LAB14:    memset(t4, 0, 8);
    t72 = (t44 + 4);
    t73 = *((unsigned int *)t72);
    t74 = (~(t73));
    t75 = *((unsigned int *)t44);
    t76 = (t75 & t74);
    t77 = (t76 & 1U);
    if (t77 != 0)
        goto LAB15;

LAB16:    if (*((unsigned int *)t72) != 0)
        goto LAB17;

LAB18:    t79 = (t4 + 4);
    t80 = *((unsigned int *)t4);
    t81 = *((unsigned int *)t79);
    t82 = (t80 || t81);
    if (t82 > 0)
        goto LAB19;

LAB20:    t84 = *((unsigned int *)t4);
    t85 = (~(t84));
    t86 = *((unsigned int *)t79);
    t87 = (t85 || t86);
    if (t87 > 0)
        goto LAB21;

LAB22:    if (*((unsigned int *)t79) > 0)
        goto LAB23;

LAB24:    if (*((unsigned int *)t4) > 0)
        goto LAB25;

LAB26:    memcpy(t3, t88, 8);

LAB27:    t89 = (t0 + 6504);
    t90 = (t89 + 56U);
    t91 = *((char **)t90);
    t92 = (t91 + 56U);
    t93 = *((char **)t92);
    memset(t93, 0, 8);
    t94 = 1U;
    t95 = t94;
    t96 = (t3 + 4);
    t97 = *((unsigned int *)t3);
    t94 = (t94 & t97);
    t98 = *((unsigned int *)t96);
    t95 = (t95 & t98);
    t99 = (t93 + 4);
    t100 = *((unsigned int *)t93);
    *((unsigned int *)t93) = (t100 | t94);
    t101 = *((unsigned int *)t99);
    *((unsigned int *)t99) = (t101 | t95);
    xsi_driver_vfirst_trans(t89, 0, 0);
    t102 = (t0 + 6344);
    *((int *)t102) = 1;

LAB1:    return;
LAB6:    t23 = (t8 + 4);
    *((unsigned int *)t8) = 1;
    *((unsigned int *)t23) = 1;
    goto LAB7;

LAB10:    t43 = (t28 + 4);
    *((unsigned int *)t28) = 1;
    *((unsigned int *)t43) = 1;
    goto LAB11;

LAB12:    t56 = *((unsigned int *)t44);
    t57 = *((unsigned int *)t50);
    *((unsigned int *)t44) = (t56 | t57);
    t58 = (t8 + 4);
    t59 = (t28 + 4);
    t60 = *((unsigned int *)t58);
    t61 = (~(t60));
    t62 = *((unsigned int *)t8);
    t63 = (t62 & t61);
    t64 = *((unsigned int *)t59);
    t65 = (~(t64));
    t66 = *((unsigned int *)t28);
    t67 = (t66 & t65);
    t68 = (~(t63));
    t69 = (~(t67));
    t70 = *((unsigned int *)t50);
    *((unsigned int *)t50) = (t70 & t68);
    t71 = *((unsigned int *)t50);
    *((unsigned int *)t50) = (t71 & t69);
    goto LAB14;

LAB15:    *((unsigned int *)t4) = 1;
    goto LAB18;

LAB17:    t78 = (t4 + 4);
    *((unsigned int *)t4) = 1;
    *((unsigned int *)t78) = 1;
    goto LAB18;

LAB19:    t83 = ((char*)((ng3)));
    goto LAB20;

LAB21:    t88 = ((char*)((ng4)));
    goto LAB22;

LAB23:    xsi_vlog_unsigned_bit_combine(t3, 1, t83, 1, t88, 1);
    goto LAB27;

LAB25:    memcpy(t3, t83, 8);
    goto LAB27;

}

static void Cont_29_1(char *t0)
{
    char t3[8];
    char t4[8];
    char t8[8];
    char t28[8];
    char t44[8];
    char t76[8];
    char t92[8];
    char *t1;
    char *t2;
    char *t5;
    char *t6;
    char *t7;
    char *t9;
    char *t10;
    unsigned int t11;
    unsigned int t12;
    unsigned int t13;
    unsigned int t14;
    unsigned int t15;
    unsigned int t16;
    unsigned int t17;
    unsigned int t18;
    unsigned int t19;
    unsigned int t20;
    unsigned int t21;
    unsigned int t22;
    char *t23;
    char *t24;
    char *t25;
    char *t26;
    char *t27;
    char *t29;
    char *t30;
    unsigned int t31;
    unsigned int t32;
    unsigned int t33;
    unsigned int t34;
    unsigned int t35;
    unsigned int t36;
    unsigned int t37;
    unsigned int t38;
    unsigned int t39;
    unsigned int t40;
    unsigned int t41;
    unsigned int t42;
    char *t43;
    unsigned int t45;
    unsigned int t46;
    unsigned int t47;
    char *t48;
    char *t49;
    char *t50;
    unsigned int t51;
    unsigned int t52;
    unsigned int t53;
    unsigned int t54;
    unsigned int t55;
    unsigned int t56;
    unsigned int t57;
    char *t58;
    char *t59;
    unsigned int t60;
    unsigned int t61;
    unsigned int t62;
    int t63;
    unsigned int t64;
    unsigned int t65;
    unsigned int t66;
    int t67;
    unsigned int t68;
    unsigned int t69;
    unsigned int t70;
    unsigned int t71;
    char *t72;
    char *t73;
    char *t74;
    char *t75;
    char *t77;
    char *t78;
    unsigned int t79;
    unsigned int t80;
    unsigned int t81;
    unsigned int t82;
    unsigned int t83;
    unsigned int t84;
    unsigned int t85;
    unsigned int t86;
    unsigned int t87;
    unsigned int t88;
    unsigned int t89;
    unsigned int t90;
    char *t91;
    unsigned int t93;
    unsigned int t94;
    unsigned int t95;
    char *t96;
    char *t97;
    char *t98;
    unsigned int t99;
    unsigned int t100;
    unsigned int t101;
    unsigned int t102;
    unsigned int t103;
    unsigned int t104;
    unsigned int t105;
    char *t106;
    char *t107;
    unsigned int t108;
    unsigned int t109;
    unsigned int t110;
    int t111;
    unsigned int t112;
    unsigned int t113;
    unsigned int t114;
    int t115;
    unsigned int t116;
    unsigned int t117;
    unsigned int t118;
    unsigned int t119;
    char *t120;
    unsigned int t121;
    unsigned int t122;
    unsigned int t123;
    unsigned int t124;
    unsigned int t125;
    char *t126;
    char *t127;
    unsigned int t128;
    unsigned int t129;
    unsigned int t130;
    char *t131;
    unsigned int t132;
    unsigned int t133;
    unsigned int t134;
    unsigned int t135;
    char *t136;
    char *t137;
    char *t138;
    char *t139;
    char *t140;
    char *t141;
    unsigned int t142;
    unsigned int t143;
    char *t144;
    unsigned int t145;
    unsigned int t146;
    char *t147;
    unsigned int t148;
    unsigned int t149;
    char *t150;

LAB0:    t1 = (t0 + 5032U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(29, ng0);
    t2 = (t0 + 3384);
    t5 = (t2 + 56U);
    t6 = *((char **)t5);
    t7 = ((char*)((ng1)));
    memset(t8, 0, 8);
    t9 = (t6 + 4);
    t10 = (t7 + 4);
    t11 = *((unsigned int *)t6);
    t12 = *((unsigned int *)t7);
    t13 = (t11 ^ t12);
    t14 = *((unsigned int *)t9);
    t15 = *((unsigned int *)t10);
    t16 = (t14 ^ t15);
    t17 = (t13 | t16);
    t18 = *((unsigned int *)t9);
    t19 = *((unsigned int *)t10);
    t20 = (t18 | t19);
    t21 = (~(t20));
    t22 = (t17 & t21);
    if (t22 != 0)
        goto LAB7;

LAB4:    if (t20 != 0)
        goto LAB6;

LAB5:    *((unsigned int *)t8) = 1;

LAB7:    t24 = (t0 + 3384);
    t25 = (t24 + 56U);
    t26 = *((char **)t25);
    t27 = ((char*)((ng2)));
    memset(t28, 0, 8);
    t29 = (t26 + 4);
    t30 = (t27 + 4);
    t31 = *((unsigned int *)t26);
    t32 = *((unsigned int *)t27);
    t33 = (t31 ^ t32);
    t34 = *((unsigned int *)t29);
    t35 = *((unsigned int *)t30);
    t36 = (t34 ^ t35);
    t37 = (t33 | t36);
    t38 = *((unsigned int *)t29);
    t39 = *((unsigned int *)t30);
    t40 = (t38 | t39);
    t41 = (~(t40));
    t42 = (t37 & t41);
    if (t42 != 0)
        goto LAB11;

LAB8:    if (t40 != 0)
        goto LAB10;

LAB9:    *((unsigned int *)t28) = 1;

LAB11:    t45 = *((unsigned int *)t8);
    t46 = *((unsigned int *)t28);
    t47 = (t45 | t46);
    *((unsigned int *)t44) = t47;
    t48 = (t8 + 4);
    t49 = (t28 + 4);
    t50 = (t44 + 4);
    t51 = *((unsigned int *)t48);
    t52 = *((unsigned int *)t49);
    t53 = (t51 | t52);
    *((unsigned int *)t50) = t53;
    t54 = *((unsigned int *)t50);
    t55 = (t54 != 0);
    if (t55 == 1)
        goto LAB12;

LAB13:
LAB14:    t72 = (t0 + 3384);
    t73 = (t72 + 56U);
    t74 = *((char **)t73);
    t75 = ((char*)((ng5)));
    memset(t76, 0, 8);
    t77 = (t74 + 4);
    t78 = (t75 + 4);
    t79 = *((unsigned int *)t74);
    t80 = *((unsigned int *)t75);
    t81 = (t79 ^ t80);
    t82 = *((unsigned int *)t77);
    t83 = *((unsigned int *)t78);
    t84 = (t82 ^ t83);
    t85 = (t81 | t84);
    t86 = *((unsigned int *)t77);
    t87 = *((unsigned int *)t78);
    t88 = (t86 | t87);
    t89 = (~(t88));
    t90 = (t85 & t89);
    if (t90 != 0)
        goto LAB18;

LAB15:    if (t88 != 0)
        goto LAB17;

LAB16:    *((unsigned int *)t76) = 1;

LAB18:    t93 = *((unsigned int *)t44);
    t94 = *((unsigned int *)t76);
    t95 = (t93 | t94);
    *((unsigned int *)t92) = t95;
    t96 = (t44 + 4);
    t97 = (t76 + 4);
    t98 = (t92 + 4);
    t99 = *((unsigned int *)t96);
    t100 = *((unsigned int *)t97);
    t101 = (t99 | t100);
    *((unsigned int *)t98) = t101;
    t102 = *((unsigned int *)t98);
    t103 = (t102 != 0);
    if (t103 == 1)
        goto LAB19;

LAB20:
LAB21:    memset(t4, 0, 8);
    t120 = (t92 + 4);
    t121 = *((unsigned int *)t120);
    t122 = (~(t121));
    t123 = *((unsigned int *)t92);
    t124 = (t123 & t122);
    t125 = (t124 & 1U);
    if (t125 != 0)
        goto LAB22;

LAB23:    if (*((unsigned int *)t120) != 0)
        goto LAB24;

LAB25:    t127 = (t4 + 4);
    t128 = *((unsigned int *)t4);
    t129 = *((unsigned int *)t127);
    t130 = (t128 || t129);
    if (t130 > 0)
        goto LAB26;

LAB27:    t132 = *((unsigned int *)t4);
    t133 = (~(t132));
    t134 = *((unsigned int *)t127);
    t135 = (t133 || t134);
    if (t135 > 0)
        goto LAB28;

LAB29:    if (*((unsigned int *)t127) > 0)
        goto LAB30;

LAB31:    if (*((unsigned int *)t4) > 0)
        goto LAB32;

LAB33:    memcpy(t3, t136, 8);

LAB34:    t137 = (t0 + 6568);
    t138 = (t137 + 56U);
    t139 = *((char **)t138);
    t140 = (t139 + 56U);
    t141 = *((char **)t140);
    memset(t141, 0, 8);
    t142 = 1U;
    t143 = t142;
    t144 = (t3 + 4);
    t145 = *((unsigned int *)t3);
    t142 = (t142 & t145);
    t146 = *((unsigned int *)t144);
    t143 = (t143 & t146);
    t147 = (t141 + 4);
    t148 = *((unsigned int *)t141);
    *((unsigned int *)t141) = (t148 | t142);
    t149 = *((unsigned int *)t147);
    *((unsigned int *)t147) = (t149 | t143);
    xsi_driver_vfirst_trans(t137, 0, 0);
    t150 = (t0 + 6360);
    *((int *)t150) = 1;

LAB1:    return;
LAB6:    t23 = (t8 + 4);
    *((unsigned int *)t8) = 1;
    *((unsigned int *)t23) = 1;
    goto LAB7;

LAB10:    t43 = (t28 + 4);
    *((unsigned int *)t28) = 1;
    *((unsigned int *)t43) = 1;
    goto LAB11;

LAB12:    t56 = *((unsigned int *)t44);
    t57 = *((unsigned int *)t50);
    *((unsigned int *)t44) = (t56 | t57);
    t58 = (t8 + 4);
    t59 = (t28 + 4);
    t60 = *((unsigned int *)t58);
    t61 = (~(t60));
    t62 = *((unsigned int *)t8);
    t63 = (t62 & t61);
    t64 = *((unsigned int *)t59);
    t65 = (~(t64));
    t66 = *((unsigned int *)t28);
    t67 = (t66 & t65);
    t68 = (~(t63));
    t69 = (~(t67));
    t70 = *((unsigned int *)t50);
    *((unsigned int *)t50) = (t70 & t68);
    t71 = *((unsigned int *)t50);
    *((unsigned int *)t50) = (t71 & t69);
    goto LAB14;

LAB17:    t91 = (t76 + 4);
    *((unsigned int *)t76) = 1;
    *((unsigned int *)t91) = 1;
    goto LAB18;

LAB19:    t104 = *((unsigned int *)t92);
    t105 = *((unsigned int *)t98);
    *((unsigned int *)t92) = (t104 | t105);
    t106 = (t44 + 4);
    t107 = (t76 + 4);
    t108 = *((unsigned int *)t106);
    t109 = (~(t108));
    t110 = *((unsigned int *)t44);
    t111 = (t110 & t109);
    t112 = *((unsigned int *)t107);
    t113 = (~(t112));
    t114 = *((unsigned int *)t76);
    t115 = (t114 & t113);
    t116 = (~(t111));
    t117 = (~(t115));
    t118 = *((unsigned int *)t98);
    *((unsigned int *)t98) = (t118 & t116);
    t119 = *((unsigned int *)t98);
    *((unsigned int *)t98) = (t119 & t117);
    goto LAB21;

LAB22:    *((unsigned int *)t4) = 1;
    goto LAB25;

LAB24:    t126 = (t4 + 4);
    *((unsigned int *)t4) = 1;
    *((unsigned int *)t126) = 1;
    goto LAB25;

LAB26:    t131 = ((char*)((ng3)));
    goto LAB27;

LAB28:    t136 = ((char*)((ng4)));
    goto LAB29;

LAB30:    xsi_vlog_unsigned_bit_combine(t3, 1, t131, 1, t136, 1);
    goto LAB34;

LAB32:    memcpy(t3, t131, 8);
    goto LAB34;

}

static void Always_32_2(char *t0)
{
    char t4[8];
    char t31[8];
    char t35[8];
    char t72[8];
    char *t1;
    char *t2;
    char *t3;
    char *t5;
    char *t6;
    unsigned int t7;
    unsigned int t8;
    unsigned int t9;
    unsigned int t10;
    unsigned int t11;
    char *t12;
    char *t13;
    unsigned int t14;
    unsigned int t15;
    unsigned int t16;
    unsigned int t17;
    unsigned int t18;
    char *t19;
    char *t20;
    unsigned int t21;
    unsigned int t22;
    unsigned int t23;
    unsigned int t24;
    unsigned int t25;
    unsigned int t26;
    unsigned int t27;
    char *t28;
    char *t29;
    char *t30;
    char *t32;
    char *t33;
    char *t34;
    char *t36;
    char *t37;
    char *t38;
    unsigned int t39;
    unsigned int t40;
    unsigned int t41;
    unsigned int t42;
    unsigned int t43;
    char *t44;
    char *t45;
    unsigned int t46;
    unsigned int t47;
    unsigned int t48;
    unsigned int t49;
    unsigned int t50;
    unsigned int t51;
    unsigned int t52;
    unsigned int t53;
    int t54;
    int t55;
    unsigned int t56;
    unsigned int t57;
    unsigned int t58;
    unsigned int t59;
    unsigned int t60;
    unsigned int t61;
    char *t62;
    unsigned int t63;
    unsigned int t64;
    unsigned int t65;
    unsigned int t66;
    unsigned int t67;
    char *t68;
    char *t69;
    char *t70;
    char *t71;
    char *t73;

LAB0:    t1 = (t0 + 5280U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(32, ng0);
    t2 = (t0 + 6376);
    *((int *)t2) = 1;
    t3 = (t0 + 5312);
    *((char **)t3) = t2;
    *((char **)t1) = &&LAB4;

LAB1:    return;
LAB4:    xsi_set_current_line(32, ng0);

LAB5:    xsi_set_current_line(33, ng0);
    t5 = (t0 + 1864U);
    t6 = *((char **)t5);
    memset(t4, 0, 8);
    t5 = (t6 + 4);
    t7 = *((unsigned int *)t5);
    t8 = (~(t7));
    t9 = *((unsigned int *)t6);
    t10 = (t9 & t8);
    t11 = (t10 & 1U);
    if (t11 != 0)
        goto LAB9;

LAB7:    if (*((unsigned int *)t5) == 0)
        goto LAB6;

LAB8:    t12 = (t4 + 4);
    *((unsigned int *)t4) = 1;
    *((unsigned int *)t12) = 1;

LAB9:    t13 = (t4 + 4);
    t14 = *((unsigned int *)t13);
    t15 = (~(t14));
    t16 = *((unsigned int *)t4);
    t17 = (t16 & t15);
    t18 = (t17 != 0);
    if (t18 > 0)
        goto LAB10;

LAB11:    xsi_set_current_line(35, ng0);
    t2 = (t0 + 3384);
    t3 = (t2 + 56U);
    t5 = *((char **)t3);
    t6 = ((char*)((ng1)));
    memset(t4, 0, 8);
    t12 = (t5 + 4);
    t13 = (t6 + 4);
    t7 = *((unsigned int *)t5);
    t8 = *((unsigned int *)t6);
    t9 = (t7 ^ t8);
    t10 = *((unsigned int *)t12);
    t11 = *((unsigned int *)t13);
    t14 = (t10 ^ t11);
    t15 = (t9 | t14);
    t16 = *((unsigned int *)t12);
    t17 = *((unsigned int *)t13);
    t18 = (t16 | t17);
    t21 = (~(t18));
    t22 = (t15 & t21);
    if (t22 != 0)
        goto LAB17;

LAB14:    if (t18 != 0)
        goto LAB16;

LAB15:    *((unsigned int *)t4) = 1;

LAB17:    t20 = (t4 + 4);
    t23 = *((unsigned int *)t20);
    t24 = (~(t23));
    t25 = *((unsigned int *)t4);
    t26 = (t25 & t24);
    t27 = (t26 != 0);
    if (t27 > 0)
        goto LAB18;

LAB19:    xsi_set_current_line(37, ng0);
    t2 = (t0 + 3384);
    t3 = (t2 + 56U);
    t5 = *((char **)t3);
    t6 = ((char*)((ng2)));
    memset(t4, 0, 8);
    t12 = (t5 + 4);
    t13 = (t6 + 4);
    t7 = *((unsigned int *)t5);
    t8 = *((unsigned int *)t6);
    t9 = (t7 ^ t8);
    t10 = *((unsigned int *)t12);
    t11 = *((unsigned int *)t13);
    t14 = (t10 ^ t11);
    t15 = (t9 | t14);
    t16 = *((unsigned int *)t12);
    t17 = *((unsigned int *)t13);
    t18 = (t16 | t17);
    t21 = (~(t18));
    t22 = (t15 & t21);
    if (t22 != 0)
        goto LAB25;

LAB22:    if (t18 != 0)
        goto LAB24;

LAB23:    *((unsigned int *)t4) = 1;

LAB25:    t20 = (t0 + 3864);
    t28 = (t20 + 56U);
    t29 = *((char **)t28);
    t30 = ((char*)((ng3)));
    memset(t31, 0, 8);
    t32 = (t29 + 4);
    if (*((unsigned int *)t32) != 0)
        goto LAB27;

LAB26:    t33 = (t30 + 4);
    if (*((unsigned int *)t33) != 0)
        goto LAB27;

LAB30:    if (*((unsigned int *)t29) > *((unsigned int *)t30))
        goto LAB28;

LAB29:    t23 = *((unsigned int *)t4);
    t24 = *((unsigned int *)t31);
    t25 = (t23 & t24);
    *((unsigned int *)t35) = t25;
    t36 = (t4 + 4);
    t37 = (t31 + 4);
    t38 = (t35 + 4);
    t26 = *((unsigned int *)t36);
    t27 = *((unsigned int *)t37);
    t39 = (t26 | t27);
    *((unsigned int *)t38) = t39;
    t40 = *((unsigned int *)t38);
    t41 = (t40 != 0);
    if (t41 == 1)
        goto LAB31;

LAB32:
LAB33:    t62 = (t35 + 4);
    t63 = *((unsigned int *)t62);
    t64 = (~(t63));
    t65 = *((unsigned int *)t35);
    t66 = (t65 & t64);
    t67 = (t66 != 0);
    if (t67 > 0)
        goto LAB34;

LAB35:    xsi_set_current_line(39, ng0);

LAB38:    xsi_set_current_line(40, ng0);
    t2 = (t0 + 3864);
    t3 = (t2 + 56U);
    t5 = *((char **)t3);
    t6 = (t0 + 3864);
    xsi_vlogvar_wait_assign_value(t6, t5, 0, 0, 1, 0LL);

LAB36:
LAB20:
LAB12:    goto LAB2;

LAB6:    *((unsigned int *)t4) = 1;
    goto LAB9;

LAB10:    xsi_set_current_line(33, ng0);

LAB13:    xsi_set_current_line(34, ng0);
    t19 = ((char*)((ng3)));
    t20 = (t0 + 3864);
    xsi_vlogvar_wait_assign_value(t20, t19, 0, 0, 1, 0LL);
    goto LAB12;

LAB16:    t19 = (t4 + 4);
    *((unsigned int *)t4) = 1;
    *((unsigned int *)t19) = 1;
    goto LAB17;

LAB18:    xsi_set_current_line(35, ng0);

LAB21:    xsi_set_current_line(36, ng0);
    t28 = ((char*)((ng4)));
    t29 = (t0 + 3864);
    xsi_vlogvar_wait_assign_value(t29, t28, 0, 0, 1, 0LL);
    goto LAB20;

LAB24:    t19 = (t4 + 4);
    *((unsigned int *)t4) = 1;
    *((unsigned int *)t19) = 1;
    goto LAB25;

LAB27:    t34 = (t31 + 4);
    *((unsigned int *)t31) = 1;
    *((unsigned int *)t34) = 1;
    goto LAB29;

LAB28:    *((unsigned int *)t31) = 1;
    goto LAB29;

LAB31:    t42 = *((unsigned int *)t35);
    t43 = *((unsigned int *)t38);
    *((unsigned int *)t35) = (t42 | t43);
    t44 = (t4 + 4);
    t45 = (t31 + 4);
    t46 = *((unsigned int *)t4);
    t47 = (~(t46));
    t48 = *((unsigned int *)t44);
    t49 = (~(t48));
    t50 = *((unsigned int *)t31);
    t51 = (~(t50));
    t52 = *((unsigned int *)t45);
    t53 = (~(t52));
    t54 = (t47 & t49);
    t55 = (t51 & t53);
    t56 = (~(t54));
    t57 = (~(t55));
    t58 = *((unsigned int *)t38);
    *((unsigned int *)t38) = (t58 & t56);
    t59 = *((unsigned int *)t38);
    *((unsigned int *)t38) = (t59 & t57);
    t60 = *((unsigned int *)t35);
    *((unsigned int *)t35) = (t60 & t56);
    t61 = *((unsigned int *)t35);
    *((unsigned int *)t35) = (t61 & t57);
    goto LAB33;

LAB34:    xsi_set_current_line(37, ng0);

LAB37:    xsi_set_current_line(38, ng0);
    t68 = (t0 + 3864);
    t69 = (t68 + 56U);
    t70 = *((char **)t69);
    t71 = ((char*)((ng4)));
    memset(t72, 0, 8);
    xsi_vlog_unsigned_minus(t72, 1, t70, 1, t71, 1);
    t73 = (t0 + 3864);
    xsi_vlogvar_wait_assign_value(t73, t72, 0, 0, 1, 0LL);
    goto LAB36;

}

static void Always_45_3(char *t0)
{
    char t4[8];
    char t31[8];
    char t35[8];
    char t72[8];
    char *t1;
    char *t2;
    char *t3;
    char *t5;
    char *t6;
    unsigned int t7;
    unsigned int t8;
    unsigned int t9;
    unsigned int t10;
    unsigned int t11;
    char *t12;
    char *t13;
    unsigned int t14;
    unsigned int t15;
    unsigned int t16;
    unsigned int t17;
    unsigned int t18;
    char *t19;
    char *t20;
    unsigned int t21;
    unsigned int t22;
    unsigned int t23;
    unsigned int t24;
    unsigned int t25;
    unsigned int t26;
    unsigned int t27;
    char *t28;
    char *t29;
    char *t30;
    char *t32;
    char *t33;
    char *t34;
    char *t36;
    char *t37;
    char *t38;
    unsigned int t39;
    unsigned int t40;
    unsigned int t41;
    unsigned int t42;
    unsigned int t43;
    char *t44;
    char *t45;
    unsigned int t46;
    unsigned int t47;
    unsigned int t48;
    unsigned int t49;
    unsigned int t50;
    unsigned int t51;
    unsigned int t52;
    unsigned int t53;
    int t54;
    int t55;
    unsigned int t56;
    unsigned int t57;
    unsigned int t58;
    unsigned int t59;
    unsigned int t60;
    unsigned int t61;
    char *t62;
    unsigned int t63;
    unsigned int t64;
    unsigned int t65;
    unsigned int t66;
    unsigned int t67;
    char *t68;
    char *t69;
    char *t70;
    char *t71;
    char *t73;

LAB0:    t1 = (t0 + 5528U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(45, ng0);
    t2 = (t0 + 6392);
    *((int *)t2) = 1;
    t3 = (t0 + 5560);
    *((char **)t3) = t2;
    *((char **)t1) = &&LAB4;

LAB1:    return;
LAB4:    xsi_set_current_line(45, ng0);

LAB5:    xsi_set_current_line(46, ng0);
    t5 = (t0 + 1864U);
    t6 = *((char **)t5);
    memset(t4, 0, 8);
    t5 = (t6 + 4);
    t7 = *((unsigned int *)t5);
    t8 = (~(t7));
    t9 = *((unsigned int *)t6);
    t10 = (t9 & t8);
    t11 = (t10 & 1U);
    if (t11 != 0)
        goto LAB9;

LAB7:    if (*((unsigned int *)t5) == 0)
        goto LAB6;

LAB8:    t12 = (t4 + 4);
    *((unsigned int *)t4) = 1;
    *((unsigned int *)t12) = 1;

LAB9:    t13 = (t4 + 4);
    t14 = *((unsigned int *)t13);
    t15 = (~(t14));
    t16 = *((unsigned int *)t4);
    t17 = (t16 & t15);
    t18 = (t17 != 0);
    if (t18 > 0)
        goto LAB10;

LAB11:    xsi_set_current_line(48, ng0);
    t2 = (t0 + 3384);
    t3 = (t2 + 56U);
    t5 = *((char **)t3);
    t6 = ((char*)((ng2)));
    memset(t4, 0, 8);
    t12 = (t5 + 4);
    t13 = (t6 + 4);
    t7 = *((unsigned int *)t5);
    t8 = *((unsigned int *)t6);
    t9 = (t7 ^ t8);
    t10 = *((unsigned int *)t12);
    t11 = *((unsigned int *)t13);
    t14 = (t10 ^ t11);
    t15 = (t9 | t14);
    t16 = *((unsigned int *)t12);
    t17 = *((unsigned int *)t13);
    t18 = (t16 | t17);
    t21 = (~(t18));
    t22 = (t15 & t21);
    if (t22 != 0)
        goto LAB17;

LAB14:    if (t18 != 0)
        goto LAB16;

LAB15:    *((unsigned int *)t4) = 1;

LAB17:    t20 = (t4 + 4);
    t23 = *((unsigned int *)t20);
    t24 = (~(t23));
    t25 = *((unsigned int *)t4);
    t26 = (t25 & t24);
    t27 = (t26 != 0);
    if (t27 > 0)
        goto LAB18;

LAB19:    xsi_set_current_line(50, ng0);
    t2 = (t0 + 3384);
    t3 = (t2 + 56U);
    t5 = *((char **)t3);
    t6 = ((char*)((ng5)));
    memset(t4, 0, 8);
    t12 = (t5 + 4);
    t13 = (t6 + 4);
    t7 = *((unsigned int *)t5);
    t8 = *((unsigned int *)t6);
    t9 = (t7 ^ t8);
    t10 = *((unsigned int *)t12);
    t11 = *((unsigned int *)t13);
    t14 = (t10 ^ t11);
    t15 = (t9 | t14);
    t16 = *((unsigned int *)t12);
    t17 = *((unsigned int *)t13);
    t18 = (t16 | t17);
    t21 = (~(t18));
    t22 = (t15 & t21);
    if (t22 != 0)
        goto LAB25;

LAB22:    if (t18 != 0)
        goto LAB24;

LAB23:    *((unsigned int *)t4) = 1;

LAB25:    t20 = (t0 + 3704);
    t28 = (t20 + 56U);
    t29 = *((char **)t28);
    t30 = ((char*)((ng3)));
    memset(t31, 0, 8);
    t32 = (t29 + 4);
    if (*((unsigned int *)t32) != 0)
        goto LAB27;

LAB26:    t33 = (t30 + 4);
    if (*((unsigned int *)t33) != 0)
        goto LAB27;

LAB30:    if (*((unsigned int *)t29) > *((unsigned int *)t30))
        goto LAB28;

LAB29:    t23 = *((unsigned int *)t4);
    t24 = *((unsigned int *)t31);
    t25 = (t23 & t24);
    *((unsigned int *)t35) = t25;
    t36 = (t4 + 4);
    t37 = (t31 + 4);
    t38 = (t35 + 4);
    t26 = *((unsigned int *)t36);
    t27 = *((unsigned int *)t37);
    t39 = (t26 | t27);
    *((unsigned int *)t38) = t39;
    t40 = *((unsigned int *)t38);
    t41 = (t40 != 0);
    if (t41 == 1)
        goto LAB31;

LAB32:
LAB33:    t62 = (t35 + 4);
    t63 = *((unsigned int *)t62);
    t64 = (~(t63));
    t65 = *((unsigned int *)t35);
    t66 = (t65 & t64);
    t67 = (t66 != 0);
    if (t67 > 0)
        goto LAB34;

LAB35:    xsi_set_current_line(52, ng0);

LAB38:    xsi_set_current_line(53, ng0);
    t2 = (t0 + 3704);
    t3 = (t2 + 56U);
    t5 = *((char **)t3);
    t6 = (t0 + 3704);
    xsi_vlogvar_wait_assign_value(t6, t5, 0, 0, 2, 0LL);

LAB36:
LAB20:
LAB12:    goto LAB2;

LAB6:    *((unsigned int *)t4) = 1;
    goto LAB9;

LAB10:    xsi_set_current_line(46, ng0);

LAB13:    xsi_set_current_line(47, ng0);
    t19 = ((char*)((ng3)));
    t20 = (t0 + 3704);
    xsi_vlogvar_wait_assign_value(t20, t19, 0, 0, 2, 0LL);
    goto LAB12;

LAB16:    t19 = (t4 + 4);
    *((unsigned int *)t4) = 1;
    *((unsigned int *)t19) = 1;
    goto LAB17;

LAB18:    xsi_set_current_line(48, ng0);

LAB21:    xsi_set_current_line(49, ng0);
    t28 = ((char*)((ng6)));
    t29 = (t0 + 3704);
    xsi_vlogvar_wait_assign_value(t29, t28, 0, 0, 2, 0LL);
    goto LAB20;

LAB24:    t19 = (t4 + 4);
    *((unsigned int *)t4) = 1;
    *((unsigned int *)t19) = 1;
    goto LAB25;

LAB27:    t34 = (t31 + 4);
    *((unsigned int *)t31) = 1;
    *((unsigned int *)t34) = 1;
    goto LAB29;

LAB28:    *((unsigned int *)t31) = 1;
    goto LAB29;

LAB31:    t42 = *((unsigned int *)t35);
    t43 = *((unsigned int *)t38);
    *((unsigned int *)t35) = (t42 | t43);
    t44 = (t4 + 4);
    t45 = (t31 + 4);
    t46 = *((unsigned int *)t4);
    t47 = (~(t46));
    t48 = *((unsigned int *)t44);
    t49 = (~(t48));
    t50 = *((unsigned int *)t31);
    t51 = (~(t50));
    t52 = *((unsigned int *)t45);
    t53 = (~(t52));
    t54 = (t47 & t49);
    t55 = (t51 & t53);
    t56 = (~(t54));
    t57 = (~(t55));
    t58 = *((unsigned int *)t38);
    *((unsigned int *)t38) = (t58 & t56);
    t59 = *((unsigned int *)t38);
    *((unsigned int *)t38) = (t59 & t57);
    t60 = *((unsigned int *)t35);
    *((unsigned int *)t35) = (t60 & t56);
    t61 = *((unsigned int *)t35);
    *((unsigned int *)t35) = (t61 & t57);
    goto LAB33;

LAB34:    xsi_set_current_line(50, ng0);

LAB37:    xsi_set_current_line(51, ng0);
    t68 = (t0 + 3704);
    t69 = (t68 + 56U);
    t70 = *((char **)t69);
    t71 = ((char*)((ng4)));
    memset(t72, 0, 8);
    xsi_vlog_unsigned_minus(t72, 2, t70, 2, t71, 2);
    t73 = (t0 + 3704);
    xsi_vlogvar_wait_assign_value(t73, t72, 0, 0, 2, 0LL);
    goto LAB36;

}

static void Always_58_4(char *t0)
{
    char t4[8];
    char *t1;
    char *t2;
    char *t3;
    char *t5;
    char *t6;
    unsigned int t7;
    unsigned int t8;
    unsigned int t9;
    unsigned int t10;
    unsigned int t11;
    char *t12;
    char *t13;
    unsigned int t14;
    unsigned int t15;
    unsigned int t16;
    unsigned int t17;
    unsigned int t18;
    char *t19;
    char *t20;

LAB0:    t1 = (t0 + 5776U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(58, ng0);
    t2 = (t0 + 6408);
    *((int *)t2) = 1;
    t3 = (t0 + 5808);
    *((char **)t3) = t2;
    *((char **)t1) = &&LAB4;

LAB1:    return;
LAB4:    xsi_set_current_line(58, ng0);

LAB5:    xsi_set_current_line(59, ng0);
    t5 = (t0 + 1864U);
    t6 = *((char **)t5);
    memset(t4, 0, 8);
    t5 = (t6 + 4);
    t7 = *((unsigned int *)t5);
    t8 = (~(t7));
    t9 = *((unsigned int *)t6);
    t10 = (t9 & t8);
    t11 = (t10 & 1U);
    if (t11 != 0)
        goto LAB9;

LAB7:    if (*((unsigned int *)t5) == 0)
        goto LAB6;

LAB8:    t12 = (t4 + 4);
    *((unsigned int *)t4) = 1;
    *((unsigned int *)t12) = 1;

LAB9:    t13 = (t4 + 4);
    t14 = *((unsigned int *)t13);
    t15 = (~(t14));
    t16 = *((unsigned int *)t4);
    t17 = (t16 & t15);
    t18 = (t17 != 0);
    if (t18 > 0)
        goto LAB10;

LAB11:    xsi_set_current_line(61, ng0);

LAB14:    xsi_set_current_line(62, ng0);
    t2 = (t0 + 3544);
    t3 = (t2 + 56U);
    t5 = *((char **)t3);
    t6 = (t0 + 3384);
    xsi_vlogvar_wait_assign_value(t6, t5, 0, 0, 3, 0LL);

LAB12:    goto LAB2;

LAB6:    *((unsigned int *)t4) = 1;
    goto LAB9;

LAB10:    xsi_set_current_line(59, ng0);

LAB13:    xsi_set_current_line(60, ng0);
    t19 = ((char*)((ng3)));
    t20 = (t0 + 3384);
    xsi_vlogvar_wait_assign_value(t20, t19, 0, 0, 3, 0LL);
    goto LAB12;

}

static void Always_67_5(char *t0)
{
    char t10[8];
    char t26[8];
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t5;
    char *t6;
    char *t7;
    int t8;
    char *t9;
    char *t11;
    char *t12;
    unsigned int t13;
    unsigned int t14;
    unsigned int t15;
    unsigned int t16;
    unsigned int t17;
    unsigned int t18;
    unsigned int t19;
    unsigned int t20;
    unsigned int t21;
    unsigned int t22;
    unsigned int t23;
    unsigned int t24;
    char *t25;
    unsigned int t27;
    unsigned int t28;
    unsigned int t29;
    char *t30;
    char *t31;
    char *t32;
    unsigned int t33;
    unsigned int t34;
    unsigned int t35;
    unsigned int t36;
    unsigned int t37;
    unsigned int t38;
    unsigned int t39;
    char *t40;
    char *t41;
    unsigned int t42;
    unsigned int t43;
    unsigned int t44;
    unsigned int t45;
    unsigned int t46;
    unsigned int t47;
    unsigned int t48;
    unsigned int t49;
    int t50;
    int t51;
    unsigned int t52;
    unsigned int t53;
    unsigned int t54;
    unsigned int t55;
    unsigned int t56;
    unsigned int t57;
    char *t58;
    unsigned int t59;
    unsigned int t60;
    unsigned int t61;
    unsigned int t62;
    unsigned int t63;
    char *t64;
    char *t65;

LAB0:    t1 = (t0 + 6024U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(67, ng0);
    t2 = (t0 + 6424);
    *((int *)t2) = 1;
    t3 = (t0 + 6056);
    *((char **)t3) = t2;
    *((char **)t1) = &&LAB4;

LAB1:    return;
LAB4:    xsi_set_current_line(67, ng0);

LAB5:    xsi_set_current_line(68, ng0);
    t4 = (t0 + 3384);
    t5 = (t4 + 56U);
    t6 = *((char **)t5);
    t7 = (t0 + 3544);
    xsi_vlogvar_assign_value(t7, t6, 0, 0, 3);
    xsi_set_current_line(69, ng0);
    t2 = (t0 + 3384);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);

LAB6:    t5 = ((char*)((ng3)));
    t8 = xsi_vlog_unsigned_case_compare(t4, 3, t5, 3);
    if (t8 == 1)
        goto LAB7;

LAB8:    t2 = ((char*)((ng4)));
    t8 = xsi_vlog_unsigned_case_compare(t4, 3, t2, 3);
    if (t8 == 1)
        goto LAB9;

LAB10:    t2 = ((char*)((ng6)));
    t8 = xsi_vlog_unsigned_case_compare(t4, 3, t2, 3);
    if (t8 == 1)
        goto LAB11;

LAB12:    t2 = ((char*)((ng1)));
    t8 = xsi_vlog_unsigned_case_compare(t4, 3, t2, 3);
    if (t8 == 1)
        goto LAB13;

LAB14:    t2 = ((char*)((ng2)));
    t8 = xsi_vlog_unsigned_case_compare(t4, 3, t2, 3);
    if (t8 == 1)
        goto LAB15;

LAB16:    t2 = ((char*)((ng5)));
    t8 = xsi_vlog_unsigned_case_compare(t4, 3, t2, 3);
    if (t8 == 1)
        goto LAB17;

LAB18:
LAB19:    goto LAB2;

LAB7:    xsi_set_current_line(70, ng0);

LAB20:    xsi_set_current_line(71, ng0);
    t6 = (t0 + 2184U);
    t7 = *((char **)t6);
    t6 = (t0 + 2344U);
    t9 = *((char **)t6);
    t6 = ((char*)((ng4)));
    memset(t10, 0, 8);
    t11 = (t9 + 4);
    t12 = (t6 + 4);
    t13 = *((unsigned int *)t9);
    t14 = *((unsigned int *)t6);
    t15 = (t13 ^ t14);
    t16 = *((unsigned int *)t11);
    t17 = *((unsigned int *)t12);
    t18 = (t16 ^ t17);
    t19 = (t15 | t18);
    t20 = *((unsigned int *)t11);
    t21 = *((unsigned int *)t12);
    t22 = (t20 | t21);
    t23 = (~(t22));
    t24 = (t19 & t23);
    if (t24 != 0)
        goto LAB24;

LAB21:    if (t22 != 0)
        goto LAB23;

LAB22:    *((unsigned int *)t10) = 1;

LAB24:    t27 = *((unsigned int *)t7);
    t28 = *((unsigned int *)t10);
    t29 = (t27 & t28);
    *((unsigned int *)t26) = t29;
    t30 = (t7 + 4);
    t31 = (t10 + 4);
    t32 = (t26 + 4);
    t33 = *((unsigned int *)t30);
    t34 = *((unsigned int *)t31);
    t35 = (t33 | t34);
    *((unsigned int *)t32) = t35;
    t36 = *((unsigned int *)t32);
    t37 = (t36 != 0);
    if (t37 == 1)
        goto LAB25;

LAB26:
LAB27:    t58 = (t26 + 4);
    t59 = *((unsigned int *)t58);
    t60 = (~(t59));
    t61 = *((unsigned int *)t26);
    t62 = (t61 & t60);
    t63 = (t62 != 0);
    if (t63 > 0)
        goto LAB28;

LAB29:    xsi_set_current_line(73, ng0);

LAB32:    xsi_set_current_line(74, ng0);
    t2 = ((char*)((ng3)));
    t3 = (t0 + 3544);
    xsi_vlogvar_assign_value(t3, t2, 0, 0, 3);

LAB30:    goto LAB19;

LAB9:    xsi_set_current_line(77, ng0);

LAB33:    xsi_set_current_line(78, ng0);
    t3 = ((char*)((ng6)));
    t5 = (t0 + 3544);
    xsi_vlogvar_assign_value(t5, t3, 0, 0, 3);
    goto LAB19;

LAB11:    xsi_set_current_line(80, ng0);

LAB34:    xsi_set_current_line(81, ng0);
    t3 = (t0 + 2504U);
    t5 = *((char **)t3);
    t3 = ((char*)((ng4)));
    memset(t10, 0, 8);
    t6 = (t5 + 4);
    t7 = (t3 + 4);
    t13 = *((unsigned int *)t5);
    t14 = *((unsigned int *)t3);
    t15 = (t13 ^ t14);
    t16 = *((unsigned int *)t6);
    t17 = *((unsigned int *)t7);
    t18 = (t16 ^ t17);
    t19 = (t15 | t18);
    t20 = *((unsigned int *)t6);
    t21 = *((unsigned int *)t7);
    t22 = (t20 | t21);
    t23 = (~(t22));
    t24 = (t19 & t23);
    if (t24 != 0)
        goto LAB38;

LAB35:    if (t22 != 0)
        goto LAB37;

LAB36:    *((unsigned int *)t10) = 1;

LAB38:    t11 = (t10 + 4);
    t27 = *((unsigned int *)t11);
    t28 = (~(t27));
    t29 = *((unsigned int *)t10);
    t33 = (t29 & t28);
    t34 = (t33 != 0);
    if (t34 > 0)
        goto LAB39;

LAB40:    xsi_set_current_line(83, ng0);

LAB43:    xsi_set_current_line(84, ng0);
    t2 = ((char*)((ng6)));
    t3 = (t0 + 3544);
    xsi_vlogvar_assign_value(t3, t2, 0, 0, 3);

LAB41:    goto LAB19;

LAB13:    xsi_set_current_line(87, ng0);

LAB44:    xsi_set_current_line(88, ng0);
    t3 = (t0 + 2504U);
    t5 = *((char **)t3);
    t3 = ((char*)((ng3)));
    memset(t10, 0, 8);
    t6 = (t5 + 4);
    t7 = (t3 + 4);
    t13 = *((unsigned int *)t5);
    t14 = *((unsigned int *)t3);
    t15 = (t13 ^ t14);
    t16 = *((unsigned int *)t6);
    t17 = *((unsigned int *)t7);
    t18 = (t16 ^ t17);
    t19 = (t15 | t18);
    t20 = *((unsigned int *)t6);
    t21 = *((unsigned int *)t7);
    t22 = (t20 | t21);
    t23 = (~(t22));
    t24 = (t19 & t23);
    if (t24 != 0)
        goto LAB48;

LAB45:    if (t22 != 0)
        goto LAB47;

LAB46:    *((unsigned int *)t10) = 1;

LAB48:    t11 = (t10 + 4);
    t27 = *((unsigned int *)t11);
    t28 = (~(t27));
    t29 = *((unsigned int *)t10);
    t33 = (t29 & t28);
    t34 = (t33 != 0);
    if (t34 > 0)
        goto LAB49;

LAB50:    xsi_set_current_line(90, ng0);

LAB53:    xsi_set_current_line(91, ng0);
    t2 = ((char*)((ng1)));
    t3 = (t0 + 3544);
    xsi_vlogvar_assign_value(t3, t2, 0, 0, 3);

LAB51:    goto LAB19;

LAB15:    xsi_set_current_line(94, ng0);

LAB54:    xsi_set_current_line(95, ng0);
    t3 = (t0 + 3864);
    t5 = (t3 + 56U);
    t6 = *((char **)t5);
    t7 = ((char*)((ng7)));
    memset(t10, 0, 8);
    t9 = (t6 + 4);
    t11 = (t7 + 4);
    t13 = *((unsigned int *)t6);
    t14 = *((unsigned int *)t7);
    t15 = (t13 ^ t14);
    t16 = *((unsigned int *)t9);
    t17 = *((unsigned int *)t11);
    t18 = (t16 ^ t17);
    t19 = (t15 | t18);
    t20 = *((unsigned int *)t9);
    t21 = *((unsigned int *)t11);
    t22 = (t20 | t21);
    t23 = (~(t22));
    t24 = (t19 & t23);
    if (t24 != 0)
        goto LAB58;

LAB55:    if (t22 != 0)
        goto LAB57;

LAB56:    *((unsigned int *)t10) = 1;

LAB58:    t25 = (t10 + 4);
    t27 = *((unsigned int *)t25);
    t28 = (~(t27));
    t29 = *((unsigned int *)t10);
    t33 = (t29 & t28);
    t34 = (t33 != 0);
    if (t34 > 0)
        goto LAB59;

LAB60:    xsi_set_current_line(97, ng0);

LAB63:    xsi_set_current_line(98, ng0);
    t2 = ((char*)((ng2)));
    t3 = (t0 + 3544);
    xsi_vlogvar_assign_value(t3, t2, 0, 0, 3);

LAB61:    goto LAB19;

LAB17:    xsi_set_current_line(101, ng0);

LAB64:    xsi_set_current_line(102, ng0);
    t3 = (t0 + 3704);
    t5 = (t3 + 56U);
    t6 = *((char **)t5);
    t7 = ((char*)((ng7)));
    memset(t10, 0, 8);
    t9 = (t6 + 4);
    t11 = (t7 + 4);
    t13 = *((unsigned int *)t6);
    t14 = *((unsigned int *)t7);
    t15 = (t13 ^ t14);
    t16 = *((unsigned int *)t9);
    t17 = *((unsigned int *)t11);
    t18 = (t16 ^ t17);
    t19 = (t15 | t18);
    t20 = *((unsigned int *)t9);
    t21 = *((unsigned int *)t11);
    t22 = (t20 | t21);
    t23 = (~(t22));
    t24 = (t19 & t23);
    if (t24 != 0)
        goto LAB68;

LAB65:    if (t22 != 0)
        goto LAB67;

LAB66:    *((unsigned int *)t10) = 1;

LAB68:    t25 = (t10 + 4);
    t27 = *((unsigned int *)t25);
    t28 = (~(t27));
    t29 = *((unsigned int *)t10);
    t33 = (t29 & t28);
    t34 = (t33 != 0);
    if (t34 > 0)
        goto LAB69;

LAB70:    xsi_set_current_line(104, ng0);

LAB73:    xsi_set_current_line(105, ng0);
    t2 = ((char*)((ng5)));
    t3 = (t0 + 3544);
    xsi_vlogvar_assign_value(t3, t2, 0, 0, 3);

LAB71:    goto LAB19;

LAB23:    t25 = (t10 + 4);
    *((unsigned int *)t10) = 1;
    *((unsigned int *)t25) = 1;
    goto LAB24;

LAB25:    t38 = *((unsigned int *)t26);
    t39 = *((unsigned int *)t32);
    *((unsigned int *)t26) = (t38 | t39);
    t40 = (t7 + 4);
    t41 = (t10 + 4);
    t42 = *((unsigned int *)t7);
    t43 = (~(t42));
    t44 = *((unsigned int *)t40);
    t45 = (~(t44));
    t46 = *((unsigned int *)t10);
    t47 = (~(t46));
    t48 = *((unsigned int *)t41);
    t49 = (~(t48));
    t50 = (t43 & t45);
    t51 = (t47 & t49);
    t52 = (~(t50));
    t53 = (~(t51));
    t54 = *((unsigned int *)t32);
    *((unsigned int *)t32) = (t54 & t52);
    t55 = *((unsigned int *)t32);
    *((unsigned int *)t32) = (t55 & t53);
    t56 = *((unsigned int *)t26);
    *((unsigned int *)t26) = (t56 & t52);
    t57 = *((unsigned int *)t26);
    *((unsigned int *)t26) = (t57 & t53);
    goto LAB27;

LAB28:    xsi_set_current_line(71, ng0);

LAB31:    xsi_set_current_line(72, ng0);
    t64 = ((char*)((ng4)));
    t65 = (t0 + 3544);
    xsi_vlogvar_assign_value(t65, t64, 0, 0, 3);
    goto LAB30;

LAB37:    t9 = (t10 + 4);
    *((unsigned int *)t10) = 1;
    *((unsigned int *)t9) = 1;
    goto LAB38;

LAB39:    xsi_set_current_line(81, ng0);

LAB42:    xsi_set_current_line(82, ng0);
    t12 = ((char*)((ng1)));
    t25 = (t0 + 3544);
    xsi_vlogvar_assign_value(t25, t12, 0, 0, 3);
    goto LAB41;

LAB47:    t9 = (t10 + 4);
    *((unsigned int *)t10) = 1;
    *((unsigned int *)t9) = 1;
    goto LAB48;

LAB49:    xsi_set_current_line(88, ng0);

LAB52:    xsi_set_current_line(89, ng0);
    t12 = ((char*)((ng2)));
    t25 = (t0 + 3544);
    xsi_vlogvar_assign_value(t25, t12, 0, 0, 3);
    goto LAB51;

LAB57:    t12 = (t10 + 4);
    *((unsigned int *)t10) = 1;
    *((unsigned int *)t12) = 1;
    goto LAB58;

LAB59:    xsi_set_current_line(95, ng0);

LAB62:    xsi_set_current_line(96, ng0);
    t30 = ((char*)((ng5)));
    t31 = (t0 + 3544);
    xsi_vlogvar_assign_value(t31, t30, 0, 0, 3);
    goto LAB61;

LAB67:    t12 = (t10 + 4);
    *((unsigned int *)t10) = 1;
    *((unsigned int *)t12) = 1;
    goto LAB68;

LAB69:    xsi_set_current_line(102, ng0);

LAB72:    xsi_set_current_line(103, ng0);
    t30 = ((char*)((ng3)));
    t31 = (t0 + 3544);
    xsi_vlogvar_assign_value(t31, t30, 0, 0, 3);
    goto LAB71;

}


extern void work_m_00000000003413782571_2963980531_init()
{
	static char *pe[] = {(void *)Cont_28_0,(void *)Cont_29_1,(void *)Always_32_2,(void *)Always_45_3,(void *)Always_58_4,(void *)Always_67_5};
	xsi_register_didat("work_m_00000000003413782571_2963980531", "isim/testbench_lb_isim_beh.exe.sim/work/m_00000000003413782571_2963980531.didat");
	xsi_register_executes(pe);
}
