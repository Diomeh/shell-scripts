use color_eyre::eyre::Result;

use crate::{
    DRunnable,
    XtractArgs,
};

impl DRunnable for XtractArgs {
    fn run(&mut self) -> Result<()> {
        println!("Running XtractArgs");
        Ok(())
    }
}
