@import <AppKit/CGAffineTransform.j>

@implementation CGAffineTransformTest : OJTestCase

- (void)testAffineTransformMake
{
    [self compareTransform:CGAffineTransformMake(1, 2, 3, 4, 3.2, 5.4)
                      with:{ a: 1, b: 2, c:3, d:4, tx:3.2, ty:5.4 }
                   message:"transform make"];
}

- (void)testCGAffineTransformMakeIdentity
{
    [self compareTransform:CGAffineTransformMakeIdentity()
                      with:{ a: 1, b: 0, c:0, d:1, tx:0, ty:0 }
                   message:"transform make identity"];
}

- (void)testAffineTransformMakeCopy
{
    var transform = CGAffineTransformMake(1, 2, 3, 4, 3.2, 5.4),
        t2 = CGAffineTransformMakeCopy(transform);

    transform.a = transform.b = transform.c = transform.d =
        transform.tx = transform.ty = 0;

    [self compareTransform:t2
                      with:CGAffineTransformMake( 1,2,3,4,3.2,5.4 )
                   message:"copy correctly made"];

    [self compareTransform:transform
                      with:CGAffineTransformMake( 0, 0, 0, 0, 0, 0 )
                   message:"original transform was changed"] ;
}

- (void)testAffineTransformMakeScale
{
    [self compareTransform:CGAffineTransformMakeScale(3,4)
                      with:CGAffineTransformMake(3, 0, 0, 4, 0, 0)
                   message:"make scale"];
}

- (void)testAffineTransformMakeTranslation
{
    [self compareTransform:CGAffineTransformMakeTranslation(3,4)
                      with:CGAffineTransformMake(1,0,0,1,3,4)
                   message:"make translation"];
}

- (void)testAffineTransformTranslate
{
    var transform = CGAffineTransformMakeTranslation(3,4);

    [self compareTransform:CGAffineTransformTranslate(transform,-3,-4)
                      with:CGAffineTransformMakeIdentity()
                   message:"translate to identity"];

    [self compareTransform:CGAffineTransformTranslate(transform,0,0)
                      with:transform
                   message:"zero translate"];
}

- (void)testAffineTransformScale
{
    var transform = CGAffineTransformMakeScale(3,4);

    [self compareTransform:CGAffineTransformScale( transform, 1/3, 1/4)
                      with:CGAffineTransformMakeIdentity()
                   message:"scale to identity"];

    transform = CGAffineTransformMake(2, -2, -3, 3, 3.2, 5.4);
    [self compareTransform:CGAffineTransformScale(transform, 1, 1)
                      with:transform
                   message:"scale by 1"];

    [self compareTransform:CGAffineTransformScale(transform, 2, 5)
                      with:CGAffineTransformMake(4,-4,-15,15, 3.2,5.4)
                   message:"random scale to somewhere"];
}

- (void)testAffineTransformConcat
{
    var testcases = {
      "identity concat" : {
        testdata: CGAffineTransformConcat( CGAffineTransformMakeIdentity(),
                                           CGAffineTransformMakeIdentity() ),
        expdata: CGAffineTransformMakeIdentity()
      },

      "translation" : {
        testdata: CGAffineTransformConcat( CGAffineTransformMakeTranslation(3,4),
                                           CGAffineTransformMakeTranslation(-3,-4) ),
        expdata: CGAffineTransformMakeIdentity()
      },

      "translation (reversed)" : {
        testdata: CGAffineTransformConcat( CGAffineTransformMakeTranslation(-3,-4),
                                            CGAffineTransformMakeTranslation(3,4) ),
        expdata: CGAffineTransformMakeIdentity()
      },

      "scale" : {
        testdata: CGAffineTransformConcat(CGAffineTransformMakeScale(3,4),
                                          CGAffineTransformMakeScale(1/3,1/4)),
        expdata: CGAffineTransformMakeIdentity()
      },

      "scale (reversed)" : {
        testdata: CGAffineTransformConcat(CGAffineTransformMakeScale(1/3,1/4),
                                          CGAffineTransformMakeScale(3,4)),
        expdata: CGAffineTransformMakeIdentity()
      },
    };

    for ( var key in testcases )
    {
        var testcase = testcases[key];
        [self compareTransform:testcase.testdata with:testcase.expdata message:key];
    }
}

- (void)testPointApplyAffineTransform
{
    var testcases = {
      "translate to zero" : {
        testdata: CGPointApplyAffineTransform( CGPointMake( 3, 4 ),
                                               CGAffineTransformMakeTranslation(-3,-4)),
        expdata: CGPointMakeZero()
      },

      "scale to 1,1" : {
        testdata: CGPointApplyAffineTransform( CGPointMake( 3, 4 ),
                                               CGAffineTransformMakeScale(1/3,1/4) ),
        expdata: CGPointMake(1,1)
      },

      "scale and translate to zero" : {
        testdata: CGPointApplyAffineTransform( CGPointMake( 3, 4 ),
                                               CGAffineTransformConcat(
                                                     CGAffineTransformMakeScale(1/3,1/4),
                                                     CGAffineTransformMakeTranslation(-1,-1))),
        expdata: CGPointMakeZero()

      },
    };

    for ( var key in testcases )
    {
        var testcase = testcases[key];
        [self comparePoint:testcase.testdata with:testcase.expdata message:key];
    }
}

