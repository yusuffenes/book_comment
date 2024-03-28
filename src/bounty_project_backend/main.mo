import Text "mo:base/Text";
import Nat16 "mo:base/Nat16";
import Bool "mo:base/Bool";
import HashMap "mo:base/HashMap";
import Buffer "mo:base/Buffer";
import List "mo:base/List";
import Array "mo:base/Array";
import Trie "mo:base/Trie";
import Iter "mo:base/Iter";
import Debug "mo:base/Debug";
import Nat "mo:base/Nat";

// 

actor
{
  type Writer = {
    choiceVisibility:Bool;
    id : Nat32;
    name : Text;
    age : ?Nat16;
    bookName:Text;
    comment:Text;
  };

  type Reader = {
    choiceVisibility:Bool;
    choiceBook:Text;
    choiceWriter:?Text;
    feedback:?Text;
  };
  
  type Book = {
    name:Text;
    writer:?Text;
    comment:Text;
  };
  
  var books: HashMap.HashMap<Text, Book> = HashMap.HashMap<Text, Book>(10, Text.equal, Text.hash);
  var writers: HashMap.HashMap<Text, Writer> = HashMap.HashMap<Text, Writer>(10, Text.equal, Text.hash);
  var readers: HashMap.HashMap<Text, Reader> = HashMap.HashMap<Text, Reader>(10, Text.equal, Text.hash);
  var comments: HashMap.HashMap<Text, Text> = HashMap.HashMap<Text, Text>(10, Text.equal, Text.hash);
  var writerBuffer: Buffer.Buffer<Text> = Buffer.Buffer<Text>(10);
  var readerBuffer: Buffer.Buffer<Text> = Buffer.Buffer<Text>(10);
  var totalReaderByBook: HashMap.HashMap<Text, Nat> = HashMap.HashMap<Text, Nat>(10, Text.equal, Text.hash);
  var feedbacks: HashMap.HashMap<Text, Text> = HashMap.HashMap<Text, Text>(10, Text.equal, Text.hash);

  public func addWriter(writer:Writer) : async () {
    let uploadBookVisible:Book = {
      name= writer.bookName;
      writer= ?writer.name;
      comment= writer.comment;
    };
    let uploadBookInvisible:Book = {
      name= writer.bookName;
      writer= null;
      comment= writer.comment;
    };
    if (writer.choiceVisibility) {
      writers.put(writer.name, writer);
      writerBuffer.add(writer.name);
      books.put(writer.bookName, uploadBookVisible);

      if(comments.get(writer.bookName) == null){
        comments.put(writer.bookName,writer.comment);
      }
      else{
        let temp:?Text = comments.get(writer.bookName);
        let text : Text = switch (temp) {
          case (null) { "default" }; 
          case (?t) { t }; 
        };
         comments.put(writer.bookName,text # ", " # writer.comment);
      }
    }
    else {
        books.put(writer.bookName, uploadBookInvisible);
        writerBuffer.add("Anonymous");
        if(comments.get(writer.bookName) == null){
        comments.put(writer.bookName,writer.comment);
        }
        else{
          let temp:?Text = comments.get(writer.bookName);
          let text : Text = switch (temp) {
            case (null) { "default" }; 
            case (?t) { t }; 
          };
         comments.put(writer.bookName,text # " " # writer.comment);
        }
    };
  };

  public func addReader(reader:Reader) : async () {
    if (reader.choiceVisibility) {
      readers.put(reader.choiceBook, reader);
      switch (reader.feedback) {
        case (null) { };
        case (?t) {
          if(feedbacks.get(reader.choiceBook) == null){
            feedbacks.put(reader.choiceBook,t);
          }
          else{
            let temp:?Text = feedbacks.get(reader.choiceBook);
            let text : Text = switch (temp) {
              case (null) { "default" }; 
              case (?t) { t }; 
            };
            feedbacks.put(reader.choiceBook,text # ", " # t);
          }
        };
      };
      let temp: ?Nat = totalReaderByBook.get(reader.choiceBook);
      let totalReader: Nat = switch (temp) {
        case (null) { 0 };
        case (?t) { t };
      };
      totalReaderByBook.put(reader.choiceBook, totalReader + 1);
    }
    else {
       switch (reader.feedback) {
        case (null) { };
        case (?t) {
          if(feedbacks.get(reader.choiceBook) == null){
            feedbacks.put(reader.choiceBook,t);
          }
          else{
            let temp:?Text = feedbacks.get(reader.choiceBook);
            let text : Text = switch (temp) {
              case (null) { "default" }; 
              case (?t) { t }; 
            };
            feedbacks.put(reader.choiceBook,text # ", " # t);
          }
    };  
    };
    };
  };
  //
  public query func getCommentsByBookName(bookName: Text):async ?Text{
    let comment: ?Text = comments.get(bookName);
    return comment;

  };
   
  public query func getWriters() : async [Text] {
    return Buffer.toArray(writerBuffer);
  };

  public query func getTotalReaderByBook(bookName:Text) : async ?Nat {
    let totalReader: ?Nat = totalReaderByBook.get(bookName);
    return totalReader;
  };

  public func getBookByName(bookName: Text) : async ?Book {
    let book: ?Book = books.get(bookName);
    return book;
  };

  private  func getWriterByName(writerName: Text) : async ?Writer {
    let writer: ?Writer = writers.get(writerName);
    return writer;
  };

  private func getReaderByName(readerName: Text) : async ?Reader {
    let reader: ?Reader = readers.get(readerName);
    return reader;
  };


  public func getBookByWriterName(writerName: Text) : async ?Book {
    let writer: ?Writer = await getWriterByName(writerName);
    if (writer == null) {
      return null;
    };
    let book: ?Book = books.get(writerName);
    return book;
  };

  public query func getFeedbackByBookName(bookName: Text) : async ?Text {
    let feedback: ?Text = feedbacks.get(bookName);
    return feedback;
  };
  
}