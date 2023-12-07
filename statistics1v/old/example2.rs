fn main() {
    // Reduce a non-empty iterator into Some(value)
    let v = vec![1usize, 2, 3, 4, 5];
    let sum = v.into_iter().reduce(|a, b| a + b);
    assert_eq!(Some(15), sum);

    // Reduce an empty iterator into None
    let v = Vec::<usize>::new();
    let sum = v.into_iter().reduce(|a, b| a + b);
    assert_eq!(None, sum);

    // Reduce a non-empty iterator into Some(value)
    let v = vec![1.0, 2.0, 3.0, 4.0, 5.0];
    let product = v.into_iter().reduce(|a, b| a * b);
    //println!("trace _product:  {}",_product);
    assert_eq!(Some(120.0), product);

}