- (void)testSizeApplyAffineTransform
{
    var testcases = {
      "translation on size should do nothing" : {
        testdata: CGSizeApplyAffineTransform( CGSizeMake(3, 12),
                                               CGAffineTransformMakeTranslation(-3,-4)),
        expdata: CGSizeMake(3, 12)
      },

      "scale to 1,1" : {
        testdata: CGSizeApplyAffineTransform( CGSizeMake( 3, 4 ),
                                               CGAffineTransformMakeScale(1/3,1/4) ),
        expdata: CGSizeMake(1, 1)
      },

      "scale and translate combined" : {
        testdata: CGSizeApplyAffineTransform( CGSizeMake( 3, 4 ),
                                               CGAffineTransformConcat(
                                                     CGAffineTransformMakeScale(1/3,1/4),
                                                     CGAffineTransformMakeTranslation(-1,-1))),
        expdata: CGSizeMake(1, 1)

      },
    };

    for ( var key in testcases )
    {
        var testcase = testcases[key];
        [self compareSize:testcase.testdata with:testcase.expdata message:key];
    }
}

- (void)testAffineTransformIsIdentityPositive
{
    var testcases = {
      "identity is identity" : {
        testdata: CGAffineTransformMakeIdentity()
      },

      "zero rotation is identity" : {
        testdata: CGAffineTransformMakeRotation(0),
      },

      "zero translation is identity" : {
        testdata: CGAffineTransformMakeTranslation(0,0)
      },

      "one scale is identity" : {
        testdata: CGAffineTransformMakeScale(1,1)
      },

      "identity concat'ed" : {
        testdata: CGAffineTransformConcat( CGAffineTransformMakeIdentity(),
                                           CGAffineTransformMakeIdentity() ),
      },

      "translation" : {
        testdata: CGAffineTransformConcat( CGAffineTransformMakeTranslation(3,4),
                                           CGAffineTransformMakeTranslation(-3,-4) ),
      },

      "translation (reversed)" : {
        testdata: CGAffineTransformConcat( CGAffineTransformMakeTranslation(-3,-4),
                                            CGAffineTransformMakeTranslation(3,4) ),
      },

      "scale" : {
        testdata: CGAffineTransformConcat(CGAffineTransformMakeScale(3,4),
                                          CGAffineTransformMakeScale(1/3,1/4)),
      },

      "scale (reversed)" : {
        testdata: CGAffineTransformConcat(CGAffineTransformMakeScale(1/3,1/4),
                                          CGAffineTransformMakeScale(3,4)),
      },

    };

    for ( var key in testcases )
        [self assert:YES
              equals:CGAffineTransformIsIdentity(testcases[key].testdata)
             message:key];
}

- (void)testAffineTransformIsIdentityNegative
{
    var testcases = {
      "some random transform" : {
        testdata: CGAffineTransformMake(1,1,1,1,1,1)
      },

      "non-zero translation is not identity" : {
        testdata: CGAffineTransformMakeTranslation(1,1)
      },

      "non-one scale is not identity" : {
        testdata: CGAffineTransformMakeScale(2,2)
      },

      "rotation" : {
        testdata: CGAffineTransformMakeRotation(Math.PI),
      },

      // TODO a two-pi rotation is actually identity
      "2PI rotation is NOT identity?" : {
        testdata: CGAffineTransformMakeRotation(Math.PI * 2),
      },

    };

    for ( var key in testcases )
        [self assert:NO
              equals:CGAffineTransformIsIdentity(testcases[key].testdata)
             message:key];
}

- (void)testAffineTransformEqualToTransform
{
    var testcases = {
      "identity" : {
        lhs: CGAffineTransformMakeIdentity(),
        rhs: CGAffineTransformMakeIdentity(),
        expdata: YES
      },

      "translate" : {
        lhs: CGAffineTransformMakeTranslation(1,1),
        rhs: CGAffineTransformMakeTranslation(1,1),
        expdata: YES
      },

      "scale" : {
        lhs: CGAffineTransformMakeScale(1,1),
        rhs: CGAffineTransformMakeScale(1,1),
        expdata: YES
      },

      "rotation" : {
        lhs: CGAffineTransformMakeRotation(Math.PI),
        rhs: CGAffineTransformMakeRotation(Math.PI),
        expdata: YES
      },

      "translate and scale" : {
        lhs: CGAffineTransformMakeScale(1,1),
        rhs: CGAffineTransformMakeTranslation(1,1),
        expdata: NO
      },
    };

    for ( var key in testcases ) {
        var testcase = testcases[key];
        [self assert:testcase.expdata
              equals:CGAffineTransformEqualToTransform(testcase.lhs, testcase.rhs)
             message:key];
    }
}

