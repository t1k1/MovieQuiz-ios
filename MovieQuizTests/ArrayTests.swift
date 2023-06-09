//
//  ArrayTests.swift
//  MovieQuizTests
//
//  Created by Aleksey Kolesnikov on 09.06.2023.
//

import XCTest // не забывайте импортировать фреймворк для тестирования
@testable import MovieQuiz // импортируем наше приложение для тестирования

class Arraytest: XCTestCase {
    func testGetValueInRange() throws {
        let array = [1,1,2,3,5]
        
        let value = array[safe: 2]
        
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
    }
    
    func testGetValueOutOfRange() throws {
        let array = [1,1,2,3,5]
        
        let value = array[safe: 20]
        
        XCTAssertNil(value)
    }
}
