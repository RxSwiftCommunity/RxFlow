//
//  StepperTests.swift
//  RxFlowTests
//
//  Created by Thibault Wittemberg on 2018-10-15.
//  Copyright © 2018 RxSwiftCommunity. All rights reserved.
//

import XCTest
@testable import RxFlow
import RxBlocking
import RxSwift
import RxCocoa

enum StepperTestsStep: Step {
    case stepOne
    case stepTwo
    case stepThree
}

final class StepperClass: Stepper {

    let steps = PublishRelay<Step>()

    func emitStepOne () {
        self.steps.accept(StepperTestsStep.stepOne)
    }
}

final class StepperTests: XCTestCase {

    func testStepperEmitStep() throws {
        let exp = expectation(description: "exp")

        // Given: a stepper
        let stepperClass = StepperClass()

        _ = stepperClass
            .steps
            .takeUntil(self.rx.deallocating)
            .filter { !($0 is NoneStep) }
            .subscribe(onNext: { step in
                XCTAssertEqual(step as! StepperTestsStep, StepperTestsStep.stepOne)
                exp.fulfill()
            })

        // When: emitting a new step
        stepperClass.emitStepOne()

        // Then: the right step is emitted
        waitForExpectations(timeout: 10)
    }

    func testOneStepper() throws {
        // Given: a OneStepper
        let stepperClass = OneStepper(withSingleStep: StepperTestsStep.stepOne)

        // When: listening to the emitted step
        // Then: the right step is emitted
        let step = try stepperClass.steps
            .startWith(elements: stepperClass.initialSteps)
            .filter { !($0 is NoneStep) }
            .toBlocking()
            .first()!

        if case StepperTestsStep.stepOne = step {
            XCTAssert(true)
        }
    }

    func testNoneStepper() {

        // Given: a NoneStepper
        let stepperClass = NoneStepper()

        // When: listening to the emitted step
        // Then: the right step is emitted
        do {
            _ = try stepperClass.steps.filter { !($0 is NoneStep) }.toBlocking(timeout: 0.1).first()!
            XCTFail()
            return
        } catch {
            if case RxError.timeout = error {
                XCTAssert(true)
                return
            }

            XCTFail()
        }
    }

    func testCompositeStepperInitialSteps() throws {

        let stepsToEmit = [StepperTestsStep.stepOne, StepperTestsStep.stepTwo, StepperTestsStep.stepThree]

        // Given: a CompositeStepper, composed of OneSteppers
        let stepperClass = CompositeStepper(steppers: stepsToEmit.map { OneStepper(withSingleStep: $0) })

        // When: getting the computed initial steps
        // Then: there are equal to the concatenation of the initial steps of the OneSteppers
        XCTAssertEqual(stepperClass.initialSteps.filter { !($0 is NoneStep) } as! [StepperTestsStep], stepsToEmit)
    }

    func testCompositeStepper() throws {

        let stepsToEmit = [StepperTestsStep.stepOne, StepperTestsStep.stepTwo, StepperTestsStep.stepThree]
        let exp = expectation(description: "exp")
        exp.expectedFulfillmentCount = stepsToEmit.count

        // Given: a CompositeStepper, composed of OneSteppers
        let stepperClass = CompositeStepper(steppers: stepsToEmit.map { OneStepper(withSingleStep: $0) })

        var stepIndex = 0

        // When: listening to the emitted step
        _ = stepperClass.steps
            .startWith(elements: stepperClass.initialSteps)
            .filter { !($0 is NoneStep) }
            .takeUntil(self.rx.deallocating)
            .subscribe(onNext: { (step) in
                guard let step = step as? StepperTestsStep else {
                    XCTFail()
                    return
                }
                
                // Then: the right step is emitted
                if step == stepsToEmit[stepIndex] {
                    exp.fulfill()
                }

                stepIndex += 1
            })

        waitForExpectations(timeout: 10)
    }
}
