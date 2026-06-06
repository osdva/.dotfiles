return {
  settings = {
    ['harper-ls'] = {
      userDictPath = '',
      workspaceDictPath = '',
      fileDictPath = '',
      linters = {
        SpellCheck = false,
        SpelledNumbers = false,
        AnA = true,
        SentenceCapitalization = false,
        UnclosedQuotes = true,
        WrongQuotes = false,
        LongSentences = true,
        RepeatedWords = true,
        Spaces = true,
        Matcher = true,
        CorrectNumberSuffix = true,
      },
      codeActions = {
        ForceStable = false,
      },
      markdown = {
        IgnoreLinkTitle = false,
      },
      diagnosticSeverity = 'hint',
      isolateEnglish = false,
      dialect = 'American',
      maxFileLength = 120000,
      ignoredLintsPath = '',
      excludePatterns = {},
    },
  },
}
