//
//  StepperTests.swift
//  RxFlowTests
//
//  Created by Thibault Wittemberg on 2018-10-15.
//  Copyright © 2018 RxSwiftCommunity. All rights reserved.
//

@testable import RxFlow
import XCTest
import RxBlocking
import RxSwift
import RxCocoa
import RxTest

enum StepperTestsStep: Step {
    case stepOne
    case stepTwo
    case stepThree
    case stepFour
    case stepFive
    case stepSix
    case stepReference
}

final class StepperClass: Stepper {

    let steps = PublishRelay<Step>()
    let initialStep: Step
    let nextStep: Step
    private(set) var madeReady = false

    init(with initialStep: Step, andNextStep nextStep: Step) {
        self.initialStep = initialStep
        self.nextStep = nextStep
    }

    func readyToEmitSteps() {
        madeReady = true
    }

    func emitNextStep () {
        self.steps.accept(self.nextStep)
    }
}

final class CustomCompositeStepper: CompositeStepper {
    let initialStep: Step

    init(with initialStep: Step, andSteppers steppers: [Stepper]) {
        self.initialStep = initialStep
        super.init(steppers: steppers)
    }
}

final class StepperTests: XCTestCase {

    func testStepperEmitStep() {
        // Given: a stepper
        let stepperClass = StepperClass(with: StepperTestsStep.stepOne, andNextStep: StepperTestsStep.stepTwo)
        let testScheduler = TestScheduler(initialClock: 0)
        let observer = testScheduler.createObserver(Step.self)
        _ = stepperClass.steps.take(until: self.rx.deallocating).bind(to: observer)
        testScheduler.start()

        // When: emitting a new step
        stepperClass.steps.accept(stepperClass.initialStep)
        stepperClass.emitNextStep()

        // Then: the right step is emitted
        XCTAssertEqual(observer.events.count, 2)
        XCTAssertEqual(observer.events[0].value.element as? StepperTestsStep, StepperTestsStep.stepOne)
        XCTAssertEqual(observer.events[1].value.element as? StepperTestsStep, StepperTestsStep.stepTwo)
    }

    func testOneStepper() {
        // Given: a OneStepper
        let stepperClass = OneStepper(withSingleStep: StepperTestsStep.stepOne)
        let testScheduler = TestScheduler(initialClock: 0)
        let observer = testScheduler.createObserver(Step.self)
        _ = stepperClass.steps.take(until: self.rx.deallocating).bind(to: observer)
        testScheduler.start()

        // When: emitting the initial step
        stepperClass.steps.accept(stepperClass.initialStep)

        // Then: the right step is emitted
        XCTAssertEqual(observer.events.count, 1)
        XCTAssertEqual(observer.events[0].value.element as? StepperTestsStep, StepperTestsStep.stepOne)
    }

    func testNoneStepper() {
        // Given: a NoneStepper
        let stepperClass = NoneStepper()
        let testScheduler = TestScheduler(initialClock: 0)
        let observer = testScheduler.createObserver(Step.self)
        _ = stepperClass.steps.take(until: self.rx.deallocating).bind(to: observer)
        testScheduler.start()

        // When: emitting the initial step
        stepperClass.steps.accept(stepperClass.initialStep)

        // Then: the right step is emitted
        XCTAssertEqual(observer.events.count, 1)
        XCTAssertEqual(observer.events[0].value.element as? NoneStep, NoneStep())
    }

    func testCompositeStepperInitialSteps() {

        let stepsToEmit = [StepperTestsStep.stepOne, StepperTestsStep.stepTwo, StepperTestsStep.stepThree]

        // Given: a CompositeStepper, composed of OneSteppers
        let compositeStepper = CompositeStepper(steppers: stepsToEmit.map { OneStepper(withSingleStep: $0) })
        let testScheduler = TestScheduler(initialClock: 0)
        let observer = testScheduler.createObserver(Step.self)
        _ = compositeStepper.steps.take(until: self.rx.deallocating).bind(to: observer)
        testScheduler.start()
        
        // When: launching the steps sequence
        compositeStepper.readyToEmitSteps()

        // Then: The initial steps are emitted
        XCTAssertEqual(observer.events.count, 3)
        XCTAssertEqual(observer.events[0].value.element as? StepperTestsStep, StepperTestsStep.stepOne)
        XCTAssertEqual(observer.events[1].value.element as? StepperTestsStep, StepperTestsStep.stepTwo)
        XCTAssertEqual(observer.events[2].value.element as? StepperTestsStep, StepperTestsStep.stepThree)
    }

