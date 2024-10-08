; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 2
; RUN: opt < %s -passes=loop-versioning -S -o - | FileCheck %s

; This test case used to end like this:
;
;    Instruction does not dominate all uses!
;      %t2 = load i16, i16* @b, align 1, !tbaa !2, !alias.scope !6
;      %tobool = icmp eq i16 %t2, 0
;    LLVM ERROR: Broken function found, compilation aborted!
;
; due to a fault where we did not replace the use of %t2 in the icmp in
; for.end, when adding a new PHI node for the versioned loops based on the
; loop-defined values used outside of the loop.
;
; Verify that the code compiles, that we get a versioned loop, and that the
; uses of %t2 in for.end and if.then are updated to use the value from the
; added phi node.

@a = dso_local global i16 0, align 1
@b = dso_local global i16 0, align 1
@c = dso_local global ptr null, align 1

define void @f1() {
; CHECK-LABEL: define void @f1() {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[T0:%.*]] = load ptr, ptr @c, align 1
; CHECK-NEXT:    [[SCEVGEP:%.*]] = getelementptr i8, ptr [[T0]], i64 2
; CHECK-NEXT:    br label [[FOR_BODY_LVER_CHECK:%.*]]
; CHECK:       for.body.lver.check:
; CHECK-NEXT:    [[BOUND0:%.*]] = icmp ult ptr [[T0]], getelementptr inbounds nuw (i8, ptr @b, i64 2)
; CHECK-NEXT:    [[BOUND1:%.*]] = icmp ult ptr @b, [[SCEVGEP]]
; CHECK-NEXT:    [[FOUND_CONFLICT:%.*]] = and i1 [[BOUND0]], [[BOUND1]]
; CHECK-NEXT:    br i1 [[FOUND_CONFLICT]], label [[FOR_BODY_PH_LVER_ORIG:%.*]], label [[FOR_BODY_PH:%.*]]
; CHECK:       for.body.ph.lver.orig:
; CHECK-NEXT:    br label [[FOR_BODY_LVER_ORIG:%.*]]
; CHECK:       for.body.lver.orig:
; CHECK-NEXT:    [[T1_LVER_ORIG:%.*]] = phi i64 [ 0, [[FOR_BODY_PH_LVER_ORIG]] ], [ [[INC_LVER_ORIG:%.*]], [[FOR_BODY_LVER_ORIG]] ]
; CHECK-NEXT:    [[T2_LVER_ORIG:%.*]] = load i16, ptr @b, align 1, !tbaa [[TBAA2:![0-9]+]]
; CHECK-NEXT:    store i16 [[T2_LVER_ORIG]], ptr [[T0]], align 1, !tbaa [[TBAA2]]
; CHECK-NEXT:    [[INC_LVER_ORIG]] = add nuw nsw i64 [[T1_LVER_ORIG]], 1
; CHECK-NEXT:    [[CMP_LVER_ORIG:%.*]] = icmp ult i64 [[INC_LVER_ORIG]], 3
; CHECK-NEXT:    br i1 [[CMP_LVER_ORIG]], label [[FOR_BODY_LVER_ORIG]], label [[FOR_END_LOOPEXIT:%.*]]
; CHECK:       for.body.ph:
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[T1:%.*]] = phi i64 [ 0, [[FOR_BODY_PH]] ], [ [[INC:%.*]], [[FOR_BODY]] ]
; CHECK-NEXT:    [[T2:%.*]] = load i16, ptr @b, align 1, !tbaa [[TBAA2]], !alias.scope [[META6:![0-9]+]]
; CHECK-NEXT:    store i16 [[T2]], ptr [[T0]], align 1, !tbaa [[TBAA2]], !alias.scope [[META9:![0-9]+]], !noalias [[META6]]
; CHECK-NEXT:    [[INC]] = add nuw nsw i64 [[T1]], 1
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult i64 [[INC]], 3
; CHECK-NEXT:    br i1 [[CMP]], label [[FOR_BODY]], label [[FOR_END_LOOPEXIT1:%.*]]
; CHECK:       for.end.loopexit:
; CHECK-NEXT:    [[T2_LVER_PH:%.*]] = phi i16 [ [[T2_LVER_ORIG]], [[FOR_BODY_LVER_ORIG]] ]
; CHECK-NEXT:    br label [[FOR_END:%.*]]
; CHECK:       for.end.loopexit1:
; CHECK-NEXT:    [[T2_LVER_PH2:%.*]] = phi i16 [ [[T2]], [[FOR_BODY]] ]
; CHECK-NEXT:    br label [[FOR_END]]
; CHECK:       for.end:
; CHECK-NEXT:    [[T2_LVER:%.*]] = phi i16 [ [[T2_LVER_PH]], [[FOR_END_LOOPEXIT]] ], [ [[T2_LVER_PH2]], [[FOR_END_LOOPEXIT1]] ]
; CHECK-NEXT:    [[TOBOOL:%.*]] = icmp eq i16 [[T2_LVER]], 0
; CHECK-NEXT:    br i1 [[TOBOOL]], label [[FOR_COND_BACKEDGE:%.*]], label [[IF_THEN:%.*]]
; CHECK:       for.cond.backedge:
; CHECK-NEXT:    br label [[FOR_BODY_LVER_CHECK]]
; CHECK:       if.then:
; CHECK-NEXT:    store i16 [[T2_LVER]], ptr @a, align 1, !tbaa [[TBAA2]]
; CHECK-NEXT:    br label [[FOR_COND_BACKEDGE]]
;
entry:
  %t0 = load ptr, ptr @c, align 1
  br label %for.cond

for.cond:                                         ; preds = %for.cond.backedge, %entry
  br label %for.body

for.body:                                         ; preds = %for.cond, %for.body
  %t1 = phi i64 [ 0, %for.cond ], [ %inc, %for.body ]
  %t2 = load i16, ptr @b, align 1, !tbaa !2
  store i16 %t2, ptr %t0, align 1, !tbaa !2
  %inc = add nuw nsw i64 %t1, 1
  %cmp = icmp ult i64 %inc, 3
  br i1 %cmp, label %for.body, label %for.end

for.end:                                          ; preds = %for.body
  %tobool = icmp eq i16 %t2, 0
  br i1 %tobool, label %for.cond.backedge, label %if.then

for.cond.backedge:                                ; preds = %for.end, %if.then
  br label %for.cond

if.then:                                          ; preds = %for.end
  store i16 %t2, ptr @a, align 1, !tbaa !2
  br label %for.cond.backedge
}

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 1}
!1 = !{!"clang version 7.0.0"}
!2 = !{!3, !3, i64 0}
!3 = !{!"long long", !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C/C++ TBAA"}
