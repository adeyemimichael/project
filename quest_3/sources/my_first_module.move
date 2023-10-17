module quest_3::my_module {

  // Imports
  use sui::object::{Self, UID};
  use std::string;
  use sui::transfer;
  use sui::tx_context;
   
  // Struct Definition
  struct Book has key {
      id: UID,
      num_pages: u8,
      owner_name: string::String
    }

  // Unit Test
  #[test]
  public fun test_create_book() {
    let ctx = tx_context::dummy();

    let book = Book {
      id: object::new(&mut ctx),
      owner_name: string::utf8(b"livingman"),
      num_pages: 150
    };

    assert!(book.owner_name == string::utf8(b"livingman"), 0);
    assert!(book.num_pages == 150, 1);
     
    let dummy_address = @0xCAFE;
    transfer::transfer(book, dummy_address);
  }

}