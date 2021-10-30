// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.5.0;

import "./Ownable.sol";
import "./StringSet.sol";
import "./AddressSet.sol";
import "./UintSet.sol";

contract BookLibrary is Ownable {

    using StringSet for StringSet.Set;
    using AddressSet for AddressSet.Set;
    using UintSet for UintSet.Set;
    
    uint book_id;
    mapping(uint => string) public booksById;
    mapping(string => Book) books;
    mapping(address => StringSet.Set) booksByOwners;
    UintSet.Set availableBooks;
    
    struct Book {
        uint id;
        string name;
        uint copies;
        bool exists;
        AddressSet.Set borrowersHistory;
    }
    
    event AddBook(uint bookId);
    event BorrowBook(uint bookId);
    event ReturnBook(uint bookId);
    
    function addBook(string memory bookName, uint bookCopies) public onlyOwner {
        
        require(bookCopies != 0, "should add only more than 0 copies!");
        
        if (books[bookName].exists) {
            books[bookName].copies += bookCopies;
            emit AddBook(books[bookName].id);
            return;
        }
        
        uint bookId = book_id++;
        booksById[bookId] = bookName;
        
        books[bookName].id = bookId;
        books[bookName].name = bookName;
        books[bookName].copies = bookCopies;
        books[bookName].exists = true;
        
        availableBooks.insert(bookId);
        
        emit AddBook(books[bookName].id);
    }
    
    function getBookByName(string memory name) public view returns (uint, string memory, uint) {
        return (books[name].id, books[name].name, books[name].copies);
    }
    
    function getAvailableBooks() public view returns (uint[] memory booksSet) {
        return availableBooks.getSet();
    }
    
    function getBookHistory(uint bookId) public view returns (address[] memory historySet) {
        string memory bookName = booksById[bookId];
        return books[bookName].borrowersHistory.getSet();
    }
    
    function borrowBook(uint bookId) public {
        string memory bookName = booksById[bookId];
        require(books[bookName].copies > 0, "There should be at least 1 copy of the book");
        require(!booksByOwners[msg.sender].exists(bookName), "Should not borrow a book which is already borrowed");
        
        if (books[bookName].copies == 1) {
            availableBooks.remove(bookId);
        }
        
        books[bookName].copies--;
        booksByOwners[msg.sender].insert(bookName);
        books[bookName].borrowersHistory.insert(msg.sender);
        
        emit BorrowBook(bookId);
    }
    
    function returnBook(uint bookId) public {
        string memory bookName = booksById[bookId];
        require(booksByOwners[msg.sender].exists(bookName), "Should return book only if it has been borrowed before that");
        
        if (books[bookName].copies == 0) {
            availableBooks.insert(bookId);
        }
        
        books[bookName].copies++;
        booksByOwners[msg.sender].remove(bookName);
        
        emit ReturnBook(bookId);
    }
}
