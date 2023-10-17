module quest_4::bookkeeper {

  // Imports
  use sui::object::{Self, UID};
  use std::string;
  use sui::tx_context::{Self, TxContext};
  use sui::transfer;

  // Struct Definition
  struct Book has key, store {
    id: UID,
    num_pages: u64,
    owner_name: string::String
  }

  // Functions
  fun new(num_pages: u64, owner_name: string::String, ctx: &mut TxContext): Book {
    Book {
      id: object::new(ctx),
      num_pages: num_pages,
      owner_name: owner_name
    }
  }

  public entry fun create(num_pages: u64, owner_name: string::String, ctx: &mut TxContext) {
    let book = new(num_pages, owner_name, ctx);
    transfer::transfer(book, tx_context::sender(ctx));
  }

  public fun get_num_pages(book: &Book): u64 {
    book.num_pages
  }

  public fun get_owner_name(self: &Book): string::String {
    return self.owner_name
  }

  public entry fun change_owner_name(book: &mut Book, new_owner_name: string::String) {
    book.owner_name = new_owner_name;
  }

  public entry fun transfer_book(book: Book, recipient: address) {
    transfer::transfer(book, recipient);
  }

  // Unit Test
  #[test]
  fun test_book_transactions() {
     
    use sui::test_scenario;
     
    // create test addresses to represent users
    let initial_owner = @0x1;
    let final_owner = @0x2;

    // first transaction - module initialization
    let scenario_val = test_scenario::begin(initial_owner);
    let scenario = &mut scenario_val;

    // second transaction - create book
    test_scenario::next_tx(scenario, initial_owner);
    {
      create(40, string::utf8(b"Alice"), test_scenario::ctx(scenario));
    };

    // third transaction - verify & transfer book
    test_scenario::next_tx(scenario, initial_owner);
    {
      let book = test_scenario::take_from_sender<Book>(scenario);
      assert!(get_num_pages(&book) == 40 && get_owner_name(&book) == string::utf8(b"Alice"), 0);
      transfer_book(book, final_owner) 
    };

    // forth transaction - change name of owner
    test_scenario::next_tx(scenario, final_owner);
    {
      let book = test_scenario::take_from_sender<Book>(scenario);
      change_owner_name(&mut book, string::utf8(b"Bob"));
      assert!(get_num_pages(&book) == 40 && get_owner_name(&book) == string::utf8(b"Bob"), 1);

      test_scenario::return_to_sender(scenario, book)
    };

    // fifth transaction - verify book & end test
    test_scenario::next_tx(scenario, final_owner);
    {
      let book = test_scenario::take_from_sender<Book>(scenario);
      assert!(get_num_pages(&book) == 40 && get_owner_name(&book) == string::utf8(b"Bob"), 2);
       
      test_scenario::return_to_sender(scenario, book)
    };
    test_scenario::end(scenario_val);
  }

}