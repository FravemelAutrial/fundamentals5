{******************************************************************************}
{                                                                              }
{   Library:          Fundamentals 5.00                                        }
{   File name:        flcCipherUtils.pas                                       }
{   File version:     5.03                                                     }
{   Description:      Cipher library                                           }
{                                                                              }
{   Copyright:        Copyright (c) 2007-2020, David J Butler                  }
{                     All rights reserved.                                     }
{                     This file is licensed under the BSD License.             }
{                     See http://www.opensource.org/licenses/bsd-license.php   }
{                     Redistribution and use in source and binary forms, with  }
{                     or without modification, are permitted provided that     }
{                     the following conditions are met:                        }
{                     Redistributions of source code must retain the above     }
{                     copyright notice, this list of conditions and the        }
{                     following disclaimer.                                    }
{                     THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND   }
{                     CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED          }
{                     WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED   }
{                     WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A          }
{                     PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL     }
{                     THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,    }
{                     INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR             }
{                     CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,    }
{                     PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF     }
{                     USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)         }
{                     HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER   }
{                     IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING        }
{                     NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE   }
{                     USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE             }
{                     POSSIBILITY OF SUCH DAMAGE.                              }
{                                                                              }
{   Github:           https://github.com/fundamentalslib                       }
{   E-mail:           fundamentals.library at gmail.com                        }
{                                                                              }
{ Revision history:                                                            }
{                                                                              }
{   2007/01/05  4.01  Initial version                                          }
{   2016/01/09  5.02  Revised for Fundamentals 5.                              }
{   2020/07/07  5.03  NativeInt and String type changes.                       }
{                                                                              }
{******************************************************************************}

{$INCLUDE flcCipher.inc}

unit flcCipherUtils;

interface

uses
  { System }
  SysUtils,

  { Fundamentals }
  flcStdTypes;



{                                                                              }
{ Cipher errors                                                                }
{                                                                              }
const
  CipherError_InvalidCipher     = 1;
  CipherError_InvalidKeySize    = 2;
  CipherError_InvalidKeyBits    = 3;
  CipherError_InvalidCipherMode = 4;
  CipherError_InvalidBufferSize = 5;
  CipherError_InvalidBuffer     = 6;
  CipherError_InvalidData       = 7;

type
  ECipher = class(Exception)
  protected
    FErrorCode : Integer;
  public
    constructor Create(const ErrorCode: Integer; const Msg: String);
    property ErrorCode: Integer read FErrorCode;
  end;



{                                                                              }
{ Secure clear                                                                 }
{                                                                              }
procedure SecureClearBuf(var Buffer; const BufferSize: NativeInt);
procedure SecureClearBytes(var B: TBytes);
procedure SecureClearStrB(var S: RawByteString);
procedure SecureClearStrU(var S: UnicodeString);
procedure SecureClearStr(var S: String); inline;



implementation



{                                                                              }
{ Cipher errors                                                                }
{                                                                              }
constructor ECipher.Create(const ErrorCode: Integer; const Msg: String);
begin
  FErrorCode := ErrorCode;
  inherited Create(Msg);
end;



{                                                                              }
{ Secure clear helper function                                                 }
{   Clears a piece of memory before it is released to help prevent             }
{   sensitive information from being exposed.                                  }
{                                                                              }
procedure SecureClearBuf(var Buffer; const BufferSize: NativeInt);
begin
  if BufferSize <= 0 then
    exit;
  FillChar(Buffer, BufferSize, $00);
end;

procedure SecureClearBytes(var B: TBytes);
begin
  SecureClearBuf(Pointer(B)^, Length(B));
  B := nil;
end;

procedure SecureClearStrB(var S: RawByteString);
var
  L : NativeInt;
begin
  L := Length(S);
  if L = 0 then
    exit;
  if StringRefCount(S) > 0 then
    SecureClearBuf(Pointer(S)^, L);
  SetLength(S, 0);
end;

procedure SecureClearStrU(var S: UnicodeString);
var
  L : NativeInt;
begin
  L := Length(S);
  if L = 0 then
    exit;
  if StringRefCount(S) > 0 then
    SecureClearBuf(Pointer(S)^, L * SizeOf(WideChar));
  SetLength(S, 0);
end;

procedure SecureClearStr(var S: String);
begin
  {$IFDEF StringIsUnicode}
  SecureClearStrU(S);
  {$ELSE}
  SecureClearStrB(S);
  {$ENDIF}
end;



end.

