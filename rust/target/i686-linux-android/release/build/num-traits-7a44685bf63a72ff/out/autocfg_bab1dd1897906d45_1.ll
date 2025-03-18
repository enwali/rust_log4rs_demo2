; ModuleID = 'autocfg_bab1dd1897906d45_1.ab22823873172a4-cgu.0'
source_filename = "autocfg_bab1dd1897906d45_1.ab22823873172a4-cgu.0"
target datalayout = "e-m:e-p:32:32-p270:32:32-p271:32:32-p272:64:64-i128:128-f64:32:64-f80:32-n8:16:32-S128"
target triple = "i686-unknown-linux-android"

@alloc_d4a7707f05e5d7266a36152d39817482 = private unnamed_addr constant <{ [8 x i8] }> <{ [8 x i8] c"\00\00\00\00\00\00\F0?" }>, align 4
@alloc_6548de77921b239bafa46fd51b17f832 = private unnamed_addr constant <{ [8 x i8] }> <{ [8 x i8] c"\00\00\00\00\00\00\00@" }>, align 4

; core::f64::<impl f64>::total_cmp
; Function Attrs: inlinehint uwtable
define internal i8 @"_ZN4core3f6421_$LT$impl$u20$f64$GT$9total_cmp17h86cf280b3010f249E"(ptr align 4 %self, ptr align 4 %other) unnamed_addr #0 {
start:
  %right = alloca [8 x i8], align 4
  %left = alloca [8 x i8], align 4
  %self1 = load double, ptr %self, align 4
  %_4 = bitcast double %self1 to i64
  store i64 %_4, ptr %left, align 4
  %self2 = load double, ptr %other, align 4
  %_7 = bitcast double %self2 to i64
  store i64 %_7, ptr %right, align 4
  %_13 = load i64, ptr %left, align 4
  %_12 = ashr i64 %_13, 63
  %_10 = lshr i64 %_12, 1
  %0 = load i64, ptr %left, align 4
  %1 = xor i64 %0, %_10
  store i64 %1, ptr %left, align 4
  %_18 = load i64, ptr %right, align 4
  %_17 = ashr i64 %_18, 63
  %_15 = lshr i64 %_17, 1
  %2 = load i64, ptr %right, align 4
  %3 = xor i64 %2, %_15
  store i64 %3, ptr %right, align 4
  %_21 = load i64, ptr %left, align 4
  %_22 = load i64, ptr %right, align 4
  %4 = icmp sgt i64 %_21, %_22
  %5 = zext i1 %4 to i8
  %6 = icmp slt i64 %_21, %_22
  %7 = zext i1 %6 to i8
  %_0 = sub nsw i8 %5, %7
  ret i8 %_0
}

; autocfg_bab1dd1897906d45_1::probe
; Function Attrs: uwtable
define void @_ZN26autocfg_bab1dd1897906d45_15probe17h8e7223b7cfd0f004E() unnamed_addr #1 {
start:
; call core::f64::<impl f64>::total_cmp
  %_1 = call i8 @"_ZN4core3f6421_$LT$impl$u20$f64$GT$9total_cmp17h86cf280b3010f249E"(ptr align 4 @alloc_d4a7707f05e5d7266a36152d39817482, ptr align 4 @alloc_6548de77921b239bafa46fd51b17f832)
  ret void
}

attributes #0 = { inlinehint uwtable "probe-stack"="inline-asm" "target-cpu"="pentiumpro" "target-features"="+mmx,+sse,+sse2,+sse3,+ssse3" }
attributes #1 = { uwtable "probe-stack"="inline-asm" "target-cpu"="pentiumpro" "target-features"="+mmx,+sse,+sse2,+sse3,+ssse3" }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 8, !"PIC Level", i32 2}
!1 = !{!"rustc version 1.80.0 (051478957 2024-07-21)"}
