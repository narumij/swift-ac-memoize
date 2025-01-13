import AcMemoize

#if true
@Memoize(maxCount: Int.max)
func fibonacci(_ n: Int) -> Int {
    if n <= 1 { return n }
    return fibonacci(n - 1) + fibonacci(n - 2)
}
print((1..<16).map { fibonacci($0) }) // Output: [1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610]
print(fibonacci(40)) // Output: 102_334_155
#endif

#if true
//@Memoize(maxCount: Int.max)
@Memoize
func tarai(x: Int, y: Int, z: Int) -> Int {
  if x <= y {
    return y
  } else {
    return tarai(
      x: tarai(x: x - 1, y: y, z: z),
      y: tarai(x: y - 1, y: z, z: x),
      z: tarai(x: z - 1, y: x, z: y))
  }
}
print("Tak 40 20 0 is \(tarai(x: 40, y: 20, z: 0))")
#endif

func A() {
  @Memoize
  func tarai(x: Int, y: Int, z: Int) -> Int {
    if x <= y {
      return y
    } else {
      return tarai(
        x: tarai(x: x - 1, y: y, z: z),
        y: tarai(x: y - 1, y: z, z: x),
        z: tarai(x: z - 1, y: x, z: y))
    }
  }
  print("Tak 20 10 0 is \(tarai(x: 20, y: 10, z: 0))")
}


#if false
struct A {

  @Memoize
  func tarai(x: Int, y: Int, z: Int) -> Int {
    if x <= y {
      return y
    } else {
      return tarai(
        x: tarai(x: x - 1, y: y, z: z),
        y: tarai(x: y - 1, y: z, z: x),
        z: tarai(x: z - 1, y: x, z: y))
    }
  }
}

struct B {

  @Memoize
  static func tarai(x: Int, y: Int, z: Int) -> Int {
    if x <= y {
      return y
    } else {
      return tarai(
        x: tarai(x: x - 1, y: y, z: z),
        y: tarai(x: y - 1, y: z, z: x),
        z: tarai(x: z - 1, y: x, z: y))
    }
  }
}

func C() {

  @Memoize
  func tarai(x: Int, y: Int, z: Int) -> Int {
    if x <= y {
      return y
    } else {
      return tarai(
        x: tarai(x: x - 1, y: y, z: z),
        y: tarai(x: y - 1, y: z, z: x),
        z: tarai(x: z - 1, y: x, z: y))
    }
  }
  
  print("Tak 20 10 0 is \(tarai(x: 20, y: 10, z: 0))")
}

struct D {

  func d() {
    @Memoize
    func tarai(x: Int, y: Int, z: Int) -> Int {
      if x <= y {
        return y
      } else {
        return tarai(
          x: tarai(x: x - 1, y: y, z: z),
          y: tarai(x: y - 1, y: z, z: x),
          z: tarai(x: z - 1, y: x, z: y))
      }
    }
    print("Tak 20 10 0 is \(tarai(x: 20, y: 10, z: 0))")
  }
}

#endif
