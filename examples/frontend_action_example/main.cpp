// Adapted from https://clang.llvm.org/docs/RAVFrontendAction.html

#include <span>

#include "clang/AST/ASTConsumer.h"
#include "clang/AST/RecursiveASTVisitor.h"
#include "clang/Frontend/CompilerInstance.h"
#include "clang/Frontend/FrontendAction.h"
#include "clang/Tooling/Tooling.h"

class FindNamedClassVisitor
    : public clang::RecursiveASTVisitor<FindNamedClassVisitor> {
public:
  explicit FindNamedClassVisitor(clang::ASTContext *Context)
      : Context_(Context) {}

  auto VisitCXXRecordDecl(clang::CXXRecordDecl *Declaration) -> bool {
    if (Declaration->getQualifiedNameAsString() == "n::m::C") {
      const clang::FullSourceLoc full_location =
          Context_->getFullLoc(Declaration->getBeginLoc());
      if (full_location.isValid()) {
        llvm::outs() << "Found declaration at "
                     << full_location.getSpellingLineNumber() << ":"
                     << full_location.getSpellingColumnNumber() << "\n";
      }
    }
    return true;
  }

private:
  clang::ASTContext *Context_;
};

class FindNamedClassConsumer : public clang::ASTConsumer {
public:
  explicit FindNamedClassConsumer(clang::ASTContext *Context)
      : Visitor_(Context) {}

  void HandleTranslationUnit(clang::ASTContext &Context) final {
    Visitor_.TraverseDecl(Context.getTranslationUnitDecl());
  }

private:
  FindNamedClassVisitor Visitor_;
};

class FindNamedClassAction : public clang::ASTFrontendAction {
public:
  auto CreateASTConsumer(clang::CompilerInstance &Compiler,
                         llvm::StringRef /*InFile*/)
      -> std::unique_ptr<clang::ASTConsumer> final {
    return std::make_unique<FindNamedClassConsumer>(&Compiler.getASTContext());
  }
};

auto main(int argc, char **argv) -> int {
  auto args = std::span(argv, static_cast<size_t>(argc));
  if (argc > 1) {
    clang::tooling::runToolOnCode(std::make_unique<FindNamedClassAction>(),
                                  args[1]);
  }
}
