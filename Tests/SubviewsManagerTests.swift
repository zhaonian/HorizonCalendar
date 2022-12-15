// Created by Bryan Keller on 12/15/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import XCTest
@testable import HorizonCalendar

// MARK: - SubviewsManagerTests

final class SubviewsManagerTests: XCTestCase {

  // MARK: Internal

  func testParentViewWeaklyHeld() {
    let view = UIView()
    let subviewsManager = SubviewsManager(parentView: view)
    DispatchQueue.main.async {
      XCTAssertNil(
        subviewsManager,
        "Subviews manager should not strongly hold a reference to the parent view.")
    }
  }

  func testCorrectSubviewsOrderFewItems() throws {
    let itemTypesToInsert: [VisibleItem.ItemType] = [
      .pinnedDayOfWeek(.first),
      .pinnedDaysOfWeekRowSeparator,
      .pinnedDaysOfWeekRowBackground,
      .overlayItem(.monthHeader(monthContainingDate: Date())),
      .daysOfWeekRowSeparator(
        Month(era: 1, year: 2022, month: 1, isInGregorianCalendar: true)),
      .layoutItemType(
        .monthHeader(Month(era: 1, year: 2022, month: 1, isInGregorianCalendar: true))),
      .dayRange(.init(containing: Date()...Date(), in: .current)),
    ]

    for itemTypeTypeToInsert in itemTypesToInsert {
      subviewsManager.insertSubview(UIView(), correspondingItemType: itemTypeTypeToInsert)
    }

    XCTAssert(
      subviewsManager._testSupport_insertedItemTypes == itemTypesToInsert.sorted(),
      "Incorrect subviews order.")
  }

  func testCorrectSubviewsOrderManyItems() throws {
    let itemTypesToInsert: [VisibleItem.ItemType] = [
      .layoutItemType(
        .monthHeader(Month(era: 1, year: 2022, month: 1, isInGregorianCalendar: true))),
      .dayRange(.init(containing: Date()...Date(), in: .current)),
      .dayRange(.init(containing: Date()...Date(), in: .current)),
      .dayRange(.init(containing: Date()...Date(), in: .current)),
      .layoutItemType(
        .monthHeader(Month(era: 1, year: 2022, month: 2, isInGregorianCalendar: true))),
      .layoutItemType(
        .monthHeader(Month(era: 1, year: 2022, month: 3, isInGregorianCalendar: true))),
      .layoutItemType(
        .monthHeader(Month(era: 1, year: 2022, month: 4, isInGregorianCalendar: true))),
      .layoutItemType(
        .monthHeader(Month(era: 1, year: 2022, month: 5, isInGregorianCalendar: true))),
      .layoutItemType(
        .monthHeader(Month(era: 1, year: 2022, month: 6, isInGregorianCalendar: true))),
      .layoutItemType(
        .monthHeader(Month(era: 1, year: 2022, month: 7, isInGregorianCalendar: true))),
      .layoutItemType(
        .monthHeader(Month(era: 1, year: 2022, month: 8, isInGregorianCalendar: true))),
      .overlayItem(.monthHeader(monthContainingDate: Date())),
      .pinnedDaysOfWeekRowBackground,
      .dayRange(.init(containing: Date()...Date(), in: .current)),
      .layoutItemType(
        .monthHeader(Month(era: 1, year: 2022, month: 9, isInGregorianCalendar: true))),
      .pinnedDayOfWeek(.first),
      .pinnedDayOfWeek(.second),
      .daysOfWeekRowSeparator(
        Month(era: 1, year: 2022, month: 1, isInGregorianCalendar: true)),
      .pinnedDayOfWeek(.third),
      .pinnedDaysOfWeekRowSeparator,
      .pinnedDayOfWeek(.fourth),
      .pinnedDayOfWeek(.fifth),
      .layoutItemType(
        .monthHeader(Month(era: 1, year: 2022, month: 10, isInGregorianCalendar: true))),
      .pinnedDayOfWeek(.sixth),
      .layoutItemType(
        .monthHeader(Month(era: 1, year: 2022, month: 11, isInGregorianCalendar: true))),
      .layoutItemType(
        .monthHeader(Month(era: 1, year: 2022, month: 12, isInGregorianCalendar: true))),
      .layoutItemType(
        .monthHeader(Month(era: 1, year: 2022, month: 1, isInGregorianCalendar: true))),
      .dayRange(.init(containing: Date()...Date(), in: .current)),
      .layoutItemType(
        .monthHeader(Month(era: 1, year: 2023, month: 1, isInGregorianCalendar: true))),
      .layoutItemType(
        .monthHeader(Month(era: 1, year: 2023, month: 2, isInGregorianCalendar: true))),
      .daysOfWeekRowSeparator(
        Month(era: 1, year: 2023, month: 1, isInGregorianCalendar: true)),
      .layoutItemType(
        .monthHeader(Month(era: 1, year: 2023, month: 3, isInGregorianCalendar: true))),
      .layoutItemType(
        .monthHeader(Month(era: 1, year: 2023, month: 4, isInGregorianCalendar: true))),
      .pinnedDayOfWeek(.last),
    ]

    for itemTypeTypeToInsert in itemTypesToInsert {
      subviewsManager.insertSubview(UIView(), correspondingItemType: itemTypeTypeToInsert)
    }

    XCTAssert(
      subviewsManager._testSupport_insertedItemTypes == itemTypesToInsert.sorted(),
      "Incorrect subviews order.")
  }

  // MARK: Private

  private lazy var subviewsManager = SubviewsManager(parentView: parentView)

  private let parentView = UIView()

}

// MARK: - VisibleItem.ItemType + Comparable

extension VisibleItem.ItemType: Comparable {

  // MARK: Public

  public static func < (
    lhs: HorizonCalendar.VisibleItem.ItemType,
    rhs: HorizonCalendar.VisibleItem.ItemType)
    -> Bool
  {
    lhs.relativeDistanceFromBack < rhs.relativeDistanceFromBack
  }

  // MARK: Private

  private var relativeDistanceFromBack: Int {
    switch self {
    case .dayRange:
      return 0

    case .layoutItemType:
      return 1

    case .daysOfWeekRowSeparator:
      return 2

    case .overlayItem:
      return 3

    case .pinnedDaysOfWeekRowBackground:
      return 4

    case .pinnedDaysOfWeekRowSeparator:
      return 5

    case .pinnedDayOfWeek:
      return 6
    }
  }

}
