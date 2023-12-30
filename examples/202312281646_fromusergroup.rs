fn f<P: AsRef<Path> + ?Sized>(path: &P) {
    fn realf(path: &Path) {}
    realf(path.as_ref())
}
