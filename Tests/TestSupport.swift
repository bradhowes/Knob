import SnapshotTesting
import SwiftUI
import XCTest

// TODO: eliminate most/all of this with latest swift-snapshot-testing package. Probably no longer needed.

public struct __SnapshotTestViewWrapper<Content: View>: View {
  let size: CGSize
  let content: Content
  let colorScheme: ColorScheme
  let background: Color

  public init(size: CGSize, colorScheme: ColorScheme, background: Color?,  @ViewBuilder _ content: () -> Content) {
    self.size = size
    self.content = content()
    self.colorScheme = colorScheme
    self.background = background ?? (colorScheme == .dark ? .black : .white)
  }

  public var body: some View {
    Group {
      content
    }
    .frame(width: size.width, height: size.height)
    .background(background)
    .environment(\.colorScheme, colorScheme)
  }
}

@inlinable
func makeUniqueSnapshotName(_ funcName: String) -> String {
  let platform: String
  platform = "iOS"
  return funcName + "-" + platform
}

@MainActor @inlinable
func assertSnapshot<V: SwiftUI.View>(
  matching: V,
  size: CGSize = CGSize(width: 400, height: 220),
  colorScheme: ColorScheme = .light,
  background: Color? = nil,
  file: StaticString = #filePath,
  testName: String = #function,
  line: UInt = #line
) throws {
  let uniqueTestName = makeUniqueSnapshotName(testName)
  let isOnGithub = ProcessInfo.processInfo.environment["XCTestBundlePath"]?.contains("/Users/runner/work") ?? false

#if os(iOS)

  let view = __SnapshotTestViewWrapper(size: size, colorScheme: colorScheme, background: background) {
    matching
  }

  if let result = SnapshotTesting.verifySnapshot(
    of: view,
    as: .image(
      drawHierarchyInKeyWindow: false,
      layout: .fixed(width: size.width, height: size.height)
    ),
    named: uniqueTestName,
    file: file,
    testName: testName,
    line: line
  ) {
    print("uniqueTestName:", uniqueTestName)
    print("file:", file)
    if isOnGithub {
      print("***", result)
    } else {
      XCTFail(result, file: file, line: line)
    }
  }
#endif
}