- (void)testStringCreateWithCGAffineTransform
{
    var testcases = {
      "identity" : {
        testdata: CGAffineTransformMakeIdentity(),
        expdata: " [[ 1, 0, 0 ], [ 0, 1, 0 ], [ 0, 0, 1]]"
      },

      "scale" : {
        testdata: CGAffineTransformMakeScale(3,4),
        expdata: " [[ 3, 0, 0 ], [ 0, 4, 0 ], [ 0, 0, 1]]"
      },

      "translation" : {
        testdata: CGAffineTransformMakeTranslation(3,4),
        expdata: " [[ 1, 0, 0 ], [ 0, 1, 0 ], [ 3, 4, 1]]"
      },

      "scale and translation" : {
        testdata: CGAffineTransformTranslate(CGAffineTransformMakeScale(3,4),5,6),
        expdata: " [[ 3, 0, 0 ], [ 0, 4, 0 ], [ 15, 24, 1]]"
      },
    };

    for ( var key in testcases ) {
        var testcase = testcases[key];
        [self assert:testcase.expdata
              equals:CGStringCreateWithCGAffineTransform(testcase.testdata)
             message:key];
    }
}

- (void)testStringFromCGAffineTransform
{
    var testcases = {
      "identity" : {
        testdata: CGAffineTransformMakeIdentity(),
        expdata: "{1, 0, 0, 1, 0, 0}"
      },

      "scale" : {
        testdata: CGAffineTransformMakeScale(3,4),
        expdata: "{3, 0, 0, 4, 0, 0}"
      },

      "translation" : {
        testdata: CGAffineTransformMakeTranslation(3,4),
        expdata: "{1, 0, 0, 1, 3, 4}"
      },

      "rotation - zero" : {
        testdata: CGAffineTransformMakeRotation(0),
        expdata: "{1, 0, 0, 1, 0, 0}"
      },

      "rotation - pi" : {
        testdata: CGAffineTransformMakeRotation(Math.PI),
        expdata: "{-1, 1.2246467991473532e-16, -1.2246467991473532e-16, -1, 0, 0}"
      },

      "rotation - 2pi" : {
        testdata: CGAffineTransformMakeRotation(2 * Math.PI),
        expdata: "{1, -2.4492935982947064e-16, 2.4492935982947064e-16, 1, 0, 0}"
      },

      "rotation - 3pi" : {
        testdata: CGAffineTransformMakeRotation(3 * Math.PI),
        expdata: "{-1, 3.6739403974420594e-16, -3.6739403974420594e-16, -1, 0, 0}"
      },

      "scale and translation and rotate" : {
        testdata: CGAffineTransformRotate(CGAffineTransformTranslate(CGAffineTransformMakeScale(3,4),5,6),Math.PI),
        expdata: "{-3, 4.898587196589413e-16, -3.6739403974420594e-16, -4, 15, 24}"
      },
    };

    for ( var key in testcases ) {
        var testcase = testcases[key];
        [self assert:testcase.expdata
              equals:CPStringFromCGAffineTransform(testcase.testdata)
             message:key];
    }
}

@end

//
// Test Helpers
//
@implementation CGAffineTransformTest (Helpers)

- (void)compareSize:(CGSize)aSize
                with:(id)anotherSize
             message:(CPString)aMsg
{
    [self assert:anotherSize.width  equals:aSize.width  message:aMsg + ": Failed for width"];
    [self assert:anotherSize.height equals:aSize.height message:aMsg + ": Failed for height"];
}

- (void)comparePoint:(CGPoint)aPoint
                with:(id)anotherPoint
             message:(CPString)aMsg
{
    [self assert:anotherPoint.x equals:aPoint.x message:aMsg + ": Failed for x"];
    [self assert:anotherPoint.y equals:aPoint.y message:aMsg + ": Failed for y"];
}

- (void)compareTransform:(CGAffineTransform)aTransform
                    with:(id)aDataSet
                 message:(CPString)aMsg
{
    [self assert:aDataSet.a  equals:aTransform.a  message:aMsg + ": Failed for a"];
    [self assert:aDataSet.b  equals:aTransform.b  message:aMsg + ": Failed for b"];
    [self assert:aDataSet.c  equals:aTransform.c  message:aMsg + ": Failed for c"];
    [self assert:aDataSet.d  equals:aTransform.d  message:aMsg + ": Failed for d"];
    [self assert:aDataSet.tx equals:aTransform.tx message:aMsg + ": Failed for tx"];
    [self assert:aDataSet.ty equals:aTransform.ty message:aMsg + ": Failed for ty"];
}

@end
