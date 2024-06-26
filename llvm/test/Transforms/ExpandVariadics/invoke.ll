; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -mtriple=wasm32-unknown-unknown -S --passes=expand-variadics --expand-variadics-override=optimize < %s | FileCheck %s -check-prefixes=CHECK
; RUN: not --crash opt -mtriple=wasm32-unknown-unknown -S --passes=expand-variadics --expand-variadics-override=lowering < %s 2>&1 | FileCheck %s -check-prefixes=ERROR
; REQUIRES: webassembly-registered-target
target datalayout = "e-m:e-p:32:32-p10:8:8-p20:8:8-i64:64-n32:64-S128-ni:1:10:20"

; ERROR: LLVM ERROR: Cannot lower callbase instruction

@_ZTIi = external constant ptr

; Function Attrs: mustprogress
define hidden void @test0(i32 noundef %x) #0 personality ptr @__gxx_wasm_personality_v0 {
; CHECK-LABEL: @test0(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    invoke void (...) @may_throw(i32 noundef [[X:%.*]])
; CHECK-NEXT:            to label [[TRY_CONT:%.*]] unwind label [[CATCH_DISPATCH:%.*]]
; CHECK:       catch.dispatch:
; CHECK-NEXT:    [[TMP0:%.*]] = catchswitch within none [label %catch.start] unwind to caller
; CHECK:       catch.start:
; CHECK-NEXT:    [[TMP1:%.*]] = catchpad within [[TMP0]] [ptr @_ZTIi]
; CHECK-NEXT:    [[TMP2:%.*]] = tail call ptr @llvm.wasm.get.exception(token [[TMP1]])
; CHECK-NEXT:    [[TMP3:%.*]] = tail call i32 @llvm.wasm.get.ehselector(token [[TMP1]])
; CHECK-NEXT:    [[TMP4:%.*]] = tail call i32 @llvm.eh.typeid.for.p0(ptr nonnull @_ZTIi)
; CHECK-NEXT:    [[MATCHES:%.*]] = icmp eq i32 [[TMP3]], [[TMP4]]
; CHECK-NEXT:    br i1 [[MATCHES]], label [[CATCH:%.*]], label [[RETHROW:%.*]]
; CHECK:       catch:
; CHECK-NEXT:    [[TMP5:%.*]] = call ptr @__cxa_begin_catch(ptr [[TMP2]]) [ "funclet"(token [[TMP1]]) ]
; CHECK-NEXT:    call void (...) @dont_throw(i32 noundef [[X]]) [ "funclet"(token [[TMP1]]) ]
; CHECK-NEXT:    call void @__cxa_end_catch() [ "funclet"(token [[TMP1]]) ]
; CHECK-NEXT:    catchret from [[TMP1]] to label [[TRY_CONT]]
; CHECK:       rethrow:
; CHECK-NEXT:    call void @llvm.wasm.rethrow() [ "funclet"(token [[TMP1]]) ]
; CHECK-NEXT:    unreachable
; CHECK:       try.cont:
; CHECK-NEXT:    ret void
;
entry:
  invoke void (...) @may_throw(i32 noundef %x)
  to label %try.cont unwind label %catch.dispatch

catch.dispatch:                                   ; preds = %entry
  %0 = catchswitch within none [label %catch.start] unwind to caller

catch.start:                                      ; preds = %catch.dispatch
  %1 = catchpad within %0 [ptr @_ZTIi]
  %2 = tail call ptr @llvm.wasm.get.exception(token %1)
  %3 = tail call i32 @llvm.wasm.get.ehselector(token %1)
  %4 = tail call i32 @llvm.eh.typeid.for.p0(ptr nonnull @_ZTIi)
  %matches = icmp eq i32 %3, %4
  br i1 %matches, label %catch, label %rethrow

catch:                                            ; preds = %catch.start
  %5 = call ptr @__cxa_begin_catch(ptr %2) #6 [ "funclet"(token %1) ]
  call void (...) @dont_throw(i32 noundef %x) #6 [ "funclet"(token %1) ]
  call void @__cxa_end_catch() #6 [ "funclet"(token %1) ]
  catchret from %1 to label %try.cont

rethrow:                                          ; preds = %catch.start
  call void @llvm.wasm.rethrow() #5 [ "funclet"(token %1) ]
  unreachable

try.cont:                                         ; preds = %entry, %catch
  ret void
}

declare void @may_throw(...)

declare i32 @__gxx_wasm_personality_v0(...)

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn
declare ptr @llvm.wasm.get.exception(token)

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn
declare i32 @llvm.wasm.get.ehselector(token)

; Function Attrs: nofree nosync nounwind memory(none)
declare i32 @llvm.eh.typeid.for.p0(ptr)

declare ptr @__cxa_begin_catch(ptr)

; Function Attrs: nounwind
declare void @dont_throw(...)

declare void @__cxa_end_catch()

; Function Attrs: noreturn
declare void @llvm.wasm.rethrow()


