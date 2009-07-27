
describe 'JSpec'
  describe '.mockRequest'
    it 'should mock XMLHttpRequests if unmockRequest() is called or the spec block has finished'
      mockRequest.and_return('test')
      XMLHttpRequest.should.eql JSpec.XMLHttpRequest
      unmockRequest()
      XMLHttpRequest.should.not.eql JSpec.XMLHttpRequest
    end
    
    it 'should restore original XMLHttpRequest constructor after each spec'
      XMLHttpRequest.should.eql JSpec.defaultXMLHttpRequest
      XMLHttpRequest.should.not.eql JSpec.XMLHttpRequest
    end
    
    describe 'mock response'
      before_each
        mockRequest.and_return('bar', 'text/plain', 200)
        request = JSpec.xhr()
        request.setRequestHeader('content-length', 12)
        request.open('GET', 'path', false, 'foo', 'bar')
        request.send('foo=bar')
      end
      
      it 'should default readyState to 0'
        request = JSpec.xhr()
        request.readyState.should.eql 0
      end
      
      it 'should populate user'
        request.user.should.eql 'foo'
      end
      
      it 'should populate password'
        request.password.should.eql 'bar'
      end
      
      it 'should respond with the mock body'
        request.body.should.eql 'bar'
      end
      
      it 'should populate method'
        request.method.should.eql 'GET'
      end
      
      it 'should populate readyState'
        request.readyState.should.eql 4
      end
      
      it 'should populate url'
        request.url.should.eql 'path'
      end
      
      it 'should populate status'
        request.status.should.eql 200
      end
      
      it 'should populate statusText'
        request.statusText.should.eql 'OK'
      end
      
      it 'should populate content type response header'
        request.getResponseHeader('content-type').should.eql 'text/plain'
      end
      
      describe '.onreadystatechange()'
        before_each
          mockRequest.and_return('bar', 'text/plain', 200)
          request = JSpec.xhr()
        end
        
        it 'should be called when opening request in context to the request'
          request.onreadystatechange = function(){
            this.readyState.should.eql 1
          }
          request.open('GET', 'path')
        end
        
        it 'should be called when sending request'
          request.open('GET', 'path')
          request.onreadystatechange = function(){
            this.readyState.should.eql 4
          }
          request.send(null)
        end
      end
      
      describe '.setRequestHeader()'
        it 'should set request headers'
          mockRequest.and_return('bar', 'text/plain', 200)
          request.open('GET', 'path', false, 'foo', 'bar')
          request.setRequestHeader('content-length', 12)
          request.send('foo=bar')
          request.requestHeaders['content-length'].should.eql 12
        end
      end
    end
  end
end