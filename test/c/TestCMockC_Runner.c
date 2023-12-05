/* ==========================================
    CMock Project - Automatic Mock Generation for C
    Copyright (c) 2007 Mike Karlesky, Mark VanderVoord, Greg Williams
    [Released under MIT License. Please refer to license.txt for details]
========================================== */

#include "unity.h"
#include <setjmp.h>
#include <stdio.h>

extern void setUp(void);
extern void tearDown(void);

extern void test_MemNewWillReturnNullIfGivenIllegalSizes(void);
extern void test_MemShouldProtectAgainstMemoryOverflow(void);
extern void test_MemChainWillReturnNullAndDoNothingIfGivenIllegalInformation(void);
extern void test_MemNextWillReturnNullIfGivenABadRoot(void);
extern void test_ThatWeCanClaimAndChainAFewElementsTogether(void);
extern void test_MemEndOfChain(void);
extern void test_ThatCMockStopsReturningMoreDataWhenItRunsOutOfMemory(void);
extern void test_ThatCMockStopsReturningMoreDataWhenAskForMoreThanItHasLeftEvenIfNotAtExactEnd(void);
extern void test_ThatWeCanAskForAllSortsOfSizes(void);

int main(void)
{
  Unity.TestFile = "TestCMock.c";
  UnityBegin(Unity.TestFile);

  RUN_TEST(test_MemNewWillReturnNullIfGivenIllegalSizes, Unity.TestFile, 21);
  RUN_TEST(test_MemShouldProtectAgainstMemoryOverflow, Unity.TestFile, 33);
  RUN_TEST(test_MemChainWillReturnNullAndDoNothingIfGivenIllegalInformation, Unity.TestFile, 42);
  RUN_TEST(test_MemNextWillReturnNullIfGivenABadRoot, Unity.TestFile, 56);
  RUN_TEST(test_ThatWeCanClaimAndChainAFewElementsTogether, Unity.TestFile, 67);
  RUN_TEST(test_MemEndOfChain, Unity.TestFile, 149);
  RUN_TEST(test_ThatCMockStopsReturningMoreDataWhenItRunsOutOfMemory, Unity.TestFile, 195);
  RUN_TEST(test_ThatCMockStopsReturningMoreDataWhenAskForMoreThanItHasLeftEvenIfNotAtExactEnd, Unity.TestFile, 244);
  RUN_TEST(test_ThatWeCanAskForAllSortsOfSizes, Unity.TestFile, 298);

  UnityEnd();
  return 0;
}
