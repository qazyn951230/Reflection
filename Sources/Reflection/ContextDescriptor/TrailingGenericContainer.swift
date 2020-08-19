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

    static var followingTrailingTypes: [AnyLayout] { get }

    func followingTrailingObjectsCount(of layout: AnyLayout) -> UInt

    func genericContextHeader() -> GenericContextDescriptorHeader
    func fullGenericContextHeader() -> Header
}

extension TrailingGenericContainer {
    public static var trailingTypes: [AnyLayout] {
        var all = [AnyLayout(Header.self), AnyLayout(GenericParamDescriptor.self),
                   AnyLayout(GenericRequirementDescriptor.self)]
        all.append(contentsOf: followingTrailingTypes)
        return all
    }

    public static var followingTrailingTypes: [AnyLayout] { [] }

    public func trailingObjectsCount(of layout: AnyLayout) -> UInt {
        switch layout {
        case Header.self, GenericParamDescriptor.self,
             GenericRequirementDescriptor.self:
            return 0
        default:
            return followingTrailingObjectsCount(of: layout)
        }
    }

    public func followingTrailingObjectsCount(of layout: AnyLayout) -> UInt {
        assert(Self.followingTrailingTypes.isEmpty)
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
    public func trailingObjectsCount(of layout: AnyLayout) -> UInt {
        switch layout {
        case Header.self:
            return isGeneric ? 1 : 0
        case GenericParamDescriptor.self:
            return UInt(genericContextHeader().parametersCount)
        case GenericRequirementDescriptor.self:
            return UInt(genericContextHeader().requirementsCount)
        default:
            return followingTrailingObjectsCount(of: layout)
        }
    }
}

public typealias TargetGenericContainer = TargetContextDescriptor & TrailingGenericContainer
