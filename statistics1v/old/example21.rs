#![ allow(unused)]

#[macro_export]
macro_rules! globalpaths {
    ( $x:ident ) => {
        const TOPPATH = $x;
        const PROJECTPATH = "{$x}/myprojectnode";
        const RESOURCEPATH = "{PROJECTPATH}/myresourcenode";
    };
}

fn main() {
    globalpaths!("/home/here");
    /*
        println!("
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~
    {}
    {}
    {}
    ...........................
    ",TOPPATH,PROJECTPATH,RESOURCEPATH);
     */
}
