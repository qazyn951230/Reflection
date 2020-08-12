// MIT License
//
// Copyright (c) 2017-present qazyn951230 qazyn951230@gmail.com
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

public protocol TrailingGenericHeader {
    var parametersCount: UInt16 { get }
    var requirementsCount: UInt16 { get }
    var keyArgumentsCount: UInt16 { get }
    var extraArgumentsCount: UInt16 { get }

    var base: GenericContextDescriptorHeader { get }
}

extension TrailingGenericHeader {
    public var argumentsCount: UInt32 {
        UInt32(keyArgumentsCount) + UInt32(extraArgumentsCount)
    }

    public var hasArguments: Bool {
        keyArgumentsCount > 0 || extraArgumentsCount > 0
    }
}

// TrailingGenericContextObjects
public protocol TrailingGenericContainer: TrailingContainer {
    associatedtype Header: TrailingGenericHeader = GenericContextDescriptorHeader

    static var followingTrailingTypes: [Any.Type] { get }

    static func followingTrailingObjectsSize(of metadata: Metadata) -> Int
    static func followingTrailingObjectsCount(of metadata: Metadata) -> Int
    static func followingTrailingObjectsAlignment(of metadata: Metadata) -> Int

    func genericContextHeader() -> GenericContextDescriptorHeader
    func fullGenericContextHeader() -> Header
}

extension TrailingGenericContainer {
    public static var trailingTypes: [Any.Type] {
        var all: [Any.Type] = [Header.self, GenericParamDescriptor.self,
                               GenericRequirementDescriptor.self]
        all.append(contentsOf: followingTrailingTypes)
        return all
    }

    public static var followingTrailingTypes: [Any.Type] { [] }

    public static func trailingObjectsSize(of metadata: Metadata) -> Int {
        switch metadata {
        case Header.self:
            return MemoryLayout<Header>.size
        default:
            return followingTrailingObjectsSize(of: metadata)
        }
    }

    public static func trailingObjectsCount(of metadata: Metadata) -> Int {
        switch metadata {
        case Header.self, GenericParamDescriptor.self,
             GenericRequirementDescriptor.self:
            return 0
        default:
            return followingTrailingObjectsCount(of: metadata)
        }
    }

    public static func trailingObjectsAlignment(of metadata: Metadata) -> Int {
        switch metadata {
        case Header.self:
            return MemoryLayout<Header>.alignment
        default:
            return followingTrailingObjectsAlignment(of: metadata)
        }
    }

    public static func followingTrailingObjectsSize(of metadata: Metadata) -> Int {
        assert(followingTrailingTypes.isEmpty)
        return 0
    }

    public static func followingTrailingObjectsCount(of metadata: Metadata) -> Int {
        assert(followingTrailingTypes.isEmpty)
        return 0
    }

    public static func followingTrailingObjectsAlignment(of metadata: Metadata) -> Int {
        assert(followingTrailingTypes.isEmpty)
        return 0
    }

    public func genericContextHeader() -> GenericContextDescriptorHeader {
        fullGenericContextHeader().base
    }

    public func fullGenericContextHeader() -> Header {
        let header: UnsafePointer<Header> = trailingObjects()
        return header.pointee
    }
}

extension TrailingGenericContainer where Self: TargetContextDescriptor {
    public func trailingObjectsCount(of metadata: Metadata) -> Int {
        switch metadata {
        case Header.self:
            return isGeneric ? 1 : 0
        case GenericParamDescriptor.self:
            return 0
        case GenericRequirementDescriptor.self:
            return 0
        default:
            return Self.followingTrailingObjectsCount(of: metadata)
        }
    }
}
