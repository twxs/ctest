#include <gtest/gtest.h>


TEST(Foo, ShouldWork) {
    ASSERT_TRUE(true);
}
TEST(Foo, ShouldFailed) {
    ASSERT_TRUE(false);
}
int main(int argc, char ** argv){
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}