    func testCompositeStepperReadyToEmitSteps() {

        // Given: a compositeStepper
        let stepper1 = StepperClass(with: StepperTestsStep.stepOne, andNextStep: StepperTestsStep.stepTwo)
        let stepper2 = StepperClass(with: StepperTestsStep.stepOne, andNextStep: StepperTestsStep.stepTwo)
        let compositeStepper = CompositeStepper(steppers: [stepper1, stepper2])

        // When: ready to emit steps
        compositeStepper.readyToEmitSteps()

        // Then: the composite steppers are made ready
        XCTAssertTrue(stepper1.madeReady)
        XCTAssertTrue(stepper2.madeReady)
    }

    func testCompositeStepper() {

        let initialStepsToEmit = [StepperTestsStep.stepOne, StepperTestsStep.stepTwo, StepperTestsStep.stepThree]
        let nextStepsToEmit = [StepperTestsStep.stepFour, StepperTestsStep.stepFive, StepperTestsStep.stepSix]

        // Given: a CompositeStepper, composed of OneSteppers
        let stepperClasses = zip(initialStepsToEmit, nextStepsToEmit).map { StepperClass(with: $0, andNextStep: $1) }
        let compositeStepper = CompositeStepper(steppers: stepperClasses)
        let testScheduler = TestScheduler(initialClock: 0)
        let observer = testScheduler.createObserver(Step.self)
        _ = compositeStepper.steps.take(until: self.rx.deallocating).bind(to: observer)
        testScheduler.start()

        // When: launching the steps sequence
        compositeStepper.readyToEmitSteps()
        stepperClasses.forEach { $0.emitNextStep() }

        // Then: The initial and next steps are emitted
        XCTAssertEqual(observer.events.count, 6)
        XCTAssertEqual(observer.events[0].value.element as? StepperTestsStep, StepperTestsStep.stepOne)
        XCTAssertEqual(observer.events[1].value.element as? StepperTestsStep, StepperTestsStep.stepTwo)
        XCTAssertEqual(observer.events[2].value.element as? StepperTestsStep, StepperTestsStep.stepThree)
        XCTAssertEqual(observer.events[3].value.element as? StepperTestsStep, StepperTestsStep.stepFour)
        XCTAssertEqual(observer.events[4].value.element as? StepperTestsStep, StepperTestsStep.stepFive)
        XCTAssertEqual(observer.events[5].value.element as? StepperTestsStep, StepperTestsStep.stepSix)
    }

    func testCompositeStepperWithInitialStep() {

        let initialStepsToEmit = [StepperTestsStep.stepOne, StepperTestsStep.stepTwo, StepperTestsStep.stepThree]
        let nextStepsToEmit = [StepperTestsStep.stepFour, StepperTestsStep.stepFive, StepperTestsStep.stepSix]

        // Given: a CompositeStepper, composed of OneSteppers
        let stepperClasses = zip(initialStepsToEmit, nextStepsToEmit).map { StepperClass(with: $0, andNextStep: $1) }
        let compositeStepper = CustomCompositeStepper(with: StepperTestsStep.stepReference, andSteppers: stepperClasses)
        let testScheduler = TestScheduler(initialClock: 0)
        let observer = testScheduler.createObserver(Step.self)
        _ = compositeStepper.steps.take(until: self.rx.deallocating).bind(to: observer)
        testScheduler.start()

        // When: launching the steps sequence
        compositeStepper.steps.accept(compositeStepper.initialStep)
        compositeStepper.readyToEmitSteps()
        stepperClasses.forEach { $0.emitNextStep() }

        // Then: The initial and next steps are emitted
        XCTAssertEqual(observer.events.count, 7)
        XCTAssertEqual(observer.events[0].value.element as? StepperTestsStep, StepperTestsStep.stepReference)
        XCTAssertEqual(observer.events[1].value.element as? StepperTestsStep, StepperTestsStep.stepOne)
        XCTAssertEqual(observer.events[2].value.element as? StepperTestsStep, StepperTestsStep.stepTwo)
        XCTAssertEqual(observer.events[3].value.element as? StepperTestsStep, StepperTestsStep.stepThree)
        XCTAssertEqual(observer.events[4].value.element as? StepperTestsStep, StepperTestsStep.stepFour)
        XCTAssertEqual(observer.events[5].value.element as? StepperTestsStep, StepperTestsStep.stepFive)
        XCTAssertEqual(observer.events[6].value.element as? StepperTestsStep, StepperTestsStep.stepSix)
    }
}
