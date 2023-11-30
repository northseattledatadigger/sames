
/*
fn generate_vec(len: usize) -> Vec<f64> {
    let mut rng = rand::thread_rng();
    let mut vec = Vec::with_capacity(len);
    for _ in 0..len {
        vec.push(rng.gen::<f64>() * 100.);
    }
    return vec;
}
enum HistogramErrors {
    Gizmo,
    WidgetNotFound { widget_name: String },
}
 */

#[derive(Debug, Snafu)]
enum MyError {
    #[snafu(display("Refrob the Gizmo"))]
    Gizmo,
    #[snafu(display("The widget '{widget_name}' could not be found"))]
    WidgetNotFound { widget_name: String },
}

fn foo() -> Result<(), MyError> {
    WidgetNotFoundSnafu {
        widget_name: "Quux",
    }
    .fail()
}

fn main() {
    if let Err(e) = foo() {
        println!("{}", e);
        // The widget 'Quux' could not be found
    }
}

