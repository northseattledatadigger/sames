#![ allow(unused)]

trait UserTrait {
    fn push_x_string(&mut self,x: String);
    fn say_so(&self);
    fn see(&self);
}

struct User {
    active: bool,
    username: String,
    email: String,
    sign_in_count: u64,
    list: Vec<String>,
}

fn init_user_struct2() -> User {
    let us: User = User {
        active: true,
        username: String::from(""),
        email: String::from(""),
        sign_in_count: 0,
        list: Vec::new(),
    };
    return us;
}

fn init_user_struct3(email: String, username: String) -> User {
    User {
        active: true,
        username: username,
        email: email,
        sign_in_count: 0,
        list: Vec::new(),
    }
}

fn init_user_struct4(email: String, username: String) -> User {
    User {
        active: true,
        username,
        email,
        sign_in_count: 0,
        list: Vec::new(),
    }
}

impl UserTrait for User {
    fn push_x_string(&mut self,x: String) {
        self.list.push(x);
    }
    fn say_so(&self) {
        println!("trace say_so in User object from UserTrait:  {}",self.list.len());
    }
    fn see(&self) {
        println!("~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        println!("trace a {}",self.active);
        println!("trace u {}",self.username);
        println!("trace e {}",self.email);
        println!("trace s {}",self.sign_in_count);
        println!("trace l {}",self.list.len());
        println!("...........................");
    }
}

fn main() {
    let uto2 = init_user_struct2();
    uto2.see();
    let uto3 = init_user_struct3("Xeno".to_string(),"xeno@aa.net".to_string());
    uto3.see();
    let uto4 = init_user_struct4("Xeno C".to_string(),"xeno@eskimo.com".to_string());
    uto4.see();
}
